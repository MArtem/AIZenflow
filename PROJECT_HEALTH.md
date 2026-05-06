# Project Health

## Purpose
This document records the current package inventory, separation boundaries, and reuse policy for `TchopApp`.
It is intended to answer three questions quickly:
- what is already reusable,
- what must remain app-specific,
- what should not be extracted into a package unless project constraints change.

## Reusable Package Inventory
### `TchopNetworking`
Status: reusable.

Owned concerns:
- request execution
- cancellation
- upload/download
- retry hooks
- logging
- offline queue
- metrics and diagnostics

Keep reusable:
- transport contracts
- interceptors
- retry policy surfaces
- diagnostics export/import

Do not couple to app:
- feed-specific DTOs
- app bundle identifiers
- app localization keys

### `TchopDatabaseCore`
Status: reusable.

Owned concerns:
- backend-neutral contracts
- migration primitives
- operation wrappers
- backend selection types

Keep reusable:
- operation abstractions
- migration runner
- backend configuration

Do not couple to app:
- app entity types
- app migration policy decisions

### `SyncCore`
Status: reusable.

Owned concerns:
- sync state machine
- mutation queue push/pull orchestration
- cursor-based remote change application
- conflict lifecycle and resolution contract

Keep reusable:
- engine/scheduler/status store contracts
- local/remote adapter protocols
- conflict primitives and metadata models

Do not couple to app:
- `FeedCardRecord`/`ChannelRecord` types
- app DTO mapping rules
- app-specific API endpoint semantics

### `TchopSwiftDataDatabase`
Status: reusable.

Owned concerns:
- SwiftData implementation of `DatabaseManaging`

Keep reusable:
- generic transaction/save behavior

Do not couple to app:
- `ChannelRecord`
- `UserRecord`
- app bootstrap rules

### `TchopCoreDataDatabase`
Status: reusable.

Owned concerns:
- Core Data implementation of `DatabaseManaging`

Keep reusable:
- generic context-backed read/write behavior

Do not couple to app:
- app-specific `NSManagedObjectModel`
- app migration rules

### `TchopDatabaseComposition`
Status: reusable.

Owned concerns:
- backend factory-set composition
- backend availability reporting
- unified resolver surface

Keep reusable:
- `DatabaseManagerFactorySet`
- generic resolver/factory APIs

Do not couple to app:
- user upgrade policy
- on-disk migration orchestration

### `TchopNavigation`
Status: reusable.

Owned concerns:
- tab router
- snapshot persistence contract
- navigation transition policy
- navigation observability contracts

Keep reusable:
- generic routing state
- event reporting primitives

Do not couple to app:
- `AppTab`
- app route models
- app URL structure

### `TchopLocalization`
Status: reusable.

Owned concerns:
- localization facade
- locale override support

Keep reusable:
- string resolution
- formatting behavior

Do not couple to app:
- app-specific keys or copy

### `TchopBranding`
Status: reusable, but still narrow.

Owned concerns:
- target-driven brand resolution
- semantic color tokens

Keep reusable:
- variant resolution
- theme abstraction

Needs expansion:
- richer semantic token groups for button, badge, tab, card, navigation, destructive, success states

### `TchopUIConfiguration`
Status: reusable, early production baseline.

Owned concerns:
- current snapshot
- refresh semantics
- persisted snapshot store

Keep reusable:
- current/refresh/store contracts
- generic snapshot persistence
- both persisted and in-memory snapshot-store implementations

Needs expansion:
- versioning
- TTL / staleness policy
- refresh throttling

### `TchopCache`
Status: reusable.

Owned concerns:
- in-memory cache
- file-backed cache
- expiration

Keep reusable:
- generic Codable cache contracts

Do not couple to app:
- feature-specific keys and payload conventions

### `TchopWidgets`
Status: reusable within iOS widget/app-group context.

Owned concerns:
- shared widget snapshot primitives

Keep reusable:
- widget snapshot store contracts

Do not couple to app:
- app navigation
- app DI

### `TchopPushNotifications`
Status: reusable.

Owned concerns:
- APNs state
- token formatting
- payload parsing
- persistent push state

Keep reusable:
- package-backed manager and parser contracts
- both persisted and in-memory state-store implementations for host apps with different lifecycle needs

Do not couple to app:
- `UIApplicationDelegate`
- `UNUserNotificationCenterDelegate`
- permission prompt timing policy

## App-Specific Modules
These should remain in `TchopApp` unless the product shape changes significantly.

### `AppState`
Reason:
- owns authenticated app lifecycle
- combines session, deep links, navigation restore, widget cleanup, push authorization entry point
- strongly tied to `AppUser`, `AppCoordinator`, and app startup rules

### `AppDatabase`
Reason:
- active runtime is SwiftData-only bootstrap
- legacy Core Data selection/migration path is intentionally commented as rollback fallback

### `DeepLinkManager`
Reason:
- parser shape is still tied to app route models and app URL schema

Future direction:
- keep parser host-app specific, but make routing table more declarative

### Repositories
`DefaultAppContentRepository`, `DefaultUserRepository`

Reason:
- map app DTOs and app persistence records into app domain models

### App bridges
- `AppPushNotificationBridge`
- `AppWidgetBridge`

Reason:
- bind reusable package managers into host app lifecycle and feature needs

## Do Not Extract Right Now
These are tempting, but should stay local for now.

### `UserSessionService`
Reason:
- too small
- current value is in app workflow, not in cross-project abstraction

### Feed feature API/repository models
Reason:
- feature-specific
- not yet proven reusable across products

### `NavigationSnapshot`
Reason:
- shape is tied to app route types and app tab model
- generic persistence already lives in `TchopNavigation`

## Current Structural Risks
### Large files
- `TchopNetworking.swift`
- `AppState.swift`
- `DeepLinkManager.swift`

### Documentation quality
Method-level comment coverage now exists, but some comments are still generic and should be refined gradually in high-value files.

### Test organization
Test doubles are still too spread across large test files.
They should move toward dedicated `TestDoubles` files/folders.

## Next Improvement Queue
1. Extract test doubles from large app test files into dedicated `TchopAppTests/TestDoubles/`.
2. Expand `TchopUIConfiguration` with versioning, TTL/staleness, and throttling.
3. Expand `TchopBranding` with richer semantic token groups.
4. Refactor `DeepLinkManager` toward declarative route definitions.
5. Remove remaining `fatalError`-style app database bootstrap behavior and improve migration tests.
6. Add snapshot/UI tests for `AppRootView`, `AppShellView`, and `NewsTabRootView`.
7. Add unified analytics/event model across navigation, push, and networking.

## Reuse Rule of Thumb
Extract into a package only if all of the following are true:
- the code has a stable responsibility,
- it does not require `TchopApp` domain types to make sense,
- another iOS project could adopt it with low adaptation cost,
- its API can be described without referencing current screen names or current app flows.
