# Agent Instructions

## Mandatory Response Header
Every working, status, readiness, confirmation, task-orientation, planning, or clarification response must start with:

- **Модель:** current model
- **Active phase:** current phase
- **Файлы смотришь/меняешь:** files being inspected/changed, or `none` if no files
- **Следующий безопасный шаг:** next safe step
- **Нужна ли сборка:** yes/no and why
- **Sandbox:** active worktree/sandbox confirmation

Short answers such as “готов”, “да, всё ясно”, “готов к новым задачам”, or “можешь присылать” are not exempt.

## Startup Read Rule
Before code, docs, git, or project changes, read:
1. `./docs/README.md`
2. `./PROJECT_DOCUMENTATION.md`
3. `./PROJECT_HEALTH.md`
4. `./docs/CURRENT_USER_OVERRIDES.md`
5. `./docs/AGENT_RULES.md`
6. `./docs/WORK_CONTINUITY.md`
7. current Zenflow task plan if present

## MVVM ViewModel API
- ViewModels expose explicit intent methods by default.
- Do not use `send(_ action:)`, `dispatch(_:)`, or UI action enums as default MVVM boilerplate.
- Reducer/action architecture requires explicit user approval and a documented rationale.

## Current Project Mode
- This is a clean `<AppName>` baseline project unless project-specific docs say otherwise.
- Do not implement app-specific demo features unless the user explicitly asks.
- Do not continue old `TaskDemo` / `TaskDemoViewModel` / behavior-test plans.
- The user may provide Swift files or text fragments to add iteratively.
- When the user provides source fragments/files, preserve the code content unless the user explicitly asks for changes.
- Add files meaningfully to the project structure and Xcode project when requested.

## Tests And Verification
- Do not write or modify tests unless the user explicitly opens a test-writing phase or asks to fix a specific failing test.
- Do not run builds/tests/simulator UI/Instruments unless explicitly requested or already approved.
- `git diff --check`, docs index checks, and project-list checks are allowed when useful.

## Plan Rule
If new user-approved work benefits from a breakdown, update the local task plan with checkbox steps and mark completed steps before reporting completion.


## New Chat / Context Transfer
- Proactively recommend a new chat when context becomes risky or a major phase changes.
- Provide a compact transition spec before transfer.
- Include the rule: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
- Do not include raw command logs, tool output, full diffs, or long scripts unless requested.


## Product-Staff Quality Bar Rule
- Never lower the engineering bar because a project is described as demo, test, sample, prototype, imported, or pre-production; those words may only describe configuration/risk context, not code quality.
- Treat every authored or reviewed code path as product-staff-level production code: correct ownership, explicit state, clear failure behavior, performance-aware rendering, privacy-safe logging, accessibility, localization, and supportable verification.
- Do not wait for Instruments/profilers before fixing statically obvious performance or memory issues. Use profiling to prove behavior, compare alternatives, or validate non-obvious risks, not as an excuse to leave avoidable redraws, broad invalidation, main-thread work, unbounded caches, or lifecycle leaks.
- Maximize quality through the simplest correct design: improve hot paths, state ownership, and error handling without adding decorative protocols, wrappers, factories, use cases, or interfaces.


## Audit / Planning Scope Rule
- When the user asks to review, audit, inspect a project/code area, evaluate requirements, or plan a task, provide the fullest unbiased high-quality analysis available, even for very small code.
- Do not silently simplify, defer, dismiss, or complicate scope on the user's behalf. The assistant must surface the full relevant concern set and let the user decide what to execute.
- Always prioritize findings and recommendations as `must do now`, `should do next`, `later / only if needed`, and `do not do / overengineering for this scope` where applicable.
- If a concern is intentionally not investigated, state it as an explicit remaining risk; never imply it is irrelevant because the project is small, early, demo-like, or because the assistant judged it unnecessary.
- During implementation, only execute the scope the user approved, but keep unexecuted review/planning concerns visible as remaining risks or backlog candidates.
