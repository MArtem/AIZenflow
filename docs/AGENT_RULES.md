# Agent Rules (Short, Mandatory)

## Purpose
This file is the short mandatory rule set for iOS coding work in this worktree.

Use `docs/IOS_ARCHITECTURE_REFERENCE.md` as **reference**, not as a mechanical checklist. Use `docs/PRODUCTION_QUALITY_GATES.md` and `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` as mandatory quality gates/checklists for implementation, refactor, and review work.

## Core Decision Rule
Always choose the **simplest correct solution** that matches:
1. existing project architecture
2. runtime correctness
3. maintainability and readability
4. product fit

Do not add abstractions unless they solve a concrete current problem.

This rule does not permit skipping required architecture. The simplest correct solution must still include the required project structure, composition root, coordinator/router boundary, explicit state ownership, error handling, accessibility, localization, and verification appropriate to the feature.

## Model Routing Rule
- Apply `./docs/MODEL_ROUTING_RULE.md` before implementation, planning, review, and package-adoption work.
- The assistant is authorized to choose the model for each task and adjust the routing when risk changes; if Zenflow/UI does not allow the assistant to switch the primary model directly, tell the user when a manual switch is needed.
- Preferred balance: `GPT-5.6 sol` or `GPT-5.5` for normal work, `GPT-5.6 tera` only for highest-risk gates, and `GPT-5.6 luna` only for low-risk mechanical/read-only work.
- Before editing code or documentation, classify the task as `GPT-5.5 Planning Required`, `GPT-5.4 Execution Only`, `GPT-5.4 Execution + GPT-5.5 Final Review`, or `GPT-5.5 Full Task Required`, with 3–5 bullets.
- Use `GPT-5.4` for approved-plan, low-risk execution only. Escalate to `GPT-5.5` when architecture, persistence, concurrency, navigation, state ownership, public APIs, security/privacy, data loss, sync, performance-sensitive SwiftUI, package adoption, Xcode integration, or app-wide behavior is involved.
- In sessions where the primary assistant is already `GPT-5.5`, use `GPT-5.4` only through available subagents/tools when it is actually suitable and resource-saving; do not lower quality to save limits.


## Filesystem Sandbox Rule
- All project work must stay inside `/Users/Artem/.zenflow`.
- Never write build artifacts, package caches, Xcode DerivedData, cloned package state, logs, temporary package verification output, or project traces outside `/Users/Artem/.zenflow`.
- Before running tools that normally use global caches or DerivedData, override their output/cache paths to `/Users/Artem/.zenflow/...`.
- Do not use `/Users/Artem/Library`, `/tmp`, global SwiftPM/Xcode caches, or any other external location for project work.
- The only allowed external filesystem action is cleanup/removal of previously created project traces inside `/Users/Artem/.zenflow` when the user explicitly requests it.


## Product-Staff Quality Bar Rule
- Never lower the engineering bar because a project is described as demo, test, sample, prototype, imported, or pre-production; those words may only describe configuration/risk context, not code quality.
- Treat every authored or reviewed code path as product-staff-level production code: correct ownership, explicit state, clear failure behavior, performance-aware rendering, privacy-safe logging, accessibility, localization, and supportable verification.
- Do not defer coordinator/router setup, app composition, physical file structure, feature state ownership, model boundaries, or view reaction rules because the current app is small. Small apps get smaller feature scope, not lower engineering standards.
- Any project uses the highest reusable standards and best current rules by default until the user explicitly approves a narrower local exception.
- Do not wait for Instruments/profilers before fixing statically obvious performance or memory issues. Use profiling to prove behavior, compare alternatives, or validate non-obvious risks, not as an excuse to leave avoidable redraws, broad invalidation, main-thread work, unbounded caches, or lifecycle leaks.
- Maximize quality through the simplest correct design: improve hot paths, state ownership, and error handling without adding decorative protocols, wrappers, factories, use cases, or interfaces.


## Audit / Planning Scope Rule
- When the user asks to review, audit, inspect a project/code area, evaluate requirements, or plan a task, provide the fullest unbiased high-quality analysis available, even for very small code.
- Do not silently simplify, defer, dismiss, or complicate scope on the user's behalf. The assistant must surface the full relevant concern set and let the user decide what to execute.
- Always prioritize findings and recommendations as `must do now`, `should do next`, `later / only if needed`, and `do not do / overengineering for this scope` where applicable.
- If a concern is intentionally not investigated, state it as an explicit remaining risk; never imply it is irrelevant because the project is small, early, demo-like, or because the assistant judged it unnecessary.
- During implementation, only execute the scope the user approved, but keep unexecuted review/planning concerns visible as remaining risks or backlog candidates.

## Context-Reset Bootstrap Rule
- After a new chat/context reset, re-read the required bootstrap docs **once** before coding.
- Do not repeatedly re-read the same full set during the same chat unless architecture/rules changed.
- After Level 0 startup, apply `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md` and read only the task-relevant standards, prompts, skills, package docs, and deep references.
- Treat `./docs/README.md` as an index/map, not an instruction to load every listed document.
- Use the transition prompt from `docs/WORK_CONTINUITY.md` to keep bootstrap consistent.
- If the user asks to refresh documentation state, re-read Level 0 and the currently selected route, then treat that read as the new current baseline.
- For every context-transfer prompt, include the rule to **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
- Apply `docs/CURRENT_USER_OVERRIDES.md` before general project defaults.

## Prompt Preset Rule
- Reusable prompt presets live in `docs/agent-prompts/`.
- Before using an imported prompt preset, read `docs/agent-prompts/README.md` and apply its project overrides.
- Imported prompts are workflow templates, not authority over project/task rules.
- If a preset conflicts with active docs, task rules, or explicit user instruction, follow the higher-priority project/task/user rule.
- When work starts from Figma, when the user provides a Figma link, or when the task says to inspect/implement a Figma design through MCP, read `./docs/agent-prompts/figma-mcp-swiftui-implementation.md` before using Figma MCP or changing code. That prompt is mandatory for Figma → SwiftUI work and reinforces native SwiftUI, existing DesignSystem usage, pre-code analysis, Figma mismatch reporting, and no web-code generation.

## Global vs Project Knowledge Rule
- Durable reusable agent-used docs/rules/prompts/skills/templates belong in the GitHub repository `MArtem/AIZenflowDocumentation`.
- `/Users/Artem/.zenflow/worktrees/documentation-vault` is the local checkout of that repository, not a separate source of truth.
- Global documentation work is complete only after the matching `documentation-vault` changes are committed and pushed to `https://github.com/MArtem/AIZenflowDocumentation`.
- Keep reusable docs and app-specific docs separated in the checkout: `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/` for shared material and `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/<AppName>/` for app snapshots.
- Apply `./docs/DOCUMENT_BOUNDARY_STANDARD.md` before changing documentation, prompts, skills, package docs, architecture-case docs, app docs, or task handoffs.
- Use `./docs/SOURCE_OF_TRUTH_MAP.md` to decide where every durable rule, app decision, task state, package contract, prompt, skill, or temporary note belongs.
- When changing a durable reusable rule or prompt, update and push `MArtem/AIZenflowDocumentation` before reporting completion; do not create per-task full-library copies.
- Reusable cross-project rules and prompts live in `docs/knowledge/global/`.
- App-specific rules, contracts, paths, entities, and current task context live in an app-specific knowledge folder or in the canonical docs indexed there.
- When a new project starts, create a new sibling project folder under `docs/knowledge/` and keep app-specific knowledge out of `global`.
- Local app exceptions never weaken reusable rules automatically. Promote a local exception to reusable only after explicit user approval and app-neutral rewriting.
- Never copy one app's docs into another app as baseline. Read another app's docs only when the user explicitly asks for cross-app reference.


## Package Documentation Rule
- Every reusable package must have a complete package-level `README.md` before adoption or publication. The README must explain purpose, solved problem, capabilities, when to use/not use, ownership boundary, products/targets, local SwiftPM usage, remote SwiftPM usage, source-only integration notes, basic usage, verification, and related docs.
- Keep `./PackagesForReuse/PACKAGE_CATALOG.md` updated whenever a reusable package or integration helper is added, removed, renamed, or its purpose/products change.
- If the package is active in an app target, also update `./PackagesInUse/PACKAGE_CATALOG.md`, `./PackagesInUse/README.md`, and the active package README.
- Reusable package docs mirrored for all tasks must stay current under `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/package-vault-docs` and pushed to `MArtem/AIZenflowDocumentation`.
- Do not create or adopt a package with only a placeholder README unless the user explicitly approves a temporary exception and the follow-up is recorded.

## ViewModel Intent API Rule
- ViewModels expose explicit intent methods by default, e.g. `loginTapped()`, `refreshRequested()`, `articleTapped(id:)`, `logoutTapped()`.
- Do not add or keep generic `send(_ action:)`, `dispatch(_:)`, or UI action-enum dispatch as default MVVM boilerplate.
- Reducer/action architecture requires explicit user approval and an ADR/state-machine rationale.
- Apply `./docs/IOS_MVVM_INTENT_API_STANDARD.md` when creating or reviewing ViewModel APIs.

## Mandatory Priorities
1. Architecture correctness first.
2. Production quality gates second: performance hot paths, state invalidation, persistence/network side effects, memory/cache/media, security/privacy, failure states.
3. Production code review checklist third: UI hot path, state ownership, DB access pattern, networking boundary, concurrency, memory/cache, naming/domain purity, persistence migration risk, verification scope, and no speculative abstractions.
4. Overengineering check fourth.
5. Minimal safe change for small tasks.
6. Explicit ownership boundaries (app vs package vs extension).

## Practical Defaults
- Prefer existing project style and naming.
- Keep API surface minimal.
- Keep state ownership explicit.
- For any SwiftUI child view, default to narrow immutable `ViewState` plus explicit callbacks; add a dedicated model/view model only for a concrete independent lifecycle, async/subscription/resource ownership, transactional editing, isolated retry/error behavior, or cross-feature reusable contract.
- Use protocol seams only at real boundaries, not for every type.
- Use UseCase/Application Service only when there is real multi-step business flow.
- Keep DTO/Domain/UI boundaries clear where they already exist.

## Avoid by Default
- Massive ViewModel / God Manager.
- Pattern-for-pattern usage.
- New Factory/Builder/Adapter layers without real pressure.
- Per-view models/view models that only mirror parent state or exist for architectural symmetry.
- Spreading business logic across View + ViewModel + Repository accidentally.


## Mandatory Production Checklist Rule
- Before any non-trivial implementation, refactor, cleanup, or review, apply `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`.
- The checklist is not optional for reviews: findings must cover runtime correctness, hot paths, state ownership, persistence/network side effects, memory/cache/media, security/privacy, and verification gaps.
- If a checklist area is irrelevant, say why in the completion report.
- If ownership, state flow, product behavior, or persistence/network policy is unclear, stop and ask the user before implementing.

## Forbidden Pattern Stop List Rule
- Treat the stop list in `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` as blocking by default.
- Do not introduce or keep forbidden patterns unless there is a documented current technical constraint and the user accepts the tradeoff.
- Especially forbidden without explicit justification: source-split domain/UI naming such as `Local*`, synchronous media/file work in SwiftUI render paths, whole view models in repeated rows, fetch-all/save-all for single-item interaction updates, silent stub/demo fallbacks, and production UI backed by stub JSON.



## iOS Production Standards Rule
- Use `./docs/IOS_PRODUCTION_FRAMEWORK.md` as the umbrella framework for generic iOS production work. Use `./docs/IOS_AGENT_PROMPT_ROUTER.md` to select prompt/skill routes when scope is broad or ambiguous.
- For production-readiness, release, security/privacy, accessibility, observability, testing strategy, API integration, data migration, design-system, CI/CD, or dependency questions, apply the corresponding `./docs/IOS_*`, `./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`, `./docs/DESIGN_SYSTEM_GOVERNANCE.md`, `./docs/CI_CD_QUALITY_GATES.md`, and `./docs/DEPENDENCY_POLICY.md` standards.
- For any feature declared done, apply `./docs/DEFINITION_OF_DONE.md`.
- For broad iOS production audits, prefer the reusable iOS skills under `./.codex/skills/ios-*` when they are available in the session.

## Production Review Trigger Rule
- When the user says `ревью`, `review`, `code review`, `аудит`, or asks whether a change is production-ready, run `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`.
- Use the prompt in `./docs/agent-prompts/production-review-completeness.md`.
- Do not narrow the review to the latest bug unless the user explicitly limits scope.
- Do not say “всё ок”, “готово”, “clean”, or “production-ready” unless every relevant gate is checked, marked not applicable with a reason, or reported as remaining risk.


## Product / Process Governance Rule
- Apply `./docs/AGENT_PREFLIGHT_CHECKLIST.md` before non-trivial implementation, refactor, documentation migration, package adoption, review, or new project/task bootstrap.
- Use `./docs/NEW_PROJECT_START_CONTRACT.md` before creating or bootstrapping a new project, task, or worktree.
- Apply `./docs/SECRET_HANDLING_AND_SECURITY_INTAKE_STANDARD.md` before creating, importing, auditing, or remediating a project that may contain local secrets; `.gitignore` is required but not sufficient because AI-readable workspace exposure is a separate risk.
- When creating or bootstrapping a new task, project, worktree, Xcode project, or app through Codex app, create and maintain the task plan/handoff and app-specific documentation boundaries automatically; do not wait for the user to explicitly request them.
- If one task contains multiple Xcode projects/apps, keep each project's app-specific docs, ADRs, plans, local rules, histories, and exceptions separate under its own app root.
- Before implementing non-trivial feature behavior, apply `./docs/PRODUCT_REQUIREMENTS_STANDARD.md`; do not guess acceptance criteria, empty/error/offline states, rollout behavior, analytics, accessibility, or localization requirements.
- If a decision changes architecture, public API, persistence, security/privacy, release behavior, or cross-team ownership, apply `./docs/ARCHITECTURE_DECISION_GOVERNANCE.md` and record the decision before coding.
- If a project intentionally violates a reusable rule, record it with `./docs/LOCAL_EXCEPTION_ADR_TEMPLATE.md` in app/task-specific docs. Do not promote it globally without explicit user approval.
- Use `./docs/CODE_OWNERSHIP_AND_REVIEW_POLICY.md` to decide required review scope and blocked-change criteria.
- Track intentional shortcuts in `./docs/TECH_DEBT_REGISTER.md` and material risks in `./docs/RISK_REGISTER.md`; untracked debt is not an acceptable production tradeoff.

## Evidence-Based Completion Rule
- Apply `./docs/COMPLETION_REPORT_CONTRACT.md` before any meaningful completion report.
- Apply `./docs/TASK_STATE_DOCUMENTATION_STANDARD.md` before changing `plan.md`, `handoff.md`, task archives, or task recovery snapshots.

## Result Model And Context Reporting Rule
- After every meaningful step, task, review, implementation block, or completion report, include a `Результат` block or equivalent concise summary that states which model(s) worked and what each one did.
- If only the primary assistant model worked, state that explicitly, for example: `GPT-5.5 — reviewed/implemented/verified the block`.
- If subagents or lower-cost models were used, list each model separately with its role, scope, and output.
- In the same result block, assess whether the current chat/context should be refreshed or replaced with a new chat. State one of: `контекст обновлять не нужно`, `желательно обновить контекст`, or `нужен новый чат`, with a short reason.
- For meaningful work, include the selected documentation route: `Docs route: Level 0 + <task-specific route>`.
- Do not hide context risk: recommend a new chat proactively when context size, phase changes, stale rules, or accumulated history can reduce reliability.
- Apply `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md` before saying a task is done, production-ready, verified, fixed, faster, safe, or clean.
- Claims must cite evidence: affected files, command output, static proof, build/test/profiler/manual validation, or explicit remaining risk.
- If a claim cannot be proven in the current environment, report it as unverified instead of implying confidence.

## Enterprise iOS Coverage Rule
- For any large or production-critical iOS app area, consider the full enterprise coverage set: modular architecture, developer experience, QA plan, localization/internationalization, Apple platform capabilities, data governance/compliance, compatibility matrix, release, incidents, SLOs, feature flags, risks, and tech debt.
- Use `./docs/MODULAR_ARCHITECTURE_STANDARD.md`, `./docs/DEVELOPER_EXPERIENCE_STANDARD.md`, `./docs/QA_TEST_PLAN_STANDARD.md`, `./docs/LOCALIZATION_INTERNATIONALIZATION_STANDARD.md`, `./docs/APPLE_PLATFORM_CAPABILITIES_STANDARD.md`, `./docs/DATA_GOVERNANCE_AND_COMPLIANCE.md`, and `./docs/COMPATIBILITY_MATRIX.md` when relevant.
- Production readiness is not only code correctness: it includes operability, rollback, observability, QA, supportability, compliance, and maintainability.

## Static Quality Gate Scripts Rule
- Use `./scripts/check_docs_index.py` after documentation index changes.
- Use `./scripts/check_documentation_remote_state.py` before claiming global documentation changes are complete.
- Use `./scripts/check_forbidden_patterns.py`, `./scripts/check_swiftui_hot_path_patterns.py`, `./scripts/check_secrets.py`, `./scripts/check_large_files.py`, and `./scripts/check_localization.py` as lightweight pre-review gates when their scope matches the task.
- Use `./scripts/run_static_quality_gates.sh` before broad production review/completion when the expected warnings are understood. If it reports pre-existing issues, classify them instead of silently ignoring them.
- Interpret static gate findings through `./docs/STATIC_QUALITY_GATE_POLICY.md`: hard fail, warning, review candidate, or allowed exception.


## Generic iOS Coverage Rule
- Inline Swift/iOS code documentation must follow `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`: if the user asks to add or improve project documentation/comments without naming exact files, cover every logically significant executable file in the project. Document contracts, ownership/lifecycle, external usage/call context, side effects, concurrency, errors, invariants, and rationale where relevant; do not document obvious code mechanically.
- For any iOS implementation/review, consider generic iOS concerns before app-specific assumptions: concurrency/runtime, memory/cache/media, UI state/rendering, network resilience, offline/sync, lifecycle/background, error handling, analytics/telemetry, configuration/environments, input validation/content safety, StoreKit/payments when applicable, and platform permissions.
- Apply these documents when relevant: `./docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md`, `./docs/IOS_MEMORY_CACHE_MEDIA_STANDARD.md`, `./docs/IOS_UI_STATE_RENDERING_STANDARD.md`, `./docs/IOS_NETWORK_RESILIENCE_STANDARD.md`, `./docs/IOS_OFFLINE_SYNC_STANDARD.md`, `./docs/IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md`, `./docs/IOS_ERROR_HANDLING_USER_FEEDBACK_STANDARD.md`, `./docs/IOS_ANALYTICS_TELEMETRY_TAXONOMY.md`, `./docs/IOS_CONFIGURATION_ENVIRONMENTS_STANDARD.md`, `./docs/IOS_INPUT_VALIDATION_CONTENT_SAFETY_STANDARD.md`, `./docs/IOS_STOREKIT_PAYMENTS_STANDARD.md`, and `./docs/IOS_CAMERA_PHOTOS_FILES_PERMISSIONS_STANDARD.md`.
- If a concern is not applicable, mark it not applicable with a reason instead of silently skipping it.
- For full production readiness claims, fill or summarize `./docs/IOS_PRODUCTION_SCORECARD.md`; any score below production threshold must be reported as remaining risk.

## Project-Calibrated Working Rules
1. Runtime code has priority over test-debt cleanup unless task explicitly says otherwise.
2. Do not introduce app-local wrappers around reusable package APIs when one direct call is enough.
3. SwiftUI composition details are governed by `.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`; do not duplicate conflicting local style rules.
4. Treat unnecessary redraw/invalidation risk as high-priority; prefer narrow-input subviews and explicit render boundaries.
5. Keep share-extension/app boundaries explicit: shared storage + sync point, no hidden runtime coupling.
6. Keep feed/composer card contract stable (`text/photo/video/audio/pdf`) unless product contract explicitly changes.
7. ViewModel interaction style must follow `.zenflow/tasks/new-task-be0b/ios-engineering-rules.md` (`@MainActor`, `@Observable`, explicit state + intents, no generic `send(action)` default).
8. Before any new abstraction, document one concrete current pain-point it solves in the PR/task notes.
9. UI/design tasks must follow `docs/UI_PIXEL_PERFECT_WORKFLOW.md`.
10. Content/feed/card persistence work must follow the active product contract for the current app.
11. Any non-trivial implementation, review, or refactor must apply `docs/PRODUCTION_QUALITY_GATES.md` and `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`; if a gate/checklist area is not relevant, state that explicitly in the completion report.
12. Never close a review as clean when runtime hot-path risks, broad invalidation, main-thread I/O, unbounded memory/cache behavior, unsafe persistence/network side effects, missing failure states, naming/domain impurity, or forbidden-pattern violations remain unchecked.

## Size Heuristic
- Small UI/bugfix task: minimal focused patch inside the established architecture.
- Architecture/runtime task: use reference guidance to choose boundaries and responsibilities.
- New app or new feature area: create the production-shaped skeleton first, including physical structure, composition, navigation/coordinator, state ownership, and error/loading/empty state strategy.

## Related
- `docs/IOS_ARCHITECTURE_REFERENCE.md`
- `docs/PRODUCTION_QUALITY_GATES.md`
- `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`
- `docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`
- `docs/IOS_PRODUCTION_READINESS_STANDARD.md`
- `docs/DEFINITION_OF_DONE.md`
- `.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`
- `.zenflow/tasks/new-task-be0b/services-engineering-rules.md`


## New Chat / Context Transfer Rule
- Proactively recommend moving to a new chat when context size, phase changes, interruptions, or accumulated history make continuity risky.
- Provide a compact handoff spec before transfer.
- Apply `./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md`.
