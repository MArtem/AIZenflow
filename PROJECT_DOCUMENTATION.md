# TchopApp Developer Onboarding Guide

## Purpose Of This Document
This document is the main onboarding guide for new developers working on `TchopApp`.

It is intentionally broader and more explicit than a normal README.
The goal is simple:

- explain what the project is;
- explain how the codebase is organized;
- explain how data moves through the app;
- explain why the main architectural decisions were made;
- give a new developer enough context to work safely without rediscovering the architecture from scratch.

This document is a living document.
Whenever the project structure, runtime flows, ownership boundaries, or important feature contracts change, this file must be updated in the same work stream.

## How To Read This Document
Read it in this order:

1. `Quick Orientation`
2. `Project Structure`
3. `Architecture Principles`
4. `Runtime Flows`
5. `Layer-By-Layer Walkthrough`
6. `Where To Change What`

If you need to start coding quickly, read sections 1 through 5 first.
If you are making architectural changes, read the whole document.

---

## Quick Orientation

`TchopApp` is a SwiftUI iOS application with:

- a coordinator-driven shell;
- app-level state in `AppState`;
- feature logic in view models and repositories;
- reusable infrastructure in `Packages/TchopInfrastructure`;
- local-first persistence;
- storage-backed feed rendering;
- explicit support for local username login and Sign in with Apple;
- widget snapshot sync;
- deep-link and navigation-state restore support.

The current app is intentionally structured so reusable infrastructure lives in the package, while product-specific composition and feature code stay in `TchopApp`.

In short:

- app layer = product composition and feature behavior;
- package layer = reusable infrastructure and shared primitives.

---

## Targets And What They Do

### App Targets

#### `TchopApp`
Primary host app target.
This is the target most developers should think of as the main application.

#### `TchopAppOcean`
Secondary host app target for target-specific branding validation.
It exists to prove that the app can support multiple branded host applications without forking the whole codebase.

### Widget Targets

#### `TchopWidgetsExtension`
Widget extension for `TchopApp`.
It renders a shared headline snapshot written by the app into app-group storage.

#### `TchopWidgetsOceanExtension`
Widget extension for `TchopAppOcean`.
It exists separately because widget extensions need their own bundle identity.

### Shared Package

#### `Packages/TchopInfrastructure`
This Swift package contains reusable modules:

- networking;
- persistence primitives;
- navigation primitives;
- localization;
- branding;
- widgets;
- push notifications;
- analytics;
- caching;
- UI configuration;
- Apple authentication.

This is the main package/app separation boundary in the repo.

---

## Top-Level Project Structure

### Root-Level Files

#### [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
This file.
The main onboarding and architecture document.

#### [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
Tracks package boundaries, extraction policy, and structural risks.

#### [APPLE_SIGN_IN_SETUP.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/APPLE_SIGN_IN_SETUP.md)
Explains local and future production setup for Sign in with Apple.

#### [scripts/verify.sh](/Users/Artem/.zenflow/worktrees/new-task-be0b/scripts/verify.sh)
Verification script for requested build and test levels.

### App Folders

#### `TchopApp/App`
Root application wiring.
Contains app entry points, dependency injection, bridges, theme/localization entry points, and app-global state.

#### `TchopApp/Models`
App-local models used by views, routes, shell, and feed presentation.

#### `TchopApp/Navigation`
Coordinator, route payloads, deep-link parsing, and navigation snapshot model.

#### `TchopApp/Persistence`
App-local persistence schema, seeding, backend selection policy, and migration orchestration.

#### `TchopApp/Repositories`
Repository orchestration that sits between feature/view-model code and services/persistence.

#### `TchopApp/Services`
Feature-facing app services such as session handling and feed API abstraction.

#### `TchopApp/ViewModels`
SwiftUI-facing state and behavior.

#### `TchopApp/Views`
SwiftUI presentation layer.

#### `TchopApp/Resources`
Bundled feature resources such as the stub feed JSON contract.

### Package Folders

The package is split by concern, not by feature.
That is intentional.
Feature code stays in the app; reusable primitives live in the package.

Main package modules:

- `TchopNetworking`
- `TchopDatabaseCore`
- `TchopSwiftDataDatabase`
- `TchopCoreDataDatabase`
- `TchopDatabaseComposition`
- `TchopDatabase`
- `TchopNavigation`
- `TchopLocalization`
- `TchopBranding`
- `TchopUIConfiguration`
- `TchopCache`
- `TchopWidgets`
- `TchopPushNotifications`
- `TchopAnalytics`
- `TchopAppleAuthentication`

---

## Architecture Principles

These principles explain why the project looks the way it does.

### 1. Reusable Infrastructure, App-Specific Composition
Anything realistically reusable across iOS apps should live in the package.
Anything tied to this product's routes, models, persistence schema, or UX should stay in `TchopApp`.

Examples:

- `TabRouter` belongs in `TchopNavigation`.
- `AppCoordinator` belongs in `TchopApp`.
- `AppleAuthenticationManager` belongs in the package.
- `AppState` belongs in the app.

### 2. Local-First Read Path
The app prefers local persisted state for bootstrap whenever possible.
This keeps startup and offline behavior predictable.

Examples:

- feed bootstraps from persisted snapshot before remote refresh;
- channel header info is seeded locally;
- user session restore reads local persisted user state;
- navigation restore reads persisted snapshot per user.

### 3. Single Clear Owner Per Concern
Every important runtime concern has one primary owner.

Examples:

- `AppState` owns authenticated user lifecycle;
- `AppCoordinator` owns selected tab and tab navigation stacks;
- `NewsFeedViewModel` owns visible feed screen state;
- `DefaultAppContentRepository` owns feed persistence/API orchestration;
- `UserSessionService` owns session marker storage;
- `DefaultUserRepository` owns persisted users.

### 4. Coordinator-Driven Navigation
Navigation is not scattered across unrelated views.
The project uses coordinator-driven tab navigation with route payloads and routers.

### 5. Storage-Backed Feature State
The current feed screen is not a pure in-memory mock anymore.
The feed is seeded, persisted, refreshed, read back from storage, and can survive app restarts and offline runtime.

### 6. Explicit Runtime Policy Over Cleverness
The codebase prefers explicit policy decisions over implicit behavior.

Examples:

- navigation restore is opt-in and user-scoped;
- card action start policy is explicit;
- rollback behavior is explicit;
- offline feed behavior is explicit;
- backend selection policy is explicit.

---

## High-Level Runtime Map

At a high level, the app works like this:

1. `TchopApp` starts.
2. `AppDIContainer` builds the dependency graph.
3. `AppState` restores session and owns authenticated lifecycle.
4. `AppRootView` chooses between login flow and shell.
5. `AppShellView` renders top bar, tabs, side menu, and shell overlays.
6. Feature view models drive their screens.
7. Repositories orchestrate API + persistence + mapping.
8. Package modules provide infrastructure under those repositories and bridges.

The main mental model:

```text
SwiftUI View
  -> ViewModel
    -> Repository
      -> Service/API and Persistence
        -> Package infrastructure
```

For some app-global concerns, `AppState` and `AppCoordinator` sit above normal feature flow.

---

## Main Entry Points

### [TchopApp.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/TchopApp.swift)
This is the app entry point.

What it does:

- creates `AppLaunchConfiguration`;
- creates `AppDIContainer`;
- asks the container for `AppState`;
- applies optional UI-test launch overrides;
- wires `TchopApplicationDelegate`;
- injects the DI container into the SwiftUI environment;
- renders `AppRootView`.

The important part is that the app does very little itself.
It delegates almost all real ownership to `AppDIContainer` and `AppState`.

### [AppRootView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/AppRootView.swift)
This is the root authentication switch.

It decides:

- no `currentUser` -> show `LoginScreenView`
- existing `currentUser` -> show `AppShellView`

This keeps the root UI split very clear and prevents authentication branching from leaking into feature screens.

---

## App Layer Walkthrough

## `TchopApp/App`

### [AppDIContainer.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppDIContainer.swift)
This is the composition root.
If you want to know how the app is wired together, start here.

### What it owns

- analytics collector;
- database manager;
- API manager;
- feed API manager;
- network monitor;
- app repositories;
- session service;
- Apple authentication manager;
- UI configuration manager;
- navigation state manager;
- deep-link manager;
- navigation event reporter;
- widget sync manager;
- push bridge.

### Key responsibilities

#### `init(databaseConfiguration:)`
Builds the app-wide dependency graph.

#### `makeAppShellViewModel()`
Creates the shell view model and injects:

- channel header info;
- `NewsFeedViewModel`;
- shell UI configuration manager.

#### `makeAppState()`
Creates the root app state object.

#### `makeSeededDatabaseManager(...)`
Creates the selected database backend and runs app-local seeding before feature graph assembly.

#### `makeContentServices(...)`
Builds:

- `APIManager`
- `StubFeedAPIManager`
- `NetworkAvailabilityMonitor`
- `DefaultAppContentRepository`
- `DefaultUserRepository`
- `UserSessionService`

### Why this file matters
This file is the answer to:

- what gets instantiated once per app process;
- which abstractions are package-backed vs app-local;
- how features obtain their dependencies.

If you add a new cross-feature service, it probably enters the project through this file.

### [AppState.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppState.swift)
This is the main app-level state object.
It is one of the most important files in the project.

### What it owns

- authenticated user state;
- `AppCoordinator`;
- `AppShellViewModel`;
- session restoration and sign-out flow;
- navigation snapshot restore/persist policy;
- deep-link buffering and replay;
- widget cleanup on sign-out;
- push authorization entry point.

### Important properties

#### `currentUser`
The current authenticated user.
This is the root source of truth for authentication state in the UI.

#### `coordinator`
Owns selected tab and tab-local routers.

#### `appShellViewModel`
Shared shell-scoped state.

#### `pendingDeepLinkInput`
Buffers deep links received before sign-in.

### Important methods

#### `signIn(username:)`
Local username sign-in path.

#### `signInWithApple(identity:)`
Apple-backed sign-in path.

#### `setNavigationRestoreEnabled(_:)`
Updates the user preference and immediately applies restore or reset policy.

#### `handleIncomingURL(_:)`
Routes incoming deep links.

#### `handleIncomingUserActivity(_:)`
Routes universal links.

#### `signOut()`
Clears session, resets navigation, closes menu, clears widget feed snapshot.

#### `restoreSession()`
Attempts to restore the last signed-in user.

#### `restoreNavigationIfNeeded(for:)`
Restores saved navigation snapshot if the active user allowed it.

#### `applyPostAuthenticationNavigation(for:)`
Important runtime rule:

- pending deep link wins first;
- snapshot restore runs second.

That precedence is deliberate and prevents an old saved stack from overriding a fresh external route.

### Why this file matters
If you need to change authenticated lifecycle, sign-in/out behavior, deep-link timing, or navigation restore policy, this is the file.

### [AppWidgetBridge.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppWidgetBridge.swift)
This file adapts app-local feed content into widget snapshot storage.

Main types:

#### `WidgetContentSyncing`
App-facing protocol used by the rest of the app.

#### `FeedHeadlineWidgetSyncManager`
Concrete implementation that writes widget snapshot data and reloads timelines.

### Why this file exists
The app should not directly depend on WidgetKit details everywhere.
This bridge keeps widget sync behind a simple app-facing contract.

### [AppPushNotificationBridge.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppPushNotificationBridge.swift)
This file bridges UIKit/APNs lifecycle callbacks into the reusable push package.

Main types:

#### `AppPushNotificationBridging`
App-facing protocol consumed by the application delegate and `AppState`.

#### `AppPushNotificationBridge`
Real bridge that:

- requests authorization;
- registers for remote notifications;
- persists device token state;
- persists registration failures;
- parses remote payloads;
- forwards them to `TchopPushNotifications`.

### Why this file exists
UIKit lifecycle glue is app-specific.
Push-state management is reusable.
This bridge is the seam between them.

---

## Navigation Layer Walkthrough

## `TchopApp/Navigation`

### [AppCoordinator.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/AppCoordinator.swift)
This type owns app navigation state.

### What it owns

- `selectedTab`
- `newsRouter`
- `mixesRouter`
- `pinnedRouter`
- `chatRouter`
- `profileRouter`

Each router is a `TabRouter<Route>` from the package.

### Important methods

#### `selectTab(_:)`
Switches tabs without resetting the tab stack.

#### `showTabRoot(_:)`
Resets the selected tab to its root state and selects it.

#### `resetAllNavigation()`
Clears all tab stacks.

#### `navigationChanges`
Publisher used by `AppState` to persist snapshots.

#### `makeSnapshot()`
Builds a serializable `NavigationSnapshot`.

#### `applySnapshot(_:)`
Restores a previously persisted snapshot.

#### `navigateToNews`, `navigateToMixes`, `navigateToPinned`, `navigateToChat`, `navigateToProfile`
Apply route transitions with idempotency checks.

### Why idempotency matters
Deep links, repeated taps, and snapshot restore should not accumulate duplicate routes.
This is why route-equivalence checking exists here.

### [TabRoutes.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/TabRoutes.swift)
Contains the route payloads for each tab.

Examples:

- `NewsRoute`
- `MixesRoute`
- `PinnedRoute`
- `ChatRoute`
- `ProfileRoute`

These are plain data payloads used by navigation stacks.
They are `Codable` where persistence needs it.

### [NavigationSnapshot.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/NavigationSnapshot.swift)
This is the serialized navigation state model.

Important fields:

- `version`
- `createdAt`
- `selectedTab`
- per-tab route arrays

Important methods:

#### `migratedToSupportedVersion()`
Moves old snapshots to the currently supported schema version.

#### `sanitized(maxRoutesPerTab:)`
Bounds route counts so restore is safe.

### Why this matters
Navigation restore is a real persisted feature, not an in-memory convenience.
That requires versioning and sanitization.

### [DeepLinkManager.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/DeepLinkManager.swift)
This type parses and applies app deep links and universal links.

### What it does

- parses incoming URLs;
- distinguishes custom scheme vs universal link;
- maps URLs to a `DeepLinkIntent`;
- applies intent into `AppCoordinator`;
- reports navigation events through `NavigationEventReporting`.

### Important behavior

- unsupported links return `false`;
- malformed in-app links fall back to a known safe app state;
- supported links become typed route payloads.

### Why this matters
Deep-link parsing is app-specific because route payloads and URL schema are app-specific.

---

## Models Layer Walkthrough

## `TchopApp/Models`

### [AppUser.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/AppUser.swift)
Domain model for a locally persisted user profile.

Fields:

- `id`
- `username`
- `appleUserID`
- `createdAt`
- `isNavigationStateRestoreEnabled`

### [AppTab.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/AppTab.swift)
Top-level application tab enum.

It provides:

- stable IDs;
- localized title;
- tab icon;
- menu icon;
- stub description.

### [ChannelHeaderInfo.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/ChannelHeaderInfo.swift)
Simple presentation model for the fixed top channel header.

### [AccountProfileSummary.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/AccountProfileSummary.swift)
App-local summary model used by the shell and profile/menu surfaces to show:

- display name;
- initials;
- sign-in method copy;
- account hint.

### [NewsFeedModels.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/NewsFeedModels.swift)
This is the main presentation model file for the home feed.

Important types:

#### `NewsFeedContent`
Root feed presentation model.
Contains:

- ordered list of cards;
- feed availability metadata.

#### `NewsFeedAvailability`
Explains whether the current visible feed is:

- `live`
- `cached`

#### `NewsFeedCacheReason`
Explains why cached content is shown:

- `bootstrap`
- `offline`

#### `NewsFeedCard`
Enum of currently supported card kinds:

- `featuredArticle`
- `discussion`

#### `FeaturedArticleCardModel`
Presentation model for one article card.

Contains:

- display content;
- comment count;
- article actions;
- runtime UI state;
- derived `detailRoute`.

#### `FeaturedArticleCardUIState`
Runtime-only per-card state owned by the screen.

Contains:

- `isLiked`
- `displayMode`
- `pendingOperation`
- `inlineStatusMessage`

Important distinction:

- card content is persisted;
- runtime pending state belongs to the screen.

#### `FeaturedArticleCardAction`
Typed user intents from the card UI.

Cases:

- `toggleLike`
- `addComment`
- `setDisplayMode(...)`
- `refreshContent`
- `runLongTask`

#### `DiscussionCardModel`
Presentation model for discussion cards.

Contains:

- headline and category;
- participants;
- reply count;
- joined count;
- runtime UI state;
- derived route.

#### `DiscussionCardAction`
Typed user intents from the discussion card UI.

### Why this file matters
If you are changing card rendering, card actions, or feed presentation contracts, you will almost certainly touch this file.

---

## Persistence Layer Walkthrough

## `TchopApp/Persistence`

### [AppDatabase.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppDatabase.swift)
This file owns app-specific persistence bootstrapping and backend selection.

Important types:

#### `AppDatabase`
App-level builder for the selected database manager.

Important methods:

##### `makeDatabaseManager(...)`
Creates the active backend manager.

##### `makeDatabaseManagerOrThrow(...)`
Same as above, but throwing.

##### `makeCoreDataManager(...)`
Builds Core Data backend.

##### `makeSwiftDataManager(...)`
Builds SwiftData backend.

##### `migrateCoreDataToSwiftDataAndCreateManager(...)`
Runs app-specific migration and then chooses the post-migration backend.

#### `AppDatabaseRuntimeContext`
Captures runtime facts used to choose persistence backend:

- stored backend preference;
- whether legacy Core Data store exists;
- whether SwiftData is available.

#### `AppDatabaseResolutionPlan`
The chosen plan:

- use Core Data;
- use SwiftData;
- migrate Core Data to SwiftData.

#### `AppDatabaseRuntimePolicy`
Decision logic for backend selection.

### Why this file matters
This is where app-specific persistence policy lives.
The generic database mechanics live in the package.
The app-specific decision about which backend to use lives here.

### [AppContentRecord.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppContentRecord.swift)
Defines app-local persistence records.

Important types:

#### `ChannelRecord`
SwiftData record for channel metadata.

#### `FeedCardRecord`
SwiftData record for one feed card snapshot.

This record stores:

- generic ordering/sync metadata;
- shared card fields;
- article-specific payload fields;
- discussion-specific payload fields;
- persisted local state payload blobs.

This is intentionally a single-card table model rather than many separate tables per card kind.
That keeps full-snapshot sync simple while the app supports only a small number of card types.

#### `UserRecord`
SwiftData record for users.

#### `FeedCardActionPayload`
Persisted payload for article action buttons.

#### `FeedCardArticleStatePayload`
Persisted local state for article cards.

#### `FeedCardDiscussionStatePayload`
Persisted local state for discussion cards.

#### `FeedCardParticipantPayload`
Persisted payload for discussion participants.

### [AppDataSeeder.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppDataSeeder.swift)
Seeds initial local data into the selected backend.

Important methods:

#### `seedIfNeeded(in:)`
Root seeding entry point.

#### `seedChannelIfNeeded(in:)`
Seeds channel metadata.

#### `seedFeedIfNeeded(in:)`
Seeds initial feed snapshot from bundled JSON.

Important detail:

- the bundled JSON is the seed contract;
- after seeding and runtime actions, persistence becomes the local source of truth.

### [AppDatabase.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppDatabase.swift) and [AppContentRecord.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppContentRecord.swift) together
These files define both:

- how the app chooses a persistence backend;
- what app-local data shape is stored inside that backend.

---

## Services Layer Walkthrough

## `TchopApp/Services`

### [UserSessionService.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Services/UserSessionService.swift)
Owns session marker persistence.

Important protocol:

#### `UserSessionManaging`
Used by `AppState`.

Important methods:

##### `signIn(username:)`
Finds or creates a local user and stores the active user ID.

##### `signInWithApple(identity:)`
Finds or creates Apple-backed user and stores active user ID.

##### `restoreSession()`
Restores active session from `UserDefaults`.

##### `signOut()`
Clears session marker.

Important detail:
The service stores only the active user marker.
It does not own user persistence logic.
That belongs to `UserRepository`.

### [FeedAPIManager.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Services/FeedAPIManager.swift)
This file defines the feed API contract and the current stub implementation.

Important types:

#### `FeedResponseDTO`
DTO for a full feed response.

#### `FeedCardDTO`
Enum DTO for supported card payloads.

#### `FeaturedArticleDTO`
DTO for article cards.

#### `DiscussionDTO`
DTO for discussion cards.

#### `FeaturedArticleStateDTO`
Persisted article local state in the contract.

#### `DiscussionStateDTO`
Persisted discussion local state in the contract.

#### `FeedAPIManaging`
Main protocol consumed by the repository.

Important methods:

- `fetchFeed()`
- `setFeaturedArticleLike(...)`
- `addFeaturedArticleComment(...)`
- `setFeaturedArticleDisplayMode(...)`
- `refreshFeaturedArticle(...)`
- `runFeaturedArticleUpdate(...)`
- `setDiscussionParticipation(...)`
- `addDiscussionReply(...)`
- `setDiscussionDisplayMode(...)`
- `refreshDiscussion(...)`
- `runDiscussionUpdate(...)`

#### `StubFeedAPIManager`
Current implementation.

Important behavior:

- full feed fetch reads bundled JSON;
- card actions simulate a successful mutation and return an updated DTO;
- repository then merges and persists that result against the latest stored card state.

#### `FeedAPIStubFactory`
Helper for loading and decoding the bundled JSON contract.

### Why this file matters
When a real backend arrives, this is the first file where stub behavior will be replaced by real transport-backed implementations.

---

## Repositories Layer Walkthrough

## `TchopApp/Repositories`

### [UserRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/UserRepository.swift)
Owns persisted user records.

Important protocol:

#### `UserRepository`
Public app-facing contract for user persistence.

Important methods:

- `findUser(id:)`
- `findUser(username:)`
- `findOrCreateUser(username:)`
- `findOrCreateAppleUser(appleUserID:preferredUsername:)`
- `updateNavigationStateRestoreEnabled(userID:isEnabled:)`

#### `DefaultUserRepository`
Backend-neutral implementation that works through `DatabaseManaging`.

### Why this file matters
All user persistence and user creation flows should go through this repository, not directly to `UserDefaults` or raw persistence records.

### [AppContentRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/AppContentRepository.swift)
This is one of the most important feature files in the app.

It owns:

- channel header fetch;
- feed bootstrap from persistence;
- online/offline refresh policy;
- full feed snapshot sync into persistence;
- targeted card actions;
- DTO-to-persistence mapping;
- persistence-to-presentation mapping.

Important protocols:

#### `ChannelInfoRepository`
Read-only contract for channel header information.

#### `NewsFeedRepository`
Main feature contract for the news screen.

Important methods:

##### `currentNewsFeedContent()`
Returns current persisted snapshot, if any.

##### `refreshNewsFeedContent()`
If online:

- fetches feed from API;
- syncs into persistence;
- re-reads storage-backed snapshot;
- returns presentation model.

If offline:

- returns persisted snapshot marked as offline;
- or throws if there is no persisted feed yet.

##### `performFeaturedArticleAction(...)`
Runs one article card action.

##### `performDiscussionAction(...)`
Runs one discussion card action.

### Important runtime behavior

#### Storage-backed feed
Even a successful refresh is not returned directly from raw DTOs.
The repository writes to storage and then reads back from storage.
That keeps the UI on one consistent read path.

#### Persisted-first card actions
Card actions do not treat bundled JSON as the source of truth.
They:

1. read latest persisted card state;
2. call API manager;
3. merge the returned DTO with latest persisted state;
4. persist the updated snapshot;
5. return the persisted card model.

This matters because:

- like state;
- comment/reply counts;
- display mode;
- participation state

must not be lost between sequential actions.

### Why this file matters
If feed behavior changes, this file is almost always involved.
This is the primary seam between:

- feature UI;
- transport;
- persistence;
- mapping;
- offline policy.

---

## ViewModel Layer Walkthrough

## `TchopApp/ViewModels`

### [LoginViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/LoginViewModel.swift)
Thin authentication screen view model.

It owns:

- username input;
- displayable validation/auth errors;
- Apple sign-in result handling.

It does not own session state.
That remains in `AppState`.

### [AppShellViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/AppShellViewModel.swift)
Owns shell-scoped UI state.

It owns:

- side menu open/close state;
- channel header info;
- shell footer text;
- floating action button visibility;
- shell UI configuration loading.

Important behavior:

- applies cached UI configuration first;
- refreshes remote configuration second.

### [NewsFeedViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/NewsFeedViewModel.swift)
This is the main screen state owner for the home feed.

Important types in this file:

#### `NewsFeedState`
Screen state enum:

- `loading`
- `loaded`
- `failed`

#### `NewsFeedLoadPolicy`
Internal load semantics:

- `initial`
- `refresh`
- `retry`

#### `CardActionFailurePolicy`
Describes how the screen should recover after a card action fails.

#### `CardActionStartDecision`
Explicit policy for whether a new card action should:

- start now;
- queue;
- ignore.

### What `NewsFeedViewModel` owns

- current visible feed screen state;
- feed loading task;
- one task slot per visible article card;
- one task slot per visible discussion card;
- queued additive actions for comments/replies.

### Important methods

#### `refresh()`
Manual feed refresh.

#### `retry()`
Retry after failed feed load.

#### `handleFeaturedArticleAction(articleID:action:)`
Routes typed article card intents into screen behavior.

#### `handleDiscussionAction(discussionID:action:)`
Routes typed discussion card intents.

#### `cancelLoading()`
Cancels feed loading and card tasks.

### Card action model

The project currently uses:

- dumb card views;
- item-level runtime state in card models;
- screen-owned orchestration;
- repository-owned persistence/API work.

That means:

- views emit typed actions;
- view model applies runtime UI state;
- repository persists results;
- view model applies returned card snapshot.

### Important action rules

#### Lightweight optimistic actions
Examples:

- like toggle;
- participation toggle;
- display mode change.

These update visible UI immediately and rollback on failure if policy requires it.

#### Additive serial actions
Examples:

- add comment;
- add reply.

Repeated taps are queued and replayed serially so every successful action increments the persisted count.

#### Non-optimistic heavy actions
Examples:

- refresh card content;
- run long update task.

These keep existing visible content while pending, then replace card content on success.

### Why this file matters
If you change feed behavior, card action runtime, rollback behavior, or inline status handling, this is the main file.

---

## Views Layer Walkthrough

## `TchopApp/Views`

The view layer is split by purpose.

### Root And Shell Views

#### [AppRootView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/AppRootView.swift)
Authentication switch.

#### [AppShellView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/AppShellView.swift)
Authenticated shell.
Owns:

- side menu overlay;
- shell content;
- drag gestures for menu open/close.

#### [ShellContentView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/ShellContentView.swift)
Lays out:

- top bar;
- selected tab content;
- floating action button;
- bottom tab bar.

#### [TabContentView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/TabContentView.swift)
Switches tab root views based on `AppTab`.

### Auth Views

#### `Views/Auth/LoginScreenView.swift`
Renders username login and Apple login entry points.

### Menu And Chrome Views

#### `Views/Menu/SideMenuView.swift`
Renders side menu with account summary and tab selection.

#### `Views/TopBarView.swift`
Fixed top chrome.

#### `Views/Tabs/BottomTabBar.swift`
Bottom tab bar.

#### `Views/Tabs/FloatingActionButton.swift`
Floating `+` action button for the news tab shell.

### News Views

#### [Views/Tabs/NewsTabRootView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Tabs/NewsTabRootView.swift)
Connects feed screen to tab router and navigation destination rendering.

#### `Views/News/NewsFeedView.swift`
Main feed screen.
Renders:

- feed availability message;
- error banner if needed;
- list of cards;
- pull-to-refresh.

#### `Views/News/FeaturedArticleCard.swift`
Renders one article card.
The card is intentionally presentation-oriented and emits typed actions upward.

#### `Views/News/DiscussionCard.swift`
Same pattern for discussion cards.

#### `Views/News/ArticleActionView.swift`
Renders article action buttons.

#### `Views/News/FeaturedArticleStatusBadge.swift`
Inline status/pending UI for article cards.

#### `Views/Tabs/NewsDestinationView.swift`
Renders pushed news details from `NewsRoute`.

### Stub Views

The non-news tabs still use placeholder/stub roots and detail views.
These exist to exercise shell, coordinator, and navigation infrastructure without pretending those features are implemented yet.

Examples:

- `MixesTabRootView`
- `PinnedTabRootView`
- `ChatTabRootView`
- stub detail screens

### Profile Views

`ProfileTabRootView` now acts as a real account screen rather than a placeholder.
It shows:

- account name;
- provider summary;
- account ID hint;
- restore-navigation setting;
- logout.

---

## Runtime Flows In Detail

## 1. App Launch Flow

Files involved:

- [TchopApp.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/TchopApp.swift)
- [AppDIContainer.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppDIContainer.swift)
- [AppState.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppState.swift)

Flow:

1. `TchopApp` creates `AppLaunchConfiguration`.
2. `TchopApp` creates `AppDIContainer`.
3. `AppDIContainer` creates database manager.
4. `AppDIContainer` seeds local data if needed.
5. `AppDIContainer` builds repositories, services, bridges, and view-model dependencies.
6. `AppDIContainer` creates `AppState`.
7. `AppState` restores session.
8. `AppRootView` chooses login or shell.

## 2. Login Flow

Files involved:

- `Views/Auth/LoginScreenView.swift`
- [LoginViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/LoginViewModel.swift)
- [AppState.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppState.swift)
- [UserSessionService.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Services/UserSessionService.swift)
- [UserRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/UserRepository.swift)

Local login:

1. user enters username;
2. `LoginViewModel.submit()` validates input;
3. `AppState.signIn(username:)` runs;
4. `UserSessionService.signIn(username:)` asks `UserRepository` for user;
5. repository finds or creates user;
6. service stores active user ID;
7. `AppState` activates authenticated runtime.

Apple login:

1. Apple sheet returns `ASAuthorization`;
2. `LoginViewModel.handleAppleSignInCompletion(...)` converts it into `AppleAuthenticationIdentity`;
3. `AppState.signInWithApple(identity:)` runs;
4. `UserSessionService.signInWithApple(identity:)` resolves Apple-backed user via repository;
5. service stores active user ID;
6. `AppState` activates authenticated runtime.

## 3. Session Restore Flow

Files involved:

- [AppState.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppState.swift)
- [UserSessionService.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Services/UserSessionService.swift)

Flow:

1. `AppState.restoreSession()` runs on startup.
2. `UserSessionService.restoreSession()` reads active user marker.
3. It upgrades old username-based marker if needed.
4. If persisted user exists, it returns `AppUser`.
5. `AppState` activates authenticated flow.

## 4. Navigation Restore Flow

Files involved:

- [AppState.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppState.swift)
- [AppCoordinator.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/AppCoordinator.swift)
- [NavigationSnapshot.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/NavigationSnapshot.swift)
- `TchopNavigation`

Flow:

1. authenticated user becomes active;
2. if no pending deep link exists, restore is considered;
3. restore preference is checked on user profile;
4. snapshot is loaded from `NavigationStateManaging`;
5. snapshot version is migrated if needed;
6. snapshot is sanitized;
7. `AppCoordinator.applySnapshot(...)` applies it;
8. navigation changes are persisted again afterward when user navigates.

## 5. Deep-Link Flow

Files involved:

- [AppState.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppState.swift)
- [DeepLinkManager.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/DeepLinkManager.swift)
- [AppCoordinator.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/AppCoordinator.swift)

Flow:

1. URL or user activity arrives;
2. `AppState` buffers it if user is not authenticated yet;
3. otherwise it asks `DeepLinkManager` to parse and apply it;
4. `DeepLinkManager` builds typed intent;
5. coordinator transitions to proper tab and route.

## 6. Feed Bootstrap And Refresh Flow

Files involved:

- [AppDIContainer.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppDIContainer.swift)
- [NewsFeedViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/NewsFeedViewModel.swift)
- [AppContentRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/AppContentRepository.swift)
- [FeedAPIManager.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Services/FeedAPIManager.swift)
- [AppDataSeeder.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppDataSeeder.swift)

Bootstrap:

1. DI asks repository for `currentNewsFeedContent()`;
2. if persisted feed exists, that becomes initial content;
3. otherwise fallback fixture is used temporarily;
4. `NewsFeedViewModel` starts first load.

Refresh when online:

1. `NewsFeedViewModel.refresh()` or initial load calls repository;
2. repository calls `feedAPIManager.fetchFeed()`;
3. repository syncs DTOs into persistence;
4. repository reads persisted feed snapshot back;
5. repository returns `NewsFeedContent`;
6. view model applies content;
7. widget snapshot sync runs.

Refresh when offline:

1. repository checks network availability;
2. if offline and persisted feed exists, it returns cached content with offline reason;
3. if offline and no persisted feed exists, it throws.

## 7. Feed Card Action Flow

Files involved:

- [NewsFeedViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/NewsFeedViewModel.swift)
- [AppContentRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/AppContentRepository.swift)
- [FeedAPIManager.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Services/FeedAPIManager.swift)
- [NewsFeedModels.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/NewsFeedModels.swift)

Example: like action

```swift
viewModel.handleFeaturedArticleAction(articleID: article.id, action: .toggleLike)
```

Flow:

1. card view emits typed action;
2. `NewsFeedViewModel` decides whether to start, queue, or ignore;
3. view model applies optimistic local UI state;
4. repository performs targeted action;
5. repository merges against latest persisted state;
6. repository persists updated card snapshot;
7. updated card model comes back to view model;
8. view model updates visible card state.

Example: add comment

Important difference:

- no optimistic fake comment insertion;
- repeated taps queue;
- each successful action increments persisted count by one;
- final card snapshot comes from persistence-backed repository result.

## 8. Widget Sync Flow

Files involved:

- [AppWidgetBridge.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppWidgetBridge.swift)
- `TchopWidgets`

Flow:

1. `NewsFeedViewModel` applies feed content;
2. widget sync manager extracts best headline;
3. it writes shared snapshot;
4. widget timelines reload.

## 9. Push Notification Flow

Files involved:

- `TchopApplicationDelegate`
- [AppPushNotificationBridge.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppPushNotificationBridge.swift)
- `TchopPushNotifications`

Flow:

1. UIKit callback enters application delegate;
2. callback is forwarded into push bridge;
3. bridge updates reusable push manager;
4. package persists status/token/payload state.

---

## Package Layer Walkthrough

The app-specific onboarding above is the most important part for day-to-day work.
The package layer exists to support it.

## `TchopAnalytics`
Reusable analytics primitives and collectors.
Current app uses an in-memory collector in DI.

## `TchopAppleAuthentication`
Apple-sign-in normalization and helper logic.

Important types:

- `AppleAuthenticationIdentity`
- `AppleAuthenticationManaging`
- `AppleAuthenticationManager`
- `AppleAuthenticationError`

App-specific session handling remains outside this package.

## `TchopBranding`
Reusable brand/theme primitives.
Used to support target-specific brand variation.

## `TchopCache`
Reusable in-memory and file-backed caching primitives.

## `TchopDatabaseCore`
Backend-neutral database contracts and migration primitives.

Important examples:

- `DatabaseManaging`
- operation wrappers
- migration step primitives
- backend kind types

## `TchopSwiftDataDatabase`
SwiftData implementation of `DatabaseManaging`.

## `TchopCoreDataDatabase`
Core Data implementation of `DatabaseManaging`.

## `TchopDatabaseComposition`
Unified database resolver/factory composition layer.

## `TchopDatabase`
Umbrella product re-exporting database modules and shared database-facing APIs.

## `TchopLocalization`
Localization facade.
New user-facing strings should go through localization, not ad-hoc string literals.

## `TchopNavigation`
Reusable navigation primitives.

Important examples:

- `TabRouter`
- `NavigationStateManaging`
- `NavigationStateManager`
- `NavigationTransitionPolicy`
- `NavigationEvent`
- event reporters

## `TchopNetworking`
Reusable networking client and request execution layer.
The app currently uses it in stub configuration through `APIManager`.

## `TchopPushNotifications`
Reusable APNs state and payload handling package.

## `TchopUIConfiguration`
Reusable server-driven UI configuration support.

## `TchopWidgets`
Reusable widget snapshot store primitives.

---

## Practical File Map: Where To Change What

### I need to change app startup or root dependency wiring
Start in:

- [TchopApp.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/TchopApp.swift)
- [AppDIContainer.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppDIContainer.swift)

### I need to change login/session behavior
Start in:

- [AppState.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppState.swift)
- [UserSessionService.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Services/UserSessionService.swift)
- [UserRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/UserRepository.swift)

### I need to change navigation, routes, or deep links
Start in:

- [AppCoordinator.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/AppCoordinator.swift)
- [DeepLinkManager.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/DeepLinkManager.swift)
- [TabRoutes.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/TabRoutes.swift)
- [NavigationSnapshot.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/NavigationSnapshot.swift)

### I need to change the news feed loading flow
Start in:

- [NewsFeedViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/NewsFeedViewModel.swift)
- [AppContentRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/AppContentRepository.swift)
- [FeedAPIManager.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Services/FeedAPIManager.swift)
- [NewsFeedModels.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/NewsFeedModels.swift)

### I need to change card action behavior
Start in:

- [NewsFeedModels.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/NewsFeedModels.swift)
- [NewsFeedViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/NewsFeedViewModel.swift)
- [AppContentRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/AppContentRepository.swift)
- [FeedAPIManager.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Services/FeedAPIManager.swift)

### I need to change local persistence or backend selection
Start in:

- [AppDatabase.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppDatabase.swift)
- [AppContentRecord.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppContentRecord.swift)
- [AppDataSeeder.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppDataSeeder.swift)

### I need to change shell/menu/tab layout
Start in:

- [AppShellView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/AppShellView.swift)
- [ShellContentView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/ShellContentView.swift)
- [TabContentView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/TabContentView.swift)
- `BottomTabBar.swift`
- `SideMenuView.swift`
- `TopBarView.swift`

### I need to change widgets or push handling
Start in:

- [AppWidgetBridge.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppWidgetBridge.swift)
- [AppPushNotificationBridge.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppPushNotificationBridge.swift)

---

## Current Product State

The app today is not a blank shell.
These are real implemented areas:

- authentication with username and Apple sign-in;
- authenticated shell with menu and tab bar;
- persisted user profiles;
- per-user navigation restore option;
- deep-link parsing and routing;
- local-first home feed;
- persisted feed snapshot;
- offline/cached feed handling;
- per-card actions for featured article and discussion;
- widget headline sync;
- push-notification bridge;
- backend-neutral persistence path with Core Data / SwiftData logic.

These are still partial or intentionally stubbed:

- real backend for feed;
- real backend for card actions;
- fully implemented non-news tabs;
- final production Apple Sign In environment setup;
- final network error semantics for real backend contracts.

---

## Development Rules Specific To This Project

### 1. Do Not Bypass Ownership Boundaries
If a concern already has a clear owner, extend that owner instead of adding sideways logic.

Examples:

- do not persist users from `AppState`;
- do not mutate feed storage from views;
- do not let views call repositories directly;
- do not move package-worthy infrastructure into ad-hoc app helpers.

### 2. Prefer The Storage-Backed Path
If feature state is already persistence-backed, keep the UI reading through the same path rather than inventing a second parallel path.

### 3. Card Views Stay Dumb
Card views render state and emit typed intents.
They do not own repository, database, or API orchestration.

### 4. Keep Package Boundaries Honest
Do not extract product-specific feature models into the package just because they sound reusable in theory.

### 5. Update This Document When The Architecture Changes
If you change:

- startup wiring;
- persistence ownership;
- repository contracts;
- navigation flow;
- card action model;
- package/app boundaries;
- onboarding-critical files;

then update this document in the same task.

---

## Suggested Reading Path For A New Developer

If you are new to the project, read these files in this order:

1. [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
2. [TchopApp.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/TchopApp.swift)
3. [AppDIContainer.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppDIContainer.swift)
4. [AppState.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/App/AppState.swift)
5. [AppCoordinator.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Navigation/AppCoordinator.swift)
6. [NewsFeedModels.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/NewsFeedModels.swift)
7. [NewsFeedViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/NewsFeedViewModel.swift)
8. [AppContentRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/AppContentRepository.swift)
9. [FeedAPIManager.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Services/FeedAPIManager.swift)
10. [AppDatabase.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppDatabase.swift)
11. [AppContentRecord.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppContentRecord.swift)
12. [AppDataSeeder.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppDataSeeder.swift)

After that, the rest of the project should read much more naturally.

---

## Final Summary

The shortest correct summary of the project is:

`TchopApp` is a SwiftUI iOS app with an app-specific shell and feature layer on top of a reusable infrastructure package.
Authentication, navigation restore, deep links, feed rendering, feed persistence, and card actions are all explicit runtime systems with clear owners.
The codebase is intentionally organized so new features can be added without collapsing those ownership boundaries.

If you are unsure where a change belongs, ask:

1. is this reusable infrastructure or product-specific behavior?
2. who already owns this runtime concern?
3. should the UI read this state from persistence, repository, or view model?
4. will this change require this document to be updated?
