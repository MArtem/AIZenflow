# Documentation Split

## Purpose
This folder preserves a historical export of documentation/rules/skills/prompts from an earlier split.

## Groups
- `./docs/documentation-split/app-specific/` — source-app-specific material: current app docs, task history, feed/card contracts, share-extension validation, source-app package names, and project-specific continuity rules.
- `./docs/documentation-split/reusable/` — reusable non-app-specific iOS production baseline: general standards, review gates, prompt presets, generic iOS skills, and normalized user/agent preferences for a new project.

## Important Rule
The split folder is an export/staging area. It does not replace the active canonical docs in `./docs`, `./.codex/skills`, or `./.zenflow/tasks/new-task-be0b`.

Do not use this snapshot to bootstrap a new project/task: its historical contents can retain superseded rules. Bootstrap from the canonical reusable baseline at `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/`, then create project-specific docs instead of importing source-app-specific files.
