# Current User Overrides

## Purpose
Task-local user preferences and hard constraints that apply before general project defaults.

## Active Overrides

### Model
- Use and report `GPT-5.5` unless the user explicitly changes the model.
- UI/design work from screenshots/Figma/PDF/SVG/CSS requires `GPT-5.5`.

### Response Header
Every working/status/readiness response must start with:
- model
- active phase
- files being inspected/changed
- next safe step
- whether a build is needed
- sandbox/worktree confirmation
- Readiness/status answers such as “готов к новым задачам” are not exempt.

### Verification / Builds / Tests
- Do not write or modify tests unless the user explicitly opens a test-writing phase or asks to fix a specific failing test.
- Do not run builds/tests/simulator UI/Instruments unless explicitly requested or already approved for the current block.
- `git diff --check` and read-only/static documentation checks are allowed when useful.

### MVVM ViewModel API
- ViewModels expose explicit intent methods by default.
- Do not use `send(_ action:)`, `dispatch(_:)`, or UI action enums as default MVVM boilerplate.
- Reducer/action architecture requires explicit user approval and a documented rationale.

### Implementation Style
- No speculative UI.
- No speculative business logic.
- No extra layers, protocols, UseCases, factories, adapters, interfaces, or abstractions unless they solve a concrete current problem.
- If anything is unclear, ask first.

### No-Loss Transfer
- Every new project/task must receive the full reusable non-app-specific baseline accumulated so far.
- If any reusable documentation, prompt, rule, skill, template, or script cannot be copied or activated, report it as an explicit remaining risk.

## Notes
If this file conflicts with a newer explicit user instruction in chat, the newer instruction wins.


### New Chat / Context Transfer
- The assistant must proactively recommend a new chat when context becomes risky or a major phase changes.
- The assistant must provide a compact transition spec and include: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
- Do not include raw command logs, tool output, full diffs, or long scripts unless requested.
