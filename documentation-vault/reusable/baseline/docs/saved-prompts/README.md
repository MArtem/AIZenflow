# Codex App Saved Prompts Inventory

## Purpose
This folder preserves the saved prompt shortcuts visible in Codex App so they are not only UI/database state.

## Source
- Screenshot attachment: `./.zenflow-attachments/dbcdd4b7-48fe-4fb7-bbea-7b40adce1a0f.png`
- Captured on: 2026-07-07

## Important Completeness Note
The screenshot shows shortcut names and truncated/visible content only. Full saved-prompt bodies were not found in `./docs`, `./documentation-vault`, `./.codex`, `./.zenflow/tasks/new-task-be0b`, or `/Users/Artem/.zenflow` during the audit.

Therefore:
- prompts marked `complete from screenshot` contain all visible content and appear complete enough from the screenshot;
- prompts marked `partial from screenshot` need a Codex App export/copy-paste if exact full body is required;
- `/ios` and `/services` are backed by physical task rule files and are linked below.

## Saved Prompt Shortcuts

| Shortcut | Physical file | Status | Backing source |
|---|---|---|---|
| `/confirm-first` | `./docs/saved-prompts/confirm-first.md` | complete from screenshot | screenshot-visible content |
| `/fix-ci` | `./docs/saved-prompts/fix-ci.md` | complete from screenshot | screenshot-visible content |
| `/pr-comments` | `./docs/saved-prompts/pr-comments.md` | partial from screenshot | needs full Codex App body for exact prompt |
| `/review` | `./docs/saved-prompts/review.md` | partial from screenshot; canonical review docs also exist | `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`, `./docs/agent-prompts/production-review-completeness.md`, `./.codex/skills/zen-review/SKILL.md` if available in environment |
| `/update-branch` | `./docs/saved-prompts/update-branch.md` | partial from screenshot | needs full Codex App body for exact prompt |
| `/ios` | `./docs/saved-prompts/ios.md` | backed by physical task rules | `./.zenflow/tasks/new-task-be0b/ios-engineering-rules.md` |
| `/services` | `./docs/saved-prompts/services.md` | backed by physical task rules | `./.zenflow/tasks/new-task-be0b/services-engineering-rules.md` |

## Rule
If Codex App saved prompts change, update this folder and the matching `./documentation-vault` copy in the same block.
