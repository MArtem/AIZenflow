# Current User Overrides

## Purpose
Task-local user preferences and hard constraints that must be applied before general project defaults.

This file exists to prevent loss of current user rules after chat/context reset.

## Scope
Applies to the current worktree/task:
- Worktree: `/Users/Artem/.zenflow/worktrees/new-task-be0b`
- Task: `new-task-be0b`

## Active Overrides

### Documentation Vault
- `MArtem/AIZenflowDocumentation` is the canonical GitHub repository for reusable/global docs, rules, prompts, skills, templates, package docs, scripts, app-specific snapshots, and task context snapshots.
- `/Users/Artem/.zenflow/worktrees/documentation-vault` is the local checkout of `https://github.com/MArtem/AIZenflowDocumentation`.
- Global documentation changes must be committed in that checkout and pushed to `MArtem/AIZenflowDocumentation`; a local-only commit is not a completed global documentation update.
- `./docs/DOCUMENT_BOUNDARY_STANDARD.md` is mandatory for all documentation/library/prompt/skill/package-doc work.
- New reusable/shared documentation changes must be made in `/Users/Artem/.zenflow/worktrees/documentation-vault`; app-local docs may keep a small operational copy only when the project needs it.
- Do not place another app's docs into this worktree's task docs; cross-app context belongs under `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/<AppName>/`.
- Local project exceptions, compromises, or intentional rule violations must remain app-specific. They must not change reusable/global rules unless the user explicitly approves promotion to reusable.


### Model Routing
- Apply `./docs/MODEL_ROUTING_RULE.md` for all implementation, planning, review, and package-adoption work.
- User authorizes the assistant to choose the suitable model before each task and to recommend or use a different model when risk/resource balance changes, subject to actual Zenflow/tool availability.
- If the current chat/session primary model is fixed by Zenflow/UI, the assistant cannot physically switch it alone; when a true primary-model switch is needed, the assistant must ask the user to switch or continue with the best available model and report risk.
- Use `GPT-5.6 sol` or `GPT-5.5` as the normal high-quality default when available; reserve `GPT-5.6 tera` for highest-risk planning/review/final gates; use `GPT-5.6 luna` only for low-risk mechanical/read-only/docs inventory work.
- Default executor is `GPT-5.4` for approved-plan, routine, low-risk implementation where architecture and ownership are already decided.
- Use `GPT-5.5` for planning gates, architecture, persistence, concurrency, navigation, state ownership, public APIs, module/package boundaries, security/privacy, data-loss/sync, performance-sensitive decisions, package adoption into `./PackagesInUse`, Xcode/app runtime integration, and high-risk final reviews.
- Before editing code or documentation, classify the task as one of: `GPT-5.5 Planning Required`, `GPT-5.4 Execution Only`, `GPT-5.4 Execution + GPT-5.5 Final Review`, or `GPT-5.5 Full Task Required`, with 3–5 bullets of reasoning.
- In a `GPT-5.5` primary-assistant session, use `GPT-5.4` through available subagents/tools only when it is genuinely suitable and resource-saving; `GPT-5.5` remains the planner, escalation target, and final decision model for high-risk work.
- Choose the reasoning/thinking level per task: save resources where safe, but never reduce reasoning effort when it would reduce quality, correctness, or verification confidence.
- Every working/status/completion response must include both model version and reasoning/thinking level.
- UI/design work from screenshots, Figma, PDF, SVG, CSS, visual references, or pixel-perfect comparison still requires `GPT-5.5` unless the user explicitly relaxes that requirement.
- If the user provides a Figma link or says the work starts from Figma, first read `./docs/agent-prompts/figma-mcp-swiftui-implementation.md`; then use Figma MCP as the design source of truth before analysis or implementation.

### Response Header

### Result Model And Context Reporting
- After every meaningful step, task, review, implementation block, or completion report, include which model(s) worked and what each one did.
- Include whether context should be refreshed or a new chat should be started: `контекст обновлять не нужно`, `желательно обновить контекст`, or `нужен новый чат`, with a short reason.

Every working response must start with:
- model and reasoning/thinking level
- active phase
- files being inspected/changed
- next safe step
- whether a build is needed
- sandbox confirmation inside `/Users/Artem/.zenflow`

### Sandbox
- Work strictly inside `/Users/Artem/.zenflow`.
- Current worktree is `/Users/Artem/.zenflow/worktrees/new-task-be0b`.
- Never write build artifacts, package caches, Xcode DerivedData, cloned package state, logs, temporary package verification output, or project traces outside `/Users/Artem/.zenflow`.
- Do not use `/Users/Artem/Library`, `/tmp`, global SwiftPM/Xcode caches, or any other path outside `/Users/Artem/.zenflow` for project work.
- If a tool defaults to an external cache/location, override it to a path under `/Users/Artem/.zenflow` before running it.
- The only allowed external filesystem action is deleting previously created project traces outside `/Users/Artem/.zenflow` when explicitly requested by the user.

### Verification / Builds / Tests
- The user restored the test-writing ban on 2026-05-29. Do not write, modify, or expand tests until the user explicitly gives permission again.
- Do not touch `./app test targets` or UI/package test files unless the user explicitly reopens test-writing work or asks to fix a specific failing test.
- Build/simulator execution is approved for cases where the assistant determines it is needed to reproduce a bug, verify a fix, or protect quality. Do not run build/simulator when cheaper evidence is sufficient.
- Test execution is allowed only when explicitly requested by the user or when a previously approved implementation block requires verification; do not add new test coverage while the ban is active.
- Simulator UI automation may be used when it materially improves repro/verification confidence; if UI automation access is insufficient, state what is missing, whether simulator/logs/code analysis can substitute, and what risk remains.
- `git diff --check` or read-only/static documentation checks are allowed when useful.
- Low-resource mode: minimum reading, minimum commands, one meaningful verification when sufficient; resource savings must never reduce quality or confidence.

### MVVM / ViewModel API
- Do not use `send(_ action:)`, `dispatch(_:)`, or UI action enums as the default ViewModel API in any project, including test/demo projects.
- Use explicit intent methods on ViewModels.
- Action/reducer architecture is allowed only after explicit user approval and documentation.

### Implementation Style
- No speculative UI.
- No speculative business logic.
- No extra layers, protocols, UseCases, factories, adapters, interfaces, or abstractions unless they solve a concrete current problem.
- Prefer the simplest correct implementation that preserves product behavior and UI.
- If anything is unclear, ask first.


### Product-Staff Quality Bar
- Any project is developed by default according to the highest reusable standards and best current rules until the user explicitly says otherwise.
- Never lower the engineering bar because a project is described as demo, test, sample, prototype, imported, or pre-production; those words may only describe configuration/risk context, not code quality.
- Treat every authored or reviewed code path as product-staff-level production code: correct ownership, explicit state, clear failure behavior, performance-aware rendering, privacy-safe logging, accessibility, localization, and supportable verification.
- Even the smallest test app must start with proper project structure, composition root, navigation coordinator/router, feature state ownership, model boundaries, view-state rendering, accessibility/localization posture, and explicit verification gates. Do not defer these foundations until future complexity appears.
- Do not wait for Instruments/profilers before fixing statically obvious performance or memory issues. Use profiling to prove behavior, compare alternatives, or validate non-obvious risks, not as an excuse to leave avoidable redraws, broad invalidation, main-thread work, unbounded caches, or lifecycle leaks.
- Maximize quality through the simplest correct design: improve hot paths, state ownership, and error handling without adding decorative protocols, wrappers, factories, use cases, or interfaces.

### Audit / Planning Scope Rule
- When the user asks to review, audit, inspect a project/code area, evaluate requirements, or plan a task, provide the fullest unbiased high-quality analysis available, even for very small code.
- Do not silently simplify, defer, dismiss, or complicate scope on the user's behalf. The assistant must surface the full relevant concern set and let the user decide what to execute.
- Always prioritize findings and recommendations as `must do now`, `should do next`, `later / only if needed`, and `do not do / overengineering for this scope` where applicable.
- If a concern is intentionally not investigated, state it as an explicit remaining risk; never imply it is irrelevant because the project is small, early, demo-like, or because the assistant judged it unnecessary.
- During implementation, only execute the scope the user approved, but keep unexecuted review/planning concerns visible as remaining risks or backlog candidates.

### Production Audit / Review Rules
- Before any non-trivial implementation, refactor, cleanup, or review, apply `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` and `./docs/PRODUCTION_QUALITY_GATES.md`.
- Treat the forbidden-pattern stop list as blocking by default.
- Do not keep source-split domain/UI naming such as `Local*` unless it is strictly storage-only and does not leak into product semantics.
- Do not perform read-only audits without using the current checklist/rules as the audit standard.
- For every audit finding, provide severity P0-P3, affected files, evidence, why it is a problem, target state, remediation order, and verification required.


### Review Trigger
- When the user writes `ревью`, `review`, `code review`, or `аудит`, run the production-grade review prompt from `./docs/agent-prompts/production-review-completeness.md`.
- Apply `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md` before claiming a change is correct or production-ready.
- Reviews must not be narrowly scoped to the current bug unless the user explicitly says so.
- If correctness cannot be proven from code/static evidence, ask the user or report the item as remaining risk.


### iOS Production Standards
- For production-level confidence in any iOS feature, apply `./docs/IOS_PRODUCTION_READINESS_STANDARD.md` and `./docs/DEFINITION_OF_DONE.md`.
- Use specialized gates when relevant: testing, security/privacy, observability, release, accessibility, performance budgets, API contracts, data migration, design-system governance, CI/CD, and dependency policy.
- If a production gate cannot be verified in the current environment, report it as remaining risk instead of implying completion.


### Evidence / Governance
- Do not claim `done`, `fixed`, `verified`, `smooth`, `safe`, `production-ready`, or `clean` without evidence from `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md`.
- Before non-trivial feature work, verify product requirements using `./docs/PRODUCT_REQUIREMENTS_STANDARD.md`; if acceptance criteria/state behavior is missing, ask instead of guessing.
- For production-scale changes, include rollout/rollback, observability, QA, localization/accessibility, data governance, compatibility, incident, risk, and tech-debt considerations when relevant.
- Use the static gate scripts under `./scripts/` when they match the task; report failures as findings or remaining risks instead of hiding them.


### Generic iOS Coverage
- For generic iOS development, use `./docs/IOS_PRODUCTION_FRAMEWORK.md` as the umbrella baseline and cover non-app-specific concerns before app-specific assumptions: concurrency/runtime, memory/cache/media, UI state/rendering, network resilience, offline/sync, lifecycle/background, error handling, analytics/telemetry, configuration/environments, input validation/content safety, permissions, and StoreKit/payments when applicable.
- If a generic iOS area cannot be verified without project-specific requirements or user answers, report it as remaining risk and do not guess.


### Code Documentation
- Document contracts, not obvious code.
- For methods used outside their declaring type, include stable external usage/call context when it helps understand who calls it, when, and why.
- For key entities, include runtime ownership/created-by information when lifecycle matters.
- Avoid fragile exhaustive caller lists unless the caller is part of the API contract.

### Documentation / Context Transfer
- When refreshing documentation state or transferring context, include the rule:
  **"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.
- After an internal assistant/runtime error, continue and finish the task automatically where possible.

## Notes
If this file conflicts with an explicit newer user instruction in chat, the newer user instruction wins.


### New Chat / Context Transfer
- The assistant must proactively tell the user when the current chat/context should be replaced by a new chat to reduce context risk.
- When recommending a new chat, provide a compact transition spec and include: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
- Do not include raw command logs, tool output, full diffs, or long scripts in the transition spec unless explicitly requested.

### AI Fieldbook Current Decisions
- AI Fieldbook is an independent internal-only learning app, not a source-app feature.
- The currently reported toolchain is Xcode 26.5; Xcode/iOS 27 beta is unavailable.
- Available runtime verification is iOS Simulator only; no physical Apple Intelligence-capable device is currently available.
- No backend, paid cloud-provider budget, or third-party cloud data path is approved.
- Default mode is local-only; private user content must not leave the device.
- Test writing remains prohibited for the independent app as well as the existing project until the user explicitly changes this decision.
- The user authorized Iteration 1 to begin block-by-block. Complete and report one self-contained block before starting the next; do not begin Iteration 2 before the Iteration 1 completion gate is accepted.
- Backend/cloud provisioning and test writing remain prohibited until separately approved.
- For every AI-related task, read `./docs/agent-prompts/AI_iOS_MASTER_PROMPT.md` and apply only its relevant sections under the higher-priority current rules above.
