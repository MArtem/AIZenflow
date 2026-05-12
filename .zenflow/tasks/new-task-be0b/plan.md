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
- Extended `docs/AGENT_RULES.md` with 8 project-calibrated practical rules for TchopApp runtime work.
- Documentation optimization pass:
  - added one-time post-reset bootstrap rule in `docs/README.md`
  - added same rule to `docs/WORK_CONTINUITY.md` and transition prompt template
  - added context-reset bootstrap requirement in `docs/AGENT_RULES.md`
- Documentation compression pass:
  - rewrote `docs/README.md` into a shorter canonical map with the same placement/hierarchy semantics
  - rewrote `docs/WORK_CONTINUITY.md` into a compact resume artifact with the same phase/baseline/contracts focus
- Compressed `.zenflow/tasks/new-task-be0b/handoff.md` into a short operational resume artifact aligned with continuity docs.
- Final docs polish:
  - removed duplicate SwiftUI/ViewModel rule wording from `docs/WORK_CONTINUITY.md` transition template and delegated to task overlay rule files
  - aligned `docs/AGENT_RULES.md` with overlay-rule ownership to avoid policy drift
- Phase 1 runtime cleanup:
  - removed unused decorative `sharedLocalFeedCardStore` passthrough property from `TchopApp/ViewModels/AppShellViewModel.swift`
  - verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`
- Phase 1 runtime cleanup (no-build safe pass):
  - removed unused translation helpers `canTranslate(_:)` and `translatedText(...)` from `TchopApp/ViewModels/NewsFeedViewModel.swift`
  - build was intentionally not run for this tiny isolated deletion-only cleanup per the verification policy reminder
- Phase 1 runtime cleanup (SwiftData-only simplification):
  - in `TchopApp/Repositories/AppContentRepository.swift`, removed runtime `#available(iOS 17, *)` branch indirection in three read paths
  - channel fetch, persisted feed snapshot fetch, and persisted card-state map now resolve directly through the active SwiftData runtime path
  - no build run in this step (policy: run only when verification is necessary)
- Phase 1 alignment cleanup:
  - updated nearby repository comments to match the new SwiftData-only active read-path semantics and remove stale “selected backend” wording
- Phase 1 indirection cleanup:
  - removed `fetchChannelsFromCurrentBackend()` and `fetchPersistedFeedSnapshotFromCurrentBackend()` wrappers in `TchopApp/Repositories/AppContentRepository.swift`
  - call sites now use direct SwiftData read-path methods
  - no build run for this small structural simplification step
- Phase 1 dead-path cleanup:
  - removed now-unreachable CoreData-only read helpers `fetchCoreDataCardStateMap(...)` and `fetchCoreDataFeedSnapshot(...)` from `TchopApp/Repositories/AppContentRepository.swift`
  - these methods no longer participated in active runtime after SwiftData-path simplification
  - no build run for this deletion-only cleanup
- Phase 1 dead-path cleanup (continued):
  - removed unused full-snapshot sync helpers `syncSwiftDataFeedCards(...)` and `syncCoreDataFeedCards(...)` from `TchopApp/Repositories/AppContentRepository.swift`
  - sync flow already uses `FeedPersistenceSyncLocalStore.applySnapshots(...)`; deleted helpers had no call sites
  - no build run for this deletion-only cleanup
- Next target in Phase 1: continue runtime-only audit for decorative seams in feed/composer/repository ownership without touching tests.

## Working Rule
- Keep this file short and current.
- Do not use it as a history log.

## Archive
Detailed historical plans are preserved only in:
- [.zenflow/tasks/new-task-be0b/archive/plan.legacy.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/archive/plan.legacy.md)
