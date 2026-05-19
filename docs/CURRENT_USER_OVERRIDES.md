# Current User Overrides

## Purpose
Task-local user preferences and hard constraints that must be applied before general project defaults.

This file exists to prevent loss of current user rules after chat/context reset.

## Scope
Applies to the current worktree/task:
- Worktree: `/Users/Artem/.zenflow/worktrees/new-task-be0b`
- Task: `new-task-be0b`

## Active Overrides

### Model
- Use and report `GPT-5.5` for all work in this worktree/task unless the user explicitly changes the model again.
- UI/design work from screenshots/Figma/PDF/CSS always requires `GPT-5.5`.

### Response Header
Every working response must start with:
- model
- active phase
- files being inspected/changed
- next safe step
- whether a build is needed
- sandbox confirmation inside `/Users/Artem/.zenflow`

### Sandbox
- Work strictly inside `/Users/Artem/.zenflow`.
- Current worktree is `/Users/Artem/.zenflow/worktrees/new-task-be0b`.

### Verification / Builds / Tests
- Do not run builds, tests, or simulator UI unless the user explicitly asks.
- `git diff --check` or read-only/static documentation checks are allowed when useful.
- Do not touch `./TchopAppTests` unless the user explicitly asks.
- Low-resource mode: minimum reading, minimum commands, one meaningful verification only when requested or explicitly justified.
- Be capable of strong test strategy and test implementation, but do not spend time/resources on tests until the user explicitly opens that phase.

### Implementation Style
- No speculative UI.
- No speculative business logic.
- No extra layers, protocols, UseCases, factories, adapters, interfaces, or abstractions unless they solve a concrete current problem.
- Prefer the simplest correct implementation that preserves product behavior and UI.
- If anything is unclear, ask first.

### Documentation / Context Transfer
- When refreshing documentation state or transferring context, include the rule:
  **"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.
- After an internal assistant/runtime error, continue and finish the task automatically where possible.

## Notes
If this file conflicts with an explicit newer user instruction in chat, the newer user instruction wins.
