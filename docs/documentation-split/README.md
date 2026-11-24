# Documentation Split

## Purpose
This folder preserves a historical export of documentation/rules/skills/prompts from an earlier split.

## Groups
- The former `app-specific/` group is preserved for recovery in `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/Tchop/history/documentation-split-app-snapshot.zip` with a file-hash inventory beside it. Its contents are historical, not current project rules.
- `./docs/documentation-split/reusable/` — reusable non-app-specific iOS production baseline: general standards, review gates, prompt presets, generic iOS skills, and normalized user/agent preferences for a new project.

The old shared skill entrypoints were removed from this export after byte-for-byte archiving in `documentation-vault/tasks/kb-audit-2026-11-11/shared-skill-export-snapshot.zip`; active skills are routed from the canonical KB.

Ninety byte-identical shared export files were removed after recovery mapping to a pinned canonical Git revision. See `documentation-vault/tasks/kb-audit-2026-11-11/shared-export-exact-duplicates.json`; remaining export contents are incomplete historical sources, not a bootstrap baseline.

The remaining 120 non-external shared source files are preserved in `documentation-vault/tasks/kb-audit-2026-11-11/shared-export-unreconciled-snapshot.zip` with a hash and mode inventory. Their semantic review is incomplete; preservation is not proof of incorporation into active rules. The remaining external-environment snapshots have separate provenance and restrictions.

The external-environment export is partial: 199 byte-identical files per copy were removed after mapping to committed KB objects. Among these two exports, twenty distinct unmatched historical files are retained in the knowledge-base-next worktree pending provenance/terms review; their original 37 paths are recorded in `documentation-vault/tasks/kb-audit-2026-11-11/remaining-external-content-inventory.json`. This is not an installable skill set.

## Important Rule
The split folder is a historical export, not an active source of rules. The canonical knowledge base is `/Users/Artem/.zenflow/worktrees/documentation-vault/`; project `./docs` and `./.codex/skills` are governed distribution or operational entrypoints, not separate authorities.

Do not use this snapshot to bootstrap a new project/task: its historical contents can retain superseded rules. Bootstrap from the canonical reusable baseline at `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/`, then create project-specific docs instead of importing source-app-specific files.
