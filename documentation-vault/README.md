# Documentation Vault

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
