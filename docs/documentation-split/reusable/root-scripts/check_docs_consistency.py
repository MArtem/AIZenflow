#!/usr/bin/env python3
"""Lightweight semantic consistency checks for active documentation rules."""
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]

SKIP_PARTS = {
    "archive",
}
SKIP_FILES = {
    # Historical task logs intentionally preserve old decisions and paths.
    ROOT / ".zenflow/tasks/new-task-be0b/plan.md",
    ROOT / "docs/documentation-split/app-specific/.zenflow/tasks/new-task-be0b/plan.md",
}

CHECKS: list[tuple[str, re.Pattern[str]]] = [
    (
        "old GPT-5.5-for-all/default rule",
        re.compile(r"use/report `GPT-5\.5`|GPT-5\.5 for all work|forced `GPT-5\.5`", re.IGNORECASE),
    ),
    (
        "retired active monolithic source-app package boundary",
        re.compile(r"belong in `\.?/?Packages/SourceAppInfrastructure|Important Areas\s*- \[Packages/SourceAppInfrastructure", re.IGNORECASE),
    ),
    (
        "absolute workspace markdown link",
        re.compile(r"\]\(/Users/Artem/\.zenflow/worktrees/new-task-be0b"),
    ),
    (
        "old worktrees-only sandbox boundary",
        re.compile(r"outside `/Users/Artem/\.zenflow/worktrees|inside `/Users/Artem/\.zenflow/worktrees|stay inside `/Users/Artem/\.zenflow/worktrees|границу `/Users/Artem/\.zenflow/worktrees"),
    ),
    (
        "required external assistant-home link",
        re.compile(r"^- \[/Users/Artem/\.zenflow/assistant", re.MULTILINE),
    ),
]


def iter_docs() -> list[pathlib.Path]:
    roots = [
        ROOT / "AGENTS.md",
        ROOT / "PROJECT_DOCUMENTATION.md",
        ROOT / "PROJECT_HEALTH.md",
        ROOT / "docs",
        ROOT / ".zenflow/tasks/new-task-be0b",
        ROOT / ".codex/skills",
    ]
    files: list[pathlib.Path] = []
    for root in roots:
        if root.is_file():
            files.append(root)
            continue
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if not path.is_file():
                continue
            if any(part in SKIP_PARTS for part in path.relative_to(ROOT).parts):
                continue
            if path in SKIP_FILES:
                continue
            if path.suffix not in {".md", ".txt"} and path.name != "SKILL.md":
                continue
            files.append(path)
    return sorted(set(files))


def main() -> int:
    findings: list[str] = []
    for path in iter_docs():
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for label, pattern in CHECKS:
            for match in pattern.finditer(text):
                line = text.count("\n", 0, match.start()) + 1
                rel = path.relative_to(ROOT)
                findings.append(f"{rel}:{line}: {label}")
    if findings:
        print("Documentation consistency check failed:")
        for finding in findings:
            print(f"- {finding}")
        return 1
    print("Documentation consistency OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
