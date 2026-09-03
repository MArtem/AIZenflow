#!/usr/bin/env python3
"""Guard an explicit Swift 6 project contract against stale Swift 5 gate expectations.

This is a narrow source-contract check, not a compiler replacement.  It accepts one explicit
project-contract JSON and one explicit Python gate source.  When the contract declares Swift 6,
only structural AST pairs/comparisons that name ``SWIFT_VERSION`` and require ``5.0`` are findings.
The checker does not infer project identity from filenames and never edits or executes the gate.
"""

from __future__ import annotations

import argparse
import ast
import json
import sys
from pathlib import Path
from typing import Any


MAX_CONTRACT_BYTES = 64 * 1024
MAX_GATE_BYTES = 2 * 1024 * 1024
MAX_FINDINGS = 64
MAX_STRING_LENGTH = 1_024
ROOT = Path(__file__).resolve().parents[1]


class GuardError(ValueError):
    pass


def reject_duplicate_keys(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise GuardError(f"duplicate JSON property: {key}")
        result[key] = value
    return result


def bounded_text(value: str) -> str:
    return value.strip()[:MAX_STRING_LENGTH]


def read_inside_root(path_value: str, maximum_bytes: int, label: str) -> tuple[Path, bytes]:
    if not path_value or path_value.startswith("~"):
        raise GuardError(f"{label} path must be explicit")
    path = Path(path_value)
    if not path.is_absolute():
        path = ROOT / path
    resolved = path.resolve()
    try:
        resolved.relative_to(ROOT)
    except ValueError as error:
        raise GuardError(f"{label} path escapes the repository root") from error
    if path.is_symlink() or not path.is_file():
        raise GuardError(f"{label} must be a regular non-symlink file")
    try:
        data = path.read_bytes()
    except OSError as error:
        raise GuardError(f"{label} is unreadable: {error}") from error
    if len(data) > maximum_bytes:
        raise GuardError(f"{label} exceeds the immutable byte limit")
    return resolved, data


def load_contract(path_value: str) -> tuple[Path, dict[str, Any]]:
    path, data = read_inside_root(path_value, MAX_CONTRACT_BYTES, "project contract")
    try:
        value = json.loads(data.decode("utf-8"), object_pairs_hook=reject_duplicate_keys)
    except (UnicodeDecodeError, json.JSONDecodeError, GuardError, RecursionError) as error:
        raise GuardError(f"project contract is malformed: {error}") from error
    if not isinstance(value, dict) or set(value) != {"schemaVersion", "project", "swiftLanguageMode", "targets"}:
        raise GuardError("project contract has an unsupported property set")
    if value.get("schemaVersion") != 1 or value.get("swiftLanguageMode") != "6":
        raise GuardError("project contract must declare schemaVersion 1 and swiftLanguageMode 6")
    project = value.get("project")
    targets = value.get("targets")
    if not isinstance(project, str) or not project.strip() or len(project) > MAX_STRING_LENGTH:
        raise GuardError("project contract has an invalid project identity")
    if not isinstance(targets, list) or not targets or len(targets) > 256:
        raise GuardError("project contract must declare one to 256 targets")
    seen_targets: set[str] = set()
    for index, target in enumerate(targets):
        if not isinstance(target, dict) or set(target) != {"name", "configurations"}:
            raise GuardError(f"project contract target {index} has an unsupported property set")
        name = target.get("name")
        configurations = target.get("configurations")
        if (
            not isinstance(name, str)
            or not name.strip()
            or len(name) > MAX_STRING_LENGTH
            or name in seen_targets
            or not isinstance(configurations, list)
            or not configurations
            or len(configurations) > 64
            or any(not isinstance(configuration, str) or not configuration.strip() for configuration in configurations)
            or len(set(configurations)) != len(configurations)
        ):
            raise GuardError(f"project contract target {index} is malformed")
        seen_targets.add(name)
    return path, value


def string_constant(node: ast.AST) -> str | None:
    return node.value if isinstance(node, ast.Constant) and isinstance(node.value, str) else None


def is_swift_version_five_pair(node: ast.AST) -> bool:
    if not isinstance(node, (ast.Tuple, ast.List)) or len(node.elts) != 2:
        return False
    return string_constant(node.elts[0]) == "SWIFT_VERSION" and string_constant(node.elts[1]) == "5.0"


def is_swift_version_five_mapping(node: ast.AST) -> bool:
    if not isinstance(node, ast.Dict):
        return False
    return any(
        string_constant(key) == "SWIFT_VERSION" and string_constant(value) == "5.0"
        for key, value in zip(node.keys, node.values)
    )


def is_swift_version_lookup(node: ast.AST) -> bool:
    return (
        isinstance(node, ast.Call)
        and isinstance(node.func, ast.Attribute)
        and node.func.attr == "get"
        and len(node.args) == 1
        and string_constant(node.args[0]) == "SWIFT_VERSION"
    )


def gate_findings(path: Path, data: bytes, contract: dict[str, Any]) -> list[dict[str, Any]]:
    try:
        tree = ast.parse(data.decode("utf-8"), filename=str(path), mode="exec")
    except (UnicodeDecodeError, SyntaxError, RecursionError) as error:
        raise GuardError(f"gate source must be valid bounded Python: {error}") from error
    findings: list[dict[str, Any]] = []
    targets = contract["targets"]
    target_summary = [
        {"name": target["name"], "configurations": target["configurations"]}
        for target in targets
    ]
    for node in ast.walk(tree):
        stale = is_swift_version_five_pair(node) or is_swift_version_five_mapping(node)
        if isinstance(node, ast.Compare):
            stale = (
                is_swift_version_lookup(node.left)
                and any(string_constant(comparator) == "5.0" for comparator in node.comparators)
            )
            stale = stale or any(
                string_constant(node.left) == "5.0"
                and is_swift_version_lookup(comparator)
                for comparator in node.comparators
            )
        if not stale:
            continue
        findings.append({
            "path": path.relative_to(ROOT).as_posix(),
            "line": getattr(node, "lineno", 0),
            "message": "Swift 6 project contract must not require SWIFT_VERSION = 5.0; use 6.0.",
            "project": contract["project"],
            "targets": target_summary,
            "remediation": "Update the gate expectation to Swift 6 for every listed target/configuration.",
        })
        if len(findings) >= MAX_FINDINGS:
            break
    return findings


def report(status: str, message: str, findings: list[dict[str, Any]] | None = None) -> dict[str, Any]:
    result: dict[str, Any] = {
        "command": "swift6-gate-contract",
        "schemaVersion": 1,
        "status": status,
        "message": message,
    }
    if findings:
        result["findings"] = findings
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description="Check an explicit Swift 6 gate contract")
    parser.add_argument("--project-contract", required=True)
    parser.add_argument("--gate-source", required=True)
    arguments = parser.parse_args()
    try:
        _, contract = load_contract(arguments.project_contract)
        gate_path, gate_data = read_inside_root(arguments.gate_source, MAX_GATE_BYTES, "gate source")
        findings = gate_findings(gate_path, gate_data, contract)
        if findings:
            print(json.dumps(report("FAIL", "Swift 6 gate contract drift was found.", findings), indent=2, sort_keys=True))
            return 1
        print(json.dumps(report("PASS", "Swift 6 gate source has no structural SWIFT_VERSION = 5.0 expectation."), indent=2, sort_keys=True))
        return 0
    except GuardError as error:
        print(json.dumps(report("BLOCKED", bounded_text(str(error))), indent=2, sort_keys=True))
        return 2


if __name__ == "__main__":
    sys.exit(main())
