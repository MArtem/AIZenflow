# Current Plan

## Goal
Complete the 3-phase runtime cleanup/refactor sequence with minimal safe changes.

## Active Steps
1. Phase 1: runtime architecture/overengineering audit and safe simplification (working code only, no `TchopAppTests` changes)
2. Phase 2: SwiftUI view decomposition pass (remove view-returning helpers inside `View`, extract explicit `View`/renderer/builder types)
3. Phase 3: ViewModel standardization (`@Observable` + explicit state container + explicit intent methods)
4. After all phases: manual runtime validation via `docs/SHARE_EXTENSION_VALIDATION.md`

## Current Phase Status
- **Phase 1: completed in this pass.**
- Main result: active repository/runtime path is converged to SwiftData-only with decorative branches, dead helpers, and redundant seams removed.
- Verification baseline after high-risk refactors: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- **Phase 2: in progress.**
- Completed in this pass:
  - `TchopApp/Views/News/NewsFeedView.swift`: removed local `some View` helpers and `@ViewBuilder` card helper funcs; extracted explicit subviews/renderer types.
  - `TchopApp/Views/Composer/SharedCardComposerView.swift`: extracted header/toolbar into explicit view types.
  - `TchopApp/Views/AppRootView.swift`: extracted restoring/loading subtree into dedicated view type.
  - verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Remaining for full Phase 2 completion: `TchopApp/Views/Auth/LoginScreenView.swift` decomposition pass.

## Working Rule
- Keep this file short and current.
- Do not use it as a history log.

## Archive
Detailed historical plans are preserved only in:
- `.zenflow/tasks/new-task-be0b/archive/plan.legacy.md`
