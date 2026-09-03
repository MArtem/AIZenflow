#!/usr/bin/env python3
"""Validate that a project/worktree can bootstrap with the required agent rules.

The check is intentionally small and dependency-free so it can run in any new
worktree before implementation starts.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


REQUIRED_FILES = [
    "AGENTS.md",
    "GLOBAL_RULES_PORTABLE_SNAPSHOT.md",
    "PROJECT_DOCUMENTATION.md",
    "PROJECT_HEALTH.md",
    "docs/README.md",
    "docs/CURRENT_USER_OVERRIDES.md",
    "docs/AGENT_RULES.md",
    "docs/WORK_CONTINUITY.md",
    "docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md",
    "docs/MODEL_ROUTING_RULE.md",
    "docs/DOCUMENT_BOUNDARY_STANDARD.md",
    "docs/DOCUMENT_CHANGE_GOVERNANCE_STANDARD.md",
    "docs/NEW_PROJECT_START_CONTRACT.md",
    "docs/TASK_TYPE_DOCUMENTATION_ROUTER.md",
    "docs/DOCUMENT_ROUTING_REGISTRY.json",
    "docs/TASK_DOCUMENT_ROUTES.json",
    "docs/REUSABLE_BASELINE_POLICY.json",
    "docs/IOS_PR_REVIEW_TEMPLATE.md",
    "docs/ENGINEERING_CHANGE_QUALITY_STANDARD.md",
    "docs/IOS_PROJECT_BOOTSTRAP_TEMPLATE.md",
    "docs/STATIC_GATE_ADOPTION.md",
    "scripts/resolve_docs_route.py",
    "scripts/report_documentation_context_cost.py",
    "scripts/check_reusable_baseline_drift.py",
]

REQUIRED_TEXT = {
    "AGENTS.md": [
        "AIZENFLOW_GLOBAL_RULES_BOOTSTRAP_V1",
        "/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/GLOBAL_RULES_BOOTSTRAP.md",
        "DOCUMENT_BOUNDARY_STANDARD.md",
        "MODEL_ROUTING_RULE.md",
        "TASK_TYPE_DOCUMENTATION_ROUTER.md",
        "/Users/Artem/.zenflow",
        "перечитать весь актуальный набор документации и правил",
    ],
    "GLOBAL_RULES_PORTABLE_SNAPSHOT.md": [
        "AIZENFLOW_GLOBAL_RULES_PORTABLE_SNAPSHOT_V1",
        "canonical-baseline-unavailable",
    ],
    "docs/README.md": [
        "DOCUMENT_BOUNDARY_STANDARD.md",
        "DOCUMENT_CHANGE_GOVERNANCE_STANDARD.md",
        "MODEL_ROUTING_RULE.md",
        "DOCUMENT_ROUTING_REGISTRY.json",
        "TASK_DOCUMENT_ROUTES.json",
        "REUSABLE_BASELINE_POLICY.json",
    ],
    "PROJECT_DOCUMENTATION.md": [
        "DOCUMENT_BOUNDARY_STANDARD.md",
    ],
    "docs/CURRENT_USER_OVERRIDES.md": [
        "DOCUMENT_BOUNDARY_STANDARD.md",
        "highest reusable standards",
    ],
    "docs/NEW_PROJECT_START_CONTRACT.md": [
        "IOS_PR_REVIEW_TEMPLATE.md",
        "STATIC_GATE_ADOPTION.md",
        "workflow_dispatch",
        "quality profile",
    ],
    "docs/IOS_PROJECT_BOOTSTRAP_TEMPLATE.md": [
        "ENGINEERING_CHANGE_QUALITY_STANDARD.md",
        "STATIC_GATE_ADOPTION.md",
        "workflow_dispatch",
        "pinned canonical engine/profile contract",
    ],
    "docs/WORK_CONTINUITY.md": [
        "TASK_TYPE_DOCUMENTATION_ROUTER.md",
        "TASK_STATE_DOCUMENTATION_STANDARD.md",
        "перечитать весь актуальный набор документации и правил",
    ],
}

ADOPTION_RECORD = "docs/STATIC_GATE_ADOPTION.md"
ADOPTION_FIELDS = ("Status", "Owner", "Revisit condition")
ADOPTION_DETAILS = (
    "Source membership authority",
    "Project quality profile path",
    "Local quality launcher path",
    "Manual GitHub workflow path",
    "Automatic workflow trigger exception",
    "Pinned quality-engine release/SHA",
    "Deterministic checks and remediation",
    "PR review form path",
    "Test/feature-flag/release/privacy/capability applicability",
)
DEFERRAL_REASON = "Deferral reason"
ADOPTION_RECORD_FIELDS = (*ADOPTION_FIELDS, *ADOPTION_DETAILS, DEFERRAL_REASON)
ADOPTION_PATH_FIELDS = (
    "Project quality profile path",
    "Local quality launcher path",
    "Manual GitHub workflow path",
    "PR review form path",
)
AUTOMATIC_TRIGGER_EXCEPTION = "Automatic workflow trigger exception"
AUTOMATIC_WORKFLOW_TRIGGERS = frozenset(
    {
        "branch_protection_rule",
        "check_run",
        "check_suite",
        "create",
        "delete",
        "deployment",
        "deployment_status",
        "discussion",
        "fork",
        "gollum",
        "issue_comment",
        "issues",
        "merge_group",
        "page_build",
        "project",
        "project_card",
        "project_column",
        "public",
        "pull_request",
        "pull_request_target",
        "push",
        "registry_package",
        "release",
        "repository_dispatch",
        "schedule",
        "status",
        "watch",
        "workflow_call",
        "workflow_run",
    }
)


def field_value(text: str, field: str) -> str | None:
    prefix = f"- {field}:"
    for line in text.splitlines():
        if line.startswith(prefix):
            value = line.removeprefix(prefix).strip().strip("`")
            return value or None
    return None


def is_filled(value: str | None) -> bool:
    if value is None:
        return False
    normalized = value.lower()
    rejected = {"<fill>", "tbd", "todo", "to do", "n/a", "not applicable", "none", "not configured", "not yet created", "unavailable"}
    return normalized not in rejected and not (
        normalized.startswith("<") and normalized.endswith(">")
    )


def is_valid_trigger_exception(value: str | None) -> bool:
    return value is not None and (value.lower() == "none" or is_filled(value))


def workflow_trigger_names(text: str) -> set[str]:
    """Read trigger names from the YAML `on` section without a nonstandard dependency."""
    lines = text.splitlines()
    for index, line in enumerate(lines):
        match = re.match(r"^(\s*)on\s*:\s*(.*)$", line)
        if match is None:
            continue
        base_indent = len(match.group(1))
        inline_value = match.group(2).strip()
        if inline_value:
            return set(re.findall(r"[A-Za-z_]+", inline_value))

        triggers: set[str] = set()
        trigger_indent: int | None = None
        for child in lines[index + 1 :]:
            if not child.strip() or child.lstrip().startswith("#"):
                continue
            child_indent = len(child) - len(child.lstrip())
            if child_indent <= base_indent:
                break
            child_match = re.match(r"^\s*([A-Za-z_]+)\s*:", child)
            if child_match and trigger_indent is None:
                trigger_indent = child_indent
            if child_match and child_indent == trigger_indent:
                triggers.add(child_match.group(1))
        return triggers
    return set()


def contained_file(root: Path, relative: str) -> tuple[Path | None, str | None]:
    """Return a regular project-owned file without following a symlink boundary."""
    path = root / relative
    if path.is_symlink():
        return None, f"{relative} must not be a symlink"
    try:
        resolved = path.resolve(strict=True)
        resolved.relative_to(root)
    except FileNotFoundError:
        return None, f"missing required file: {relative}"
    except (OSError, ValueError):
        return None, f"{relative} must remain inside the project root"
    if not resolved.is_file():
        return None, f"missing required file: {relative}"
    return resolved, None


def validate_static_gate_adoption(root: Path) -> list[str]:
    resolved, failure = contained_file(root, ADOPTION_RECORD)
    if failure == f"missing required file: {ADOPTION_RECORD}":
        return [f"quality-control adoption BLOCKED: missing completed record: {ADOPTION_RECORD}"]
    if failure:
        return [f"quality-control adoption BLOCKED: {failure}"]
    assert resolved is not None

    text = resolved.read_text(encoding="utf-8", errors="replace")
    values = {field: field_value(text, field) for field in ADOPTION_RECORD_FIELDS}
    missing = [field for field in ADOPTION_FIELDS if not is_filled(values[field])]
    if missing:
        return [f"quality-control adoption BLOCKED: {ADOPTION_RECORD} missing {', '.join(missing)}"]

    status = values["Status"]
    if status == "ADOPTED":
        missing = [
            field
            for field in ADOPTION_DETAILS
            if field != AUTOMATIC_TRIGGER_EXCEPTION and not is_filled(values[field])
        ]
        if not is_valid_trigger_exception(values[AUTOMATIC_TRIGGER_EXCEPTION]):
            missing.append(AUTOMATIC_TRIGGER_EXCEPTION)
        if missing:
            return [f"quality-control adoption BLOCKED: ADOPTED record missing {', '.join(missing)}"]
        failures: list[str] = []
        for field in ADOPTION_PATH_FIELDS:
            value = values[field]
            assert value is not None
            candidate = value.removeprefix("./")
            _, failure = contained_file(root, candidate)
            if failure:
                failures.append(f"quality-control adoption BLOCKED: {field} {failure}")

        workflow_value = values["Manual GitHub workflow path"]
        assert workflow_value is not None
        workflow_path, workflow_failure = contained_file(root, workflow_value.removeprefix("./"))
        if workflow_failure is None:
            assert workflow_path is not None
            workflow_text = workflow_path.read_text(encoding="utf-8", errors="replace")
            triggers = workflow_trigger_names(workflow_text)
            if "workflow_dispatch" not in triggers:
                failures.append("quality-control adoption BLOCKED: manual workflow lacks workflow_dispatch")
            has_automatic_trigger = bool(triggers & AUTOMATIC_WORKFLOW_TRIGGERS)
            trigger_exception = values[AUTOMATIC_TRIGGER_EXCEPTION]
            assert trigger_exception is not None
            if has_automatic_trigger and trigger_exception.lower() == "none":
                failures.append(
                    "quality-control adoption BLOCKED: automatic workflow trigger lacks an explicit exception"
                )
            if not has_automatic_trigger and trigger_exception.lower() != "none":
                failures.append(
                    "quality-control adoption BLOCKED: automatic workflow trigger exception is stale"
                )
            if has_automatic_trigger and trigger_exception.lower() != "none":
                _, exception_failure = contained_file(root, trigger_exception.removeprefix("./"))
                if exception_failure:
                    failures.append(
                        "quality-control adoption BLOCKED: automatic workflow trigger exception "
                        f"{exception_failure}"
                    )
        return failures
    if status == "DEFERRED":
        if not is_filled(values[DEFERRAL_REASON]):
            return [f"quality-control adoption BLOCKED: DEFERRED record missing {DEFERRAL_REASON}"]
        return []
    return [f"quality-control adoption BLOCKED: Status must be ADOPTED or DEFERRED, found `{status}`"]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "root",
        nargs="?",
        default=Path(__file__).resolve().parents[1],
        type=Path,
        help="Project/worktree root to validate.",
    )
    args = parser.parse_args()
    root = args.root.resolve()

    failures: list[str] = []
    files: dict[str, Path] = {}
    for rel in REQUIRED_FILES:
        path, failure = contained_file(root, rel)
        if failure:
            failures.append(failure)
            continue
        assert path is not None
        files[rel] = path

    for rel, needles in REQUIRED_TEXT.items():
        path = files.get(rel)
        if path is None:
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for needle in needles:
            if needle not in text:
                failures.append(f"{rel}: missing required text `{needle}`")

    failures.extend(validate_static_gate_adoption(root))

    if failures:
        print("Bootstrap contract FAILED:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(f"Bootstrap contract OK: {root}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
