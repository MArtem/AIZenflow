# Current Plan

## Goal
Complete the 3-phase runtime cleanup/refactor sequence with minimal safe changes.

## Active Steps
1. Phase 1: runtime architecture/overengineering audit and safe simplification (working code only, no `TchopAppTests` changes)
2. Phase 2: SwiftUI view decomposition pass (remove view-returning helpers inside `View`, extract explicit `View`/renderer/builder types)
3. Phase 3: ViewModel standardization (`@Observable` + explicit state container + explicit intent methods)
4. After all phases: manual runtime validation via `./docs/SHARE_EXTENSION_VALIDATION.md`

## Current Phase Status
- **Phase 1:** completed.
- **Phase 2:** completed.
- **Phase 3:** completed.
- Completed now:
  - `./TchopApp/ViewModels/AppShellViewModel.swift`: explicit `State` container with intent-driven mutations preserved.
  - `./TchopApp/ViewModels/LoginViewModel.swift`: explicit `State` container added; intent methods preserved.
  - `./TchopApp/ViewModels/ProfileTabViewModel.swift`: explicit `State` container added; optimistic preference intent preserved.
- Verification after this pass: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Next active step: manual runtime validation via `./docs/SHARE_EXTENSION_VALIDATION.md`.

## Working Rule
- Keep this file short and current.
- Do not use it as a history log.

## Archive
Detailed historical plans are preserved only in:
- `./.zenflow/tasks/new-task-be0b/archive/plan.legacy.md`
