# Current Plan

## Goal
Keep a short task-local snapshot for the active two-phase cleanup plan after the completed runtime restoration.

## Active Steps
1. Phase 1: continue auditing working runtime code for architectural mistakes and unnecessary indirection
2. Phase 1: remove only safe overengineering in app/runtime/package layers
3. Phase 1: do not touch `TchopAppTests` during this pass
4. Phase 2: after Phase 1 finishes, execute the saved `ViewModel` standardization plan toward `@Observable + explicit state container + explicit intent methods`
5. After both phases, return to runtime validation against the share matrix in `docs/SHARE_EXTENSION_VALIDATION.md`

## Working Rule
- Keep this file short and current.
- Do not use it as a history log.

## Archive
Detailed historical plans are preserved only in:
- [.zenflow/tasks/new-task-be0b/archive/plan.legacy.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/archive/plan.legacy.md)
