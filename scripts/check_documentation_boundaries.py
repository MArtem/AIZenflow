#!/usr/bin/env python3
"""Validate active reusable/app documentation boundary ownership."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


PROJECT_SELECTOR_RE = re.compile(r"\b([A-Za-z][A-Za-z0-9_-]*)\.(?:xcodeproj|xcworkspace)\b")
APP_TOKEN_SCAN_EXCLUDED_ROOTS = {"package-vault-docs"}
REUSABLE_FORBIDDEN_TERMS = ["new-task-be0b"]
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


def discover_app_tokens(apps: Path) -> tuple[set[str], set[str], set[str], list[str]]:
    """Derive app names and project-selector aliases from current app manifests."""
    tokens: set[str] = set()
    root_names: set[str] = set()
    selector_aliases: set[str] = set()
    failures: list[str] = []
    if apps.is_symlink() or not apps.is_dir():
        return tokens, root_names, selector_aliases, failures

    for app_root in sorted(apps.iterdir()):
        if app_root.name.startswith(".") or app_root.is_symlink() or not app_root.is_dir():
            continue
        root_name = app_root.name
        root_names.add(root_name)
        tokens.add(root_name)
        manifest = app_root / "MANIFEST.md"
        if manifest.is_symlink() or not manifest.is_file():
            continue
        try:
            text = manifest.read_text(encoding="utf-8")
        except (OSError, UnicodeError) as error:
            failures.append(f"{manifest.relative_to(apps.parent)}: unable to read manifest: {error}")
            continue
        selectors = set(PROJECT_SELECTOR_RE.findall(text))
        tokens.update(selectors)
        selector_aliases.update(name for name in selectors if name != root_name)

    return tokens, root_names, selector_aliases, failures


def is_historical_app_path(path: Path, app_root: Path) -> bool:
    return any(part in HISTORICAL_SEGMENTS for part in path.relative_to(app_root).parts)


def is_reusable_scan_excluded(path: Path, reusable: Path) -> bool:
    return "external-environment" in path.relative_to(reusable).parts


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "vault",
        nargs="?",
        default=Path.cwd(),
        type=Path,
        help="Documentation vault root (defaults to the current directory).",
    )
    args = parser.parse_args()
    vault = args.vault.resolve()

    failures: list[str] = []
    apps = vault / "apps"
    app_tokens, app_root_names, project_selector_aliases, discovery_failures = discover_app_tokens(apps)
    failures.extend(discovery_failures)
    if not vault.is_dir():
        failures.append(f"vault does not exist: {vault}")
    else:
        for rel in ["reusable", "apps", "tasks"]:
            if not (vault / rel).is_dir():
                failures.append(f"missing vault root: {rel}")

        for alias in sorted(project_selector_aliases - app_root_names):
            if (apps / alias).exists():
                failures.append(f"apps/{alias}: project-selector alias duplicates a canonical app root")

        for manifest_name in ["MANIFEST.md", "DOCUMENT_LIBRARY_GUIDE.md"]:
            manifest = vault / manifest_name
            if manifest.is_file():
                try:
                    text = manifest.read_text(encoding="utf-8")
                except OSError as error:
                    failures.append(f"{manifest_name}: unable to read: {error}")
                    continue
                for alias in sorted(project_selector_aliases - app_root_names):
                    if f"apps/{alias}" in text or f"documentation-vault/apps/{alias}" in text:
                        failures.append(f"{manifest_name}: references non-canonical app root apps/{alias}")

        reusable = vault / "reusable"
        if reusable.is_dir():
            for path in reusable.rglob("*.md"):
                if is_reusable_scan_excluded(path, reusable):
                    continue
                try:
                    text = path.read_text(encoding="utf-8")
                except (OSError, UnicodeError) as error:
                    failures.append(f"{path.relative_to(vault)}: unable to read: {error}")
                    continue
                if path.name in CORE_REUSABLE_NAMES and "baseline" in path.parts:
                    for phrase in CORE_FORBIDDEN_PHRASES:
                        if phrase in text:
                            rel = path.relative_to(vault)
                            failures.append(f"{rel}: non-neutral core phrase `{phrase}`")
                relative = path.relative_to(reusable)
                # Package snapshots retain package identifiers and selected consuming-app
                # provenance; their own catalog documents that boundary. Keep the global
                # app-name leak scan focused on shared rules, prompts, skills, and examples.
                if relative.parts and relative.parts[0] not in APP_TOKEN_SCAN_EXCLUDED_ROOTS:
                    hits = [token for token in app_tokens if token in text]
                else:
                    hits = []
                if hits:
                    failures.append(
                        f"{path.relative_to(vault)}: app-specific token(s) {', '.join(hits)}"
                    )
                for term in REUSABLE_FORBIDDEN_TERMS:
                    if term in text:
                        failures.append(f"{path.relative_to(vault)}: non-neutral term `{term}`")

        if apps.is_symlink():
            failures.append("apps: linked documentation root is not allowed")
        elif apps.is_dir():
            # Inspect every active app, including names introduced after this checker.
            # Reject directory links instead of traversing an unowned external tree.
            for app_root in sorted(apps.iterdir()):
                if app_root.name.startswith("."):
                    continue
                if app_root.is_symlink():
                    failures.append(f"{app_root.relative_to(vault)}: linked app root is not allowed")
                    continue
                if not app_root.is_dir():
                    continue
                app = app_root.name
                manifest = app_root / "MANIFEST.md"
                if manifest.is_symlink() or not manifest.is_file():
                    failures.append(f"missing or linked app manifest: apps/{app}/MANIFEST.md")
                legacy_root = app_root / "legacy-reference"
                if legacy_root.is_dir() and not (legacy_root / "README.md").is_file():
                    failures.append(f"apps/{app}/legacy-reference: missing non-authoritative README.md")
                for path in app_root.rglob("*"):
                    if path.is_symlink():
                        failures.append(f"{path.relative_to(vault)}: linked app content is not allowed")
                        continue
                    if not path.is_file() or path.suffix != ".md":
                        continue
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
