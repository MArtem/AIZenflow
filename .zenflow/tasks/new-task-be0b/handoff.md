# Handoff

## Current Status
- Project: `TchopApp`
- Worktree: `/Users/Artem/.zenflow/worktrees/new-task-be0b`
- Build state: app builds successfully
- Active track: Phase 1 runtime architecture/simplification audit (working code only)

## Resume Read Order (One-Time)
1. `docs/README.md`
2. `PROJECT_DOCUMENTATION.md`
3. `PROJECT_HEALTH.md`
4. `docs/WORK_CONTINUITY.md`
5. this file
6. `.zenflow/tasks/new-task-be0b/plan.md`

## Restored Runtime Snapshot
- Runtime taxonomy and contract restored: `text/photo/video/audio/pdf`.
- Composer/feed alignment restored, including non-photo media parity.
- Local published cards run through feed-native models/store.
- Share-extension foundation is wired and builds:
  - `TchopShareSupport` storage/import root
  - `SharedLocalFeedCardSyncManager` bridge (sync on activation + pull-to-refresh)
  - shared composer (`SharedCardComposerView`) used by app and extension.
- Translation feed-stage exists; detail-stage still open.

## Current Contract (Short)
- Card kinds: `text`, `photo`, `video`, `audio`, `pdf`
- Text fields: `text`, `headline`, `subheadline`, `source`
- Draft rules:
  - empty draft forbidden
  - without media, `text` required
  - with media, optional text fields may be removed
- Media rules:
  - `photo` up to 10
  - `video/audio/pdf` single + mutually exclusive
  - non-photo media may have teaser

## Current Next Work
1. Finish Phase 1 runtime audit and safe simplifications.
2. Then Phase 2 SwiftUI decomposition (remove view-returning helpers inside `View`).
3. Then Phase 3 ViewModel standardization.
4. After phases: manual validation via `docs/SHARE_EXTENSION_VALIDATION.md`.

## Important Files
- `TchopApp/ViewModels/AppShellViewModel.swift`
- `TchopApp/ViewModels/NewsFeedViewModel.swift`
- `TchopApp/Models/NewsFeedModels.swift`
- `TchopApp/Views/News/NewsFeedView.swift`
- `TchopApp/Views/Composer/SharedCardComposerView.swift`
- `TchopApp/Repositories/AppContentRepository.swift`
- `TchopApp/Shared/SharedLocalFeedCardSyncManager.swift`
- `Packages/TchopInfrastructure/Sources/TchopShareSupport/TchopShareSupport.swift`
- `Packages/TchopInfrastructure/Sources/TchopShareSupport/ShareItemImporter.swift`

## Verification Baseline
- Use `TESTING_INSTRUCTIONS.md` when verification is requested.
- Last confirmed build command: `./scripts/verify.sh low`
- Last confirmed result: `BUILD SUCCEEDED`

## Archive
Detailed historical handoff is preserved in:
- `.zenflow/tasks/new-task-be0b/archive/handoff.legacy.md`
