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
- Database module: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopDatabase/TchopDatabase.swift`
- Networking tests: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Tests/TchopNetworkingTests/TchopNetworkingTests.swift`
- Database tests: `/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Tests/TchopDatabaseTests/TchopDatabaseTests.swift`
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
- The `TchopDatabase` module currently provides `SwiftDataDatabaseManager` and `DatabaseManaging` with:
  backend-neutral manager factory,
  `DatabaseBackendSelectionPolicy`,
  `DatabaseReadOperation`,
  `DatabaseWriteOperation`,
  `SwiftDataDatabaseManager`,
  `CoreDataDatabaseManager`,
  `rollback`,
  timestamp and soft-delete marker protocols.
- The infrastructure database module is now backend-neutral in the same way as the app layer:
  the package can instantiate either `SwiftData` or `Core Data` through one shared contract.
- The package-level backend selection is driven by:
  `DatabaseConfiguration`
  and
  `DatabaseServiceFactory.makeDatabaseManager(...)`.
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
  it builds the app's `SwiftData` and `Core Data` containers and delegates backend selection to `DatabaseServiceFactory`.
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
- Latest navigation verification is green:
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build`
  and
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -destination 'id=8D07221C-A47D-48AC-BA55-1078C1001909' -configuration Debug CODE_SIGNING_ALLOWED=NO test`.

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
