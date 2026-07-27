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

## Model Routing
- Apply `./docs/MODEL_ROUTING_RULE.md` before implementation, planning, review, or package-adoption work.
- Classify the task before editing code or documentation.
- Use `GPT-5.4` only for approved-plan low-risk execution; use `GPT-5.5` for architecture, persistence, concurrency, navigation, state ownership, public APIs, package boundaries/adoption, security/privacy, data-loss/sync, performance-sensitive work, and high-risk final reviews.

## Startup Read Rule
Before code, docs, git, or project changes:

1. Read `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md`.
2. Read its current Level 0 set once, including current task handoff/plan when present.
3. Load only the task-relevant routes before acting.

The router is the sole source of truth for the numbered startup list. Do not treat the documentation index as an always-read library.


## Documentation Vault
- Durable reusable rules, prompts, skills, templates, scripts, and app-specific docs should be mirrored into the active git-backed documentation vault when a project provides one.
- Apply `./docs/DOCUMENT_BOUNDARY_STANDARD.md` before documentation moves, reusable rule updates, app-specific docs updates, prompt/skill changes, package-doc updates, task handoff updates, or new-project bootstrapping.
- Use `./docs/SOURCE_OF_TRUTH_MAP.md` to choose the correct durable location for every reusable rule, app decision, task state, package contract, prompt, skill, or temporary note.
- Keep reusable/global docs under the vault's `reusable/` area, app-specific docs under `apps/<AppName>/`, and task-only handoffs/plans under `tasks/<task-id>/` when a vault is present.
- Do not copy another app's docs into a new task's local task folder; keep cross-app context in the vault's app-specific area.
- Local app exceptions remain local and must not weaken reusable/global rules without explicit user-approved promotion and app-neutral rewriting.

## Filesystem Sandbox
- Keep all project work, build output, package caches, Xcode DerivedData, cloned package state, logs, traces, and temporary project artifacts inside the active worktree sandbox.
- Do not use global SwiftPM/Xcode caches, `/tmp`, user-library caches, or any path outside the active local sandbox for project work.
- If a tool defaults outside the sandbox, override its output/cache/DerivedData paths before running it.

## MVVM ViewModel API
- ViewModels expose explicit intent methods by default.
- Do not use `send(_ action:)`, `dispatch(_:)`, or UI action enums as default MVVM boilerplate.
- Reducer/action architecture requires explicit user approval and a documented rationale.

## Current Project Mode
- This is a clean `<AppName>` baseline project unless project-specific docs say otherwise.
- This project uses the highest reusable standards and best current rules by default until the user explicitly approves a narrower local exception.
- Do not implement app-specific demo features unless the user explicitly asks.
- Do not continue stale app/task-specific demo plans from another project.
- The user may provide Swift files or text fragments to add iteratively.
- When the user provides source fragments/files, preserve the code content unless the user explicitly asks for changes.
- Add files meaningfully to the project structure and Xcode project when requested.

## Tests And Verification
- Do not write or modify tests unless the user explicitly opens a test-writing phase or asks to fix a specific failing test.
- Do not run builds/tests/simulator UI/Instruments unless explicitly requested or already approved.
- `git diff --check`, docs index checks, and project-list checks are allowed when useful.

## Plan Rule
If new user-approved work benefits from a breakdown, update the local task plan with checkbox steps and mark completed steps before reporting completion.

## Preflight And Completion
- Apply `./docs/NEW_PROJECT_START_CONTRACT.md` before creating or bootstrapping a new project/task/worktree.
- Apply `./docs/AGENT_PREFLIGHT_CHECKLIST.md` before non-trivial implementation, refactor, docs migration, package adoption, review, or bootstrap work.
- Apply `./docs/LOCAL_EXCEPTION_ADR_TEMPLATE.md` when a local project intentionally violates a reusable/global rule.
- Apply `./docs/COMPLETION_REPORT_CONTRACT.md` before meaningful completion reports.
- Apply `./docs/TASK_STATE_DOCUMENTATION_STANDARD.md` before changing task plan/handoff/archive/recovery docs.


## New Chat / Context Transfer

## Result Model And Context Reporting
- After every meaningful step/task/completion report, state which model(s) worked and what each one did.
- Include whether context should be refreshed or a new chat should be started, with a short reason.

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


## Figma MCP SwiftUI Prompt Rule
- When work starts from Figma, when the user provides a Figma link, or when the task says to inspect/implement a Figma design through MCP, read `./docs/agent-prompts/figma-mcp-swiftui-implementation.md` before using Figma MCP or changing code. That prompt is mandatory for Figma → SwiftUI work and reinforces native SwiftUI, existing DesignSystem usage, pre-code analysis, Figma mismatch reporting, and no web-code generation.
