# TchopApp Project Documentation

## Overview
`TchopApp` is a multi-target iOS SwiftUI application built around a coordinator-driven shell, package-backed infrastructure, and a local-first data layer.
The project currently includes:
- app targets: `TchopApp`, `TchopAppOcean`
- widget extensions: `TchopWidgetsExtension`, `TchopWidgetsOceanExtension`
- shared infrastructure package: `Packages/TchopInfrastructure`

The architecture is intentionally split so that reusable service, persistence, navigation, branding, localization, caching, widget, push, and server-driven UI pieces can be moved into other iOS projects with minimal adaptation.

## Targets
### `TchopApp`
Primary host application using the `classic` brand variant.

### `TchopAppOcean`
Secondary host application using the `ocean` brand variant.
The target exists to validate multi-target app composition and target-specific semantic branding.

### `TchopWidgetsExtension`
Widget extension embedded into `TchopApp`.
Uses shared app-group storage to render the latest feed headline snapshot.

### `TchopWidgetsOceanExtension`
Widget extension embedded into `TchopAppOcean`.
Exists separately because widget extension bundle identifiers cannot be shared across multiple host apps with different bundle identifiers.

## App Architecture
### Entry points
- `TchopApp/TchopApp.swift`: app bootstrap and application-delegate wiring.
- `TchopApp/App/AppDIContainer.swift`: composition root for runtime dependencies.
- `TchopApp/App/AppState.swift`: root state object for authentication, navigation restore, deep links, push authorization entry point, and widget cleanup.

### UI architecture
The app follows `MVVM` with coordinator-driven navigation:
- `View`: presentation only.
- `ViewModel`: UI state + feature logic.
- `Repository`: orchestration and domain mapping.
- `Infrastructure packages`: reusable low-level services and managers.

### Navigation
Navigation is coordinator-based and tab-aware:
- `AppCoordinator` owns selected tab and per-tab routers.
- `TabRouter<Route>` comes from `TchopNavigation`.
- navigation snapshots are persisted per user through `NavigationStateManaging`.
- deep links and universal links are routed through `DeepLinkManager`.
- navigation transition semantics and observability contracts now live in `TchopNavigation`.

### Authentication and session
- `UserSessionService` performs local sign-in / restore / sign-out.
- `AppState` restores session on launch.
- after sign-in, the app applies pending deep links first, then restores navigation snapshot if allowed by user settings.

### Persistence
The app uses a backend-neutral database abstraction.
Runtime selection works as follows:
- iOS `<17`: Core Data path remains available.
- iOS `17+`: SwiftData is preferred.
- if a legacy Core Data store exists and the app runs on iOS `17+`, the app migrates content to SwiftData and removes the old Core Data store files after successful migration.

`AppDatabase` is app-specific orchestration only. Backend-neutral manager contracts and concrete database managers live in the infrastructure package.

## Infrastructure Package
The reusable package is defined in `Packages/TchopInfrastructure/Package.swift`.

### `TchopNetworking`
Reusable networking stack with:
- typed requests
- cancellation
- upload/download support
- retry hooks
- logging
- metrics/observability
- offline queue foundation and persisted queue support
- mock transport support

### `TchopDatabaseCore`
Shared database contracts and migration primitives:
- backend selection types
- database operation wrappers
- `DatabaseManaging`
- migration version storage
- migration runner and migration steps

### `TchopSwiftDataDatabase`
SwiftData-backed implementation of `DatabaseManaging`.

### `TchopCoreDataDatabase`
Core Data-backed implementation of `DatabaseManaging`.

### `TchopDatabaseComposition`
Reusable composition layer for database managers:
- `DatabaseManagerFactorySet`
- backend availability reporting
- unified resolver/factory API for backend creation

### `TchopDatabase`
Backward-compatible umbrella product that re-exports database modules and `TchopNavigation`.

### `TchopNavigation`
Reusable navigation infrastructure:
- `TabRouter`
- `NavigationStateManaging`
- `NavigationStateManager`
- `NavigationTransitionPolicy`
- `NavigationEvent`
- `NavigationEventReporting`
- no-op and in-memory event reporters

### `TchopLocalization`
Package-backed localization facade with locale override support.
All new user-facing strings must go through localization keys.

### `TchopBranding`
Target-driven semantic branding layer backed by build settings / info dictionary values.
Raw palette tokens live separately from semantic theme resolution.

### `TchopUIConfiguration`
Server-driven UI configuration package with:
- current snapshot access
- refresh semantics
- persisted snapshot storage
- default `UserDefaults` store

### `TchopCache`
Reusable local cache package with in-memory and file-backed implementations.
Supports Codable payloads and expiration policies.

### `TchopWidgets`
Shared app/widget snapshot primitives for feed headline rendering.

### `TchopPushNotifications`
Reusable APNs state/token/payload management package.
System callback handling remains in the app bridge layer.
The package now includes both `UserDefaultsPushNotificationStateStore` and `InMemoryPushNotificationStateStore`, so host apps can choose between persisted and ephemeral storage without adding app-local store implementations.

## Key Runtime Flows
### App launch
1. `TchopApp` creates `AppDIContainer`.
2. `AppDIContainer` builds database manager, repositories, bridges, and feature services.
3. `AppState` restores session.
4. If a user exists, `AppState` applies pending deep link or snapshot restore.

### News feed loading
1. `NewsFeedViewModel` triggers `repository.fetchNewsFeedContent()`.
2. `DefaultAppContentRepository` fetches DTOs from `FeedAPIManaging`.
3. DTOs are mapped into `NewsFeedContent`.
4. widget snapshot is updated through `WidgetContentSyncing`.

### Shell UI configuration
1. `AppShellViewModel` reads cached `currentConfiguration()`.
2. it applies shell UI state immediately.
3. it then calls `refreshConfiguration()`.
4. refreshed state is applied and persisted by `TchopUIConfiguration`.

### Push notifications
1. UIKit callbacks enter through `TchopApplicationDelegate`.
2. app-level bridge normalizes platform callbacks.
3. `TchopPushNotifications` package stores authorization, token, and latest payload state.

## Directory Guide
### App
- `TchopApp/App`: root state, DI, app bridges, app theming/localization entry points.
- `TchopApp/Navigation`: app-specific coordinator, routes, deep-link parser, snapshot model.
- `TchopApp/Repositories`: repository orchestration and mapping.
- `TchopApp/Services`: feature-facing service abstractions.
- `TchopApp/Persistence`: app-specific records, seeding, and database orchestration.
- `TchopApp/ViewModels`: SwiftUI view models.
- `TchopApp/Views`: SwiftUI screens and reusable presentation components.

### Tests
- `TchopAppTests`: app-level contract/regression tests.
- `Packages/TchopInfrastructure/Tests`: package-level behavior tests.

## Testing Strategy
The project uses two test layers:
- package tests for reusable modules and low-level behavior
- app tests for session, navigation, repository mapping, shell UI configuration, and view-model contracts

Current test philosophy:
- add tests where refactors change contracts or lifecycle behavior
- prioritize regression protection around coordinator flow, persistence selection, repositories, server-driven UI config, and infrastructure managers

## Verification Policy
Verification is explicit and user-driven.
Default level is `Absent`.
Supported levels:
- `Low`: build on `iPhone 17 Pro (iOS 26.0)`
- `Medium`: all tests + build on `iPhone 17 Pro (iOS 26.0)`
- `Full`: all tests + build on `iPhone 16 Pro (iOS 18.2)` + build on `iPhone 17 Pro (iOS 26.0)`

If a requested verification finds a real issue, the issue must be fixed immediately and the same verification level rerun.

Verification is also codified in [scripts/verify.sh](/Users/Artem/.zenflow/worktrees/new-task-be0b/scripts/verify.sh), so routine checks do not depend on recalling long command lines manually:
- `./scripts/verify.sh low`
- `./scripts/verify.sh medium`
- `./scripts/verify.sh full`

## Documentation and Commenting Policy
The project now requires two documentation layers:
- project-level documentation in markdown for architecture, targets, packages, flows, and working rules
- code-level method comments in Swift source files

Comment policy:
- every method/function/initializer should carry a concise comment explaining its role
- comments should favor behavior and responsibility over restating syntax
- public APIs should remain DocC-compatible
- app and test code follow the same baseline so navigation, session, and UI contracts are readable without rediscovery

## Working Rules Summary
- use package-backed reusable managers where that improves cross-project reuse
- keep app-specific composition in the app layer
- do not add abstractions or package extraction without clear practical value for the current app or a realistic near-term reuse case
- reject changes that mostly increase indirection, code size, onboarding cost, or logic depth while adding little real benefit
- prefer the simplest design that preserves correctness, maintainability, and practical reuse
- avoid view-returning helper methods inside screens
- support light and dark appearance
- support localization for all user-facing strings
- prefer semantic theme tokens over hardcoded UI colors
- optimize SwiftUI code to avoid unnecessary re-renders and memory waste
- ask clarifying questions when requirements or trade-offs are unclear
