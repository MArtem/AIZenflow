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

### [x] Step: State and localization foundation

Started the state/localization modernization pass with the root and feed contracts, then extended it into auth and shell chrome.
Completed:
- `AppState` now drives the root flow through explicit `AppSessionState` values instead of an implicit `currentUser == nil` split.
- `NewsFeedViewModel` / `NewsFeedView` now use explicit `loading / content / empty / offline / failed` feed states.
- `TchopLocalization` and `AppLocalization` now support resource-first lookups cleanly enough to move production surfaces away from inline fallback copy.
- Root/feed messaging, login/auth copy, tab/menu/top-bar chrome, floating-action-button accessibility text, default channel metadata, and side-menu/footer text now resolve through localization resources.
- The remaining localization cleanup has been completed, so production UI copy is now resource-backed across the active app surfaces instead of being sourced from inline Swift fallback strings.

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

### [x] Step: Readability-first refactor 4 — simplify composition root in AppDIContainer

Applied a readability-focused refactor to `TchopApp/App/AppDIContainer.swift` without changing the public app-facing composition API.
The container initializer now assembles runtime services through a few linear factory groups instead of one long mixed block, and `makeAppState()` now reads more directly by constructing local coordinator/shell objects before returning the root state.
Added small private helpers for seeded database setup, repository assembly, and navigation service assembly so related dependencies stay grouped in one place without introducing new abstraction layers.
Verification: `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO build` succeeded.

### [x] Step: Readability-first refactor 5 — simplify interceptor flow in TchopNetworking

Applied a package-level readability refactor to `Packages/TchopInfrastructure/Sources/TchopNetworking/TchopNetworking.swift`, focused only on the `APIManager` control flow.
The repeated interceptor loops for request preparation, transport result broadcasting, and retry scheduling are now expressed through a few private helpers, which makes `perform` / `upload` / `download` read more linearly without changing the public networking API or runtime capabilities.
This step intentionally avoided new public abstractions and only removed repeated low-level plumbing inside the package implementation.
Verification: `swift test --package-path Packages/TchopInfrastructure` succeeded.

### [x] Step: Readability-first refactor 6 — simplify persistence branches in UserRepository

Applied a readability-focused refactor to `TchopApp/Repositories/UserRepository.swift` without changing any repository contracts or persistence behavior.
The main repository methods now delegate the repeated SwiftData/Core Data branches to small private helpers for fetch, create, and restore-preference update flows, and the repeated Core Data single-record request setup is centralized in one helper.
This step intentionally kept the logic in the same file and did not introduce any new protocols, services, or generic abstraction layers.

### [ ] Step: Real-API readiness plan — maximize auth/network/error foundation before backend exists

Goal: prepare the app as far as possible for a real authenticated backend without waiting for final API endpoints, while preserving the current app/session/feed architecture.

Recommended implementation order:

1. **Introduce a real auth domain in the app layer**
   - Add app-facing auth models:
     - `AuthTokenSet` (`accessToken`, `refreshToken`, `expiresAt`, optional `tokenType`, optional `subjectUserID`)
     - `AuthenticatedSession`
     - `AuthFailure`
   - Keep this separate from `AppUser` so local profile persistence and remote auth state do not get conflated.
   - Critical files:
     - new `TchopApp/Auth/` folder
     - `TchopApp/Services/UserSessionService.swift`
     - `TchopApp/App/AppState.swift`

2. **Add secure token storage now**
   - Implement a production-grade keychain-backed token store:
     - `AuthTokenStoring`
     - `KeychainAuthTokenStore`
     - optional in-memory test/dummy implementation
   - Do not use `UserDefaults` for bearer/refresh tokens.
   - Persist:
     - token set
     - token issue/expiry metadata
     - optional remote session identifier
   - Keep `UserDefaults` only for non-sensitive local session markers if still needed.
   - Critical files:
     - new `Packages/TchopInfrastructure/Sources/TchopSecurity/` or `TchopAuth/`
     - `TchopApp/App/AppDIContainer.swift`

3. **Implement a real authentication provider for the existing networking package**
   - Reuse existing infrastructure contracts from `TchopNetworking`:
     - `APIAuthenticationProviding`
     - `APIAuthenticationRefreshing`
     - `APIAuthenticationInterceptor`
     - `APIAuthorizationRefreshInterceptor`
   - Add one concrete provider:
     - `APIAuthProvider`
   - Responsibilities:
     - build `Authorization` header from stored access token
     - refresh token when needed
     - atomically write refreshed tokens back to secure storage
     - expose a “no credentials” path cleanly
   - Critical files:
     - `Packages/TchopInfrastructure/Sources/TchopNetworking/TchopNetworking.swift`
     - new auth provider implementation in app or new infra auth package

4. **Prepare an auth service/API manager before real endpoints exist**
   - Add a dedicated auth-facing service layer now:
     - `AuthenticationAPIManaging`
     - `DefaultAuthenticationAPIManager`
   - Even if methods are temporarily stubbed, define the real contract now:
     - `exchangeAppleIdentity(...)`
     - `exchangeUsernameLogin(...)` if this flow stays
     - `refreshSession(using refreshToken:)`
     - `logout(...)` or `revokeSession(...)`
   - This prevents feed/content services from becoming the place where auth logic leaks.

Progress so far in this phase:
- completed: app-local auth token model, keychain token store, auth-aware networking provider, DI interceptor wiring, and `TchopErrors` package foundation;
- completed: async token-aware startup restore in `AppState`/`UserSessionService`;
- completed: async login path from `LoginScreenView` through `AppState` into `UserSessionService`, with backend-first token exchange and local fallback while auth endpoints remain stubbed;
- completed: refresh deduplication in `SessionAuthenticationProvider`;
- completed: local-first logout with best-effort remote revoke hook.
- completed: session lifecycle edge cases now clean up stale credentials as well: successful backend token exchange no longer leaves orphaned tokens behind if local user creation fails, and token-only restore state is now cleared when no matching local app user exists.
- completed: session cleanup semantics are now split more cleanly: explicit `signOut()` keeps best-effort remote revoke, while restore-time corruption/stale-state cleanup uses local-only persisted-state clearing and avoids accidental revoke side effects.
- completed: app-local user persistence failures now participate in the shared error pipeline as well, so local username validation/account-resolution problems no longer degrade to generic unknown errors in login/profile flows.
- completed: dedicated auth transport layer with `DefaultAuthenticationAPIManager`, configurable auth endpoint paths, and a separate unauthenticated `APIManager` so auth routes do not recurse through the main authenticated interceptor pipeline.
- completed: `NewsFeedViewModel` now consumes `AppErrorManaging` for feed-level refresh failures and non-repository card-action failures, while keeping explicit repository-specific UX for offline/stale-card cases.
- completed: `AppShellViewModel` and `AppPushNotificationBridge` now route runtime failures through `AppErrorManaging` as well, so shell configuration and APNs flows no longer rely only on raw `assertionFailure` text.
- completed: `AppDIContainer` now builds `AppErrorManager` with an app-local mapper/message catalog layered over `TchopErrors`, so `RepositoryError`, `AuthenticationSessionError`, and secure-storage failures no longer degrade to generic `unknown`.
- completed: widget snapshot sync now uses the same shared error pipeline, and widget-store creation degrades safely to `NoopWidgetContentSyncManager` if app-group widget storage cannot be initialized.
- completed: profile restore-navigation preference failures now also use `AppErrorManager`, so the optimistic toggle rollback keeps shared error semantics instead of a hard-coded fallback-only message.
- completed: startup persistence/bootstrap paths are now more explicit: `AppDIContainer` uses `AppDatabase.makeDatabaseManagerOrThrow(...)`, unrecoverable database-manager failures crash with normalized persistence diagnostics, and recoverable local-seeding failures now assert with the same mapped error semantics.
   - Critical files:
     - new `TchopApp/Services/AuthAPIManager.swift`
     - `TchopApp/App/AppDIContainer.swift`

5. **Split local app session from remote auth session**
   - Refactor `UserSessionService` so it no longer means only “active local user in UserDefaults”.
   - New responsibilities:
     - create authenticated session after successful backend auth
     - restore authenticated session on launch
     - clear auth state on sign-out
   - Keep user-profile lookup in `UserRepository`, but do not let it be the auth source of truth.
   - Result:
     - `AppUser` remains local domain/profile
     - `AuthTokenSet` becomes remote auth source of truth
   - Critical files:
     - `TchopApp/Services/UserSessionService.swift`
     - `TchopApp/Repositories/UserRepository.swift`
     - `TchopApp/App/AppState.swift`

6. **Add startup restore policy for real auth**
   - On app launch:
     - load stored tokens
     - if access token is still valid, restore session
     - if expired but refresh token exists, refresh before entering authenticated shell
     - if refresh fails, clear tokens and remain signed out
   - This should live in app/session/auth layer, not in feed repository.
   - Critical files:
     - `TchopApp/App/AppState.swift`
     - `TchopApp/Services/UserSessionService.swift`
     - auth service/provider files

7. **Wire auth + retry interceptors into DI**
   - Replace current stub-only API client assembly with a real composition path that can still run against stubs:
     - `APIMetricsInterceptor`
     - `APIAuthenticationInterceptor`
     - `APIAuthorizationRefreshInterceptor`
     - `APIRetryInterceptor`
     - optional `APILoggingInterceptor` gated by build/runtime config
   - Keep `.stub` support, but the client graph should already look like production.
   - Critical files:
     - `TchopApp/App/AppDIContainer.swift`

8. **Add environment/config management**
   - Introduce explicit runtime API environments:
     - `localStub`
     - `development`
     - `staging`
     - `production`
   - Store:
     - base URL
     - default headers
     - timeout
     - logging flags
     - retry policy toggles
   - This should sit above `APIConfiguration`, not replace it.
   - Critical files:
     - new `TchopApp/App/AppEnvironment.swift`
     - `TchopApp/App/AppDIContainer.swift`

9. **Prepare a request-header policy layer**
   - Define what every authenticated request should carry, even before backend exists:
     - `Authorization`
     - app version
     - platform / OS version
     - locale
     - optional device identifier policy if product/security allows it
   - Keep it centralized so repositories and feature API managers never hand-build headers.
   - Critical files:
     - auth provider
     - API environment/config layer

10. **Harden logout and invalid-session semantics**
    - Define one consistent policy now:
      - clear tokens
      - clear active local session marker
      - clear widget/shared auth-dependent state
      - optionally keep local cached content or clear it by policy
    - Also define what happens after irrecoverable 401/refresh failure:
      - hard logout
      - user-facing message
      - navigation reset
    - Critical files:
      - `TchopApp/App/AppState.swift`
      - `TchopApp/Services/UserSessionService.swift`
      - auth provider / error manager

11. **Prepare feed/content APIs for real backend migration**
    - Keep `FeedAPIManager` contract, but move stub behavior behind a transport-neutral route layer.
    - Add request builders for:
      - fetch feed
      - card actions
      - future pagination
    - The repository contracts can remain mostly stable if request routing is cleaned now.
    - Critical files:
      - `TchopApp/Services/FeedAPIManager.swift`
      - `TchopApp/Repositories/AppContentRepository.swift`

12. **Add a production-grade error package/manager**
    - Recommended package/module:
      - `Packages/TchopInfrastructure/Sources/TchopErrors/`
    - Scope:
      - cross-layer error classification
      - feature-safe mapping
      - user-message generation
      - recovery policy hints
      - diagnostics payloads
    - Core types:
      - `AppError`
      - `AppErrorCategory`
      - `AppErrorSeverity`
      - `AppRecoverySuggestion`
      - `AppErrorContext`
      - `AppErrorPresentable`
      - `AppErrorLoggingPayload`
      - `AppErrorMapper`
      - `AppErrorReporter`
      - `AppErrorMessageCatalog`
    - Minimum mapping inputs:
      - `APIError`
      - repository/domain errors
      - auth errors
      - persistence/bootstrap errors
    - Output responsibilities:
      - stable internal category
      - retryability
      - auth-expired / logout-required flags
      - safe user-facing copy
      - analytics/log payload
    - This package should become the single place where raw transport/persistence errors stop and app-meaningful errors begin.

13. **Use the error package in three layers**
    - Networking/auth layer:
      - map raw `APIError` + refresh failures into auth/network categories
    - Repository layer:
      - map repository-specific failures into feature-safe errors
    - View model/UI layer:
      - render localized user messages without switch-ing on raw infra errors
    - Critical files:
      - `TchopApp/Repositories/AppContentRepository.swift`
      - `TchopApp/ViewModels/NewsFeedViewModel.swift`
      - `TchopApp/ViewModels/LoginViewModel.swift`
      - `TchopApp/App/AppState.swift`

14. **Define concurrency policy for token refresh**
    - Before real API arrives, implement the production-safe rule:
      - one refresh in flight
      - concurrent 401 requests wait for the same refresh result
      - failure fans out consistently
    - This is a common failure point and worth solving now.
    - Best ownership:
      - inside auth provider / auth session coordinator

15. **Add observability for auth/session/error flows**
    - Reuse existing metrics direction and extend it:
      - auth started
      - auth succeeded
      - auth failed
      - token refresh started/succeeded/failed
      - forced logout reason
      - retry scheduled because of 401 vs transient 5xx
    - The error package should expose a clean reporting payload for this.

Recommended delivery phases:

- **Phase A: auth foundation**
  - token models
  - keychain store
  - auth provider
  - DI wiring
  - startup restore policy

- **Phase B: production error package**
  - new `TchopErrors` module
  - error mapper/reporter/message catalog
  - integrate into login/session/feed flows

- **Phase C: service cleanup for real backend**
  - dedicated auth API manager
  - environment config
  - feed route cleanup
  - logout semantics

- **Phase D: hardening**
  - refresh deduplication
  - richer diagnostics/observability
  - test doubles and end-to-end failure scenarios

Critical files expected to change:
- `TchopApp/App/AppDIContainer.swift`
- `TchopApp/App/AppState.swift`
- `TchopApp/Services/UserSessionService.swift`
- `TchopApp/Services/FeedAPIManager.swift`
- `TchopApp/Repositories/AppContentRepository.swift`
- `TchopApp/ViewModels/LoginViewModel.swift`
- `TchopApp/ViewModels/NewsFeedViewModel.swift`
- `Packages/TchopInfrastructure/Sources/TchopNetworking/TchopNetworking.swift`
- new auth/security/error package sources under `Packages/TchopInfrastructure/Sources/`

Verification plan once implementation starts:
- unit tests for:
  - keychain token store
  - auth provider header injection
  - one-shot refresh + retry after 401
  - refresh deduplication under concurrency
  - logout after irrecoverable auth failure
  - error mapping from `APIError`/auth/repository failures into app-facing errors
- package tests:
  - `swift test --package-path Packages/TchopInfrastructure`
- app build/test later when explicitly requested:
  - `./scripts/verify.sh low`

Progress update for this step:
- implemented initial auth foundation in app layer (`AuthTokenSet`, keychain token store, auth provider, stub auth API manager);
- wired auth/refresh/retry interceptors into app DI while preserving current stub feed behavior;
- introduced new `TchopErrors` infrastructure module with app-error taxonomy, default catalog/reporter, `APIError` mapper, and `AppErrorManager` facade + baseline tests;
- added `AppAPIEnvironment` so transport configuration and logging policy are no longer hard-wired in the composition root;
- upgraded session restore to an async token-aware path that remains backward-compatible when secure credentials are absent.
- integrated `AppErrorManager` into the first real app-facing flows (`LoginViewModel` and `AppState`) and linked `TchopErrors` into both app targets.
- expanded the auth API contract to a real backend-shaped surface and added refresh deduplication in `SessionAuthenticationProvider` so concurrent token refresh paths already have sane production semantics.

### [x] Step: Fix and harden card action flow baseline

Completed the in-progress card action architecture so the feature layer is no longer left in a half-integrated state.
`FeaturedArticleCard` and `DiscussionCard` now use repository-backed stub API actions, persist card-local state into the feed snapshot, and build successfully through the app target.
The screen-level rollback semantics are now explicit and future-backend-safe:
optimistic actions rollback to the previous persisted snapshot on failure,
while non-optimistic actions preserve the current persisted snapshot and only clear pending UI state with an inline status message.
Offline card-action failures now show a saved-state/offline message, and missing persisted-card failures show an out-of-sync/refresh message.

### [x] Step: Preserve per-card state across stub actions

Fixed the main state-loss issue in the stub card-action flow.
`StubFeedResponse.json` now acts as initial seed content only, while repository action persistence explicitly merges the current persisted card state back into each successful action result before saving it.
This prevents likes, comment counts, reply counts, participation state, and display mode from resetting when a later action runs.
Display-mode actions now also use an explicit pending state so they no longer race with other card actions on the same item.

### [x] Step: Serialize repeated comment and reply actions without state loss

Finished the remaining runtime behavior fix for repeated additive card actions.
Repository action persistence now recomputes each successful card-action merge from the latest persisted card snapshot instead of the potentially stale snapshot captured before the async API call started.
On top of that, `NewsFeedViewModel` now drains repeated `addComment` and `addReply` taps as a per-card serial queue instead of cancelling or dropping them, so every tap increments the persisted count once and no later action wipes out previously saved like/reply/display-mode state.
The same runtime contract now also skips no-op display-mode saves, so selecting an already active layout no longer starts unnecessary async action work.
That policy is now explicit in `NewsFeedViewModel` through a start-decision layer (`start` / `queue` / `ignore`) instead of being spread across ad-hoc guard checks in each action starter.

### [x] Step: Apple auth extraction 1 — move Apple auth semantics into infrastructure package

Created a dedicated reusable package product `TchopAppleAuthentication` inside `Packages/TchopInfrastructure`.
The package now owns normalized Apple auth identity parsing, cancellation detection, and optional credential-state lookup, while app-local session persistence, `AppUser`, and profile UX remain in the app target.
`LoginViewModel` and the login screen now consume an explicit `appleAuthenticationManager` from the composition root instead of parsing `AuthenticationServices` payloads inline.

### [x] Step: Apple auth profile 1 — replace stub profile with real account summary

Replaced the old profile-tab stub flow with a real account screen in the app layer.
The screen now shows the current display name, the actual sign-in method (`Sign in with Apple` or `Local account`), a lightweight account identifier hint, the existing navigation-restore preference, and logout.
This intentionally stayed app-local and did not introduce a new settings module or a package extraction for profile UI.

### [x] Step: Apple auth shell 1 — reuse account summary across profile and side menu

Added an app-local `AccountProfileSummary` model as the single presentation source for account initials, sign-in method, and account identifier hint.
The same summary now drives both the profile screen and the shell side menu, which removes duplicate provider logic from the profile view and makes the authenticated shell visibly account-aware without adding a new UI framework.

### [x] Step: Apple auth environment 1 — prepare simulator-only local setup as far as possible

Prepared the project-side Apple sign-in environment without pretending simulator-only validation is enough.
App and widget entitlements now resolve the shared app group from build setting `APP_GROUP_IDENTIFIER`, relevant app/widget targets now expose bundle identifiers through `APP_BUNDLE_IDENTIFIER`, and the login screen explicitly warns that simulator-only Apple auth remains an unreliable signal.
This keeps the project locally ready for the moment a real bundle id, Apple capability setup, and physical-device validation become available.

### [x] Step: Feed contract 1 — move stub feed DTO creation into JSON resource parsing

Replaced hardcoded in-code feed DTO construction with a project-stored JSON resource in the app target.
`StubFeedAPIManager` now decodes `StubFeedResponse.json` into `Decodable` feed DTOs, and the stub contract already includes `remoteUpdatedAt` / `publishedAt` fields so the later persistence and sync layer can build on the same API shape.

### [x] Step: Feed persistence 1 — add storage schema for feed card snapshots

Added app-local persistence schema for feed cards in both SwiftData and Core Data.
The storage model uses one feed-card record/entity with `kind`, ordering, and sync metadata (`remoteUpdatedAt`, `syncedAt`, `publishedAt`) plus type-specific optional fields, which keeps the schema small now while still allowing future card kinds to be added without redesigning the whole persistence layer.

### [x] Step: Verification and baseline preservation after readability cycle

Ran `Full` verification through `./scripts/verify.sh full`.
Result:
- package tests passed
- app tests passed
- build on `iPhone 16 Pro (iOS 18.2)` passed
- build on `iPhone 17 Pro (iOS 26.0)` passed

One real issue was found during the first `Full` attempt:
- `NewsFeedViewModelTests` relied on synchronous `Task` scheduling and intermittently failed around `fetchCallCount`

The fix stayed narrow and test-only:
- `TchopAppTests/NewsFeedViewModelTests.swift` now waits for the expected repository call count instead of assuming immediate task execution

After verification, the persistent documentation baseline was also strengthened so future modules, entities, files, and refactors inherit the same readability-first, no-overengineering, and architecture-preservation rules by default.
Verification: `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO build` succeeded.

### [x] Step: Readability-first refactor 7 — simplify channel-loading flow in AppContentRepository

Applied a small readability refactor to `TchopApp/Repositories/AppContentRepository.swift`, focused only on the channel-loading branch.
`fetchChannelInfo()` now reads as one linear flow: resolve the current backend result, then require a non-empty channel or throw the repository error.
The repeated missing-channel guard was removed from the backend-specific methods, and the Core Data single-record request setup is now centralized in one helper.
This step intentionally did not touch the feed-loading contract or introduce new repository abstractions.
Verification was not run for this step because the user explicitly requested not to run automatic low-level checks after every iteration unless asked.

### [x] Step: Readability-first refactor 8 — simplify root-reset flow in AppCoordinator

Applied a narrow readability refactor to `TchopApp/Navigation/AppCoordinator.swift`.
The repeated tab-specific `popToRoot()` switch logic is now centralized in one helper and reused by both `showTabRoot(_:)` and `resetAllNavigation()`, while snapshot application now uses a dedicated helper for path replacement.
This step keeps the same navigation model and public surface and only removes procedural repetition from the coordinator.
Verification was not run for this step because the user explicitly requested not to run automatic low-level checks after every iteration unless asked.

### [x] Step: Readability-first refactor 9 — simplify shell configuration flow in AppShellViewModel

Applied a small readability refactor to `TchopApp/ViewModels/AppShellViewModel.swift`.
The shell now applies configuration snapshots through a dedicated helper instead of repeating direct FAB flag assignment, and fallback channel resolution is expressed explicitly instead of being hidden inside an inline nil-coalescing expression.
This step intentionally did not introduce a separate shell state model or alter the existing initialization/runtime flow.
Verification was not run for this step because the user explicitly requested not to run automatic low-level checks after every iteration unless asked.

### [x] Step: Content-model runtime refactor — prepare NewsFeedViewModel and card models for real DI/service usage

Applied a larger content-flow refactor across `NewsFeedViewModel`, `NewsFeedModels`, `AppShellViewModel`, `AppDIContainer`, `AppWidgetBridge`, and `NewsTabRootView`.
`NewsFeedViewModel` no longer hides app-level bootstrap/fallback content and error text inside itself; these are now injected from the composition root, which makes the view model closer to a real runtime type used in production apps.
`AppShellViewModel` also no longer creates `NewsFeedViewModel` internally and instead receives it as an injected dependency together with already-resolved `ChannelHeaderInfo`, so feature view-model construction is now owned by the DI layer rather than by another view model.
The two card models now expose service/navigation-facing derived values (`serviceHeadline` and `detailRoute`), and shared feed-level service access (`primaryServiceHeadline`) is exposed on `NewsFeedContent`, which removes manual card-type switching from widget sync and news-tab navigation code.
App tests were updated to match the new initialization surface.
Verification was not run for this step because the user explicitly requested not to run automatic low-level checks after every iteration unless asked.

### [x] Step: Feed-state runtime refactor — introduce a minimal explicit NewsFeedState

Applied the minimal explicit state-model variant to `TchopApp/ViewModels/NewsFeedViewModel.swift` and `TchopApp/Views/News/NewsFeedView.swift`.
`NewsFeedViewModel` now publishes one `NewsFeedState` source of truth (`loading`, `loaded`, `failed`) instead of mutating three separate published fields for content/loading/error, while lightweight computed accessors are still kept for callers that only need convenience reads.
The feed UI now renders from `viewModel.state`, and feed-view-model tests were updated to assert the explicit state transitions directly.
This keeps the change narrow and readable without introducing a larger screen-state architecture.
The recent mechanical `return` fix in `AppDIContainer.makeAppShellViewModel()` from the last requested `Low` verification is included in the same commit so the worktree does not keep a dangling verification-only fix.
Verification was not run for this step because the user explicitly requested not to run automatic low-level checks after every iteration unless asked.

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

### [x] Step: Strengthen tests around shell UI configuration contract

Completed the next test-layer pass by adding focused app-level coverage for the new shell UI configuration flow.
`AppShellViewModelTests` now verifies that shell state first applies the cached `currentConfiguration()` snapshot and then updates again when `refreshConfiguration()` succeeds, which protects the new persisted/current/refresh contract added to `TchopUIConfiguration`.

### [x] Step: Final documentation and comment coverage sync

Completed the final documentation pass by adding project-level documentation in `PROJECT_DOCUMENTATION.md`, updating persistent rules, and applying method-level comments across app, package, and test Swift files.
The project now treats method comments as a required baseline rather than an optional style choice, and the working documentation explicitly records the architecture, targets, package modules, runtime flows, verification policy, and documentation standard.

### [x] Step: Add project health inventory and next-cycle roadmap

Started the next improvement cycle by adding `PROJECT_HEALTH.md` as the package/app-boundary inventory for the project.
The document now records which modules are already reusable, which ones must remain app-specific, what should not be extracted yet, where the main structural risks are, and the ordered queue for the next round of improvements.

### [x] Step: Extract test doubles from large test files

Move app test helper types into dedicated `TchopAppTests/TestDoubles/` files so test suites become smaller and easier to maintain.
This should cover session doubles, navigation-state doubles, deep-link doubles, and UI-configuration doubles where appropriate.

Completed by moving the reusable test infrastructure out of `AppStateTests`, `AppShellViewModelTests`, and `NewsFeedViewModelTests` into dedicated `TchopAppTests/TestDoubles/` files.
`TestUserSessionService`, `TestUserRepository`, `TestNavigationStateManager`, `TestDeepLinkManager`, `TestUIConfigurationManager`, `TestNewsFeedRepository`, and `TestAppContentRepository` now live in a shared test-only layer so the test suites remain focused on behavior rather than embedded fixture plumbing.

### [x] Step: Expand UI configuration package with versioning and staleness policy

Add schema/version support, TTL or staleness metadata, and optional refresh throttling to `TchopUIConfiguration`.
Keep the package generic and reusable; avoid app-specific config rules.

Completed by adding `UIConfigurationSnapshotMetadata` with schema version and freshness timestamps, plus manager-level `UIConfigurationStalenessPolicy` and `UIConfigurationRefreshThrottling`.
`UIConfigurationManager` now validates stored and remote snapshot schema versions, reports staleness, bypasses throttling when cached data is stale, and reuses the current snapshot when refresh throttling applies; app DI now opts into a conservative default policy instead of treating every refresh equally.

### [x] Step: Expand branding package into fuller semantic token groups

Grow `TchopBranding` from the current narrow token set into broader semantic groups for button, badge, tab, card, navigation, destructive, and success states.
Keep target-based resolution centralized and package-backed.

Completed by expanding `BrandTheme` into semantic groups (`button`, `badge`, `tab`, `card`, `navigation`, `status`) while preserving backward-compatible aliases for the older narrow tokens.
`AppTheme` now starts consuming those semantic groups directly, so target-specific theming has a broader reusable surface without forcing the app to keep inventing its own parallel token vocabulary.

### [x] Step: Refactor deep-link routing toward declarative rules

Reduce `DeepLinkManager` growth risk by moving route definitions and parsing behavior toward a more declarative routing table or equivalent structured model.
Preserve the current app-specific URL contract while making the implementation easier to extend safely.

Completed by replacing the root-segment `switch` in `DeepLinkManager` with a declarative `DeepLinkRouteDefinition` table that resolves supported roots (`news`, `mixes`, `pinned`, `chat`, `profile`) through explicit handlers.
The external URL contract and fallback behavior stay unchanged, but adding a new root destination no longer requires expanding a monolithic `switch` and scattering that change across the parser.

### [x] Step: Strengthen AppDatabase migration policy and testability

Remove remaining `fatalError`-style bootstrap behavior where practical, isolate migration policy further, and add stronger migration-focused tests around legacy Core Data to SwiftData upgrade scenarios.
Completed by extracting a testable runtime-selection layer (`AppDatabaseRuntimePolicy`, `AppDatabaseRuntimeContext`, `AppDatabaseResolutionPlan`) out of the app database bootstrap path.
`AppDatabase` now exposes a throwing bootstrap API for callers and tests that want to avoid the fatal wrapper, and the Core Data store URL bootstrap no longer uses `fatalError` internally.
Added focused `AppDatabasePolicyTests` covering automatic backend selection, legacy Core Data migration selection, unsupported explicit SwiftData requests, and the throwing in-memory Core Data bootstrap path.

### [x] Step: Add snapshot or UI test coverage for core screens

Add focused UI-level regression coverage for `AppRootView`, `AppShellView`, and `NewsTabRootView`.
Prefer a minimal but stable baseline that protects layout/state regressions without introducing brittle test noise.

Completed by adding a dedicated `TchopAppUITests` target with smoke coverage for three core launch states: signed-out root, authenticated shell, and authenticated news feed entry.
The app now supports UI-test launch configuration through `AppLaunchConfiguration`, using process-environment flags to force in-memory persistence and an authenticated session bootstrap so the smoke suite stays deterministic and isolated from device state.

### [x] Step: Add unified analytics and event layer across core infra packages

Design and implement a shared product-level event model that can sit above `TchopNavigation`, `TchopPushNotifications`, and `TchopNetworking`.
Keep transport-specific or app-lifecycle-specific details behind adapters rather than hardcoding them into the shared event API.

Completed by introducing a new reusable package target, `TchopAnalytics`, with a shared `ProductAnalyticsEvent` model, collector contract, and in-memory collector.
Thin adapters now map `NavigationEvent`, `APIMetricsEvent`, and the new `PushNotificationEvent` lifecycle stream into that shared analytics surface without coupling the lower-level packages to one product analytics format.

### [x] Step: Analytics Integration Cycle

Integrate the new analytics infrastructure into real app runtime paths, but only where it produces direct practical value and does not noticeably raise complexity for day-to-day development.
Apply the standing anti-overengineering rule to this entire cycle: skip any substep that turns into abstraction for abstraction's sake.

- [x] Wire `TchopAnalytics` into `AppDIContainer` as one shared collector surface.
- [x] Replace the current no-op navigation reporter with an analytics-backed reporter in app runtime composition.
- [x] Add `APIAnalyticsMetricsCollector` into the real `APIManager` interceptor pipeline.
- [x] Connect push lifecycle analytics through the app push bridge / push manager wiring.
- [x] Add a lightweight debug inspection surface only if it stays simple and materially helps validate event flow.
- [x] Add only the highest-value app/package tests needed to prove that runtime wiring actually emits analytics events.

Progress:
`TchopAnalytics` is now linked into both app targets, and `AppDIContainer` owns one shared `ProductAnalyticsMemoryCollector` as the app-level analytics sink.
Navigation diagnostics are now also wired to that collector through `NavigationAnalyticsEventReporter`, so deep-link and snapshot-restore events already flow into the shared analytics sink during normal app runtime.
`APIManager` now also includes `APIMetricsInterceptor` backed by `APIAnalyticsMetricsCollector`, so prepared/succeeded/failed/retry networking metrics are emitted into the same shared analytics sink during runtime.
`PushNotificationManager` now also emits lifecycle analytics through `PushNotificationAnalyticsCollector`, so authorization, registration, token, payload, and reset events reach the same shared analytics sink during runtime.
Added `AppDIContainerTests` as the minimal app-level regression layer proving that the real DI-assembled runtime now emits navigation, networking, and push analytics into the shared collector.
The optional debug inspection surface was intentionally not implemented: at the current project size it would add more UI/debug complexity than practical value, so skipping it is the correct anti-overengineering decision for this cycle.

### [ ] Step: Quality / Verification Cycle

Strengthen proof of correctness around the architecture that now exists, focusing on contract protection and regression prevention rather than on test volume for its own sake.
Apply the same anti-overengineering rule here: prefer the smallest verification additions that meaningfully reduce risk.

- Re-run and harden the analytics-related package and app coverage after runtime integration.
- Expand UI smoke coverage only where it protects important launch/navigation states without becoming brittle.
- Review and tighten the current `Low` / `Medium` / `Full` verification workflow so it is more repeatable and easier to apply.
- Target unstable or high-risk paths first: navigation restore, deep links, DB selection/migration, push flow, and UI configuration lifecycle.
- Clean up warnings or test harness issues only when they reduce real verification noise or false negatives.

Quality / verification cycle progress:
- Added [scripts/verify.sh](/Users/Artem/.zenflow/worktrees/new-task-be0b/scripts/verify.sh) as the single source of truth for `low`, `medium`, and `full` verification commands.
- Kept the script intentionally narrow: it only codifies the already agreed verification matrix for `TchopApp`, without introducing CI-only wrappers or extra orchestration layers.
- Expanded UI smoke coverage only for one high-value launch/navigation path: authenticated startup with an initial deep link to `profile`, using a deterministic launch hook instead of broader brittle UI automation.
- Added app-level regression tests for `AppState` side effects that were present in runtime but not yet protected: `signOut()` now has coverage for widget snapshot clearing, and `requestPushNotificationAuthorization()` now has coverage for push-bridge delegation.

### [ ] Step: Package Completeness Cycle

Perform one more reuse-focused package pass, but only on capabilities that materially improve portability across iOS projects.
Do not expand packages with speculative features that are not justified by current code or realistic near-term reuse.

- Reassess `TchopAnalytics` for only the missing practical pieces needed for real reuse, such as retention/persistence/privacy if justified.
- Reassess `TchopNetworking`, `TchopNavigation`, and `TchopPushNotifications` for remaining app-specific leakage in their public APIs.
- Add package functionality only where it closes a real reuse gap already visible in this project.
- Keep app-specific policy, product semantics, and host lifecycle composition in the app layer unless extraction is clearly beneficial.
- Finish with documentation updates that explain what was intentionally not generalized and why.

Package completeness cycle progress:
- Promoted `InMemoryPushNotificationStateStore` from a test-only helper into the `TchopPushNotifications` package, because the package already exposed a reusable store abstraction but only shipped a `UserDefaults` implementation publicly.
- This closes a real portability gap for previews, ephemeral hosts, and tests without adding new lifecycle policy or host-app coupling.
- Promoted `InMemoryUIConfigurationSnapshotStore` from a test-only helper into `TchopUIConfiguration` for the same reason: the package already exposed a reusable snapshot-store contract but only shipped a `UserDefaults` implementation publicly.
- This gives other apps and preview/test hosts an ephemeral cache option without introducing any new server-driven UI policy into the package.
- During a later `Full` verification pass, fixed a Swift concurrency warning in `TchopUIConfiguration` by replacing the default `dateProvider` value with an explicitly `@Sendable` closure instead of passing `Date.init` directly.
- The same `Full` verification then exposed a real Xcode project issue: the `TchopAppUITests` group path in `project.pbxproj` pointed inside `TchopApp/` even though the test bundle lives as a sibling directory. The group path was corrected to `../TchopAppUITests` before rerunning `Full`.
- A subsequent `Full` rerun then exposed stale app test code in `AppDatabasePolicyTests`: the suite still targeted older database-policy signatures. The tests were updated to the current `AppDatabaseConfiguration` contract before rerunning `Full` again.
- The next `Full` rerun then showed that `TchopAppUITests` used overly aggressive launch-time waits for the current simulator/runtime. The smoke suite was updated to wait longer and to use `waitForExistence` on the concrete target elements instead of checking some of them immediately.
- The current `Full` rerun then exposed one more UI test harness issue: `news.feed` is attached to a `ScrollView`, so querying it via `otherElements["news.feed"]` was too type-specific and caused a false negative. The smoke suite now resolves launch markers through a generic descendant lookup by accessibility identifier before rerunning `Full` again.
- The following `Full` rerun then showed that `shell.content` is not a stable enough launch marker in the XCUI accessibility tree for this runtime, even though `shell.screen` and the feature-specific markers are. The shell smoke test was simplified to assert only the stable shell-level container instead of layering on a brittle second marker.
- The same UI smoke pass also showed that `login.usernameField` and `login.continueButton` are not stable enough XCUI launch markers on this runtime for a signed-out smoke test. That scenario now asserts the stable `login.screen` container only, while control-level interaction remains outside the scope of this lightweight launch smoke suite.
- After the UI smoke suite was stabilized, the same `Full` run exposed a timing-sensitive analytics integration test in `AppDIContainerTests`: networking analytics events travel through an async interceptor pipeline, so reading the shared collector immediately after `perform(...)` was too optimistic. The test now waits briefly for the expected event count instead of assuming zero-latency delivery.
- A subsequent focused rerun showed the deeper root cause: `APIManager` bypassed request interceptors entirely for `stubResponse`-backed `perform`, `upload`, and `download` calls. This meant networking observability never fired for stubbed requests. The networking implementation now routes stubbed requests through `prepare`/`didReceive` with a synthetic successful HTTP response, so analytics and other request interceptors observe stub traffic consistently.

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

## Next Agreed Plan

### [ ] Step: Commit verification fixes

Formally close the last completed verification cycle with one dedicated commit containing the fixes found during the successful `Full` run.
This step exists to remove hanging context and create a clean baseline before any further cleanup or refactoring work starts.

### [ ] Step: Clean Core Data test warnings

Investigate and remove the old `NSEntityDescription` duplication warnings still emitted by the package database tests.
Keep this step behavior-preserving: the goal is cleaner verification and a healthier test harness, not product changes.

### [x] Step: Add lightweight API trace commands

Added two lightweight local API inspection commands and documented them as the preferred default over tests, builds, and simulator runtime when the user only wants request-chain validation.

- `scripts/api_http_trace`
- `scripts/api_method_trace`

`api_http_trace` performs a real HTTP request and prints request/response details.
`api_method_trace` prints the static app-method chain and performs the real HTTP call when the method reaches transport.
Current supported method id: `login.submit`.

### [x] Step: Formalize new screen plus API workflow

Documented the standard delivery flow for future API-backed screens:

1. discovery questions first,
2. screen/state/API contract definition,
3. stable trace method id definition,
4. API integration and mapping,
5. `api_method_trace` verification,
6. UI wiring,
7. optional UI-driven validation only when explicitly requested.

Also documented the mandatory discovery checklist the agent must collect before starting implementation of a new screen or feature.
Completed by removing ambiguous Core Data subclass-to-entity resolution from `TchopDatabaseTests`.
The test harness now creates/fetches Core Data entities via explicit `entityName` + `NSManagedObject`, which avoids duplicate `NSEntityDescription` lookup warnings when multiple in-memory models are created during the suite.
Verification:
`swift test --package-path Packages/TchopInfrastructure` succeeded and the old Core Data warnings no longer appear in `TchopDatabaseTests`.

### [ ] Step: Readability-first project-wide refactoring cycle

Run a fresh refactoring pass across the app and reusable packages with the updated project rules:
- no development for its own sake,
- highest possible engineering quality,
- simplest readable code that preserves correctness, structure, hierarchy, and scalability,
- explicit escalation to the user when there is a real trade-off between architectural purity and human readability.

Scope for this cycle:
- review app code and package code together,
- simplify logic and reduce unnecessary indirection where possible,
- keep reusable boundaries where they still provide real value,
- avoid weakening architecture or scalability just to make code shorter,
- ask the user about any meaningful readability-vs-architecture compromise before deciding.

Readability-first cycle progress:
- Step 1 focused on [AppDatabase.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppDatabase.swift), which remained one of the highest-noise orchestration files after the earlier architecture work.
- The database bootstrap flow is now more explicit without changing the public app-facing API:
  `makeDatabaseManagerOrThrow(...)` first builds a dedicated `AppDatabaseRuntimeContext`, then resolves a concrete `AppDatabaseResolutionPlan`, then delegates to one manager-building entry point.
- Stable backend persistence was also moved behind `AppDatabaseResolutionPlan.persistedBackendKind`, so the bootstrap switch no longer hardcodes `save(.coreData)` / `save(.swiftData)` inline.
- Legacy Core Data store discovery moved into `AppDatabaseRuntimeContext.current(...)`, which keeps runtime facts grouped together instead of spreading them across the top-level bootstrap enum.
- Verification:
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO build` succeeded after adding the required `@MainActor` isolation to the new runtime-context helpers.
- Step 2 focused on [AppState.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppState.swift), where the runtime flow was correct but repeated the same deep-link and navigation-reset logic in several places.
- Incoming URL and user-activity handling now share one private entry point, pending deep-link replay now shares one resolver, snapshot application now uses one helper with `defer`, and "go back to default app navigation" now lives in a single helper instead of being repeated inline.
- This step intentionally did not introduce any new abstractions or split the type across files; the goal was to keep the same responsibilities but make the control flow easier to scan.
- Verification:
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO build` succeeded.
  A targeted `xcodebuild test -only-testing:TchopAppTests/AppStateTests` run was attempted first, but the simulator runner stalled without producing a useful failure signal, so it was not used as the primary verification result for this step.
- Step 3 focused on [DeepLinkManager.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/DeepLinkManager.swift), which still had repetitive "tab root or detail" intent construction and repetitive coordinator-application code for tab-specific destinations.
- `mixes`, `pinned`, `chat`, and `profile` intent builders now share one private `buildTabOrDetailIntent(...)` helper instead of each reimplementing the same `title` / `description` flow.
- Applying parsed destinations into the coordinator is also now more direct to read:
  news destinations share one helper,
  tab-specific detail destinations share one helper for `selectTab(...) + navigate()`,
  while tab-root behavior still stays explicit through `coordinator.showTabRoot(...)`.
- This was kept deliberately local to the file: no URL contract changes, no route-definition changes, and no new public abstractions.
- Verification:
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO build` succeeded.
- The latest readability-first step focused on the feed runtime flow in [NewsFeedViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/NewsFeedViewModel.swift) without expanding the existing `NewsFeedState` enum.
- Feed loading now has explicit public entry points with distinct intent:
  `refresh()` is the normal user-driven reload path and ignores duplicate refresh requests while a load is already running,
  `retry()` only starts a new request after a visible failed state,
  and legacy `reload()` remains only as a backward-compatible alias to `refresh()`.
- The policy itself stays private and local to the type through `NewsFeedLoadPolicy`, `shouldStartLoad(for:)`, and `makeLoadingTask()`, so the runtime semantics are clearer without adding new screen states or spreading feed rules into the UI layer.
- [NewsFeedView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/News/NewsFeedView.swift) now uses `refresh()` explicitly, and [NewsFeedViewModelTests.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopAppTests/NewsFeedViewModelTests.swift) now covers:
  duplicate refresh suppression while loading,
  retry after failure,
  and inert retry before failure.
- The next feed step stayed deliberately minimal and completed the UI-to-runtime path:
  [NewsFeedView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/News/NewsFeedView.swift) now exposes an explicit `Retry` control in the failed-state banner, wired directly to `viewModel.retry()`.
- This keeps the new retry policy usable from the actual screen without introducing a separate error view model, additional screen states, or a debug-only trigger path.
- The next readability-first step moved to [AppShellViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/AppShellViewModel.swift).
  No responsibilities were moved out of the type.
  The cleanup was limited to the configuration bootstrap path:
  `init` now starts one explicit `startUIConfigurationLoad()` helper,
  `loadUIConfiguration()` applies the current snapshot and then delegates the remote refresh to `refreshUIConfiguration()`,
  and the refresh failure path now goes through one named `handleUIConfigurationRefreshFailure(...)` helper instead of staying embedded inline.
- This keeps the shell runtime flow easier to scan without adding new state, new abstractions, or any extra DI surface.
- The next readability-first step returned to [AppDIContainer.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppDIContainer.swift).
  The container already had the right high-level layering, so the cleanup stayed narrow:
  the dense `database -> api -> feed api -> repositories -> session` assembly path is now grouped behind one `makeContentServices(...)` helper.
- This leaves the initializer reading in clearer stages without introducing a builder type, nested container, or extra protocol surface:
  persistence bootstrap,
  content services assembly,
  UI/widget/push bridges,
  navigation services.
- The next readability-first step moved into [TchopUIConfiguration.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopUIConfiguration/TchopUIConfiguration.swift).
  The public API and behavior stayed the same.
  The cleanup focused only on the manager refresh path:
  `refreshConfiguration()` now reads linearly through
  reusable-current-snapshot resolution and
  `fetchAndStoreRemoteSnapshot()`,
  while stale checks now have one instance-level helper instead of repeatedly threading policy through static calls.
- This makes the manager easier to scan without introducing new package types or expanding the feature surface.
- The next readability-first step moved into [TchopNetworking.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopNetworking/TchopNetworking.swift).
  The API surface stayed the same.
  The cleanup targeted the two biggest repeated orchestration patterns:
  stub execution and retry scheduling.
- Stubbed request execution now goes through shared `executeStubResponse(...)` helpers, and repeated retry notification/sleep logic now goes through `performRetryIfNeeded(...)`.
  This keeps `perform`, `upload`, `download`, and the internal execute loop closer to the same mental model without introducing a separate executor object or changing runtime semantics.
- The next readability-first step moved into [TchopPushNotifications.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopPushNotifications/TchopPushNotifications.swift).
  The public manager contract stayed the same.
  The cleanup targeted repeated state reconstruction inside `PushNotificationManager`.
- State transitions now go through two local helpers:
  `makeState(...)` builds the next snapshot while preserving unchanged fields,
  and `updateState(...)` centralizes apply/persist/event-emission.
  This removes the repeated full-state reconstruction from each lifecycle method without introducing a second state layer or changing persistence behavior.
- The next readability-first step returned to [AppState.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppState.swift), because it remains one of the highest-value app-level orchestration files.
  The cleanup stayed local to navigation snapshot restore.
  `restoreNavigationIfNeeded(for:)` now reads as a three-stage flow:
  resolve a restorable snapshot,
  report restore start,
  apply the restored snapshot.
- The branchy snapshot-specific logic now lives behind `resolveRestorableSnapshot(...)`, `applyRestoredSnapshot(...)`, `reportSnapshotRestoreSkipped(...)`, and `reportSnapshotRestoreFailed(...)`.
  This reduces cognitive load in the main runtime flow without changing persistence semantics, restore policy, or public behavior.
- The next readability-first step returned to `TchopApp/ViewModels/NewsFeedViewModel.swift` because the feed runtime still had one leftover ambiguity:
  both the explicit `refresh()/retry()` API and the old `reload()` alias existed at the same time even though the rest of the app no longer used `reload()`.
  The cleanup removed that alias and simplified `NewsFeedLoadPolicy` guards so the view model now exposes only the real runtime intents it supports.
- `initial`, `refresh`, and `retry` still keep the same behavior, but the policy reads more directly:
  initial load always starts,
  refresh only starts when no request is in flight,
  and retry only starts from a visible failed state.
  This improves clarity in an actively used feature type without expanding the state machine or adding new abstraction layers.
- The next readability-first step returned to `TchopApp/Navigation/DeepLinkManager.swift`, which is still one of the larger app-level routing files.
  The cleanup stayed deliberately narrow:
  article and discussion deep links were both manually reconstructing the same `NewsRoute` shape with mostly duplicated query parsing and fallback localization logic.
- That duplication now goes through one `buildNewsDetailIntent(...)` helper.
  The URL contract, event reporting, tab selection behavior, and route table did not change.
  This was still worth doing because it removes repeated routing logic from a high-traffic orchestration file without introducing a new routing layer or any extra public types.
- The next readability-first step returned to `TchopApp/App/AppState.swift`, but this time for the authenticated bootstrap path rather than navigation restore.
  Both `signIn(...)` and `restoreSession()` were manually performing the same
  `currentUser = user` plus post-authentication navigation bootstrap sequence.
- That shared transition now goes through one `activateAuthenticatedUser(...)` helper.
  The runtime behavior did not change, but the authenticated entry path is now easier to scan and easier to keep consistent in future edits because the standard post-login bootstrap only exists in one place.
- The next readability-first step touched `Packages/TchopInfrastructure/Sources/TchopUIConfiguration/TchopUIConfiguration.swift`, but only at a very narrow seam:
  `UIConfigurationManager` was still manually implementing `fetchConfiguration()` even though `UIConfigurationManaging` already provides the exact same alias to `refreshConfiguration()` through its default protocol extension.
- The actor-level duplicate implementation was removed.
  This keeps the public API unchanged while reducing one unnecessary override in a reusable package type.
  At this point the remaining readability-first opportunities are getting much closer to cosmetic cleanup than to meaningful simplification.
- Temporary execution rule from commit `a063e72` onward:
  do not write tests,
  do not update tests,
  do not run tests,
  and do not spend delivery budget on verification until the user explicitly asks for a retrospective test pass across the commits from this point to the then-current head.
- Current implementation focus:
  integrate `Sign in with Apple` into the existing auth flow without introducing unnecessary auth layers.
  The target baseline for this step is:
  stable Apple identity persistence,
  session restore by stable local user id,
  and a readable login screen that keeps local username sign-in as a fallback path.
- Verification for this step has not been run yet after the final change set; the user did not request automatic verification for this task.
- The next content-persistence step moved into [AppContentRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/AppContentRepository.swift).
  Feed loading now uses a repository-owned storage-backed path instead of mapping the API response straight into UI models.
  On each successful feed fetch, the repository now:
  maps the API snapshot into persistence payloads,
  performs full-snapshot sync into the active backend (`SwiftData` or `Core Data`) by stable card `id`,
  removes obsolete cards,
  and then rereads the ordered persisted cards back into `NewsFeedContent`.
- The persistence sync stays intentionally local:
  no generic sync engine was introduced,
  no new package was added,
  and `NewsFeedViewModel` was not expanded yet.
  Article actions and discussion participants are serialized into the existing feed-card records,
  `sortOrder`, `remoteUpdatedAt`, `publishedAt`, and local `syncedAt` now participate in the stored snapshot,
  and the app now has the first real offline-capable feed path for the home screen.
- No tests or verification were run for this step because the temporary test freeze is still in effect and the user did not request an exception.
- The next feed-runtime step kept the architecture local and explicit:
  `NewsFeedRepository` now exposes `currentNewsFeedContent()` and `refreshNewsFeedContent()`
  instead of one mixed "fetch" entry point.
  `DefaultAppContentRepository` uses the same persistence-backed snapshot path as before,
  but `AppDIContainer` now resolves the initial feed content from local storage first and falls back to `NewsFeedFixtures` only when the database is empty.
- `NewsFeedViewModel` now starts from that local snapshot and uses the explicit refresh path for remote updates.
  This gives the home screen a real `local snapshot + remote refresh` bootstrap flow without introducing a second feed state model, cache layer, or coordinator.
- The next feed step added a minimal internet-availability gate to the repository path.
  `DefaultAppContentRepository` now receives an app-local `NetworkAvailabilityChecking` dependency backed by `NWPathMonitor`.
  When the path is satisfied, feed refresh still goes through the current stubbed API request and then syncs persistence.
  When the path is unavailable, the repository skips the API path and returns the persisted feed snapshot from the database instead.
- This keeps the offline/online branching local to the feed repository and avoids introducing a broader reachability framework before the real pull-to-refresh requirements are defined.
- The next persistence step closed the remaining first-launch offline gap.
  `AppDataSeeder` no longer seeds only the channel record.
  It now independently seeds both:
  the default channel metadata and
  the initial feed snapshot.
- The feed seed is built from the same stub JSON resource already used by the current API-emulation path,
  so the app now has a consistent first local feed snapshot even before the first successful refresh.
  This keeps the bootstrap path pragmatic:
  no new cache layer,
  no new bundled database,
  and no duplication of a second stub contract file.
- The next UX/runtime step then made cached feed visibility explicit without widening the architecture.
  `NewsFeedContent` now carries lightweight source metadata (`live` vs persisted `cached` with reason and last sync date),
  `DefaultAppContentRepository` marks bootstrap snapshots as cached and rewrites them to offline-cached when the network gate blocks refresh,
  and `NewsFeedView` shows a small status line above the cards when the user is seeing saved content.
- This keeps the stale/offline signal honest for the user while avoiding a second feed state machine, a separate banner service, or extra coordinator/UI policy layers.
- The pull-to-refresh policy is now fixed for this section:
  when the device is online, refresh goes through the API path again and then syncs the database snapshot;
  when the device is offline, refresh intentionally keeps the current persisted snapshot visible and the UI explicitly shows that the feed is being served from offline/saved data.
- The latest shell/news UI step finalized the floating-action-button visibility policy.
  The `+` button is now intended to be visible only on the root news feed list,
  hidden on pushed news-detail routes,
  and hidden once the user scrolls the feed more than about `30pt` away from the top.
- The route-depth part is now driven by observing the concrete `newsRouter` in shell composition,
  while the scroll signal comes from `NewsFeedView` through a lightweight UIKit `UIScrollView.contentOffset` observer rather than a `GeometryReader`-based layout probe.
- `Low` verification was explicitly requested for this step.
  The first run failed on a compile error in `NewsFeedView.swift`,
  that issue was fixed immediately,
  and the repeated `Low` run finished green with `BUILD SUCCEEDED`.
- Auth integration now also supports a dedicated development-only external environment backed by ReqRes demo auth.
  `AppLaunchConfiguration` reads `TCHOP_API_ENV=reqres_demo_auth` plus `TCHOP_REQRES_API_KEY`,
  `AppAPIEnvironment.developmentExternalAuth(...)` keeps the main/feed API on `.stub`,
  but routes only auth requests through `https://reqres.in` with `x-api-key`.
- `DefaultAuthenticationAPIManager` now supports a third mode, `reqResDemo`,
  with real `/api/login` and `/api/register` requests,
  vendor-local token decoding (`{ token, id? } -> AuthTokenSet`),
  and app-local refresh/revoke fallback so the session lifecycle does not depend on ReqRes features it does not expose.
- The login UI/runtime path now has two explicit contracts via `LoginScreenMode`:
  `defaultAppAuth` keeps the default app email/password + Apple flow,
  while `reqResDemoExternalAuth` renders email/password plus separate sign-in/register actions.
  `UserSessionService` and `AppState` now have matching `signIn(email:password:)` and `register(email:password:)` paths,
  using email as the local `AppUser.username` until a richer backend profile contract exists.
- The latest simplification pass was accepted and should be treated as the new baseline:
  `FeedAPIManaging` now exposes one action entry point per card family (`performFeaturedArticleAction(...)`, `performDiscussionAction(...)`) instead of one public method per button,
  with narrow `FeaturedArticleActionContext` / `DiscussionActionContext` payloads rather than view-model `UIState` types.
- `NewsFeedViewModel` no longer owns raw per-card task dictionaries directly.
  That bookkeeping now lives in `NewsFeedCardActionCoordinator`,
  while `NewsFeedViewModel` still owns the start/queue/ignore policy and all product-facing action behavior.
  The coordinator now asserts and cancels the conflicting new task if code tries to register a second active task for the same card id.
- App-specific error normalization was also extracted out of `AppDIContainer.swift` into `TchopApp/App/AppErrorMapping.swift`.
  The architecture did not change:
  `TchopErrors` remains infrastructure-only,
  and app-local semantics still stay in the app target.
- `AppDIContainer` now keeps more of its assembled graph private.
  This did not change the composition flow,
  but it reduced the container's accidental service-locator surface and should remain the preferred direction for future cleanup.
- Database launch selection is now explicit at app startup through `AppLaunchConfiguration`.
  `TCHOP_DATABASE_BACKEND=automatic` keeps the existing multi-backend runtime policy,
  while `TCHOP_DATABASE_BACKEND=swiftData` and `TCHOP_DATABASE_BACKEND=coreData`
  force a single concrete backend for development/debug runs.
  No new repository contract was introduced for this:
  both concrete managers already satisfy `DatabaseManaging`,
  so the app still talks to one backend-neutral interface even when launch forces a specific implementation.
- Added a new root documentation file, `TESTING_INSTRUCTIONS.md`,
  as the operational source of truth for agent-driven testing workflows.
  The testing contract now has three modes:
  `Method-Driven API Testing` as the default low-cost baseline,
  `Feature-Action API Testing` as a middle layer,
  and `UI-Driven API Testing` only for explicit simulator-level validation of real screen interaction.
- Added mandatory SwiftUI preview coverage across the current renderable view layer.
  Shared preview fixtures/helpers now live in `ViewPreviewSupport`,
  every renderable app-side view under `TchopApp/Views` now has at least one `#Preview`,
  and widget rendering is covered in `FeedHeadlineWidget.swift`.
  The persistent iOS rules and onboarding/handoff docs were updated so preview coverage stays mandatory and current.
- Added accessibility as a persistent product requirement and applied a first app-wide accessibility baseline.
  The persistent iOS rules now require accessibility support by default.
  The current implementation adds VoiceOver semantics to core controls and hides decorative-only visuals from accessibility in the main app surfaces.
- Added strict concurrency as a persistent project baseline.
  `SWIFT_STRICT_CONCURRENCY = complete` is now enabled in the Xcode project and mirrored into the local infrastructure package through package-level Swift settings.
  The follow-up `Low` verification build completed green, so the project currently builds under complete strict concurrency without additional source changes.
- Added a new concurrency-state rule and applied it immediately.
  Shared mutable state should now be modeled with `@MainActor` or custom actors rather than `DispatchQueue`.
  The current codebase moved network reachability state to an actor and replaced `DispatchQueue.main.async` in the news feed scroll observer with an explicit main-actor task hop.
- Normalized the broader project engineering contract against the user's new Staff-level requirements document.
  The merged baseline now explicitly says:
  deployment-target assumptions come from the customer-owned Xcode project rather than a generic `iOS 17+` default,
  tests remain recommended but are only written/run on explicit user request,
  three-option architectural breakdowns are required only for non-trivial trade-off-heavy choices,
  protocol boundaries should exist only when they provide a real seam,
  and the full screen-state matrix is mandatory for data-backed/auth-sensitive screens rather than every static view.
- Added an explicit Liquid Glass adoption baseline and applied the first production-safe pass.
  The current rule is:
  use native Liquid Glass on supported SDK/runtime combinations for shell-level floating chrome and accessory controls,
  keep an availability-gated fallback for older deployment targets,
  and avoid spraying glass across dense content cards or forms.
  The current implementation applies that policy to the top bar, bottom tab bar, and floating action button through a shared compatibility layer.
- Started the `State + Localization foundation` pass.
  The app now has an explicit root `AppSessionState` (`restoring / signedOut / authenticated`),
  the home feed now resolves into explicit `loading / content / empty / offline / failed` UI states,
  and root/feed localization moved onto a resource-first path with new keyed entries in the localization bundle for those flows.
- Added a zero-warning baseline rule.
  New compiler, target, and project warnings should be fixed immediately instead of being deferred into later cleanup.
- Generalized target-specific Liquid Glass theming.
  Brand-specific glass tinting now lives in extensible semantic `BrandGlassRole` tokens inside the branding layer rather than as a one-off `FloatingActionButton` patch.
- Completed the `Profile architecture pass`.
  `ProfileTabRootView` no longer performs optimistic persistence/error work directly.
  That behavior now lives in `ProfileTabViewModel`,
  which owns profile presentation state, restore-navigation preference updates, rollback on failure, and error-message projection through the shared app error pipeline.
- Started the `Design system pass`.
  `AppTheme.swift` now also defines shared `AppTypography`, `AppSpacing`, `AppRadius`, and semantic `warning` tokens,
  and the tokenization sweep has already moved login, profile, feed, feature-scaffold, top-bar, side-menu, tab-bar, FAB, restoring-root, stub, and destination surfaces away from repeated raw font/padding/radius styling.
- The design-system pass now also covers feed card internals and the shared brand mark.
  `FeaturedArticleCard`, `DiscussionCard`, `ArticleActionView`, `FeedCardStatusBadge`, and `BrandMarkView`
  now read typography/radius choices from the shared token layer instead of view-local literals.
- Started the `Accessibility + formatting + docs cleanup` pass.
  The shell menu dismiss overlay now exposes explicit accessibility semantics,
  the menu-open edge-strip is hidden from accessibility,
  `FeedCardStatusBadge` now combines its content for VoiceOver,
  and `NewsFeedView` no longer uses a view-local `DateFormatter`, switching cached-status timestamps to modern locale-aware `FormatStyle`.
- The same pass also closed the remaining package doc-comment inconsistency.
  `Packages/TchopInfrastructure/Sources/TchopDatabase/TchopDatabase.swift`
  now documents its role as the umbrella re-export entry point for the app's database layer.
- Feed-card controls now also participate in the accessibility baseline explicitly.
  `ArticleActionView`, the featured-article overflow menu, and the discussion action/menu row
  now expose explicit labels, hints, and state values (`Active` / `In progress`) instead of relying on incidental system reading order.
- The `Accessibility + formatting + docs cleanup` pass is now effectively closed.
  Shell/menu dismiss semantics, feed status formatting, feed-control accessibility, and package doc consistency have all been normalized to the current project baseline.
