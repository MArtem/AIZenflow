#!/usr/bin/env python3
"""Validate active reusable/app documentation boundary ownership."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


EXPECTED_APP_ROOTS = ["Tchop", "MVVMExample", "BattleshipGame", "AIFieldbook"]
APP_TOKENS = ["Tchop", "TchopApp", "AIFieldbook", "MVVMExample", "BattleshipGame"]
REUSABLE_FORBIDDEN_TERMS = ["new-task-be0b"]
ALLOWED_REUSABLE_TOKEN_PATHS = {
    Path("baseline/docs/DOCUMENT_LIBRARY_GUIDE.md"),
}
CORE_FORBIDDEN_PHRASES = [
    "new-task-be0b",
    "feed/composer card",
    "Работаем в ",
    "Zenflow workspace",
    "Zenflow sandbox",
    "Zenflow tasks",
]
CORE_REUSABLE_NAMES = {
    "AGENTS.md",
    "PROJECT_DOCUMENTATION.md",
    "PROJECT_HEALTH.md",
    "CURRENT_USER_OVERRIDES.md",
    "AGENT_RULES.md",
    "WORK_CONTINUITY.md",
    "TASK_TYPE_DOCUMENTATION_ROUTER.md",
}
GENERIC_APP_FILENAMES = CORE_REUSABLE_NAMES | {
    "TESTING_INSTRUCTIONS.md",
    "PRODUCTION_CODE_REVIEW_CHECKLIST.md",
    "PRODUCTION_QUALITY_GATES.md",
    "PACKAGES_AND_MANAGERS.md",
    "IOS_UI_STATE_RENDERING_STANDARD.md",
    "IOS_MVVM_INTENT_API_STANDARD.md",
}
HISTORICAL_SEGMENTS = {"archive", "history", "legacy-reference"}


def is_historical_app_path(path: Path, app_root: Path) -> bool:
    return any(part in HISTORICAL_SEGMENTS for part in path.relative_to(app_root).parts)


def is_reusable_scan_excluded(path: Path, reusable: Path) -> bool:
    return "external-environment" in path.relative_to(reusable).parts


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "vault",
        nargs="?",
        default=Path("/Users/Artem/.zenflow/worktrees/documentation-vault"),
        type=Path,
        help="Documentation vault root.",
    )
    args = parser.parse_args()
    vault = args.vault.resolve()

    failures: list[str] = []
    if not vault.is_dir():
        failures.append(f"vault does not exist: {vault}")
    else:
        for rel in ["reusable", "apps", "tasks"]:
            if not (vault / rel).is_dir():
                failures.append(f"missing vault root: {rel}")

        for app in EXPECTED_APP_ROOTS:
            app_root = vault / "apps" / app
            if not app_root.is_dir():
                failures.append(f"missing app documentation root: apps/{app}")
            elif not (app_root / "MANIFEST.md").is_file():
                failures.append(f"missing app manifest: apps/{app}/MANIFEST.md")

        if (vault / "apps" / "TchopApp").exists():
            failures.append("legacy apps/TchopApp exists as a top-level app root")

        for manifest_name in ["MANIFEST.md", "DOCUMENT_LIBRARY_GUIDE.md"]:
            manifest = vault / manifest_name
            if manifest.is_file():
                text = manifest.read_text(encoding="utf-8", errors="replace")
                if "apps/TchopApp" in text or "documentation-vault/apps/TchopApp" in text:
                    failures.append(f"{manifest_name}: references legacy apps/TchopApp")

        reusable = vault / "reusable"
        if reusable.is_dir():
            for path in reusable.rglob("*.md"):
                if is_reusable_scan_excluded(path, reusable):
                    continue
                text = path.read_text(encoding="utf-8", errors="replace")
                if path.name in CORE_REUSABLE_NAMES and "baseline" in path.parts:
                    for phrase in CORE_FORBIDDEN_PHRASES:
                        if phrase in text:
                            rel = path.relative_to(vault)
                            failures.append(f"{rel}: non-neutral core phrase `{phrase}`")
                relative = path.relative_to(reusable)
                if relative in ALLOWED_REUSABLE_TOKEN_PATHS:
                    continue
                hits = [token for token in APP_TOKENS if token in text]
                if hits:
                    failures.append(
                        f"{path.relative_to(vault)}: app-specific token(s) {', '.join(hits)}"
                    )
                for term in REUSABLE_FORBIDDEN_TERMS:
                    if term in text:
                        failures.append(f"{path.relative_to(vault)}: non-neutral term `{term}`")

        apps = vault / "apps"
        if apps.is_dir():
            for app in EXPECTED_APP_ROOTS:
                app_root = apps / app
                if not app_root.is_dir():
                    continue
                legacy_root = app_root / "legacy-reference"
                if legacy_root.is_dir() and not (legacy_root / "README.md").is_file():
                    failures.append(f"apps/{app}/legacy-reference: missing non-authoritative README.md")
                for path in app_root.rglob("*.md"):
                    if path.name == "MANIFEST.md" or is_historical_app_path(path, app_root):
                        continue
                    if path.name in GENERIC_APP_FILENAMES:
                        failures.append(
                            f"{path.relative_to(vault)}: reusable baseline file in active app area"
                        )

    if failures:
        print("Documentation boundary FAILED:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(f"Documentation boundary OK: {vault}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
