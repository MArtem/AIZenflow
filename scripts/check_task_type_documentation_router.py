#!/usr/bin/env python3
"""Validate documentation routing coverage, Level 0 budget, and path integrity."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

from resolve_docs_route import is_classified, load_json, validate_route_registry


ROOT = Path(__file__).resolve().parents[1]
ROUTER = ROOT / "docs" / "TASK_TYPE_DOCUMENTATION_ROUTER.md"
REGISTRY = ROOT / "docs" / "DOCUMENT_ROUTING_REGISTRY.json"
TASK_ROUTES = ROOT / "docs" / "TASK_DOCUMENT_ROUTES.json"
LEVEL_KEYS = ("level0", "level1", "level2", "level3")
OLD_STARTUP_LIST_PATTERNS = (
    re.compile(r"^1[.)]\s+`?\./docs/README\.md`?", re.MULTILINE),
    re.compile(r"^1[.)]\s+`?\./PROJECT_DOCUMENTATION\.md`?", re.MULTILINE),
)
SINGLE_SOURCE_SURFACES = (
    "AGENTS.md",
    "PROJECT_DOCUMENTATION.md",
    "docs/README.md",
    "docs/WORK_CONTINUITY.md",
    "templates/AGENTS.template.md",
    "templates/PROJECT_DOCUMENTATION.template.md",
    "templates/docs/README.template.md",
    "templates/docs/WORK_CONTINUITY.template.md",
)


def local_path(path: str) -> Path:
    if not path.startswith("./"):
        raise ValueError(f"registry path must start with ./: {path}")
    return ROOT / path[2:]


def main() -> int:
    failures: list[str] = []

    if not ROUTER.is_file():
        failures.append("missing docs/TASK_TYPE_DOCUMENTATION_ROUTER.md")
    if not REGISTRY.is_file():
        failures.append("missing docs/DOCUMENT_ROUTING_REGISTRY.json")
    if not TASK_ROUTES.is_file():
        failures.append("missing docs/TASK_DOCUMENT_ROUTES.json")
    if failures:
        return report(failures)

    router_text = ROUTER.read_text(encoding="utf-8")
    try:
        registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as error:
        return report([f"invalid routing registry: {error}"])
    try:
        task_routes = load_json(TASK_ROUTES)
    except ValueError as error:
        return report([str(error)])
    failures.extend(validate_route_registry(task_routes))

    assigned: dict[str, str] = {}
    for level in LEVEL_KEYS:
        entries = registry.get(level)
        if not isinstance(entries, list) or not entries:
            failures.append(f"registry {level} must be a non-empty list")
            continue
        for path in entries:
            if not isinstance(path, str):
                failures.append(f"registry {level} contains a non-string path")
                continue
            if path in assigned:
                failures.append(f"duplicate primary assignment: {path} in {assigned[path]} and {level}")
            assigned[path] = level
            try:
                candidate = local_path(path)
            except ValueError as error:
                failures.append(str(error))
                continue
            if not candidate.is_file():
                failures.append(f"missing registered file: {path}")

    discovered = {
        "./PROJECT_DOCUMENTATION.md",
        "./PROJECT_HEALTH.md",
        *{f"./docs/{path.name}" for path in (ROOT / "docs").glob("*.md")},
    }
    missing_assignments = sorted(discovered - set(assigned))
    stale_assignments = sorted(set(assigned) - discovered)
    for path in missing_assignments:
        failures.append(f"active top-level document has no primary level: {path}")
    for path in stale_assignments:
        failures.append(f"registered top-level document is not active: {path}")

    level0_match = re.search(r"## Level 0\b(?P<body>.*?)(?=\n## Level 1\b)", router_text, re.DOTALL)
    if not level0_match:
        failures.append("router has no parseable Level 0 section")
    else:
        numbered_level0 = set(
            re.findall(r"^\d+\.\s+`(\./[^`]+)`", level0_match.group("body"), re.MULTILINE)
        )
        expected_level0 = set(registry.get("level0", []))
        if numbered_level0 != expected_level0:
            failures.append(
                "router Level 0 list differs from registry: "
                f"router={sorted(numbered_level0)}, registry={sorted(expected_level0)}"
            )

    for level in ("level1", "level2", "level3"):
        for path in registry.get(level, []):
            if f"`{path}`" not in router_text:
                failures.append(f"{path}: assigned {level} but unreachable from router")

    route_level0 = task_routes.get("level0", {}).get("documents", [])
    if route_level0 != registry.get("level0", []):
        failures.append(
            "task route Level 0 differs from primary registry: "
            f"routes={route_level0}, registry={registry.get('level0', [])}"
        )
    machine_reachable: set[str] = set(route_level0)
    for name, route in task_routes.get("routes", {}).items():
        route_paths = [
            *route.get("documents", []),
            *route.get("optional_documents", []),
        ]
        if len(route_paths) != len(set(route_paths)):
            failures.append(f"task route {name} contains duplicate documents")
        for path in route_paths:
            if not isinstance(path, str) or not path.startswith("./"):
                failures.append(f"task route {name} has invalid path: {path!r}")
                continue
            machine_reachable.add(path)
            candidate = local_path(path)
            if path in route.get("documents", []) and not candidate.is_file():
                failures.append(f"task route {name} has missing required document: {path}")
            if candidate.is_file() and not is_classified(path, registry):
                failures.append(f"task route {name} has unclassified document: {path}")
    for level in ("level1", "level2", "level3"):
        for path in registry.get(level, []):
            if path not in machine_reachable:
                failures.append(f"{path}: assigned {level} but unreachable from machine task routes")

    max_words = registry.get("level0_max_words")
    if not isinstance(max_words, int) or max_words <= 0:
        failures.append("registry level0_max_words must be a positive integer")
    else:
        level0_words = 0
        for path in registry.get("level0", []):
            candidate = local_path(path)
            if candidate.is_file():
                level0_words += len(re.findall(r"\b\w+[\w.-]*\b", candidate.read_text(encoding="utf-8")))
        if level0_words > max_words:
            failures.append(f"Level 0 word budget exceeded: {level0_words} > {max_words}")

    patterns = registry.get("path_patterns")
    if not isinstance(patterns, dict) or not all(patterns.get(key) for key in ("level2", "level3", "archive")):
        failures.append("registry path_patterns must define non-empty level2, level3, and archive lists")

    single_source_paths = [ROOT / rel for rel in SINGLE_SOURCE_SURFACES]
    split_templates = ROOT / "docs" / "documentation-split" / "reusable" / "templates"
    if split_templates.is_dir():
        single_source_paths.extend(split_templates.rglob("*.md"))
    task_root = ROOT / ".zenflow" / "tasks"
    if task_root.is_dir():
        single_source_paths.extend(task_root.rglob("REUSABLE_PROJECT_DOCUMENTATION.md"))

    for path in sorted(set(single_source_paths)):
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for pattern in OLD_STARTUP_LIST_PATTERNS:
            if pattern.search(text):
                failures.append(f"{path.relative_to(ROOT)}: duplicates an obsolete numbered startup list")
                break

    if failures:
        return report(failures)

    print(
        "Task type documentation router OK: "
        f"{len(assigned)} documents classified; Level 0 {level0_words}/{max_words} words"
    )
    return 0


def report(failures: list[str]) -> int:
    print("Task type documentation router FAILED:")
    for failure in failures:
        print(f"- {failure}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
