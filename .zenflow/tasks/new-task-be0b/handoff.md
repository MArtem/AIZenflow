# Handoff

## TL;DR
- Project: `TchopApp`
- Status: working iOS SwiftUI app built from screenshot, now on MVVM + SwiftData + coordinator-based navigation + login flow + session restoration
- Last confirmed state: app builds successfully with app-level state, DI environment, tab coordinators, login/logout flow, restored active user session across relaunch, and real feature landing screens for `Mixes`, `Pinned`, and `Chat`
- Resume point: continue from existing Xcode project, not from scratch

## Paths
- Root: `/Users/Artem/.zenflow/worktrees/new-task-be0b`
- Xcode project: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp.xcodeproj`
- App folder: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp`
- Infrastructure package: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure`
- This handoff: `/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/handoff.md`
- Engineering rules: `/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`
- Services rules: `/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/services-engineering-rules.md`

## Active Prompt Memory
- The project has an active persistent iOS ruleset in `ios-engineering-rules.md`.
- The project also has an active persistent services and infrastructure ruleset in `services-engineering-rules.md`.
- A standing merge instruction also exists:
  when asked to merge from `main`, merge the latest changes from `main` and ask the user if any conflict resolution is unclear.
- Post-task verification policy now uses 4 explicit levels with default `Absent` (`Отсутствует`).
- Verification runs only when the user explicitly requests a level after task completion:
  `Full` = all tests + build on iPhone 16 Pro (iOS 18.2) + build on iPhone 17 Pro (iOS 26.0),
  `Medium` = all tests + build on iPhone 17 Pro (iOS 26.0),
  `Low` = build on iPhone 17 Pro (iOS 26.0),
  `Absent` = no tests/build/simulator checks.
- If a requested verification run finds a real code/configuration issue, fix it immediately and rerun that same verification level before closing the task.
- The user may refer to these as `/ios` and `/services` shorthand. Treat them as active instructions for future chats after reading the two rules files.

## What Was Built
- Full iOS SwiftUI app project created from scratch.
- Screen recreated from screenshot.
- Pinned top bar.
- Bottom tab bar.
- Side menu with tap open and swipe open/close.
- Side menu and tab bar synchronized through shared tab state.
- MVVM baseline for shell and news feed.
- SwiftData-backed local content storage with first-launch seeding.
- Generic tab routers with a shared app coordinator and per-tab navigation stacks.
- Login screen with username-only sign-in and logout back to auth flow.

## Current Architecture
- App entry: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/TchopApp.swift`
- App DI container: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppDIContainer.swift`
- App state source of truth: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppState.swift`
- App database backend selection and adapters: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppDatabase.swift`
- Shell and navigation state: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/AppShellView.swift`
- App root auth switch: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/AppRootView.swift`
- Shell content view: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/ShellContentView.swift`
- Tab content switcher: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/TabContentView.swift`
- Tab enum/model: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/AppTab.swift`
- User model: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/AppUser.swift`
- Channel header model: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/ChannelHeaderInfo.swift`
- Feed models: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/NewsFeedModels.swift`
- App shell view model: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/AppShellViewModel.swift`
- News feed view model: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/NewsFeedViewModel.swift`
- Login view model: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/LoginViewModel.swift`
- App coordinator: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/AppCoordinator.swift`
- Generic tab router: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/TabRouter.swift`
- Tab route structs: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/TabRoutes.swift`
- Navigation contracts: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/NavigationContracts.swift`
- Navigation snapshot model: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/NavigationSnapshot.swift`
- Navigation snapshot manager: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/NavigationStateManager.swift`
- Deep and universal link manager: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/DeepLinkManager.swift`
- SwiftData database bootstrap: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppDatabase.swift`
- SwiftData records: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppContentRecord.swift`
- SwiftData seed service: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppDataSeeder.swift`
- Content repository: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/AppContentRepository.swift`
- User repository: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/UserRepository.swift`
- Session service: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Services/UserSessionService.swift`
- Feed API manager: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Services/FeedAPIManager.swift`
- Networking module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopNetworking/TchopNetworking.swift`
- Navigation module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopNavigation/TchopNavigation.swift`
- Database umbrella module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopDatabase/TchopDatabase.swift`
- Database core module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopDatabaseCore/TchopDatabaseCore.swift`
- SwiftData database module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopSwiftDataDatabase/TchopSwiftDataDatabase.swift`
- Core Data database module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopCoreDataDatabase/TchopCoreDataDatabase.swift`
- Database composition module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopDatabaseComposition/TchopDatabaseComposition.swift`
- Localization module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopLocalization/TchopLocalization.swift`
- Branding module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopBranding/TchopBranding.swift`
- UI configuration module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopUIConfiguration/TchopUIConfiguration.swift`
- Local cache module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopCache/TchopCache.swift`
- Widgets module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopWidgets/TchopWidgets.swift`
- Push notifications module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopPushNotifications/TchopPushNotifications.swift`
- Networking tests: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Tests/TchopNetworkingTests/TchopNetworkingTests.swift`
- Database tests: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Tests/TchopDatabaseTests/TchopDatabaseTests.swift`
- Local cache tests: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Tests/TchopCacheTests/TchopCacheTests.swift`
- Widgets tests: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Tests/TchopWidgetsTests/TchopWidgetsTests.swift`
- Push notification tests: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Tests/TchopPushNotificationsTests/TchopPushNotificationsTests.swift`
- Login screen: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Auth/LoginScreenView.swift`
- Header: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/TopBarView.swift`
- Side menu: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Menu/SideMenuView.swift`
- Bottom tabs: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Tabs/BottomTabBar.swift`
- News feed root: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/News/NewsFeedView.swift`
- News tab navigation root: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Tabs/NewsTabRootView.swift`
- News tab destinations: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Tabs/NewsDestinationView.swift`
- Featured card: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/News/FeaturedArticleCard.swift`
- News action row: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/News/ArticleActionView.swift`
- Discussion card: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/News/DiscussionCard.swift`
- Stub tabs: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Stub/TabStubView.swift`
- Stub tab navigation root: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Tabs/StubTabNavigationRootView.swift`
- Stub tab detail: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Tabs/StubTabDetailView.swift`
- Profile tab root: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Tabs/ProfileTabRootView.swift`
- Mixes tab root: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Tabs/MixesTabRootView.swift`
- Pinned tab root: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Tabs/PinnedTabRootView.swift`
- Chat tab root: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Tabs/ChatTabRootView.swift`
- Feature tab scaffold: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Tabs/FeatureTabScaffoldView.swift`
- Feature tab fixture models: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/FeatureTabModels.swift`
- Launch screen: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/LaunchScreen.storyboard`
- App metadata: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Info.plist`
- App branding bridge: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppBranding.swift`
- App push notification bridge: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppPushNotificationBridge.swift`
- App delegate bridge: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/TchopApplicationDelegate.swift`
- App push request entry point: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppState.swift`
- App widget bridge: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppWidgetBridge.swift`
- Shared app-group config: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Shared/AppGroupConfiguration.swift`
- Simulator push payload for TchopApp: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/PushNotifications/SampleTchopApp.apns`
- Simulator push payload for TchopAppOcean: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/PushNotifications/SampleTchopAppOcean.apns`
- Widget extension bundle: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopWidgetsExtension/TchopWidgetsBundle.swift`
- Widget extension view/provider: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopWidgetsExtension/FeedHeadlineWidget.swift`
- Widget extension Info.plist: `/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopWidgetsExtension/Info.plist`

## Code Style Decision
- Do not use computed properties like `private var something: some View` for view composition.
- Do not use helper methods that return `some View` for reusable UI pieces.
- Do not use local `@ViewBuilder` helper functions for screen composition.
- Prefer:
  separate `View` structs in separate files,
  direct composition inside `body`,
  plain state/data helpers that do not return views.
- For any new destination screen or composed UI element, use one of two approaches only:
  direct view type initialization at call site, or
  a dedicated `Builder/Factory` entity in a separate type/file when that actually improves composition/dependency wiring.
- Never add local methods/properties/functions that return a new `View`/`some View` for this purpose.
- This preference was explicitly requested by the user and should be preserved in future edits.
- Nested reusable `View` types inside other view files should also be avoided when they can be first-class screen/component files.
- In addition to project state, a reusable instruction file now exists:
  `ios-engineering-rules.md`
  This file should be treated as the persistent engineering ruleset for future chats.
- Additional persistent UI quality rule:
  interface code must always be written to minimize or eliminate unnecessary re-renders and memory waste,
  and implementations should avoid logical/programming mistakes that can degrade render/memory behavior.
- Additional persistent localization rule:
  localization and internationalization are mandatory by default;
  every new user-facing element must be wired through localization keys (no hardcoded user-facing literals).
  Prefer centralized manager/facade approach (package-backed where practical) to keep locale handling reusable and consistent.
- Additional persistent target-branding rule:
  for multi-target apps, target-specific colors and future UI tokens should be resolved through a centralized semantic branding layer,
  preferably package-backed and driven by target metadata/build settings rather than local target checks inside views.
- Server-driven UI settings baseline:
  reusable UI configuration fetched from backend should be modeled behind a package-backed manager/snapshot contract where practical,
  so server-controlled visibility/toggle rules can evolve without scattering request logic into SwiftUI screens.
- Widget baseline:
  widget-related persistence and shared contracts should live in a reusable package-backed layer where practical,
  while app-specific mapping from feature state into widget snapshots should stay in an app bridge/composition layer.
  Current implementation uses `TchopWidgets` for shared snapshot storage and `AppWidgetBridge` to publish the first feed-card headline into shared app-group storage for the widget extension.
  Important fix: the widget extension must use an explicit `Info.plist` with a valid nested `NSExtension` dictionary.
  The earlier auto-generated plist configuration caused simulator install failure with `IXErrorDomain` / `Invalid placeholder attributes`.
  Multi-app nuance:
  widget extensions cannot be shared as one `.appex` target across host apps with different bundle identifiers.
  `TchopApp` embeds `TchopWidgetsExtension` with bundle id `com.example.TchopApp.widgets`,
  while `TchopAppOcean` embeds `TchopWidgetsOceanExtension` with bundle id `com.example.TchopAppOcean.widgets`.
  Both extension targets reuse the same widget source files and app-group-backed snapshot model.
- Push notifications baseline:
  APNs state/token/payload parsing is now package-backed via `TchopPushNotifications`,
  while `AppPushNotificationBridge` and `TchopApplicationDelegate` own UIKit / `UNUserNotificationCenter` callback wiring in the app layer.
  The package currently provides:
  `PushNotificationManager`,
  `PushNotificationState`,
  `APNsDeviceToken`,
  `DefaultPushNotificationPayloadParser`,
  and `UserDefaultsPushNotificationStateStore`.
  The app now includes the minimum realistic project configuration available without a real server yet:
  `aps-environment = development` in app entitlements,
  `remote-notification` background mode in `Info.plist`,
  and simulator-ready `.apns` payload files for both app bundle identifiers.
  Current launch behavior is intentionally conservative:
  on app start we only refresh current notification authorization state and auto-register for remote notifications if permission already exists;
  we do not auto-prompt the user on every launch.
  `AppState` now also exposes an explicit app-facing method to request push authorization on demand,
  so future UI can trigger the permission flow without reaching directly into `UIApplicationDelegate` wiring.
  Post-integration verification hardening also fixed:
  APNs package tests that still called an outdated manager API,
  a missing `await` in `AppState`,
  early assignment of the application-delegate bridge in `TchopApp.init`,
  and main-actor violations caused by no-op widget/push dependencies in default arguments.
  Current verification state for this APNs block is fully green:
  package tests pass,
  `TchopApp` builds and tests pass on `iPhone 16 Pro (iOS 18.2)`,
  and `TchopApp` builds and tests pass on `iPhone 17 Pro (iOS 26.0)`.
- Composition/DI baseline:
  hidden fallback dependency resolution has been removed from `AppState`, `AppShellViewModel`, and `NewsFeedViewModel`.
  No-op implementations are still allowed, but they must now be injected explicitly from the composition root or tests instead of being silently created inside feature/runtime types.
  `AppDIContainer` is the single place that assembles package-backed bridges/managers for runtime use and now owns explicit helper factories for API, UI configuration, widget sync, push bridge, and local seeding.
- Navigation/coordinator baseline:
  `AppCoordinator` now owns the canonical root-opening behavior for tabs via `showTabRoot(_:)` and also exposes a single `navigationChanges` publisher for snapshot persistence observers.
  `AppState` no longer knows about every router publisher directly, and `DeepLinkManager` no longer manually resets tab stacks.
  Deep links to tab roots now intentionally land on that tab's root screen instead of preserving a stale nested stack from a previous session.
- Repository/data-flow baseline:
  `DefaultAppContentRepository` is now thinner and delegates DTO/persistence-to-domain mapping to dedicated private mapper helpers instead of mixing orchestration and all mapping logic inside the fetch methods.
  `DefaultUserRepository` now enforces username normalization at the repository boundary as well:
  `findUser(username:)` still returns `nil` for blank input,
  but `findOrCreateUser(username:)` now throws for blank/whitespace-only usernames instead of silently creating invalid persisted users if some non-UI caller bypasses screen validation.
- Concurrency warning hardening:
  feed stub response path now explicitly satisfies `@Sendable` requirements, and feed DTO types are marked `Sendable`
  to prevent data-race warnings in the networking stub pipeline.
- Additional collaboration rule:
  if anything is unclear, ask questions, clarify trade-offs, and propose alternatives/ideas instead of assuming silent defaults.
  Each new task and shared implementation plan should be treated as a collaborative step requiring active attention from both sides.
- Current profiling baseline:
  CLI profiling was captured for `TchopApp` on `iPhone 17 Pro (iOS 26.0)` with `xctrace` (`App Launch`, `Time Profiler`, `Leaks`), `sample`, `vmmap`, and simulator logs.
  Startup appears healthy with first-active transition around `0.67s`, idle sample showed no CPU hotspot or busy-loop pattern, and physical footprint was about `24.6MB` with peak around `25.2MB` during startup/idle sampling.
  Environment limitations:
  `SwiftUI` instrument is unsupported on Simulator, `Allocations` had an attach-privileges limitation in CLI mode, and the app process exits early with `exit(0)` in these scripted launches, so long-running render/memory profiling should be repeated in interactive Instruments or on device when needed.
- Persistent profiling workflow:
  when the user asks for `профайлинг`, treat that as a request for the fullest practical profiling pass available in the current environment, not a minimal one-off check.
  Preferred workflow:
  build with isolated DerivedData if needed,
  collect `xctrace` traces (`App Launch`, `Time Profiler`, `Leaks`, `Allocations` when supported),
  collect `sample` and `vmmap`,
  inspect simulator/device logs,
  then summarize startup, CPU, memory, leaks risk, environment/tooling limitations, and concrete fix directions.
  If Simulator/CLI restrictions make some instruments non-authoritative, state that explicitly and recommend follow-up in interactive Instruments and/or on a physical device.

## Important Fixes Already Done
- Fixed `Missing bundle ID` by adding required bundle keys into `Info.plist`.
- Fixed non-fullscreen presentation cause:
  the real issue was missing launch screen, which caused compatibility-style presentation on simulator/device.
- Added `UILaunchStoryboardName = LaunchScreen`.
- Added `LaunchScreen.storyboard` to Xcode project resources.
- Rebuilt and reinstalled the app in simulator.
- Verified fullscreen rendering after reinstall.

## Simulator Notes
- Bundle ID: `com.example.TchopApp`
- Last used booted simulator: `iPhone 17 Pro`
- Last successful reinstall flow:
```sh
xcrun simctl uninstall <device-id> com.example.TchopApp || true
xcrun simctl install <device-id> <path-to-app>
xcrun simctl launch <device-id> com.example.TchopApp
```

## Verification Commands
- Build:
```sh
xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build
```
- Package tests:
```sh
swift test --package-path Packages/TchopInfrastructure
```
- App tests:
```sh
xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug CODE_SIGNING_ALLOWED=NO test
```
- App verification matrix (required):
```sh
xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' -configuration Debug CODE_SIGNING_ALLOWED=NO build
xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' -configuration Debug CODE_SIGNING_ALLOWED=NO test
xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' -configuration Debug CODE_SIGNING_ALLOWED=NO build
xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' -configuration Debug CODE_SIGNING_ALLOWED=NO test
```
- Find booted simulator:
```sh
xcrun simctl list devices | grep Booted
```
- Verification levels (current default):
```text
Default: Absent (no verification runs unless explicitly requested by the user)
Full:    all tests + build iPhone 16 Pro (18.2) + build iPhone 17 Pro (26.0)
Medium:  all tests + build iPhone 17 Pro (26.0)
Low:     build iPhone 17 Pro (26.0)
Absent:  no tests/build/simulator checks
```

## Current Truth
- The latest verified screenshot after uninstall + reinstall showed the UI occupying the full screen correctly.
- If fullscreen issue appears again, first suspect stale simulator-installed app and repeat uninstall/install.
- The codebase now follows the user's SwiftUI identity rule:
  no computed properties returning `some View`,
  no helper methods returning `some View`,
  no local `@ViewBuilder` helper functions,
  only `body` on concrete `View` types should return views.
- For new destination screens or composed UI elements, the allowed patterns are:
  direct type initialization at call site, or dedicated `Builder/Factory` (when justified by complexity/dependency wiring).
- Local methods/properties/functions that return new `View`/`some View` are explicitly disallowed.
- The codebase also follows the stronger structure rule:
  reusable UI must be extracted into separate configurable types in separate files, not nested inside parent views.
- `AppShellView` composition is now split into standalone files:
  `ShellContentView.swift` and `TabContentView.swift`.
- `FeaturedArticleCard` action rows are now extracted into standalone `ArticleActionView.swift`.
- `BrandMarkView` no longer uses a view-returning helper method.
- Step 1 of the new roadmap is complete:
  the project is now on a real MVVM baseline.
- `TchopApp` owns a root `@StateObject` of `AppShellViewModel`.
- Root shell state (`selectedTab`, menu state, header info, current screen coordination) moved from views into `AppShellViewModel`.
- News screen content moved to `NewsFeedViewModel` plus typed models in `NewsFeedModels.swift`.
- `View` files are now dumber:
  `TopBarView`, `SideMenuView`, `BottomTabBar`, `FeaturedArticleCard`, `DiscussionCard`, and `NewsFeedView`
  render injected state instead of owning screen data.
- Current feed data is still local fixture content,
  but it is now represented by model types instead of inline hardcoded strings inside views.
- This prepares roadmap step 2 cleanly:
  replacing fixture content with real services / repositories / persistence
  without rewriting the view layer again.
- Step 2 of the roadmap is now also complete:
  local fixture-backed data has been replaced with a real `SwiftData` source.
- `TchopApp` now creates a shared `ModelContainer`, seeds it on first launch, and injects a repository-backed root view model.
- Current implementation uses a single `SwiftDataAppContentRepository` that provides:
  channel header data and news feed content.
- On first launch the app seeds local records for:
  channel,
  featured article,
  article actions,
  discussion preview,
  discussion participants.
- The current data layer is intentionally simple and local-first,
  but already structured so it can be replaced later by DI-driven services / repositories without reworking the views again.
- Step 3 of the roadmap is complete:
  navigation is no longer a single flat tab switch.
- The app now uses:
  one shared `AppCoordinator`,
  one generic `TabRouter<Route>` per tab,
  route structs instead of enum routes,
  independent `NavigationStack` state per tab that is preserved while switching tabs.
- The route design intentionally keeps routes as data structs.
  Screen construction happens in destination views / coordinator-owned composition, not by storing `ViewBuilder` closures in routes.
- Step 4 is also in place:
  app composition now has explicit DI and app-wide state.
- `TchopApp` creates:
  repositories,
  session service,
  `AppCoordinator`,
  and a single `@StateObject` `AppState`.
- `AppState` is the current app-level source of truth for:
  signed-in user,
  logout behavior,
  coordinator reset on auth changes.
- The app now also has a real DI root:
  `AppDIContainer`.
- `TchopApp` creates one container and injects it into the app root.
- The container owns and wires:
  `ModelContainer`,
  `DatabaseManaging`,
  `APIManaging`,
  feature API managers,
  repositories,
  session service.
- The persistence layer no longer depends directly on `ModelContext` in repositories.
- Repositories now depend on `DatabaseManaging` instead.
- The infrastructure layer has now been extracted into a local Swift package:
  `Packages/TchopInfrastructure`.
- `TchopApp` now links two local package products:
  `TchopNetworking` and `TchopDatabase`.
- Old app-local infra files for `APIManager`, `DatabaseManaging`, and `DatabaseManager` were removed after the module split.
- The database infrastructure is now split into reusable package targets:
  `TchopDatabaseCore`,
  `TchopSwiftDataDatabase`,
  `TchopCoreDataDatabase`,
  `TchopDatabaseComposition`,
  plus umbrella target `TchopDatabase` for backward-compatible imports.
- `TchopDatabaseCore` owns the shared contract surface:
  `DatabaseManaging`,
  `DatabaseBackendSelectionPolicy`,
  `DatabaseReadOperation`,
  `DatabaseWriteOperation`,
  `DatabaseBatchWriteOperation`,
  shared errors, and migration primitives.
- `TchopSwiftDataDatabase` owns `SwiftDataDatabaseManager`.
- `TchopCoreDataDatabase` owns `CoreDataDatabaseManager`.
- `TchopDatabaseComposition` owns the resolver/facade layer:
  `DatabaseManagerResolving`,
  `DatabaseManagerResolver`,
  and compatibility facade `DatabaseServiceFactory`.
- The infrastructure package now also exposes a reusable local cache module:
  `TchopCache`.
- `TchopCache` currently provides a protocol-first cache contract
  (`LocalCacheManaging`) and two manager implementations:
  `InMemoryLocalCacheManager` and `FileLocalCacheManager`,
  with expiration policies (`never`, `after`, `at`) and cleanup of expired entries.
- The package-level backend selection is now driven by:
  `DatabaseConfiguration`
  and
  `DatabaseManagerResolver` / `DatabaseServiceFactory`.
- Package tests now verify both backends:
  `SwiftData` and `Core Data`,
  plus factory selection for each.
- The `TchopNetworking` module currently provides:
  `APIManager`,
  `MockAPIManager`,
  `APIConfiguration`,
  request cancellation,
  interceptor pipeline,
  retry and logging interceptors,
  typed request/response boundaries.
- The app now also has an Xcode unit test target:
  `TchopAppTests`.
- Current app-level unit coverage includes:
  `AppStateTests`,
  `LoginViewModelTests`,
  `NewsFeedViewModelTests`,
  `TabRouterTests`,
  `AppCoordinatorTests`,
  `UserRepositoryTests`,
  `AppContentRepositoryTests`.
- Latest dual-simulator verification snapshot:
  `iPhone 16 Pro (iOS 18.2)`:
  `build` and `test` both green.
  `iPhone 17 Pro (iOS 26.0)`:
  `build` green,
  `test` failed twice with the same simulator/test-runner bootstrap infrastructure error:
  `Early unexpected exit, operation never finished bootstrapping - test runner crashed before establishing connection`.
  This is currently tracked as an environment instability, not a reproducible assertion failure in app tests.
- Manual launch validation on `iPhone 17 Pro (iOS 26.0)` after database fallback change:
  app installs and launches successfully via `simctl launch` (process starts normally),
  which confirms the reported startup fatal error path is resolved.
- The app persistence layer now uses the package database contract directly.
  Repositories and seeders depend on `DatabaseManaging` from `TchopDatabase`, not on an app-local duplicate abstraction.
- `TchopApp/Persistence/AppDatabase.swift` is now only an app-specific composition layer:
  it builds the app's `SwiftData` and `Core Data` containers and delegates backend creation to package composition contract `DatabaseManagerResolving`.
- `AppDIContainer` now chooses persistence through `DatabaseConfiguration` and `DatabaseBackendSelectionPolicy`.
  The default production policy remains `automatic`, which resolves to `SwiftData` on iOS 17+ and falls back to `Core Data` otherwise.
- The persisted local model is intentionally reduced to the records the app truly reads locally today:
  the primary channel metadata and users.
  Feed cards continue to come from the API layer.
- `TchopNetworking` was also pushed to a more complete baseline:
  it now includes typed `noConnection` and `timeout` errors,
  request authentication via `APIAuthenticationInterceptor`,
  upload and download APIs with progress callbacks,
  and an `APIOfflineRequestQueue` foundation that can replay queued work when connectivity returns.
- Package tests now verify:
  authentication header injection,
  offline queue drain behavior,
  and mock download writing in addition to the existing cancellation and stub-response coverage.
  `APIRequest`,
  `APIManaging`,
  interceptor protocols,
  logging interceptor,
  retry interceptor,
  cancellation token support.
- `StubFeedAPIManager` now uses the generic `APIManager` instead of returning raw synchronous data directly.
- Feed loading is now async end-to-end from the feed API manager through repository into `NewsFeedViewModel`.
- `NewsFeedViewModel` now owns:
  loading state,
  error state,
  cancellation of in-flight feed loading.
- Transitional `AppEnvironment` has now been removed.
- `AppState` no longer depends on the full DI container.
- `AppState` depends only on `UserSessionManaging`, which reduces container coupling and keeps the composition root explicit.
- Public APIs inside the infrastructure package are now documented with DocC-style comments.
- Current networking setup intentionally uses no auth, with the interceptor pipeline left as the extension point for future auth strategies.
- Current database backend is `SwiftData`, which implies an iOS 17+ floor for the infrastructure package.
- Local persistent instructions were also updated:
  `ios-engineering-rules.md` now explicitly includes SOLID,
  and `services-engineering-rules.md` was added for service-layer guidance.
- Step 5 is complete:
  the app now has a simple login flow backed by persisted users.
- `LoginScreenView` accepts a username.
- On login:
  the username is normalized,
  a user is looked up or created in SwiftData,
  and `AppState.currentUser` becomes the single source of truth for the active user in memory.
- On logout:
  `AppState` clears the current user,
  resets all tab navigation stacks back to root,
  closes the side menu,
  and returns the app to the login screen.
- `UserRecord` is persisted in SwiftData,
  so every new username is stored in the local database.
- The current signed-in session is now restored automatically on app launch.
- `UserSessionService` persists the active username in `UserDefaults`.
- On app launch, `AppState` restores the active user through `UserSessionService.restoreSession()`.
- If the stored username no longer exists in SwiftData, the stale session key is cleared automatically.
- The news feed structure is now card-based instead of hardcoded as two fixed top-level fields.
- Each feed card has its own model:
  `FeaturedArticleCardModel`,
  `DiscussionCardModel`,
  and the list is represented as `[NewsFeedCard]`.
- `NewsFeedView` now renders a typed card list from `NewsFeedContent.cards`.
- A stub service layer for feed loading now exists in `FeedAPIManager.swift`.
- `SwiftDataAppContentRepository` depends on `FeedAPIManaging` and maps DTOs into domain card models.
- Current setup is intentionally stubbed:
  the feed API manager returns local stub DTOs,
  while the repository keeps the service/repository separation ready for a real backend later.
- The feed stub flow is now backed by `TchopNetworking` instead of an app-local API manager file.
- Repositories and the seeder now import `TchopDatabase` instead of app-local database manager files.
- A documentation pass has now been applied across the app layer as well, not only the package modules.
- App models, repositories, services, navigation types, state objects, persistence records, and key view models now contain inline code documentation explaining their role and important methods.
- Small readability refactors were also applied without behavior changes:
  the feed API stub payload was moved into a private fixture factory,
  shell channel fallback resolution was extracted into a helper,
  and news feed fallback content now lives in a dedicated private fixture namespace.
- Latest verification:
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build`
  succeeded after this refactor.
  `swift test --package-path Packages/TchopInfrastructure`
  also succeeded after the module split.
- The active tab experience has now moved beyond generic placeholder roots for `Mixes`, `Pinned`, and `Chat`.
- `TabContentView` no longer routes those tabs through `StubTabNavigationRootView`.
- Each of those tabs now has its own dedicated root screen:
  `MixesTabRootView`,
  `PinnedTabRootView`,
  and
  `ChatTabRootView`.
- Those screens share one reusable presentational scaffold:
  `FeatureTabScaffoldView`.
- Their content is driven by typed local fixtures in:
  `FeatureTabModels.swift`.
- The intent of this step was UI refinement only:
  the repository / service architecture is unchanged,
  and each tab still preserves its own independent `NavigationStack` through the existing `TabRouter` instances.
- Current feature tab navigation still uses the existing lightweight detail destination:
  `StubTabDetailView`.
  The root surfaces are now product-shaped,
  while the deeper destination layer remains intentionally generic until real backend-backed features are introduced.
- Latest verification after the feature-tab replacement:
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build`
  succeeded.
  `swift test --package-path Packages/TchopInfrastructure`
  also succeeded.
- App-level `xcodebuild test` was attempted twice after this change:
  once against `iPhone 17 Pro`
  and once against `iPhone 16 Pro`.
  In both cases the build phase completed, but the run stalled in CoreSimulator / test runner startup,
  so there is currently no fresh green app-test confirmation for this specific tab-refinement step.
- The app now has explicit light/dark appearance support in the UI layer through shared semantic theme tokens in:
  `TchopApp/App/AppTheme.swift`.
- Active shell and content surfaces now consume `AppTheme` instead of hardcoded RGB values in key views:
  `AppShellView`,
  `TopBarView`,
  `SideMenuView`,
  `LoginScreenView`,
  `BottomTabBar`,
  `FeatureTabScaffoldView`,
  `ProfileTabRootView`,
  `NewsDestinationView`,
  `StubTabDetailView`,
  `FeaturedArticleCard`,
  `ArticleActionView`,
  `FloatingActionButton`,
  `BrandMarkView`,
  and
  `TabStubView`.
- Fixed colors are intentionally kept only in decorative content blocks (for example parts of card illustration art), while surfaces and text use semantic theme tokens for readability in both appearance modes.
- Navigation modernization plan is now implemented through step 9/10 and includes:
  typed navigation contracts (`NavigationStateManaging`, `DeepLinkManaging`),
  codable route snapshots (`NavigationSnapshot`) with per-user persistence,
  profile-level restore preference (`isNavigationStateRestoreEnabled`),
  deterministic priority policy (pending deep link before snapshot restore after auth),
  and app lifecycle link wiring for both `onOpenURL` and `onContinueUserActivity`.
- `AppDatabase.makeDatabaseManager` now includes a production-safe backend fallback:
  if primary backend initialization fails (for example SwiftData container load issue),
  app retries with Core Data backend before failing hard.
  This prevents startup crash loops on simulator/device stores with SwiftData compatibility or migration issues.
- `AppState` now owns navigation save/restore policy decisions:
  snapshot writes are enabled only for authenticated users with restore enabled,
  writes are blocked while applying a restore payload to avoid loops,
  and disabling restore clears persisted snapshot plus resets current tab paths.
- Deep and universal links are now routed by a dedicated manager:
  custom scheme `tchop://...` and `https://...` URLs map to typed destinations and are dispatched through `AppCoordinator` tab routers.
- New app-level tests now cover the navigation contract behavior:
  restore enabled vs disabled on app initialization,
  deep-link priority over snapshot restore after sign-in,
  custom-scheme routing,
  universal-link routing.
- Latest persistence/runtime update (2026-04-17):
  deployment target is now `iOS 16.0` (app + `TchopInfrastructure` package),
  database contracts are availability-safe for iOS 16 builds,
  and runtime policy is:
  `Core Data` path for iOS `<17`,
  `SwiftData` for iOS `17+`,
  with automatic Core Data -> SwiftData migration and legacy store cleanup after successful migration on iOS `17+`.
- `TchopDatabase` now resolves `.automatic` backend as:
  `coreData` on iOS `<17`,
  `swiftData` on iOS `17+`.
- App-level repositories/seeders/tests were adjusted to avoid unconditional iOS 17-only SwiftData API usage in iOS 16 build contexts.
- Latest navigation verification is green:
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build`
  and
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -destination 'id=8D07221C-A47D-48AC-BA55-1078C1001909' -configuration Debug CODE_SIGNING_ALLOWED=NO test`.
- Dual-simulator verification is currently green after persistence changes:
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' -configuration Debug CODE_SIGNING_ALLOWED=NO build`
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' -configuration Debug CODE_SIGNING_ALLOWED=NO test`
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' -configuration Debug CODE_SIGNING_ALLOWED=NO build`
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' -configuration Debug CODE_SIGNING_ALLOWED=NO test`
- Latest infra/navigation packaging update (2026-04-19):
  reusable navigation primitives now live in a dedicated infrastructure module (`Packages/TchopInfrastructure/Sources/TchopNavigation/TchopNavigation.swift`):
  generic `TabRouter<Route>`,
  generic `NavigationStateManaging`,
  and `NavigationStateManager`.
- App code now imports `TchopNavigation` directly for routing/snapshot concerns instead of getting navigation primitives indirectly from `TchopDatabase`.
- `TchopDatabase` remains as a backward-compatible umbrella import and now re-exports `TchopNavigation` for older call sites, but navigation and persistence are no longer coupled at the package-boundary level.
- App-local duplicates (`TabRouter.swift`, `NavigationContracts.swift`, `NavigationStateManager.swift`) had already been removed from `TchopApp/Navigation`,
  and app-specific link routing contract remains a dedicated local file `DeepLinkManaging.swift`.
- `DatabaseServiceFactory` public API is now tighter for reuse:
  Core Data overload remains iOS 16-compatible,
  SwiftData overload is typed with `ModelContainer` and constrained to iOS 17+,
  while backend fallback behavior in app database policy remains unchanged.
- Fresh verification after this packaging/unification pass:
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,id=8D07221C-A47D-48AC-BA55-1078C1001909' test` succeeded;
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,id=39CE4180-05FE-4978-A3DD-4CE44AE7F334' test` succeeded.
- Latest universal infra uplift (phase 1, 2026-04-17):
  `TchopDatabase` gained reusable migration primitives (`DatabaseMigrationVersionStoring`, `UserDefaultsDatabaseMigrationVersionStore`, `DatabaseMigrationStep`, `DatabaseMigrationRunner`) and explicit batch contract support (`DatabaseBatchWriteOperation`, `writeBatch`, async-friendly `readAsync/writeAsync/writeBatchAsync` extensions).
- `TchopNetworking` gained auth-refresh retry support (`APIAuthenticationRefreshing`, `APIAuthorizationRefreshInterceptor`) and retry-time request re-preparation so refreshed headers are applied on the next attempt.
- `APIRequest` now supports custom accepted status code ranges (`validStatusCodes`), a reusable JSON builder (`APIRequest.json(...)`), and `APIEmptyResponse` for no-body endpoints.
- Package tests now also cover:
  migration-runner flow,
  batch write behavior,
  auth refresh + retry header update path,
  and custom status-code acceptance.
- Verification for this uplift is green:
  `swift test --package-path Packages/TchopInfrastructure`,
  `xcodebuild ... test` on `iPhone 16 Pro (iOS 18.2)`,
  and `xcodebuild ... test` on `iPhone 17 Pro (iOS 26.0)`.
- Latest universal infra uplift (phase 2, 2026-04-17):
  `TchopNetworking` now includes a reusable durable offline queue layer with persisted payload records.
- Added reusable primitives:
  `APIOfflineQueueEntry<Payload>`,
  `APIOfflineQueueStoring`,
  `FileAPIOfflineQueueStore<Payload>`,
  and actor `APIPersistedOfflineQueue<Store>`.
- `APIPersistedOfflineQueue` behavior:
  loads persisted entries at init,
  enqueues and persists new payloads,
  drains only when connectivity provider reports online,
  retries failed operations by incrementing attempts,
  and moves entries to dead letters after configured max attempts.
- Added package tests for:
  persisted queue reload across instances,
  offline-vs-online drain behavior,
  dead-letter transition after retry threshold.
- Fresh verification for phase 2 is green:
  `swift test --package-path Packages/TchopInfrastructure`,
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' test`,
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' test`.
- Post-review reliability hardening (2026-04-17):
  `APIPersistedOfflineQueue.drainIfConnected` now detaches the active batch before awaits and merges retry entries back with entries enqueued during drain, preventing data loss from actor reentrancy.
- Dead-letter persistence is now durable for file-backed storage:
  `FileAPIOfflineQueueStore` persists and reloads dead-letter entries in a companion file, and `APIPersistedOfflineQueue` restores dead letters at init.
- Added regression tests for:
  enqueue-during-drain retention (`testPersistedOfflineQueueDoesNotDropEntriesEnqueuedDuringDrain`),
  dead-letter persistence reload (`testPersistedOfflineQueueReloadsDeadLetters`).
- Fresh verification after these fixes is green:
  `swift test --package-path Packages/TchopInfrastructure`,
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' test`,
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' test`.
- Latest universal infra uplift (phase 3, 2026-04-17):
  added observability foundation in `TchopNetworking` with typed metric events (`APIMetricsEvent`), collector contract (`APIMetricsCollecting`), in-memory collector (`APIMemoryMetricsCollector`), and lifecycle interceptor (`APIMetricsInterceptor`).
- Interceptor contract now includes retry scheduling callback (`didScheduleRetry`), and `APIManager` emits retry events when backoff is selected.
- `APIPersistedOfflineQueue` now exposes operational diagnostics via `Snapshot` and `DrainReport`, with new `drainWithReportIfConnected(...)` while keeping existing `drainIfConnected(...)`.
- Added tests for metrics lifecycle capture and queue diagnostic counters/snapshots.
- Verification for phase 3: `swift test --package-path Packages/TchopInfrastructure` succeeded.
- Latest universal infra uplift (phase 4, 2026-04-17):
  networking extension points were expanded without breaking existing interceptors.
- Added pluggable error mapping via `APIErrorMapping` + `APIDefaultErrorMapper`, and `APIManager` now uses injected mapper for non-`APIError` failures across request flows.
- Added typed retry metadata model `APIRetryContext` and a new interceptor surface `retryDirective(for context: APIRetryContext)`.
  Existing retry API remains compatible through default bridging.
- Added tests for:
  custom mapper behavior (`testAPIManagerUsesCustomErrorMapperForNonAPIErrors`),
  retry-context-driven retry policy (`testAPIManagerUsesRetryContextSurface`).
- Verification for phase 4: `swift test --package-path Packages/TchopInfrastructure` succeeded.
- Latest universal infra uplift (phase 5, 2026-04-17):
  security hardening was applied to networking diagnostics/logging defaults.
- `APILoggingInterceptor` now supports `RedactionConfiguration` and redacts sensitive query values and headers before emitting logs.
  Response/failure logs also use redacted URL output.
- Added regression test proving tokens/authorization secrets are not emitted:
  `testLoggingInterceptorRedactsSensitiveHeadersAndQueryValues`.
- Verification for phase 5: `swift test --package-path Packages/TchopInfrastructure` succeeded.
- Latest universal infra uplift (phase 6, 2026-04-17):
  operational tooling and recovery ergonomics were added around persisted offline queues.
- `FileAPIOfflineQueueStore` now supports corruption policies:
  `throwError` and `recoverToEmpty` (default).
  Recovery mode moves corrupted payload files aside and restores queue/dead-letter state as empty.
- `APIPersistedOfflineQueue` now supports diagnostics export/import:
  `DiagnosticsPayload`,
  `DiagnosticsImportStrategy`,
  `exportDiagnosticsPayload()`,
  `importDiagnosticsPayload(...)`.
- Added tests for corruption recovery and diagnostics payload roundtrip import/export.
- Verification for phase 6: `swift test --package-path Packages/TchopInfrastructure` succeeded.
- Post-review hardening follow-up (2026-04-18):
  applied requested fixes from review findings for phase 3-6.
- `FileAPIOfflineQueueStore` recovery path now only auto-recovers on JSON `DecodingError` corruption.
  Generic I/O/read errors are no longer swallowed in `recoverToEmpty`, preventing silent queue loss on non-corruption failures.
- `APIManager` now emits `didScheduleRetry` for retries triggered by the `invalidStatusCode` branch as well, so observability/metrics interceptors see all scheduled retries consistently.
- Added regression tests:
  `testFileOfflineQueueStoreRecoverToEmptyDoesNotMaskNonDecodingReadErrors`,
  `testAPIManagerEmitsRetryScheduledForInvalidStatusCodeBranch`.
- Fresh verification after hardening is green:
  `swift test --package-path Packages/TchopInfrastructure`,
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' test`,
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' test`.
- Navigation reliability + state evolution cycle (phase 7/8, 2026-04-18):
  added production-oriented reliability and observability on top of the existing navigation baseline.
- Phase 7 (reliability / policy):
  `DeepLinkManager` now resolves links via typed intent parsing states
  (`resolved`, `invalidInAppLink`, `unsupported`) with deterministic fallback behavior for invalid in-app links.
  Added coordinator-level transition policy (`NavigationTransitionPolicy`: `push`, `replace`, `popToRoot`) and idempotent per-tab route application helpers to prevent duplicate stack churn.
- Phase 8 (snapshot evolution / observability):
  `NavigationSnapshot` moved to schema `v2` with backward-compatible decode for v1 payloads, migration helper (`migratedToSupportedVersion`), and bounded restore sanitization (`maxRoutesPerTab`).
  Added typed navigation observability contracts:
  `NavigationEvent`,
  `NavigationEventReporting`,
  `NavigationNoopEventReporter`,
  `NavigationMemoryEventReporter`.
  `AppState` now emits restore lifecycle events and applies safe rollback for unsupported future snapshot versions (clear snapshot + reset navigation).
- Added/extended tests for:
  migration+sanitization restore behavior,
  future-version snapshot rollback,
  invalid in-app deep-link fallback,
  unsupported host rejection,
  deep-link push transition behavior,
  idempotent coordinator transitions.
- Fresh verification for phase 7/8 is green:
  `swift test --package-path Packages/TchopInfrastructure`,
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' test`,
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' test`.
- Documentation pass (2026-04-18):
  added concise `///` comments across Swift files that previously had no doc comments.
- Scope of the pass:
  top-level views,
  tab roots and shared tab components,
  feature/tab fixture models,
  app entry point,
  test suites and test helpers,
  package manifest root declaration.
- Goal:
  improve discoverability/onboarding without adding noisy line-by-line comments.

## Next Recommended Step
- Next logical work is deeper feature behavior, not shell architecture.
- Good candidates:
  replacing the generic detail destination for `Mixes`, `Pinned`, and `Chat` with real per-feature destination screens,
  moving tab fixture data behind feature-specific view models or repositories,
  refining side menu destinations and deep-link handling,
  or adding network-backed services on top of the current local-first data layer.

## If You Continue In A New Chat
- Ask the new chat to read both this file and `ios-engineering-rules.md`.
- Also read `services-engineering-rules.md` when service / repository / infra work is involved.
- Use the handoff as project state and the rules files as the working style and architecture contract.
- Recommended prompt:
```text
Прочитай /Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/handoff.md.
Потом прочитай /Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/ios-engineering-rules.md.
Потом прочитай /Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/services-engineering-rules.md.
Первый файл — это актуальное состояние задачи. Второй файл — постоянные инженерные правила для iOS части. Третий файл — правила для services / infra слоя.
Используй все три файла как источник истины и продолжай работу оттуда.
```

## Working Agreement
- Keep this file updated after every substantial change.
- Prefer recording:
  what changed,
  why it changed,
  what was verified,
  what the next chat should assume as current truth.
- Keep `ios-engineering-rules.md` updated only if the user changes permanent engineering expectations.
- Keep `services-engineering-rules.md` updated only if the user changes permanent services / infra expectations.

## Model Policy (Quality vs Limits)
- Default implementation agent:
  `GPT-5.3 Codex`.
- Default reviewer agent:
  `GPT-5.4`,
  but used as a targeted review gate, not as a mandatory check for every trivial change.
- Require `GPT-5.4` review when at least one trigger is true:
  changes touch `AppState`, DI, navigation, persistence, networking, or auth/session;
  diff is larger than about 4 files or 200 lines;
  protocol/contract refactors are involved;
  test runs are failing or unstable;
  work is about to merge into `main` for medium/large scope tasks.
- For trivial/small low-risk edits:
  `GPT-5.3 Codex` implementation plus local verification (`xcodebuild ... build` and relevant tests) is sufficient.
