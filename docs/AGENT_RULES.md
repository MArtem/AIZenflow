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

## Size Heuristic
- Small UI/bugfix task: minimal focused patch.
- Architecture/runtime task: use reference guidance to choose boundaries and responsibilities.

## Related
- `docs/IOS_ARCHITECTURE_REFERENCE.md`
- `.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`
- `.zenflow/tasks/new-task-be0b/services-engineering-rules.md`
