# Agent Rules (Short, Mandatory)

## Purpose
This file is the short mandatory rule set for coding work in `TchopApp`.

Use `docs/IOS_ARCHITECTURE_REFERENCE.md` as **reference**, not as a mechanical checklist.

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

## Mandatory Priorities
1. Architecture correctness first.
2. Overengineering check second.
3. Minimal safe change for small tasks.
4. Explicit ownership boundaries (app vs package vs extension).

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

## Project-Calibrated Working Rules (TchopApp)
1. Runtime code has priority over test-debt cleanup unless task explicitly says otherwise.
2. Do not introduce app-local wrappers around reusable package APIs when one direct call is enough.
3. SwiftUI composition details are governed by `.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`; do not duplicate conflicting local style rules.
4. Treat unnecessary redraw/invalidation risk as high-priority; prefer narrow-input subviews and explicit render boundaries.
5. Keep share-extension/app boundaries explicit: shared storage + sync point, no hidden runtime coupling.
6. Keep feed/composer card contract stable (`text/photo/video/audio/pdf`) unless product contract explicitly changes.
7. ViewModel interaction style must follow `.zenflow/tasks/new-task-be0b/ios-engineering-rules.md` (`@MainActor`, `@Observable`, explicit state + intents, no generic `send(action)` default).
8. Before any new abstraction, document one concrete current pain-point it solves in the PR/task notes.

## Size Heuristic
- Small UI/bugfix task: minimal focused patch.
- Architecture/runtime task: use reference guidance to choose boundaries and responsibilities.

## Related
- `docs/IOS_ARCHITECTURE_REFERENCE.md`
- `.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`
- `.zenflow/tasks/new-task-be0b/services-engineering-rules.md`
