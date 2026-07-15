# Shared Document Library Guide

## Canonical Location
The shared documentation library for Codex app tasks and local worktrees is here:

- `/Users/Artem/.zenflow/worktrees/documentation-vault`

This is the single shared source for reusable agent rules, prompt presets, skills, templates, package documentation, architecture cases, and app-specific documentation snapshots.

## Rule
Do not copy the full library into each task/worktree. A task/worktree may keep only minimal local task state such as `AGENTS.md`, `plan.md`, and task-specific handoff notes. Shared knowledge belongs here.

Apply `./reusable/baseline/docs/DOCUMENT_BOUNDARY_STANDARD.md` before moving, copying, promoting, or editing documentation that may be reusable or app-specific.

Local project exceptions stay under `./apps/<AppName>/` or `./tasks/<TaskId>/` and never weaken reusable rules without explicit promotion approval.

## Default Task Read Flow
For any task/worktree:

1. Read the task-local `AGENTS.md` and task plan/handoff if present.
2. Read this central guide.
3. Read `./reusable/baseline/docs/DOCUMENT_BOUNDARY_STANDARD.md`.
4. Use `./ALL_DOCUMENTS_INVENTORY.md` and manifests to select only task-relevant docs.
5. Read scope-specific docs from this central library.

## Main Areas
- `./reusable/`: reusable non-app-specific docs, prompts, skills, templates, package docs, architecture cases, package/manager docs, reusable scripts, and app-neutral knowledge.
- `./apps/Tchop/`: Tchop-specific snapshots, local rules, exceptions, histories, plans, and app decisions.
- `./apps/MVVMExample/`: MVVMExample-specific snapshots, local rules, exceptions, histories, plans, and app decisions.
- `./apps/BattleshipGame/`: BattleshipGame-specific snapshots, local rules, exceptions, histories, plans, and app decisions.
- `./apps/AIFieldbook/`: AIFieldbook-specific snapshots, local rules, exceptions, histories, plans, and app decisions.
- `./tasks/`: task and assistant recovery archives.
- `./MANIFEST.md`: generated vault manifest.
- `./ALL_DOCUMENTS_INVENTORY.md`: generated full inventory of this central library.

## Resource Rule
Do not read the full library by default. Read the smallest sufficient set:

1. local task rules;
2. this guide and the document-boundary standard;
3. task-specific docs selected from the central inventory;
4. full inventory only for documentation-library maintenance, migration, recovery, or audit.

## Update Rule
When a durable reusable rule/prompt/skill/template/doc changes, update it under `./reusable/`. Do not create full per-task copies.

When an app-specific rule, plan, ADR, exception, prompt, skill, or history changes, update only the matching `./apps/<AppName>/` area.

When a task-only handoff, plan, or recovery note changes, update only `./tasks/<TaskId>/` and the local task docs.

Promote local app decisions into `./reusable/` only after explicit user approval and app-neutral rewriting.

## Context Transfer Rule
перечитать весь актуальный набор документации и правил для этого worktree и task-контекста
