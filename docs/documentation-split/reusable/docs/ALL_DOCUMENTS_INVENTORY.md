# All Documents Inventory

## Purpose
Project-local generated inventory of physical documentation, prompt, skill, task-context, package-documentation, architecture-case, and helper-script files.

## Generation Rule
This file is a reusable baseline placeholder. Each project/task should regenerate it for its own worktree so paths are local and complete.

A valid project-specific inventory should include:

- root docs such as `./AGENTS.md`, `./PROJECT_DOCUMENTATION.md`, `./PROJECT_HEALTH.md`, and `./TESTING_INSTRUCTIONS.md` when present;
- active `./docs` files;
- local skills under `./.codex/skills`;
- current task docs under `./.zenflow/tasks/<task-id>`;
- reusable package docs, architecture cases, or helper scripts that are part of the project knowledge baseline;
- a pointer to any central `./documentation-vault` or external documentation vault manifests.

## Reading Rule
Do not read the full inventory on every task. Use it for audits, migration, missing-doc checks, documentation-library maintenance, and transfer into another task.

## Context Transfer Rule
перечитать весь актуальный набор документации и правил для этого worktree и task-контекста
