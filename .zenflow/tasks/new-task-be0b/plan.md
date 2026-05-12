# Current Plan

## Goal
Continue runtime cleanup with safe simplification while preserving current behavior.

## Active Steps
1. Runtime cleanup audit: `./TchopApp/Repositories/AppContentRepository.swift`.
2. Runtime cleanup audit: app/package sync ownership around shared feed-card sync.
3. Keep tests untouched (`./TchopAppTests`).
4. Manual share-extension runtime validation remains pending via `./docs/SHARE_EXTENSION_VALIDATION.md`.

## Current Status
- Completed audit: `./TchopApp/ViewModels/NewsFeedViewModel.swift` safe-pass (reduced residual duplication in action-start guards).
- Completed audit: `./TchopApp/Models/NewsFeedModels.swift` safe-pass (consolidated repeated file-media mutation path via shared updater helper).
- Completed audit: `./TchopApp/App/AppPushNotificationBridge.swift` (deduplicated remote-registration update path and extracted authorization capability check).
- Completed audit: `./TchopApp/App/AppState.swift` (removed duplicated share-session sync call paths by consolidating authenticated-state resolution).
- Completed audit: `./TchopApp/App/AppDIContainer.swift` (no safe simplifications accepted in this pass; container wiring kept as-is).
- Completed audit: `./TchopApp/App/ChannelSettingsRepository.swift` (deduplicated default channel list constant).
- Completed audit: `./TchopApp/App/ChannelsStore.swift` (removed duplicated selected-channel resolution and reused static preferred channel order).
- Completed audit: `./TchopApp/Repositories/AppContentRepository.swift` (removed now-unused `upsertFeedCard` helper after earlier dead-code removal).
- Completed audit: `./TchopApp/ViewModels/NewsFeedViewModel.swift` (removed small runtime duplication: unified card-task cancellation path and simplified search/translation checks).
- Completed audit: `./TchopApp/Models/NewsFeedModels.swift` (removed minor import-path duplication and unreachable single-file `.image` branch).
- Completed audit: `./Packages/TchopInfrastructure/Sources/TchopShareSupport/ShareItemImporter.swift` (no safe simplifications needed; logic already direct and minimal).
- Completed audit: `./TchopApp/Shared/SharedLocalFeedCardSyncManager.swift` (no safe simplifications needed; ownership boundary already minimal).
- Completed now: removed dead private action-state persistence helpers from `./TchopApp/Repositories/AppContentRepository.swift`.
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Next focus: `./TchopApp/Services/FeedAPIManager.swift` runtime mapping/branch simplification audit.
- Interactive share validation tracker: `./.zenflow/tasks/new-task-be0b/share-extension-validation-report.md`.

## Working Rule
- Keep this file short and current.
- Do not use it as a history log.

## Archive
Detailed historical plans are preserved only in:
- `./.zenflow/tasks/new-task-be0b/archive/plan.legacy.md`
