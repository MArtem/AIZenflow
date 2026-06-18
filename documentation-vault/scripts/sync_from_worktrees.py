#!/usr/bin/env python3
"""Synchronize the git-backed documentation vault from active Zenflow worktrees.

The vault intentionally stores documentation, rules, prompt presets, skills, templates,
and lightweight task context. It does not move or delete operational worktree copies.
"""
from __future__ import annotations

import json
import shutil
from dataclasses import dataclass
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
ZENFLOW_ROOT = Path("/Users/Artem/.zenflow")
VAULT_ROOT = REPO_ROOT / "documentation-vault"
CURRENT_WORKTREE = REPO_ROOT
MVVM_WORKTREE = ZENFLOW_ROOT / "worktrees" / "mvvmexample-3c80"
ASSISTANT_ROOT = ZENFLOW_ROOT / "assistant"

ALLOWED_SUFFIXES = {
    ".md",
    ".markdown",
    ".txt",
    ".json",
    ".yml",
    ".yaml",
    ".sh",
    ".py",
    ".template",
}
ALLOWED_NAMES = {"AGENTS.md", "PROJECT_DOCUMENTATION.md", "PROJECT_HEALTH.md", "TESTING_INSTRUCTIONS.md", "APPLE_SIGN_IN_SETUP.md"}
EXCLUDED_PARTS = {
    ".git",
    ".build",
    ".swiftpm",
    "build",
    "DerivedData",
    "xcuserdata",
    "node_modules",
    "__pycache__",
}

@dataclass(frozen=True)
class CopySet:
    source_root: Path
    destination_root: Path
    include_roots: tuple[str, ...]
    description: str
    content_terms: tuple[str, ...] = ()
    exact_names: tuple[str, ...] = ()


def is_allowed_file(path: Path) -> bool:
    if any(part in EXCLUDED_PARTS for part in path.parts):
        return False
    if path.name in ALLOWED_NAMES:
        return True
    if path.name == "SKILL.md":
        return True
    if path.suffix.lower() in ALLOWED_SUFFIXES:
        return True
    return False


def has_content_term(path: Path, terms: tuple[str, ...]) -> bool:
    if not terms:
        return True
    if path.suffix.lower() not in {".md", ".txt", ".json", ".yml", ".yaml"} and path.name != "SKILL.md":
        return False
    try:
        text = path.read_text(errors="ignore")
    except OSError:
        return False
    lower = text.lower()
    return any(term.lower() in lower for term in terms)


def copy_file(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)


def copy_tree_files(copy_set: CopySet) -> list[str]:
    copied: list[str] = []
    if not copy_set.source_root.exists():
        return copied
    for path in sorted(copy_set.source_root.rglob("*")):
        if not path.is_file() or not is_allowed_file(path):
            continue
        rel = path.relative_to(copy_set.source_root)
        rel_text = rel.as_posix()
        if copy_set.destination_root.as_posix().endswith("/reusable/baseline") and rel_text == "MVVMEXAMPLE_REMEDIATION_SPEC.md":
            continue
        if copy_set.include_roots and rel.parts[0] not in copy_set.include_roots:
            continue
        if copy_set.exact_names and path.name not in copy_set.exact_names and rel_text not in copy_set.exact_names:
            continue
        if copy_set.content_terms and not has_content_term(path, copy_set.content_terms):
            continue
        destination = copy_set.destination_root / rel
        copy_file(path, destination)
        copied.append(destination.relative_to(VAULT_ROOT).as_posix())
    return copied


def copy_single_files(source_root: Path, destination_root: Path, rel_paths: list[str]) -> list[str]:
    copied: list[str] = []
    for rel_text in rel_paths:
        source = source_root / rel_text
        if source.exists() and source.is_file() and is_allowed_file(source):
            destination = destination_root / rel_text
            copy_file(source, destination)
            copied.append(destination.relative_to(VAULT_ROOT).as_posix())
    return copied


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def main() -> None:
    if not str(VAULT_ROOT).startswith(str(ZENFLOW_ROOT)):
        raise SystemExit(f"Vault must stay inside {ZENFLOW_ROOT}: {VAULT_ROOT}")

    # Rebuild only generated content areas. Keep this script if it is already present.
    for child in ["reusable", "apps", "tasks"]:
        target = VAULT_ROOT / child
        if target.exists():
            shutil.rmtree(target)

    copied_by_set: dict[str, list[str]] = {}

    copy_sets = [
        CopySet(
            CURRENT_WORKTREE / "docs" / "documentation-split" / "reusable",
            VAULT_ROOT / "reusable" / "baseline",
            include_roots=(),
            description="Reusable baseline split from AIZenflow/TchopApp worktree.",
        ),
        CopySet(
            CURRENT_WORKTREE / ".codex" / "skills",
            VAULT_ROOT / "reusable" / "local-ios-skills",
            include_roots=tuple(sorted(p.name for p in (CURRENT_WORKTREE / ".codex" / "skills").glob("ios-*"))),
            description="Reusable iOS local skills.",
        ),
        CopySet(
            CURRENT_WORKTREE / "docs" / "agent-prompts",
            VAULT_ROOT / "reusable" / "agent-prompts",
            include_roots=(),
            description="Reusable prompt presets.",
        ),
        CopySet(
            CURRENT_WORKTREE / "docs" / "knowledge" / "global",
            VAULT_ROOT / "reusable" / "knowledge-global",
            include_roots=(),
            description="Reusable global knowledge.",
        ),
        CopySet(
            CURRENT_WORKTREE / "PackagesForReuse",
            VAULT_ROOT / "reusable" / "package-vault-docs",
            include_roots=(),
            description="Reusable package vault documentation, scripts, contracts, and DocC files.",
        ),
        CopySet(
            CURRENT_WORKTREE / "Packages" / "SDKCreation",
            VAULT_ROOT / "reusable" / "sdk-creation",
            include_roots=(),
            description="Reusable SDK/package creation baseline.",
        ),
        CopySet(
            CURRENT_WORKTREE / "docs" / "documentation-split" / "app-specific",
            VAULT_ROOT / "apps" / "TchopApp" / "baseline",
            include_roots=(),
            description="TchopApp-specific split baseline.",
        ),
        CopySet(
            CURRENT_WORKTREE / ".codex" / "skills",
            VAULT_ROOT / "apps" / "TchopApp" / "skills",
            include_roots=("tchop-feed-cards", "tchop-packages"),
            description="TchopApp local product/package skills.",
        ),
        CopySet(
            CURRENT_WORKTREE / "docs" / "knowledge" / "TchopApp",
            VAULT_ROOT / "apps" / "TchopApp" / "knowledge",
            include_roots=(),
            description="TchopApp knowledge docs.",
        ),
        CopySet(
            CURRENT_WORKTREE / ".zenflow" / "tasks" / "new-task-be0b",
            VAULT_ROOT / "tasks" / "new-task-be0b",
            include_roots=(),
            description="Current TchopApp task context snapshots and reports.",
        ),
        CopySet(
            MVVM_WORKTREE,
            VAULT_ROOT / "apps" / "MVVMExample" / "app-specific-matches",
            include_roots=("docs", ".zenflow"),
            description="MVVMExample app-specific docs selected by content match.",
            content_terms=("MVVMExample", "TaskDemo", "MVVM", "mvvmexample-3c80"),
        ),
        CopySet(
            ASSISTANT_ROOT,
            VAULT_ROOT / "tasks" / "assistant-archive",
            include_roots=("docs", "memory", ".zenflow"),
            description="Assistant docs, memory markdown, and task-plan archive inside expanded sandbox.",
        ),
    ]

    for copy_set in copy_sets:
        copied_by_set[copy_set.description] = copy_tree_files(copy_set)

    copied_by_set["MVVMExample remediation spec"] = copy_single_files(
        MVVM_WORKTREE / "docs" / "reusable-baseline",
        VAULT_ROOT / "apps" / "MVVMExample" / "remediation-spec",
        ["MVVMEXAMPLE_REMEDIATION_SPEC.md"],
    )

    # Normalize copied reusable manifest so the vault copy follows the new no-cross-app split.
    reusable_manifest = VAULT_ROOT / "reusable" / "baseline" / "REUSABLE_MANIFEST.md"
    if reusable_manifest.exists():
        reusable_manifest.write_text("\n".join(
            line for line in reusable_manifest.read_text().splitlines()
            if "MVVMEXAMPLE_REMEDIATION_SPEC.md" not in line
        ) + "\n")

    copied_by_set["TchopApp root docs"] = copy_single_files(
        CURRENT_WORKTREE,
        VAULT_ROOT / "apps" / "TchopApp" / "root-docs",
        [
            "AGENTS.md",
            "PROJECT_DOCUMENTATION.md",
            "PROJECT_HEALTH.md",
            "TESTING_INSTRUCTIONS.md",
            "APPLE_SIGN_IN_SETUP.md",
            "docs/README.md",
            "docs/CURRENT_USER_OVERRIDES.md",
            "docs/AGENT_RULES.md",
            "docs/WORK_CONTINUITY.md",
            "docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md",
            "docs/MODEL_ROUTING_RULE.md",
            "docs/PACKAGE_USAGE_IN_TCHOPAPP.md",
            "docs/PACKAGES_AND_MANAGERS.md",
        ],
    )
    copied_by_set["MVVMExample root docs"] = copy_single_files(
        MVVM_WORKTREE,
        VAULT_ROOT / "apps" / "MVVMExample" / "root-docs",
        [
            "AGENTS.md",
            "PROJECT_DOCUMENTATION.md",
            "PROJECT_HEALTH.md",
            "TESTING_INSTRUCTIONS.md",
            "docs/README.md",
            "docs/CURRENT_USER_OVERRIDES.md",
            "docs/AGENT_RULES.md",
            "docs/WORK_CONTINUITY.md",
            "docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md",
            "docs/MODEL_ROUTING_RULE.md",
            "docs/PACKAGES_AND_MANAGERS.md",
        ],
    )

    inventory = {
        "vault_root": VAULT_ROOT.relative_to(REPO_ROOT).as_posix(),
        "source_worktrees": {
            "AIZenflow_TchopApp": str(CURRENT_WORKTREE),
            "MVVMExample": str(MVVM_WORKTREE),
            "Assistant": str(ASSISTANT_ROOT),
        },
        "copied_counts": {key: len(value) for key, value in copied_by_set.items()},
        "copied_files": copied_by_set,
    }

    write_text(
        VAULT_ROOT / "README.md",
        """# Documentation Vault

This folder is the git-backed documentation vault for reusable agent rules, prompts, skills, templates, scripts, and app-specific documentation snapshots.

## Purpose
- Preserve documentation in the `AIZenflow` git repository if Zenflow task storage is unavailable.
- Provide a complete reusable baseline for new tasks/projects.
- Keep app-specific documentation separated by app.
- Keep operational worktree copies in place; this vault is an additional durable copy, not a replacement.

## Layout
- `reusable/`: non-app-specific docs, prompts, skills, templates, scripts, and reusable package documentation.
- `apps/TchopApp/`: TchopApp-specific docs/rules/skills/task-relevant snapshots.
- `apps/MVVMExample/`: MVVMExample-specific docs/rules/task-relevant snapshots.
- `tasks/`: task/assistant archives that are useful for recovery but are not default read paths.
- `scripts/`: vault sync and consistency tooling.

## Update Rule
When an agent changes a rule, prompt, skill, template, or durable doc that it uses, update both the worktree copy and this vault copy in the same block.

## Context Transfer Rule
перечитать весь актуальный набор документации и правил для этого worktree и task-контекста
""",
    )
    write_text(
        VAULT_ROOT / "SYNC_POLICY.md",
        """# Documentation Vault Sync Policy

## Invariants
1. Every durable rule/prompt/skill/template/doc used by agents must exist in at least one git-backed location.
2. Current worktrees keep their operational copies. The vault keeps durable recovery and transfer copies.
3. Reusable docs must not depend on one app's product behavior unless generalized first.
4. App-specific docs stay under `apps/<AppName>/`. A worktree should not need another app's docs in its local task folder.
5. New app tasks may copy `reusable/` first, then create their own `apps/<NewApp>/` area.

## Required Update Flow
- Edit the active worktree doc/rule first.
- Mirror the durable copy into `./documentation-vault`.
- Update manifests when paths are added or removed.
- Run vault/documentation consistency checks before declaring completion.

## Non-Goals
- Do not move active worktree docs out of their current locations.
- Do not mix TchopApp-specific and MVVMExample-specific docs in one app folder.
- Do not use this vault for generated build outputs, DerivedData, SwiftPM caches, simulator traces, or raw logs.
""",
    )


    def write_area_manifest(area: str, title: str) -> None:
        area_root = VAULT_ROOT / area
        files = sorted(
            path.relative_to(VAULT_ROOT).as_posix()
            for path in area_root.rglob("*")
            if path.is_file() and not any(part in EXCLUDED_PARTS for part in path.relative_to(area_root).parts)
        ) if area_root.exists() else []
        lines = [f"# {title}", "", f"Area: `./documentation-vault/{area}`", "", f"Files: {len(files)}", "", "## Files", ""]
        lines.extend(f"- `./documentation-vault/{rel}`" for rel in files)
        write_text(area_root / "MANIFEST.md", "\n".join(lines) + "\n")

    write_area_manifest("reusable", "Reusable Vault Manifest")
    write_area_manifest("apps/TchopApp", "TchopApp Vault Manifest")
    write_area_manifest("apps/MVVMExample", "MVVMExample Vault Manifest")
    write_area_manifest("tasks", "Task And Assistant Archive Manifest")

    manifest_lines = [
        "# Documentation Vault Manifest",
        "",
        "Generated by `./documentation-vault/scripts/sync_from_worktrees.py`.",
        "",
        "## Source Worktrees",
        f"- AIZenflow/TchopApp: `{CURRENT_WORKTREE}`",
        f"- MVVMExample: `{MVVM_WORKTREE}`",
        f"- Assistant archive: `{ASSISTANT_ROOT}`",
        "",
        "## Copied Sets",
    ]
    for key, files in copied_by_set.items():
        manifest_lines.append(f"- **{key}**: {len(files)} files")
    manifest_lines.extend(["", "## Files", ""])
    for key, files in copied_by_set.items():
        manifest_lines.append(f"### {key}")
        if not files:
            manifest_lines.append("- none")
        else:
            for rel in files:
                manifest_lines.append(f"- `./documentation-vault/{rel}`")
        manifest_lines.append("")
    write_text(VAULT_ROOT / "MANIFEST.md", "\n".join(manifest_lines))
    write_text(VAULT_ROOT / "inventory.json", json.dumps(inventory, indent=2, ensure_ascii=False) + "\n")

    print(json.dumps(inventory["copied_counts"], indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
