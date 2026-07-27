#!/usr/bin/env python3
"""Validate the shared documentation-vault boundary contract.

Hard failures are reserved for structural problems that can misroute future
work. Potential app-token leakage is reported as warnings because legacy
recovery snapshots may intentionally preserve historical terms inside app areas.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


EXPECTED_APP_ROOTS = ["Tchop", "MVVMExample", "BattleshipGame", "AIFieldbook"]
APP_TOKENS = ["TchopApp", "AIFieldbook", "MVVMExample", "BattleshipGame"]
ALLOWED_REUSABLE_TOKEN_FILES = {
    "DOCUMENT_BOUNDARY_STANDARD.md",
    "DOCUMENT_LIBRARY_GUIDE.md",
    "NEW_PROJECT_PORTING_GUIDE.md",
    "TRANSFER_CHECKLIST.md",
    "SOURCE_OF_TRUTH_MAP.md",
    "CLONE_CREATION_PLAYBOOK.md",
}


def is_allowed_reusable_token_file(path: Path) -> bool:
    return path.name in ALLOWED_REUSABLE_TOKEN_FILES or "templates" in path.parts


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
    warnings: list[str] = []

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
                if is_allowed_reusable_token_file(path):
                    continue
                text = path.read_text(encoding="utf-8", errors="replace")
                hits = [token for token in APP_TOKENS if token in text]
                if hits:
                    rel = path.relative_to(vault)
                    warnings.append(f"{rel}: app-specific token(s) {', '.join(hits)}")

    if failures:
        print("Documentation boundary FAILED:")
        for failure in failures:
            print(f"- {failure}")
        if warnings:
            print("Warnings:")
            for warning in warnings[:50]:
                print(f"- {warning}")
            if len(warnings) > 50:
                print(f"- ... {len(warnings) - 50} more warnings")
        return 1

    print(f"Documentation boundary OK: {vault}")
    if warnings:
        print(f"Warnings: {len(warnings)} potential reusable app-token reference(s)")
        for warning in warnings[:20]:
            print(f"- {warning}")
        if len(warnings) > 20:
            print(f"- ... {len(warnings) - 20} more warnings")
    return 0


if __name__ == "__main__":
    sys.exit(main())
