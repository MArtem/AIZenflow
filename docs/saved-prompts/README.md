# Codex App Saved Prompts Inventory

## Purpose
This folder preserves Codex App saved prompt shortcuts as physical repository files so they are not only UI/database state.

## Source
- Screenshot attachment: `./.zenflow-attachments/dbcdd4b7-48fe-4fb7-bbea-7b40adce1a0f.png`
- Exact local export: `./.zenflow/tasks/new-task-be0b/saved-prompts-export.json`
- Exported on: 2026-07-07

## Completeness
All saved prompts visible in the screenshot were recovered from the local Zenflow/Codex App `saved_prompts` SQLite table and are now preserved as complete physical markdown files.

## Saved Prompt Shortcuts

| Shortcut | Physical file | Status | Notes |
|---|---|---|---|
| `/confirm-first` | `./docs/saved-prompts/confirm-first.md` | complete exact export | Planning confirmation guard |
| `/fix-ci` | `./docs/saved-prompts/fix-ci.md` | complete exact export | CI-fix shortcut |
| `/pr-comments` | `./docs/saved-prompts/pr-comments.md` | complete exact export | GitHub PR comment planning guard |
| `/review` | `./docs/saved-prompts/review.md` | complete exact export | General code-review shortcut |
| `/update-branch` | `./docs/saved-prompts/update-branch.md` | complete exact export | Main-merge/conflict shortcut |
| `/ios` | `./docs/saved-prompts/ios.md` | complete exact export plus canonical historical-rule reference | Tracked canonical recovery copy under `documentation-vault/apps/Tchop/legacy-reference/TchopApp/baseline/` |
| `/services` | `./docs/saved-prompts/services.md` | complete exact export plus canonical historical-rule reference | Tracked canonical recovery copy under `documentation-vault/apps/Tchop/legacy-reference/TchopApp/baseline/` |

## Usage Rule
- These files preserve Codex App saved prompt bodies.
- For current source-app work, apply active project/task rules first: `./AGENTS.md`, `./docs/README.md`, `./docs/CURRENT_USER_OVERRIDES.md`, and task handoff/plan.
- If Codex App saved prompts change, update this folder and the matching `./documentation-vault/reusable/saved-prompts/` mirror in the same block.
