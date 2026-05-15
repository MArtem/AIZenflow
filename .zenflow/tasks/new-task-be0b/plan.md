# Current Plan

## Goal
Continue runtime cleanup with safe simplification while preserving current behavior.

## Active Steps
### [x] Step: Phase 3 batch 1 — ViewModel safe cleanup (`./TchopApp/ViewModels/AppShellViewModel.swift`, `./TchopApp/ViewModels/NewsFeedViewModel.swift`)
### [x] Step: Phase 3 batch 2 — remaining non-view cleanup candidates
### [x] Step: Keep tests untouched (`./TchopAppTests`) — skipped by request (tests remain untouched)
### [x] Step: Manual share-extension runtime validation (`./docs/SHARE_EXTENSION_VALIDATION.md`) — skipped by request
### [x] Step: Package review 1 — `./Packages/TchopInfrastructure/Sources/TchopDatabaseCore`
### [x] Step: Package review 2 — `./Packages/TchopInfrastructure/Sources/TchopDatabaseComposition`
### [x] Step: Package review 3 — `./Packages/TchopInfrastructure/Sources/TchopSwiftDataDatabase`
### [x] Step: Package review 4 — `./Packages/TchopInfrastructure/Sources/TchopCoreDataDatabase`
### [x] Step: Package review 5 — `./Packages/TchopInfrastructure/Sources/TchopDatabase`
### [x] Step: Package review 6 — `./Packages/TchopInfrastructure/Sources/TchopNetworking`
### [x] Step: Package review 7 — `./Packages/TchopInfrastructure/Sources/TchopErrors`
### [x] Step: Package review 8 — `./Packages/TchopInfrastructure/Sources/TchopCache`
### [x] Step: Package review 9 — `./Packages/TchopInfrastructure/Sources/SyncCore`
### [x] Step: Package review 10 — `./Packages/TchopInfrastructure/Sources/TchopNavigation`
### [x] Step: Package review 11 — `./Packages/TchopInfrastructure/Sources/TchopLocalization`
### [x] Step: Package review 12 — `./Packages/TchopInfrastructure/Sources/TchopUIConfiguration`
### [x] Step: Package review 13 — `./Packages/TchopInfrastructure/Sources/TchopPushNotifications`
### [x] Step: Package review 14 — `./Packages/TchopInfrastructure/Sources/TchopOnDeviceAI`
### [x] Step: Package review 15 — `./Packages/TchopInfrastructure/Sources/TchopShareSupport`
### [x] Step: Package review 16 — `./Packages/TchopInfrastructure/Sources/TchopBranding`
### [x] Step: Package review 17 — `./Packages/TchopInfrastructure/Sources/TchopWidgets`
### [x] Step: Package review 18 — `./Packages/TchopInfrastructure/Sources/TchopAnalytics`
### [x] Step: Package review 19 — `./Packages/TchopInfrastructure/Sources/TchopAppleAuthentication`
### [x] Step: Package architecture pass 2 — cross-package reusable-surface tightening
### [x] Step: UI bugfix pass — restore card action/menu responsiveness for feed cards
### [x] Step: UI bugfix pass 2 — restore optimistic card mutations for scoped ids across channels
### [x] Step: UI diagnostics pass — add focused debug assertions for card-action lookup failures
### [x] Step: UI bugfix pass 3 — fix scoped-id unwrapping for hyphenated channel ids
### [x] Step: UI bugfix pass 4 — preserve full local action state across sequential card actions
### [x] Step: UI pass — align empty composer screen chrome/toolbar with provided design
### [x] Step: UI pass 2 — enforce full-screen composer presentation and toolbar spacing polish
### [x] Step: UI pass 3 — fine-tune add/photo/calendar spacing to latest screenshot
### [x] Step: UI pass 4 — pin Publish button to right edge and align toolbar spacing to reference
### [x] Step: UI pass 5 — align entered text origin with placeholder origin in composer text view
### [x] Step: UI pass 6 — match entered body text size/alignment with placeholder in primary composer field
### [x] Step: UI pass 5 — extend empty composer toolbar background to full-screen bottom reference
### [x] Step: UI pass 7 — align composer `+` popup bottom-sheet layout/styling to reference
### [x] Step: UI pass 8 — pixel-tighten composer `+` popup sheet geometry/spacing to latest reference
### [x] Step: Continuity docs pass — enforce full docs/rules reread rule in context-transfer prompt
### [x] Step: UI pass 9 — restore `+` popup icons/labels/count/typography to match latest provided reference
### [x] Step: UI pass 10 — reorder composer text fields and keep source at the bottom
### [x] Step: UI pass 11 — match placeholder copy for Source/Headline/Sub Heading
### [x] Step: UI pass 12 — tighten composer text-field vertical spacing to match reference
### [x] Step: UI pass 13 — apply exact composer text-field spacing values
### [x] Step: UI pass 14 — remove empty text-field reserved height causing large Source gap
### [x] Step: UI pass 15 — enforce composer text wrapping and 200-character field limit
### [x] Step: UI pass 16 — focus newly inserted fields and recover focus after field deletion
### [x] Step: UI pass 17 — focus primary text field when composer opens
### [x] Step: Simulator media setup — add image/pdf/audio fixtures for composer and share/import validation
### [x] Step: Simulator media setup 2 — add MP4 fixture for video validation
### [x] Step: Composer media picker pass — select real photo/video/audio/pdf files into draft cards
### [x] Step: Composer audio Files visibility fix — expose app documents and include MP3 content type
### [x] Step: Composer file importer completion fix — keep media kind until Audio/PDF import applies
### [x] Step: Composer media detail pass — render/play selected video/audio/pdf draft files
### [x] Step: Local feed persistence pass — keep created cards after app restart

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
- Completed now: package-wide ownership/complexity review across `./Packages/TchopInfrastructure/Sources/*` (database/network/sync/platform/product modules), with no app-specific leakage accepted in this pass.
- Completed now: `./Packages/TchopInfrastructure/Sources/TchopSwiftDataDatabase/TchopSwiftDataDatabase.swift` (deduplicated write and batch-write transaction path via shared helper).
- Completed now: `./Packages/TchopInfrastructure/Sources/TchopCoreDataDatabase/TchopCoreDataDatabase.swift` (deduplicated write and batch-write transaction path via shared helper).
- Completed now: `./Packages/TchopInfrastructure/Sources/TchopUIConfiguration/TchopUIConfiguration.swift` (reused persistent encoder/decoder in UserDefaults snapshot store).
- Completed now: `./Packages/TchopInfrastructure/Sources/TchopWidgets/TchopWidgets.swift` (reused persistent encoder/decoder in UserDefaults snapshot manager).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: second architecture pass across all packages (`./Packages/TchopInfrastructure/Sources/*`) with emphasis on reusable surface strictness and portability.
- Completed now: `./Packages/TchopInfrastructure/Sources/TchopAppleAuthentication/TchopAppleAuthentication.swift` (`AppleAuthenticationManaging` is now `Sendable`).
- Completed now: `./Packages/TchopInfrastructure/Sources/TchopWidgets/TchopWidgets.swift` (`FeedHeadlineWidgetSnapshotManaging` is now `Sendable`; concrete manager marked `@unchecked Sendable`).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/ViewModels/NewsFeedViewModel.swift` UI bugfix pass (card action cancellation now clears per-card coordinator/task state and resets pending operation for photo/text cards to avoid stuck non-responsive action bars and menu actions).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Services/FeedAPIManager.swift` bugfix pass (fixed scoped-card id unwrapping for stub mutation lookup so photo/text actions resolve the real card id across channels, including leadership `article-*` ids).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Services/FeedAPIManager.swift` diagnostics pass (added DEBUG assertion failures with channel/path/card id context when stub card lookup fails for photo/text mutation routes).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Services/FeedAPIManager.swift` follow-up fix (card lookup now removes exact `<channelID>-` prefix before fallback unscoping, fixing actions for hyphenated channels like `leadership-channel`).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Services/FeedAPIManager.swift` + `./TchopApp/Repositories/AppContentRepository.swift` follow-up fix (action mutation context now carries full local card state, so like/comment/display-mode/reply actions no longer reset each other; refresh/update now preserve local interaction state).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` empty-screen UI pass (header order and labels aligned to design; bottom toolbar updated to single `+ + chevron` action, clickable photo action, and non-clickable calendar icon; publish disabled behavior preserved via existing `canPublish` gating).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Views/ShellContentView.swift` + `./TchopApp/Views/Composer/SharedCardComposerView.swift` full-screen/pixel pass (composer presentation switched from sheet to fullScreenCover; toolbar height/paddings/top-divider/icon-group spacing and publish sizing tightened to match provided screenshot direction).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` spacing pass (explicit tuned constants for `+`/chevron gap, add-to-media spacing, and photo/calendar spacing to align with latest cropped reference).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.

- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` toolbar alignment pass (locked left tool cluster to fixed reference width and pinned `Publish` to the right edge with fixed size/offset behavior).
- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` empty-screen layout pass (kept the tuned left cluster and right-pinned `Publish`, extended the toolbar chrome through the bottom safe area, and increased content bottom inset to match the taller reference bar).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.

- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` text-origin pass (placeholder and typed text now share the same top-leading inset source so entered text starts at the same visual origin as placeholder).

- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` typography/alignment correction (primary composer text field now uses 24pt input font to match placeholder scale and cursor baseline expectations).

- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` add-popup UI pass (bottom-sheet overlay, container width/bottom position, corner radius, handle sizing, row height, and row typography aligned to the supplied reference without adding logic).
- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` add-popup pixel pass 2 (retuned overlay opacity, corner radius, side/bottom insets, handle paddings, and row metrics for tighter parity with the latest popup reference).
- Completed now: `./docs/WORK_CONTINUITY.md` continuity-rule pass (context-transfer template now explicitly mandates adding the rule to reread the full актуальный набор docs/rules for the active worktree + task context).
- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` popup parity pass (restored icon rows, `Schedule`, `PDF file`, and `Sub heading` labels, and adjusted row typography/spacing to match the latest target screenshot).
- Completed now: composer text-field ordering pass across `./TchopApp/Models/NewsFeedModels.swift`, `./TchopApp/ViewModels/AppShellViewModel.swift`, and `./TchopApp/Views/Composer/SharedCardComposerView.swift` (`headline/subheadline/text` render before content, while `source` renders as the final field regardless of added media/content).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Models/NewsFeedModels.swift` placeholder-copy pass (removed `Add` prefix from `Source`, `Headline`, and `Sub Heading` placeholders to match the provided design copy).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` text-field spacing pass (reduced composer stack spacing and compacted optional text-field minimum heights so placeholder rows sit closer to the provided reference).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` exact-spacing pass (replaced uniform `ForEach` text-field layout with explicit field order and spacing: Headline→Sub Heading 8pt, Sub Heading→Text 16pt, Text/content→Source 8pt).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` text-field height correction (reduced empty primary text field minimum height from 120pt to one-line height so `Source` no longer sits below a reserved blank text area; dynamic growth for real text remains).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: composer text input wrapping/limit pass across `./TchopApp/Views/Composer/SharedCardComposerView.swift` and `./TchopApp/Models/NewsFeedModels.swift` (text views are constrained to available width, wrap instead of expanding horizontally, and all composer text inputs are limited to 200 characters including paste/programmatic draft updates).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` focus-management pass (newly inserted composer text fields become first responder; after removing an optional text field focus moves to the first visible composer text field instead of disappearing).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` initial-focus pass (composer now focuses the primary `.text` field on appear, falling back to the first available text field when `.text` is unavailable).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: simulator media setup for booted iPhone 17 Pro (iOS 26.0): imported two JPEGs into Photos and copied JPEG/PDF/MP3 fixtures into Files app Documents, simulator Downloads, TchopApp Documents, and the app group under `TchopTestAssets` for composer/share-extension validation.
- Completed now: simulator MP4 setup for booted iPhone 17 Pro (iOS 26.0): imported `1vcgc.mp4` into Photos via `simctl addmedia` and copied it into Files app Documents, simulator Downloads, TchopApp Documents, and the app group under `TchopTestAssets`.
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.

- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift`, `./TchopApp/ViewModels/AppShellViewModel.swift`, and `./TchopApp/Models/NewsFeedModels.swift` composer media picker pass (Photo/Video now open Photos picker, Audio/PDF open Files importer, selected files are copied into app storage and attached to draft media; picked photos render from the real image in composer/detail previews).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.

- Completed now: `./TchopApp/Info.plist` and `./TchopApp/Views/Composer/SharedCardComposerView.swift` audio picker visibility fix (enabled app Documents visibility in Files with in-place document opening and added explicit MP3 content-type support to the audio importer filter).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.

- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` file importer completion fix (separated Files picker presentation state from selected media kind so Audio/PDF selection completion still knows which draft media to attach after the picker dismisses).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.

- Completed now: `./TchopApp/Views/Composer/SharedCardComposerView.swift` media detail pass (draft video now uses `VideoPlayer`, draft audio has an `AVPlayer` play/pause control, and draft PDF renders through `PDFKit.PDFView` when selected media has a real file URL).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
- Completed now: `./TchopApp/ViewModels/AppShellViewModel.swift` local feed persistence pass (created/imported `LocalFeedCardModel` entries are saved to `UserDefaults` and rehydrated into feed cards when the app starts).
- Verification: `./scripts/verify.sh low` => `BUILD SUCCEEDED`.

## Working Rule
- Keep this file short and current.
- Do not use it as a history log.

## Archive
Detailed historical plans are preserved only in:
- `./.zenflow/tasks/new-task-be0b/archive/plan.legacy.md`
