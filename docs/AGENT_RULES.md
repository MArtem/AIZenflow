# Agent Rules (Short, Mandatory)

## Purpose
This file is the short mandatory rule set for coding work in `TchopApp`.

Use `docs/IOS_ARCHITECTURE_REFERENCE.md` as **reference**, not as a mechanical checklist. Use `docs/PRODUCTION_QUALITY_GATES.md` and `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` as mandatory quality gates/checklists for implementation, refactor, and review work.

## Core Decision Rule
Always choose the **simplest correct solution** that matches:
1. existing project architecture
2. runtime correctness
3. maintainability and readability
4. product fit

Do not add abstractions unless they solve a concrete current problem.

## Context-Reset Bootstrap Rule
- After a new chat/context reset, re-read the required bootstrap docs **once** before coding.
- Do not repeatedly re-read the same full set during the same chat unless architecture/rules changed.
- Use the transition prompt from `docs/WORK_CONTINUITY.md` to keep bootstrap consistent.
- If the user asks to refresh documentation state, re-read the active documentation set from `docs/README.md` and treat that read as the new current baseline.
- For every context-transfer prompt, include the rule to **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
- Apply `docs/CURRENT_USER_OVERRIDES.md` before general project defaults.

## Prompt Preset Rule
- Reusable prompt presets live in `docs/agent-prompts/`.
- Before using an imported prompt preset, read `docs/agent-prompts/README.md` and apply its project overrides.
- Imported prompts are workflow templates, not authority over project/task rules.
- If a preset conflicts with active docs, task rules, or explicit user instruction, follow the higher-priority project/task/user rule.

## Global vs Project Knowledge Rule
- Reusable cross-project rules and prompts live in `docs/knowledge/global/`.
- TchopApp-specific rules, contracts, paths, entities, and current task context live in `docs/knowledge/TchopApp/` or in the canonical docs indexed there.
- When a new project starts, create a new sibling project folder under `docs/knowledge/` and keep app-specific knowledge out of `global`.

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
- Use protocol seams only at real boundaries, not for every type.
- Use UseCase/Application Service only when there is real multi-step business flow.
- Keep DTO/Domain/UI boundaries clear where they already exist.

## Avoid by Default
- Massive ViewModel / God Manager.
- Pattern-for-pattern usage.
- New Factory/Builder/Adapter layers without real pressure.
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

## Project-Calibrated Working Rules (TchopApp)
1. Runtime code has priority over test-debt cleanup unless task explicitly says otherwise.
2. Do not introduce app-local wrappers around reusable package APIs when one direct call is enough.
3. SwiftUI composition details are governed by `.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`; do not duplicate conflicting local style rules.
4. Treat unnecessary redraw/invalidation risk as high-priority; prefer narrow-input subviews and explicit render boundaries.
5. Keep share-extension/app boundaries explicit: shared storage + sync point, no hidden runtime coupling.
6. Keep feed/composer card contract stable (`text/photo/video/audio/pdf`) unless product contract explicitly changes.
7. ViewModel interaction style must follow `.zenflow/tasks/new-task-be0b/ios-engineering-rules.md` (`@MainActor`, `@Observable`, explicit state + intents, no generic `send(action)` default).
8. Before any new abstraction, document one concrete current pain-point it solves in the PR/task notes.
9. UI/design tasks must follow `docs/UI_PIXEL_PERFECT_WORKFLOW.md`.
10. Local feed/card persistence work must follow `docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md`.
11. Any non-trivial implementation, review, or refactor must apply `docs/PRODUCTION_QUALITY_GATES.md` and `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`; if a gate/checklist area is not relevant, state that explicitly in the completion report.
12. Never close a review as clean when runtime hot-path risks, broad invalidation, main-thread I/O, unbounded memory/cache behavior, unsafe persistence/network side effects, missing failure states, naming/domain impurity, or forbidden-pattern violations remain unchecked.

## Size Heuristic
- Small UI/bugfix task: minimal focused patch.
- Architecture/runtime task: use reference guidance to choose boundaries and responsibilities.

## Related
- `docs/IOS_ARCHITECTURE_REFERENCE.md`
- `docs/PRODUCTION_QUALITY_GATES.md`
- `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`
- `.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`
- `.zenflow/tasks/new-task-be0b/services-engineering-rules.md`
