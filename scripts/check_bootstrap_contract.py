#!/usr/bin/env python3
"""Validate that a project/worktree can bootstrap with the required agent rules.

The check is intentionally small and dependency-free so it can run in any new
worktree before implementation starts.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


REQUIRED_FILES = [
    "AGENTS.md",
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
        "DOCUMENT_BOUNDARY_STANDARD.md",
        "MODEL_ROUTING_RULE.md",
        "TASK_TYPE_DOCUMENTATION_ROUTER.md",
        "/Users/Artem/.zenflow",
        "перечитать весь актуальный набор документации и правил",
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
    "docs/NEW_PROJECT_START_CONTRACT.md": ["IOS_PR_REVIEW_TEMPLATE.md", "STATIC_GATE_ADOPTION.md"],
    "docs/IOS_PROJECT_BOOTSTRAP_TEMPLATE.md": [
        "ENGINEERING_CHANGE_QUALITY_STANDARD.md",
        "STATIC_GATE_ADOPTION.md",
    ],
    "docs/WORK_CONTINUITY.md": [
        "TASK_TYPE_DOCUMENTATION_ROUTER.md",
        "TASK_STATE_DOCUMENTATION_STANDARD.md",
        "перечитать весь актуальный набор документации и правил",
    ],
}

ADOPTION_RECORD = "docs/STATIC_GATE_ADOPTION.md"
ADOPTION_FIELDS = ("Status", "Owner", "Revisit condition")
ADOPTION_DETAILS = ("Source membership authority", "Local runner", "Deterministic rules and remediation")
DEFERRAL_REASON = "Deferral reason"
ADOPTION_RECORD_FIELDS = (*ADOPTION_FIELDS, *ADOPTION_DETAILS, DEFERRAL_REASON)


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
        return [f"static-gate adoption BLOCKED: missing completed record: {ADOPTION_RECORD}"]
    if failure:
        return [f"static-gate adoption BLOCKED: {failure}"]
    assert resolved is not None

    text = resolved.read_text(encoding="utf-8", errors="replace")
    values = {field: field_value(text, field) for field in ADOPTION_RECORD_FIELDS}
    missing = [field for field in ADOPTION_FIELDS if not is_filled(values[field])]
    if missing:
        return [f"static-gate adoption BLOCKED: {ADOPTION_RECORD} missing {', '.join(missing)}"]

    status = values["Status"]
    if status == "ADOPTED":
        missing = [field for field in ADOPTION_DETAILS if not is_filled(values[field])]
        if missing:
            return [f"static-gate adoption BLOCKED: ADOPTED record missing {', '.join(missing)}"]
        return []
    if status == "DEFERRED":
        if not is_filled(values[DEFERRAL_REASON]):
            return [f"static-gate adoption BLOCKED: DEFERRED record missing {DEFERRAL_REASON}"]
        return []
    return [f"static-gate adoption BLOCKED: Status must be ADOPTED or DEFERRED, found `{status}`"]


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
