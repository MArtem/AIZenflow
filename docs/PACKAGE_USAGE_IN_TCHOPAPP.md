# Package Usage in TchopApp

## Current integration mode

`TchopApp` currently uses reusable infrastructure package code in **source-only local mode**.

This is intentional. The worktree is used to build a reusable package library, but connecting dozens of packages through SwiftPM creates large `.build`, `.swiftpm`, cloned package, and DerivedData artifacts. To control disk usage, only source files from active packages are compiled into app targets.

## Folder roles

- `./PackagesForReuse`: complete source-only package library/vault. Every reviewed package goes here.
- `./PackagesInUse`: active source-only subset compiled into this app.
- `./Packages`: SDK/package creation documentation, templates, reports, and optional copy-file helpers only.

## Runtime target ownership

- `TchopApp` compiles the active app package subset from `./PackagesInUse`.
- `TchopShareExtension` compiles only share-relevant package source from `./PackagesInUse`.
- `TchopWidgetsExtension` compiles only widget/localization package source from `./PackagesInUse`.
- Package source is not linked as SwiftPM products in this worktree.

## When to use package code

Use package mechanics instead of app-local duplicated code when the package surface directly fits the app need:

- networking/request/retry/error primitives
- app-facing error taxonomy/mapping helpers
- localization lookup mechanics
- brand/theme token mechanics
- Liquid Glass availability/fallback mechanics
- widget snapshot storage mechanics
- share-extension import/app-group storage mechanics
- push registration/notification forwarding mechanics
- permission state/request mechanics
- runtime environment/build/test flag snapshot mechanics
- app lifecycle phase/event tracking mechanics
- database execution-boundary utilities
- on-device AI abstraction/fallback mechanics
- analytics event/transport mechanics

Keep product policy in app code:

- product strings and copy
- app routes and tab semantics
- endpoint-specific DTO/domain mapping
- session/auth policy
- feed/card product behavior
- schema ownership and migration decisions
- visual layout decisions and semantic roles

## Future SwiftPM use

Every package under `./PackagesForReuse` and `./PackagesInUse` keeps SwiftPM metadata and package-owned tests. A future project can copy one folder and connect it as a normal Swift Package when disk/build-cache cost is acceptable.

## Current permission package usage

`./TchopApp/App/AppPushNotificationBridge.swift` uses `./PackagesInUse/AppPermissions` for the notification permission request/state boundary and `./PackagesInUse/AppPushNotifications` for push runtime state, APNs token handling, and notification payload handling.

## Current environment package usage

`./TchopApp/App/AppLaunchConfiguration.swift` uses `./PackagesInUse/AppEnvironment` for generic process/runtime flag resolution. Product-specific launch switches such as `TCHOP_API_ENV`, `TCHOP_DATABASE_BACKEND`, and UI-test usernames remain app-owned policy.


## Current lifecycle package usage

`./TchopApp/TchopApp.swift` maps SwiftUI `ScenePhase` values into `./PackagesInUse/AppLifecycle` phases/events, while `./TchopApp/App/AppState.swift` records launch and scene transitions through `DefaultAppLifecycleManager`. Product-specific foreground behavior, such as share-extension sync and feed refresh, remains app-owned policy.

## AppFileStorage

`./TchopApp/Shared/AppFileStorageDomains.swift` defines the app-owned composer media storage domain on top of `./PackagesInUse/AppFileStorage`. Composer-created media in `./TchopApp/Views/Composer/SharedCardComposerView.swift` now writes and copies files through package APIs while preserving the stable `Documents/TchopComposerMedia` directory used by persisted feed cards. `./TchopApp/Views/News/NewsFeedView.swift` keeps old absolute-path and stale-container fallback behavior, but resolves composer media fallback through the same app-owned package domain.

`./PackagesInUse/AppShareExtensionSupport` and `./PackagesInUse/AppNetworking` intentionally keep their package-local file mechanisms because root packages must remain single-folder standalone and cannot directly depend on sibling packages. Cross-package composition should be introduced only through host app code or explicit integration helpers.
