# Current Plan

## Goal
Continue runtime cleanup with safe simplification while preserving current behavior.

## Active Steps
### [x] Step: Phase 3 batch 1 — ViewModel safe cleanup (`./TchopApp/ViewModels/AppShellViewModel.swift`, `./TchopApp/ViewModels/NewsFeedViewModel.swift`)
### [x] Step: Phase 3 batch 2 — remaining non-view cleanup candidates
### [x] Step: Keep tests untouched (`./TchopAppTests`) — skipped by request (tests remain untouched)
### [x] Step: Manual share-extension runtime validation (`./docs/SHARE_EXTENSION_VALIDATION.md`) — skipped by request
### [x] Step: Package review 1 — `./Packages/TchopInfrastructure/Sources/TchopDatabaseCore`
### [ ] Step: Package review 2 — `./Packages/TchopInfrastructure/Sources/TchopDatabaseComposition`
### [ ] Step: Package review 3 — `./Packages/TchopInfrastructure/Sources/TchopSwiftDataDatabase`
### [ ] Step: Package review 4 — `./Packages/TchopInfrastructure/Sources/TchopCoreDataDatabase`
### [ ] Step: Package review 5 — `./Packages/TchopInfrastructure/Sources/TchopDatabase`
### [ ] Step: Package review 6 — `./Packages/TchopInfrastructure/Sources/TchopNetworking`
### [ ] Step: Package review 7 — `./Packages/TchopInfrastructure/Sources/TchopErrors`
### [ ] Step: Package review 8 — `./Packages/TchopInfrastructure/Sources/TchopCache`
### [ ] Step: Package review 9 — `./Packages/TchopInfrastructure/Sources/SyncCore`
### [ ] Step: Package review 10 — `./Packages/TchopInfrastructure/Sources/TchopNavigation`
### [ ] Step: Package review 11 — `./Packages/TchopInfrastructure/Sources/TchopLocalization`
### [ ] Step: Package review 12 — `./Packages/TchopInfrastructure/Sources/TchopUIConfiguration`
### [ ] Step: Package review 13 — `./Packages/TchopInfrastructure/Sources/TchopPushNotifications`
### [ ] Step: Package review 14 — `./Packages/TchopInfrastructure/Sources/TchopOnDeviceAI`
### [ ] Step: Package review 15 — `./Packages/TchopInfrastructure/Sources/TchopShareSupport`
### [ ] Step: Package review 16 — `./Packages/TchopInfrastructure/Sources/TchopBranding`
### [ ] Step: Package review 17 — `./Packages/TchopInfrastructure/Sources/TchopWidgets`
### [ ] Step: Package review 18 — `./Packages/TchopInfrastructure/Sources/TchopAnalytics`
### [ ] Step: Package review 19 — `./Packages/TchopInfrastructure/Sources/TchopAppleAuthentication`

## Current Status
- Completed audit: `./TchopApp/Navigation/DeepLinkManager.swift` safe-pass (removed decorative route-definition table and switched to direct root-segment dispatch).
- Completed audit: `./TchopApp/Services/UserSessionService.swift` safe-pass (deduplicated token-backed sign-in flow via shared session persistence helpers).
- Completed audit: `./TchopApp/Persistence/AppDatabase.swift` safe-pass (removed unused non-throwing bootstrap wrapper and dead debug-description helper).
- Completed audit: `./TchopApp/Services/FeedAPIManager.swift` safe-pass (cached ISO8601 formatters and clarified mutation-path id parsing naming).
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
- Checkpoint: Phase 1 runtime cleanup is complete and aligned with `./.zenflow/tasks/new-task-be0b/handoff.md`.
- Completed now: `./TchopApp/Views/News/NewsFeedView.swift` safe decomposition pass (extracted content-section rendering and unified repeated local file-card wrappers without changing feed behavior).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` safe decomposition pass (extracted repeated media surfaces/items and unified repeated file-media presentation logic without changing composer rules).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Views/Auth/LoginScreenView.swift` safe decomposition pass (replaced decorative `AnyView` sections with explicit subviews and centralized login field appearance helpers without changing auth behavior).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: shell/container SwiftUI pass across `./TchopApp/Views/TopBarView.swift`, `./TchopApp/Views/Menu/SideMenuView.swift`, `./TchopApp/Views/ShellContentView.swift`, and `./TchopApp/Views/TabContentView.swift` (extracted local subviews, reduced repeated chrome/menu wiring, and kept runtime behavior unchanged).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: root/profile SwiftUI pass across `./TchopApp/Views/AppRootView.swift`, `./TchopApp/Views/AppShellView.swift`, and `./TchopApp/Views/Tabs/ProfileTabRootView.swift` (extracted session/menu helpers, centralized repeated menu constants, and isolated profile binding/error rendering without changing behavior).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: visual/card SwiftUI pass across `./TchopApp/Views/News/PhotoCardView.swift`, `./TchopApp/Views/News/TextCardView.swift`, and `./TchopApp/Views/Tabs/FeatureTabScaffoldView.swift` (extracted local hero/content/action sections, reduced repeated card wiring, and kept card behavior unchanged).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: remaining small-surface SwiftUI pass across `./TchopApp/Views/Tabs/FeatureTabScaffoldView.swift`, `./TchopApp/Views/Tabs/MixesTabRootView.swift`, `./TchopApp/Views/Tabs/PinnedTabRootView.swift`, `./TchopApp/Views/Tabs/ChatTabRootView.swift`, `./TchopApp/Views/Tabs/BottomTabBar.swift`, `./TchopApp/Views/BrandMarkView.swift`, and `./TchopApp/Views/Stub/TabStubView.swift` (consolidated repeated feature-tab navigation wiring and extracted residual local view sections without changing behavior).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Next focus: checkpoint Phase 2 coverage, summarize remaining non-view cleanup candidates, and leave manual share-extension validation pending.
- Interactive share validation tracker: `./.zenflow/tasks/new-task-be0b/share-extension-validation-report.md`.
- Completed now: `./TchopApp/ViewModels/AppShellViewModel.swift` (deduplicated selected channel resolution for composer initialization via shared computed property).
- Completed now: `./TchopApp/ViewModels/NewsFeedViewModel.swift` (unified repeated empty-state transitions via shared helper without behavior changes).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/ViewModels/AppShellViewModel.swift` (removed residual duplication in composer publish flow by reusing `dismissComposer()`).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./Packages/TchopInfrastructure/Sources/TchopDatabaseCore/TchopDatabaseCore.swift` (removed repeated SwiftData operation wrapping by extracting one shared helper, behavior unchanged).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.

## Working Rule
- Keep this file short and current.
- Do not use it as a history log.

## Archive
Detailed historical plans are preserved only in:
- `./.zenflow/tasks/new-task-be0b/archive/plan.legacy.md`
