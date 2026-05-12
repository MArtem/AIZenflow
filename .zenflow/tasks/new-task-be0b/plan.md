# Current Plan

## Goal
Keep a short task-local snapshot for the active three-part cleanup/refactor plan after the completed runtime restoration.

## Active Steps
1. Phase 1: continue auditing working runtime code for architectural mistakes and unnecessary indirection
2. Phase 1: remove only safe overengineering in app/runtime/package layers
3. Phase 1: do not touch `TchopAppTests` during this pass
4. Phase 2: after Phase 1 finishes, execute the SwiftUI view decomposition pass:
   remove `private var ...: some View` and `@ViewBuilder private func ... -> some View` helpers inside `View` types, replacing them with explicit extracted `View`/renderer/builder types
5. Phase 3: after Phase 2 finishes, execute the saved `ViewModel` standardization plan toward `@Observable + explicit state container + explicit intent methods`
6. After all three phases, return to runtime validation against the share matrix in `docs/SHARE_EXTENSION_VALIDATION.md`


## Current Phase Status
- Phase 1 is in progress.
- Latest safe simplification pass: removed redundant local alias indirection in repository runtime methods and one redundant optional unwrap path in feed loading state transition.
- Continuity rule updated: added a universal new-chat transition prompt template in `docs/WORK_CONTINUITY.md` and documented its canonical placement in `docs/README.md`.
- Response-format rule updated: added explicit active-model header requirement in `.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`, aligned with `/Users/Artem/.zenflow/assistant/docs/model-routing-policy.md`.
- Runtime ownership cleanup: moved `FeedComposerInsertion.textFieldKind` mapping from `AppShellViewModel` layer to `NewsFeedModels` (model layer) to remove decorative cross-layer coupling.
- Added architecture-guidance docs split:
  - short mandatory rules in `docs/AGENT_RULES.md`
  - long reference usage in `docs/IOS_ARCHITECTURE_REFERENCE.md`
  - canonical placement/read-order updated in `docs/README.md`
- Next target in Phase 1: continue runtime-only audit for decorative seams in feed/composer/repository ownership without touching tests.

## Working Rule
- Keep this file short and current.
- Do not use it as a history log.

## Archive
Detailed historical plans are preserved only in:
- [.zenflow/tasks/new-task-be0b/archive/plan.legacy.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/archive/plan.legacy.md)
