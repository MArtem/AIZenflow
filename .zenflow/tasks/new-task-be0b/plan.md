# Auto

## Configuration
- **Artifacts Path**: {@artifacts_path} → `.zenflow/tasks/{task_id}`

---

## Agent Instructions

Ask the user questions when anything is unclear or needs their input. This includes:
- Ambiguous or incomplete requirements
- Technical decisions that affect architecture or user experience
- Trade-offs that require business context

Do not make assumptions on important decisions — get clarification first.

---

## Workflow Steps

### [x] Step: Implementation
<!-- chat-id: e77a8cef-de0f-455a-9ecb-2d90a1f622a9 -->

Implemented this as a standalone SwiftUI feed screen because the worktree does not contain the existing iOS app source files. The added view recreates the screenshot with a top bar, featured article card, discussion preview, floating action button, and bottom tab bar so it can be pasted into an app and refined there.
The implementation has since been expanded into a full Xcode project with the SwiftUI code split across app shell, tab, menu, and news component files so it is easier to evolve as a real iOS app.
The infrastructure layer has now been split into a local Swift package at `Packages/TchopInfrastructure` with two separate modules: `TchopNetworking` and `TchopDatabase`. The app target now links those package products, the old app-local API/database manager files were removed, public module APIs were documented, package tests were added, and both the package test suite and the main app build now pass.
After the module split, an additional refactoring and documentation pass was applied across the app layer. Core app types now contain inline documentation, and a few large stub/fallback builders were extracted into private helpers to keep runtime logic smaller and easier to maintain.
The app now also has an Xcode unit test target, `TchopAppTests`, covering `AppState`, `LoginViewModel`, and `NewsFeedViewModel`. Both the package suite and `xcodebuild test` for the app now pass, so the current baseline includes automated verification for infrastructure and app-level state logic.
The app-level test coverage was then extended to include `TabRouter`, `AppCoordinator`, `UserRepository`, and `AppContentRepository`, so the current app behavior around navigation and repository mapping is now verified. The persistence layer was also refactored behind a common `AppDatabaseManaging` adapter contract with both `SwiftDataAppDatabaseAdapter` and `CoreDataAppDatabaseAdapter`, and the DI container now selects the concrete backend through runtime policy instead of binding repositories directly to SwiftData types.
The same backend-neutral architecture is now also implemented inside the `TchopDatabase` infrastructure module. The package exposes a shared `DatabaseManaging` contract with backend selection policy, `SwiftData` and `Core Data` managers, and backend-neutral read/write operation wrappers. Package tests now validate both backends and the factory selection path, and the full app test suite still passes against the updated package.
The app layer has now been brought onto that same package contract directly. Repositories and seeders use `DatabaseManaging` from `TchopDatabase`, while `AppDatabase.swift` is reduced to app-specific container construction and hands backend choice to `DatabaseServiceFactory`. In parallel, `TchopNetworking` was extended with typed connectivity errors, an authentication interceptor, upload and download APIs with progress reporting, and an offline queue foundation. Both `swift test --package-path Packages/TchopInfrastructure` and `xcodebuild ... test` pass after these changes.

### [x] Step: Replace stub tabs with feature screens

Continue from the current coordinator-based tab architecture by replacing the generic stub views in `Mixes`, `Pinned`, and `Chat` with concrete SwiftUI feature screens that match the existing visual system and preserve independent navigation stacks.
This step was completed by introducing dedicated `MixesTabRootView`, `PinnedTabRootView`, and `ChatTabRootView` screens backed by shared `FeatureTabContent` models and a reusable `FeatureTabScaffoldView`, while keeping each tab on its own `TabRouter`.
Verification: `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build` succeeded, and `swift test --package-path Packages/TchopInfrastructure` still passes. `xcodebuild ... test` was attempted on both `iPhone 17 Pro` and `iPhone 16 Pro`, but the run stalled in CoreSimulator after build completion, so app test execution could not be conclusively completed in this environment.

### [x] Step: Refresh handoff state

Recorded the new tab-screen baseline in `handoff.md`, including the new view/model files, the removal of stub tab roots from active navigation, and the current verification status with the CoreSimulator issue noted for the next chat.

### [x] Step: Model usage policy for quality vs limits

Added a persistent workflow policy for model roles so implementation defaults to `GPT-5.3 Codex` and `GPT-5.4` is used as a targeted review gate instead of a mandatory every-step reviewer.
The policy includes concrete review triggers (risk areas, diff size, refactors, unstable tests, and pre-merge checks) to keep code quality high while avoiding unnecessary token spend on trivial edits.

### [x] Step: Add light/dark theme support as baseline requirement

Implemented semantic theme colors for active app surfaces and text states so the existing SwiftUI screens now render correctly in both light and dark appearance modes without introducing business-logic changes.
Updated the persistent engineering rules to require light/dark support for every new project by default, with semantic tokens as the standard approach and fixed colors limited to purely decorative elements.

### [x] Step: Apply review recommendations for theme consistency

Address the review notes by removing remaining hardcoded discussion-card colors and aligning this screen with semantic theme tokens so light/dark behavior stays consistent across the app.
Move `AppTheme` out of `AppTab` model file into a dedicated theme file to reduce UI/model coupling and keep design-system code discoverable.
`AppTheme` was extracted into `TchopApp/App/AppTheme.swift`, wired into the app target, and `DiscussionCard` now uses theme tokens instead of fixed color literals. Verification succeeded with `xcodebuild ... build`, `xcodebuild ... test` (iPhone 16 Pro simulator), and `swift test --package-path Packages/TchopInfrastructure`.

### [x] Step: Clarify view-composition requirements

Reviewed the persistent iOS requirements and confirmed the project already bans local helper/computed properties that return `View`/`some View` in screens.
Added an explicit rule to also ban local `@ViewBuilder` helpers and to require a separate `Builder/Factory` entity when screen/card assembly or dependency wiring becomes complex.

### [x] Step: Sync handoff with updated composition rules

Mirrored the same view-composition constraints in `handoff.md` so future chats inherit the exact policy from both persistent sources.
Handoff now explicitly includes: no local `@ViewBuilder` helper functions and Builder/Factory-only escalation when view assembly/dependency setup becomes complex.

### [x] Step: Generalize builder/factory rule scope

Updated the rule wording so it applies to any new destination screen or composed UI element, not only screen/card assembly.
Allowed patterns are now explicit: direct type initialization at call site or dedicated `Builder/Factory` when complexity/dependency wiring justifies it; local view-returning helpers remain disallowed.

### [x] Step: Navigation plan 1/10 — define target architecture contracts

Started the navigation modernization track with explicit contracts and shared data models for the new capabilities.
Added `NavigationStateManaging`, `DeepLinkManaging`, and `NavigationSnapshot` as the baseline architecture layer that the next steps will implement.

### [x] Step: Navigation plan 2/10 — implement snapshot persistence manager

Add a concrete `NavigationStateManager` with per-user snapshot save/restore/clear and route-serialization compatibility handling.
Implemented `NavigationStateManager` as a dedicated manager with per-user keys in `UserDefaults`, snapshot JSON encoding/decoding, and version gating that automatically drops incompatible/corrupted payloads.

### [x] Step: Navigation plan 3/10 — add user profile restore flag

Persist `isNavigationStateRestoreEnabled` in user storage/repository and expose update APIs used by app state/profile UI.
Added `isNavigationStateRestoreEnabled` into app user domain and persistence records (SwiftData/CoreData), and extended `UserRepository` with explicit update API for this profile preference.

### [x] Step: Navigation plan 4/10 — integrate restore policy into app flow

Wire restore behavior into `AppState`/`AppCoordinator` so login/restore flows conditionally resume navigation only when the profile flag is enabled.
`AppState` now receives `UserRepository` and `NavigationStateManaging`, restores navigation only when profile flag is enabled, and applies immediate policy changes when the flag is toggled.

### [x] Step: Navigation plan 5/10 — coordinator snapshot API and save triggers

Add coordinator snapshot export/apply API and automatic snapshot save triggers on tab/path changes with race-safe behavior.
Added `AppCoordinator.makeSnapshot/applySnapshot` and wired `AppState` reactive persistence bindings for selected tab + each tab router path.
Snapshot writes now happen only for authenticated users with restore enabled, with an explicit guard to skip writes while applying restored state.

### [x] Step: Navigation plan 6/10 — implement deep link manager

Create `DeepLinkManager` to parse deep/universal links into typed navigation intents and route them via coordinator APIs.
Implemented a dedicated `DeepLinkManager` that handles both custom scheme and universal-link URLs, maps them to typed tab/route destinations, and routes via coordinator-owned tab routers.

### [x] Step: Navigation plan 7/10 — app lifecycle integration for links

Connect URL and `NSUserActivity` entry points from the app lifecycle into `DeepLinkManager` with shared dispatching.
App lifecycle link entry points are now wired from `TchopApp`/`AppRootView` into `AppState`, and `AppState` dispatches authenticated URL/user-activity events through `DeepLinkManager`.

### [x] Step: Navigation plan 8/10 — deep link vs restore priority policy

Ensure incoming deep/universal links take priority over restore on startup/auth transitions and keep behavior deterministic.
`AppState` now queues incoming link payloads before auth and applies them first after authentication/session-restore; navigation snapshot restore runs only when no pending link handled the transition.

### [x] Step: Navigation plan 9/10 — navigation tests for restore and links

Extend tests for restore on/off, snapshot policy, deep/universal link routing, and conflict-priority behavior.
Added app-level tests for snapshot restore enabled/disabled behavior, post-login deep-link priority over snapshot restore, and dedicated deep-link parsing/routing coverage for both custom scheme and universal links.

### [x] Step: Navigation plan 10/10 — documentation and handoff refresh

Update task documentation with architecture, manager contracts, policy details, and verification notes for resumed chats.
Updated `handoff.md` with the new navigation architecture surface (`NavigationContracts`, `NavigationSnapshot`, `NavigationStateManager`, `DeepLinkManager`), restore-policy behavior in `AppState`, deep-link lifecycle entry points, and deterministic deep-link-over-restore priority.
Also recorded fresh green verification commands for this navigation batch (`xcodebuild ... build` and `xcodebuild ... test` on iPhone 16 Pro simulator id), and corrected the theme-token source path to `TchopApp/App/AppTheme.swift` to keep resume context accurate.

### [x] Step: Add dual-simulator verification policy

Ran app verification on both required simulators:
`iPhone 16 Pro (iOS 18.2)` and `iPhone 17 Pro (iOS 26.0)`.
`iPhone 16 Pro` build/test passed; `iPhone 17 Pro` build passed but tests failed twice with the same test-runner bootstrap infrastructure crash (`Early unexpected exit` before establishing connection) even after simulator restart.
Updated persistent iOS rules to require build+test on both targets and to explicitly record repeated iOS 26.0 bootstrap failures instead of masking them.

### [x] Step: Add safe database backend fallback for iOS 26 launch

Investigated runtime crash on manual launch (`Fatal error: Failed to create database manager` with SwiftData model-container load issue) and found `AppDatabase.makeDatabaseManager` crashed unconditionally on primary backend init errors.
Implemented a production-safe fallback: when primary backend init fails and policy is not already forced `coreData`, app now retries with Core Data backend before failing hard.
This keeps app startup resilient on simulator/device stores where SwiftData container initialization can fail due to migration/runtime incompatibility.
Post-fix verification: `iPhone 16 Pro (18.2)` build/test are green; `iPhone 17 Pro (26.0)` build is green and manual `simctl launch` succeeds, while `xcodebuild test` on 26.0 still fails with known runner bootstrap instability (`Early unexpected exit`).

### [x] Step: Persist first-run backend strategy and auto-migrate Core Data to SwiftData on iOS 17+

Reworked `AppDatabase` backend resolution to persist first-run backend selection in local settings and keep using the same backend across launches.
On iOS 17+, when a legacy Core Data backend marker/store is found, app now automatically creates both managers, migrates channel/user content into SwiftData, switches persistent backend preference to SwiftData, and deletes old Core Data store files to save disk space.
Deployment target was lowered from `18.0` to `16.0`, and `TchopDatabase` package platform target was also lowered to `iOS 16` with explicit SwiftData availability guards.
App repositories/seeders and tests were updated to avoid unconditional iOS 17-only SwiftData API usage when building for iOS 16, while keeping SwiftData behavior active on iOS 17+.
Verification is green on both required targets after the change:
`xcodebuild ... build` and `xcodebuild ... test` on
`iPhone 16 Pro (iOS 18.2)` and `iPhone 17 Pro (iOS 26.0)`.

### [x] Step: Package reusable navigation core and tighten DB factory typing

Moved reusable navigation primitives into `TchopInfrastructure/TchopDatabase` by introducing `TchopNavigationCore.swift` with generic `TabRouter<Route>` and generic snapshot persistence contract `NavigationStateManaging` + `NavigationStateManager`.
Updated app navigation to consume package types, removed duplicate app-local navigation utility files, and kept app-specific deep-link contract separate as `DeepLinkManaging`.
Refined `DatabaseServiceFactory` overloads so SwiftData creation remains typed at the public API level (`ModelContainer` only in iOS 17+ overload), while preserving iOS 16 compatibility for Core Data paths. Synced Xcode project file references accordingly. Verification is green on both required simulator targets:
`iPhone 16 Pro (iOS 18.2)` and `iPhone 17 Pro (iOS 26.0)` with `xcodebuild ... test`.

### [x] Step: Universal infra uplift phase 1 (reusability-first)

Raise `TchopNetworking` and `TchopDatabase` toward a more universal reusable baseline while preserving package-first architecture and iOS app portability.
Scope for this phase: add backend-agnostic versioned migration primitives in DB module, extend DB contract with batch/async-friendly APIs, and improve networking with auth-refresh retry pipeline plus more flexible response handling utilities.
Completed:
- `TchopDatabase` now includes reusable migration infrastructure (`DatabaseMigrationVersionStoring`, `UserDefaultsDatabaseMigrationVersionStore`, `DatabaseMigrationStep`, `DatabaseMigrationRunner`) plus explicit `DatabaseBatchWriteOperation` and `writeBatch` / async-friendly manager extensions.
- `TchopNetworking` now supports reusable auth-refresh retry flow (`APIAuthenticationRefreshing`, `APIAuthorizationRefreshInterceptor`), request re-preparation on each retry attempt (critical for refreshed headers), customizable accepted status-code ranges per request, and a dedicated JSON request builder (`APIRequest.json`) plus `APIEmptyResponse`.
- Added package tests for migration runner, batch writes, auth-refresh retry behavior, and custom status-code handling.
Verification: `swift test --package-path Packages/TchopInfrastructure`, `xcodebuild ... test` on `iPhone 16 Pro (iOS 18.2)`, and `xcodebuild ... test` on `iPhone 17 Pro (iOS 26.0)` all succeeded.

### [x] Step: Universal infra uplift phase 2 (durable offline execution)

Introduce a persisted offline queue in `TchopNetworking` to move from in-memory foundation to reusable durable behavior suitable for real apps.
Scope: payload-based queue records, pluggable persistence store with default file-backed implementation, retry attempts with dead-letter handling, and deterministic drain behavior gated by connectivity provider.
Verification target: package tests plus app tests on both required simulators.
Completed:
- Added payload-based persisted queue primitives in `TchopNetworking`:
  `APIOfflineQueueEntry`,
  `APIOfflineQueueStoring`,
  `FileAPIOfflineQueueStore`,
  and `APIPersistedOfflineQueue` with retry attempts, dead-letter capture, and connectivity-gated draining.
- Added tests for persistence reload, connectivity-aware drain policy, and dead-letter transition after retry limit.
- Post-review hardening applied:
  fixed actor reentrancy race in `drainIfConnected` to preserve items enqueued while drain is in-flight,
  and persisted dead-letter entries in `FileAPIOfflineQueueStore` so dead letters survive app restarts.
- Added regression tests for:
  enqueue-during-drain retention,
  and dead-letter reload across queue instances.
- Verification is green:
  `swift test --package-path Packages/TchopInfrastructure`,
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' test`,
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' test`.

### [x] Step: Add persistent UI performance and memory rule

Added a permanent coding requirement in `ios-engineering-rules.md` and synced it to `handoff.md`:
UI must always be implemented with explicit focus on avoiding unnecessary re-renders and memory waste.
The expected baseline is stable, optimal code without logical/programming issues that can cause redundant rendering or excess memory usage.

### [x] Step: Universal infra uplift phase 3 (observability foundation)

Add reusable observability primitives to infrastructure modules so API/database/offline queue behavior can be measured in production and tests.
Scope: typed metrics events for networking, queue snapshots/drain reports, lightweight collector utilities, and baseline tests for deterministic event capture.
Completed:
- Added networking observability primitives: `APIMetricsEvent`, `APIMetricsCollecting`, `APIMemoryMetricsCollector`, and `APIMetricsInterceptor`.
- Extended interceptor contract with retry scheduling callback (`didScheduleRetry`) and wired retry notifications from `APIManager`.
- Added queue diagnostics in `APIPersistedOfflineQueue`: `Snapshot`, `DrainReport`, and `drainWithReportIfConnected(...)` while preserving existing `drainIfConnected(...)`.
- Added tests for metrics event capture and queue diagnostic report/snapshot behavior.
Verification: `swift test --package-path Packages/TchopInfrastructure` succeeded.

### [x] Step: Universal infra uplift phase 4 (extensibility and API ergonomics)

Improve extension points without breaking current consumers.
Scope: pluggable API error mapping strategy and unified retry metadata surface so feature modules can customize behavior with minimal adapter code.
Completed:
- Added pluggable `APIErrorMapping` contract with default implementation `APIDefaultErrorMapper`.
- `APIManager` now accepts custom error mapper and uses it for non-`APIError` runtime failures across perform/upload/download/execute flows.
- Added typed retry metadata surface `APIRetryContext` and new interceptor extension point `retryDirective(for context: APIRetryContext)`.
- Kept compatibility by preserving existing `retryDirective(for:error:attempt:request:)` and bridging default behavior.
- Added tests for custom mapper usage and retry-context-driven retry flow.
Verification: `swift test --package-path Packages/TchopInfrastructure` succeeded.

### [x] Step: Universal infra uplift phase 5 (security hardening)

Harden diagnostics and logging defaults to avoid leaking sensitive data.
Scope: sensitive header/query redaction in logging pipeline, safe defaults, and tests proving secrets are not emitted.
Completed:
- Added `APILoggingInterceptor.RedactionConfiguration` with default sensitive header/query key sets and redaction placeholder.
- Logging now redacts sensitive query values in URLs and sensitive headers in request logs.
- Response/failure logs now use redacted URLs.
- Added regression test (`testLoggingInterceptorRedactsSensitiveHeadersAndQueryValues`) to ensure secret query/header values are not emitted.
Verification: `swift test --package-path Packages/TchopInfrastructure` succeeded.

### [x] Step: Universal infra uplift phase 6 (operational tooling and recovery ergonomics)

Add lightweight operational helpers around persisted offline queues for debugging/support workflows.
Scope: queue diagnostics export/import helpers (pending + dead letters), corruption-safe load behavior, and tests for recovery scenarios.
Completed:
- Added corruption handling policy to `FileAPIOfflineQueueStore` (`throwError` or `recoverToEmpty`).
- Default behavior is now corruption-safe recovery for persisted queue/dead-letter files by moving broken payloads aside and continuing with empty state.
- Added queue operational tooling in `APIPersistedOfflineQueue`:
  `DiagnosticsPayload`, `DiagnosticsImportStrategy`, `exportDiagnosticsPayload()`, and `importDiagnosticsPayload(...)`.
- Added tests for corrupted store recovery and diagnostics export/import roundtrip.
Verification: `swift test --package-path Packages/TchopInfrastructure` succeeded.

### [x] Step: Apply post-review hardening recommendations for phase 3-6

Applied review-driven corrections in `TchopNetworking` to avoid silent data-loss behavior and to keep retry observability complete.
`FileAPIOfflineQueueStore` now recovers only from JSON decoding corruption (not generic I/O/read errors), and `APIManager` now emits `didScheduleRetry` for retries coming from the `invalidStatusCode` branch as well.
Added regression tests for both fixes to prevent reintroduction.
Verification:
`swift test --package-path Packages/TchopInfrastructure`,
`xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' test`,
`xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' test`.

### [x] Step: Navigation phase 7 — reliability, intent validation, and transition policy

Introduce typed deep-link intents with explicit validation and deterministic fallback behavior for invalid in-app links.
Add coordinator-level navigation transition policy (`push/replace/popToRoot`) with idempotent route application to avoid duplicate-stack churn and unstable navigation jumps.
Add focused tests for invalid-link fallback, idempotent transitions, and deterministic route outcomes.
Completed:
- Added typed deep-link intent pipeline with parse result states (`resolved` / `invalidInAppLink` / `unsupported`) and deterministic fallback-to-news behavior for invalid in-app links.
- Added coordinator-level `NavigationTransitionPolicy` and idempotent route application helpers for all tabs to avoid duplicate pushes/replaces.
- Added tests for invalid in-app fallback, unsupported host rejection, deep-link push behavior, and idempotent coordinator transitions.

### [x] Step: Add reusable APNs push-notification package and app integration

Introduce a package-backed APNs manager that can own authorization state, APNs registration results, device-token persistence, and remote-payload dispatching without depending on a real backend yet.
Wire it into the SwiftUI app through an app-level bridge and `UIApplicationDelegate` callbacks, and add the project configuration that is realistically possible today: push entitlement, remote-notification background mode, and simulator-friendly mock payload support for manual testing.
Completed:
- Added package product/target/test target `TchopPushNotifications` with reusable types for APNs authorization state, token formatting, payload parsing, and `UserDefaults`-backed state persistence.
- Added app-layer bridge `AppPushNotificationBridge` and `TchopApplicationDelegate` so the SwiftUI app now receives APNs registration and remote-notification callbacks through a composition layer instead of app-global logic.
- Updated project/app configuration with push entitlement, `remote-notification` background mode, and simulator-ready `.apns` payload fixtures for both app bundle identifiers.
- Added an explicit app-facing `AppState.requestPushNotificationAuthorization()` entry point for future UI wiring, while keeping the permission prompt opt-in rather than auto-triggered on launch.
- Post-implementation hardening:
  fixed APNs package test drift after manager API changes,
  fixed missing `await` in `AppState`,
  fixed early `UIApplicationDelegateAdaptor` assignment in `TchopApp`,
  and refactored widget/push no-op defaults to avoid main-actor violations in default arguments.
- Full verification is now green:
  `swift test --package-path Packages/TchopInfrastructure`,
  `xcodebuild ... build` and `xcodebuild ... test` on `iPhone 16 Pro (iOS 18.2)`,
  and `xcodebuild ... build` and `xcodebuild ... test` on `iPhone 17 Pro (iOS 26.0)`.

### [x] Step: Establish profiling baseline for current app runtime

Captured a CLI-driven profiling baseline for `TchopApp` on `iPhone 17 Pro (iOS 26.0)` using `xctrace`, `sample`, `vmmap`, and simulator logs.
Observed baseline:
- build for profiling succeeded with isolated DerivedData;
- `App Launch`, `Time Profiler`, and `Leaks` traces were recorded successfully;
- `SwiftUI` instrument is not supported on Simulator, and `Allocations` produced an attach-privileges limitation in this environment, so those results are non-authoritative;
- startup appears fast with the first active scene transition completing in roughly `0.67s` based on simulator logs;
- idle CPU sample did not show hot loops or busy work on the main thread;
- physical footprint was about `24.6MB` with peak around `25.2MB` in the sampled startup/idle window.
Risk note:
- CLI launches in this environment exit unusually early with `exit(0)`, which limits long-running live profiling depth; future deeper profiling should be done with interactive Instruments/device sessions when investigating rendering hitches or sustained memory growth.

### [x] Step: Persist profiling workflow in project documentation

Added a persistent `профайлинг` workflow definition to project documentation so future requests use the fullest practical profiling pass by default.
The documented profiling workflow now includes:
- `xctrace` traces for launch/CPU/leaks/allocations when supported,
- `sample`,
- `vmmap`,
- simulator/device log inspection,
- an explicit report structure covering startup, CPU, memory, leak risk, tooling limitations, and remediation suggestions.
Also documented that Simulator/CLI restrictions must be called out explicitly and escalated to interactive Instruments or real-device profiling when deeper evidence is required.

### [x] Step: Add reusable widget package and first feed headline widget

Introduced a reusable widgets support package `TchopWidgets` with shared snapshot contracts and `UserDefaults` app-group persistence for widget content.
Added app-side widget sync bridge plus a real `TchopWidgetsExtension` target that reads the shared snapshot and renders the headline of the first feed card.
Current test payload is the featured article headline from the feed screen, which resolves to the stubbed text `Parrots help others in need, study shows for first time`.
Lightweight validation only:
- `plutil -lint TchopApp.xcodeproj/project.pbxproj` passed;
- `swift package dump-package --package-path Packages/TchopInfrastructure` passed;
- `xcodebuild -list -project TchopApp.xcodeproj` sees `TchopWidgetsExtension` and `TchopWidgets` successfully.
Per current project verification policy, no full build/test run was started because the user did not request a verification level for this task.

### [x] Step: Fix widget extension install failure on simulator

Investigated simulator install failure (`IXErrorDomain`, `Invalid placeholder attributes`) and confirmed the root cause was the widget extension using an auto-generated Info.plist that did not produce a valid nested `NSExtension` dictionary for placeholder creation.
Fixed the extension target by switching to an explicit `TchopWidgetsExtension/Info.plist` with a proper `NSExtension` payload.
Re-ran the requested `Low` verification and then verified the originally failing path directly:
- `xcodebuild ... build` on `iPhone 17 Pro (iOS 26.0)` passed;
- `xcrun simctl install ... TchopApp.app` passed;
- `xcrun simctl launch ... com.example.TchopApp` passed.

### [x] Step: Embed widget extension into TchopAppOcean

Extended widget embedding so `TchopWidgetsExtension` is now also embedded into the `TchopAppOcean` application target, not only the base `TchopApp` target.
This was done by adding the extension target dependency and a dedicated `Embed App Extensions` copy phase for `TchopAppOcean` in the Xcode project configuration.

### [x] Step: Split Ocean widget extension identity and pass Low verification

While verifying `TchopAppOcean`, the build failed because the shared widget extension bundle identifier (`com.example.TchopApp.widgets`) is not a valid prefix for the `TchopAppOcean` host bundle identifier.
Fixed this by introducing a dedicated `TchopWidgetsOceanExtension` target that reuses the same widget sources but uses its own bundle identifier: `com.example.TchopAppOcean.widgets`.
Re-ran the same `Low` verification successfully:
- `xcodebuild -project TchopApp.xcodeproj -scheme TchopAppOcean -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO build`

### [x] Step: Navigation phase 8 — snapshot evolution, migration, and navigation observability

Evolve navigation snapshot model to a new version with backward migration from v1 payloads and safe restore sanitization controls.
Add navigation observability primitives (typed events + reporter) and emit metrics/traces for restore/deep-link success-failure paths.
Add tests for snapshot migration, sanitization behavior, and observability event emission.
Completed:
- Upgraded `NavigationSnapshot` to version `2`, added backward-compatible decoding for v1 payloads, explicit migration to supported version, and stack sanitization (`maxRoutesPerTab`).
- Added navigation observability contracts (`NavigationEvent`, `NavigationEventReporting`, noop + memory reporter) and wired event emission in deep-link handling and snapshot restore flows.
- Added safe rollback path for unsupported future snapshot versions (clear + reset), with explicit failure event.
- Added tests for migration + sanitization and future-version rollback behavior.
Verification:
`swift test --package-path Packages/TchopInfrastructure`,
`xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' test`,
`xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' test`.

### [x] Step: Add baseline comments across all Swift files

Added concise documentation comments to Swift files that had no `///` comments, focusing on top-level types and key test suites/views/models to improve readability and onboarding.
The pass intentionally keeps comments short and structural (purpose/role), without over-commenting implementation details.

### [x] Step: Apply view performance review optimizations

Apply the previously reported SwiftUI review notes to reduce avoidable re-render cost and transient allocations in hot UI paths.
Scope is intentionally narrow: remove fallback model allocation from `TabContentView`, remove temporary array allocation from `FeaturedArticleCard`, and localize menu/tab animations in `AppShellView`.
Completed:
- Removed fallback `AppUser` allocation from `TabContentView` and replaced it with a guarded `currentUser` branch + lightweight loading placeholder.
- Replaced `ForEach(Array(article.actions.enumerated()))` with index-based iteration in `FeaturedArticleCard` to avoid temporary array creation on each render.
- Narrowed animation scope in `AppShellView` (removed container-wide animation modifiers) and moved tab selection animation to `BottomTabBar`.
Verification:
`swift test --package-path Packages/TchopInfrastructure`,
`xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' test`,
`xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' test`.

### [x] Step: Add project-wide localization/i18n baseline with package manager

Introduce a reusable package-level localization manager and wire app-level localization access through a dedicated facade so screens/view-models/routes consume string keys instead of hardcoded user-facing literals.
Migrate existing UI and fixture content paths to localized keys, add English/Russian resources, and update coding rules/handoff to require localization+i18n for every new element by default.
Completed:
- Added `TchopLocalization` package module with reusable `LocalizationManaging` + `LocalizationManager`, plus `en/ru` localized resources and dedicated package tests.
- Wired app target to the new package product and added centralized app facade `AppLocalization` for key-based lookup/formatting.
- Replaced hardcoded user-facing strings in views, models, feature fixtures, deep-link defaults, and view-model error messaging with localization keys.
- Updated persistent docs (`ios-engineering-rules.md` and `handoff.md`) to require localization/i18n for every new user-facing element by default.
Verification:
`swift test --package-path Packages/TchopInfrastructure`,
`xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' test`,
`xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' test`.

### [x] Step: Add reusable local cache package module

Introduce a dedicated infrastructure cache module as a reusable package product with a clear manager protocol and concrete in-memory + file-backed local cache implementations.
Cover core behaviors with tests (set/get/remove/clear, expiration policy, and persistence restore), then sync task docs/rules with the new cache baseline.
Verify through package tests and app test matrix on both required simulators.
Completed:
- Added new package product/target `TchopCache` in `Packages/TchopInfrastructure/Package.swift`.
- Implemented reusable cache API in `TchopCache`:
  `LocalCacheManaging`,
  `CacheExpiration`,
  `LocalCacheError`,
  `InMemoryLocalCacheManager`,
  `FileLocalCacheManager` (file-backed persistence in caches directory).
- Added dedicated cache tests for core lifecycle and expiration behavior:
  `Packages/TchopInfrastructure/Tests/TchopCacheTests/TchopCacheTests.swift`.
- Synced task documentation:
  `handoff.md` now includes the cache module/tests in architecture state,
  and `services-engineering-rules.md` now includes persistence-layer guidance for protocol-first reusable local cache managers.
Verification:
- `swift test --package-path Packages/TchopInfrastructure`
- `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' test`
- `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' test`

### [x] Step: Add explicit post-task verification levels and set default to absent

Updated project documentation to use four explicit verification levels after each task:
`Full`, `Medium`, `Low`, and `Absent`.
Set default behavior to `Absent` so no tests/build/simulator checks are run unless the user explicitly requests a verification level after task completion.
Synced this policy in:
`ios-engineering-rules.md` (persistent rule source) and `handoff.md` (resume context).

### [x] Step: Split database infrastructure into reusable backend packages plus composition facade

Refactor the current single mixed database module into separate reusable package targets for shared contracts, SwiftData backend, Core Data backend, and composition/factory resolution.
Keep the app-facing contract backend-neutral (`DatabaseManaging`) while moving backend-specific code into isolated targets so future projects can depend on combined mode or only one backend as needed.
Preserve current runtime behavior in the app, including backend selection policy and migration path, then verify with full package/app checks.
Completed:
- Split the database package into dedicated reusable targets/products:
  `TchopDatabaseCore`,
  `TchopSwiftDataDatabase`,
  `TchopCoreDataDatabase`,
  `TchopDatabaseComposition`,
  while keeping `TchopDatabase` as a backward-compatible umbrella target.
- Moved shared database contracts, configuration, operations, errors, and migration primitives into `TchopDatabaseCore`.
- Moved backend implementations into isolated targets:
  `SwiftDataDatabaseManager` to `TchopSwiftDataDatabase`,
  `CoreDataDatabaseManager` to `TchopCoreDataDatabase`.
- Added composition contract `DatabaseManagerResolving` and concrete `DatabaseManagerResolver` in `TchopDatabaseComposition`, with `DatabaseServiceFactory` preserved as compatibility facade.
- Switched app composition in `TchopApp/Persistence/AppDatabase.swift` to the new resolver contract instead of treating the DB layer as one mixed manager implementation.
- Extended package tests to verify resolver-based creation for both backends.
- Synced `handoff.md` with the new DB package structure and composition contract.
Verification:
- `swift test --package-path Packages/TchopInfrastructure`
- `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -derivedDataPath .cache/DerivedData -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' test`
- `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -derivedDataPath .cache/DerivedData-build16 -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' build`
- `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -derivedDataPath .cache/DerivedData-build17 -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' build`

### [x] Step: Add multi-target app branding with package-backed UI configuration

Add a second app target and introduce a reusable package-backed branding layer so target-specific UI differences are configured centrally instead of scattered through app code.
Use target build settings / Info.plist keys as the source of truth for brand selection, wire the first-tab `+` button color to a semantic branding token, and document the stronger collaboration/clarification rule for future tasks.
Completed:
- Added package-backed target branding infrastructure via `TchopBranding`, with semantic brand tokens resolved from target metadata instead of scattered target checks in app views.
- Added a second app target, `TchopAppOcean`, that reuses the same codebase but supplies a different brand variant through build settings and shared `Info.plist` placeholders.
- Added shared app-level bridge `AppBranding` and wired `AppTheme` semantic tokens to target branding so the news-tab floating `+` button now changes color by target.
- Added a dedicated shared scheme for `TchopAppOcean` and linked both app targets to the new `TchopBranding` package product.
- Updated persistent documentation to require proactive clarification/collaboration and to standardize target-based theming through centralized semantic branding.
- Follow-up verification policy was tightened as well: if a requested verification run finds a real code/configuration error, fix it immediately and rerun the same verification level before reporting back.

### [x] Step: Extract raw brand colors into dedicated tokens file

Moved the raw `classic` and `ocean` color definitions out of the brand-theme factory into a dedicated branding source file so future target palette edits happen in one obvious place.
The goal is discoverability: semantic theme resolution stays in `TchopBranding.swift`, while the actual RGB values now live in explicit brand token constants.

### [x] Step: Add package-backed server-driven UI configuration baseline

Prepared a reusable infrastructure layer for UI settings fetched from server, starting with a mock remote source and a shell-level flag controlling whether the floating action button should be shown.
The app shell now consumes this through a dedicated `TchopUIConfiguration` package so future server-driven UI tweaks can extend the same snapshot/manager flow instead of introducing ad-hoc per-screen flags.

### [x] Step: Fix Sendable warning in feed stub response pipeline

Resolved Swift concurrency warning:
`Converting non-Sendable function value to '@Sendable () async throws -> FeedResponseDTO' may introduce data races`.
Applied an explicit `@Sendable`-compatible stub closure in `StubFeedAPIManager` and marked feed DTO graph as `Sendable` to keep the request/stub path concurrency-safe.

### [x] Step: Separate navigation primitives from database umbrella boundary

Completed the first architecture-boundary refactor by extracting generic navigation primitives into a dedicated reusable package target/product, `TchopNavigation`.
Moved `TabRouter`, `NavigationStateManaging`, and `NavigationStateManager` out of the `TchopDatabase` source tree, linked both app targets to `TchopNavigation`, and switched app navigation-focused files to import the new module directly.
Kept `TchopDatabase` as a backward-compatible umbrella by re-exporting `TchopNavigation`, so package consumers are not forced into a breaking migration while the app layer now reflects the cleaner dependency boundary.
Validation for this step was structural:
`swift package dump-package --package-path Packages/TchopInfrastructure`
and
`plutil -lint TchopApp.xcodeproj/project.pbxproj`.

### [x] Step: Tighten composition root and remove hidden DI fallbacks

Completed the DI/composition cleanup by removing implicit no-op/fallback dependency creation from `AppState`, `AppShellViewModel`, and `NewsFeedViewModel`.
Those runtime/feature types now require their infrastructure dependencies explicitly, while `AppDIContainer` owns the actual assembly and exposes small helper factories for seeding, API manager creation, feed API composition, UI configuration, widget sync, and push-bridge setup.
Updated app tests to pass explicit test/no-op dependencies so the composition contract is now visible in both production and test code instead of being hidden behind optional parameters.

### [x] Step: Centralize navigation root behavior in coordinator

Completed the navigation/coordinator cleanup by moving tab-root reset behavior into `AppCoordinator` (`showTabRoot(_:)`) and exposing a single `navigationChanges` publisher for snapshot persistence observers.
`AppState` now subscribes to coordinator-level navigation changes instead of wiring every router publisher manually, and `DeepLinkManager` now delegates root resets to the coordinator instead of mutating tab stacks itself.
Also tightened deep-link semantics: links that target a tab root now intentionally open that tab at root state rather than preserving a stale nested stack.

### [x] Step: Tighten repository data-flow contracts

Completed the data-flow cleanup by making repositories more explicit about orchestration vs mapping responsibilities.
`DefaultAppContentRepository` now delegates DTO/persistence mapping to focused private mapper helpers, while `DefaultUserRepository` now enforces username normalization at the repository boundary and throws on blank usernames in `findOrCreateUser(username:)` instead of relying only on UI validation.
Added a regression test to ensure whitespace-only usernames cannot be persisted through the repository API.

### [x] Step: Split persistence orchestration responsibilities inside AppDatabase

Completed the persistence-orchestration refactor by separating `AppDatabase` internals into focused helpers without changing the app-facing API.
Backend preference persistence now lives in `AppDatabaseBackendPreferenceStore`, migration flow in `AppDatabaseMigrationCoordinator`, and container/store bootstrap in `AppDatabaseContainerFactory`, while `AppDatabase` itself remains the runtime policy/orchestration facade.
This keeps app-specific persistence policy local to the app layer, but reduces the amount of mixed backend/bootstrap/migration code living in one enum body.

### [x] Step: Make networking transfer cancellation consistent

Completed the first `TchopNetworking` package uplift by adding optional `APICancellationToken` support to `upload` and `download`, matching the existing cancellation model already used by `perform`.
This makes the reusable API client more coherent for consumers with long-running transfer operations and avoids having one cancellation contract for standard requests and another for uploads/downloads.
Added regression tests to verify cancelled upload/download flows short-circuit correctly.

### [x] Step: Unify database resolver composition surface

Completed the next database-package uplift by replacing the resolver's overload-heavy composition surface with a reusable `DatabaseManagerFactorySet`.
`TchopDatabaseComposition` now exposes one universal payload for backend factories, explicit `availableBackends` reporting, and a single resolver/factory entry point that can select either backend from the same factory set.
`AppDatabase` now uses that unified composition contract, and package tests cover both backend availability reporting and backend resolution through the new factory-set API.

### [x] Step: Expand UI configuration package into reusable current/refresh/store layer

Completed the first real `TchopUIConfiguration` package uplift by moving it beyond a thin one-shot remote fetch wrapper.
The package now supports a reusable persisted snapshot store, explicit `currentConfiguration()` vs `refreshConfiguration()` semantics, and a default `UserDefaultsUIConfigurationSnapshotStore` so other iOS projects can adopt server-driven UI config without rebuilding caching/bootstrap behavior from scratch.
`AppShellViewModel` now applies the current cached snapshot first and then refreshes from the remote provider, while package tests cover fallback bootstrap, persistence on refresh, and reload from store.

### [x] Step: Move reusable navigation observability and transition contracts into package

Completed the first extraction pass for app-local navigation infrastructure that was generic enough to live in `TchopNavigation`.
`NavigationTransitionPolicy`, `NavigationEvent`, `NavigationEventReporting`, `NavigationNoopEventReporter`, and `NavigationMemoryEventReporter` now live in the package instead of the app target, so transition semantics and navigation observability are reusable across projects that adopt the same coordinator/router pattern.
The app navigation layer now imports those contracts from `TchopNavigation` rather than defining them locally.

### [x] Step: Tighten feed UI action flow and remove hidden card lookups

Completed the first targeted SwiftUI quality pass by removing hidden feed-card lookups from `NewsTabRootView`.
`NewsFeedView` now forwards the concrete tapped `FeaturedArticleCardModel` or `DiscussionCardModel` back to the tab root, so navigation opens the exact card the user tapped without rescanning the feed array or relying on "first matching card" behavior.
This reduces unnecessary feed traversal during interaction and makes the card-to-destination flow more explicit and less error-prone as the timeline grows.

**Debug requests, questions, and investigations:** answer or investigate first. Do not create a plan upfront — the user needs an answer, not a plan. A plan may become relevant later once the investigation reveals what needs to change.

**For all other tasks**, before writing any code, assess the scope of the actual change (not the prompt length — a one-sentence prompt can describe a large feature). Scale your approach:

- **Trivial** (typo, config tweak, single obvious change): implement directly, no plan needed.
- **Small** (a few files, clear what to do): write 2–3 sentences in `plan.md` describing what and why, then implement. No substeps.
- **Medium** (multiple components, design decisions, edge cases): write a plan in `plan.md` with requirements, affected files, key decisions, verification. Break into 3–5 steps.
- **Large** (new feature, cross-cutting, unclear scope): gather requirements and write a technical spec first (`requirements.md`, `spec.md` in `{@artifacts_path}/`). Then write `plan.md` with concrete steps referencing the spec.

**Skip planning and implement directly when** the task is trivial, or the user explicitly asks to "just do it" / gives a clear direct instruction.

To reflect the actual purpose of the first step, you can rename it to something more relevant (e.g., Planning, Investigation). Do NOT remove meta information like comments for any step.

Rule of thumb for step size: each step = a coherent unit of work (component, endpoint, test suite). Not too granular (single function), not too broad (entire feature). Unit tests are part of each step, not separate.

Update `{@artifacts_path}/plan.md`.
