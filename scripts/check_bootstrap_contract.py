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
]

REQUIRED_TEXT = {
    "AGENTS.md": [
        "DOCUMENT_BOUNDARY_STANDARD.md",
        "MODEL_ROUTING_RULE.md",
        "AIZenflowDocumentation",
        "/Users/Artem/.zenflow",
        "перечитать весь актуальный набор документации и правил",
    ],
    "docs/README.md": [
        "DOCUMENT_BOUNDARY_STANDARD.md",
        "MODEL_ROUTING_RULE.md",
    ],
    "PROJECT_DOCUMENTATION.md": [
        "DOCUMENT_BOUNDARY_STANDARD.md",
    ],
    "docs/CURRENT_USER_OVERRIDES.md": [
        "AIZenflowDocumentation",
        "DOCUMENT_BOUNDARY_STANDARD.md",
        "Product-Staff Quality Bar",
    ],
    "docs/WORK_CONTINUITY.md": [
        "AIZenflowDocumentation",
        "DOCUMENT_BOUNDARY_STANDARD.md",
        "перечитать весь актуальный набор документации и правил",
    ],
}


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
    for rel in REQUIRED_FILES:
        if not (root / rel).is_file():
            failures.append(f"missing required file: {rel}")

    for rel, needles in REQUIRED_TEXT.items():
        path = root / rel
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for needle in needles:
            if needle not in text:
                failures.append(f"{rel}: missing required text `{needle}`")

    if failures:
        print("Bootstrap contract FAILED:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(f"Bootstrap contract OK: {root}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
