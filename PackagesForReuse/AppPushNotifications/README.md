# AppPushNotifications

## Summary

Push notification registration, token and payload event helper mechanics.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Separates APNs mechanics from app state.
- Keeps token forwarding and failure reporting explicit.
- Provides reusable push event analytics/diagnostics hooks.

## What It Does

- APNs token registration contracts.
- Notification payload event models.
- Registration/failure reporting helpers.

## When To Use It

- apps register for APNs and need reusable push plumbing.
- push events should be observable by app/analytics layers.

## When Not To Use It

- you need product-specific routing for notification payloads; keep that in app.
- the app has no push capability.

## Ownership Boundary

Package owns push mechanics; host apps own entitlements, backend token registration, notification routing, user permissions and copy.

## Products And Targets

- **Library products**: `AppPushNotifications`
- **SwiftPM targets**: `AppPushNotifications`
- **Repository path**: `./PackagesForReuse/AppPushNotifications`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppPushNotifications")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppPushNotifications"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppPushNotifications`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppPushNotifications.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppPushNotifications"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppPushNotifications`.
2. Copy/sync it into `./PackagesInUse/AppPushNotifications`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppPushNotifications

// Use the package APIs from the target that owns product-specific policy.
```

## Verification

From this package folder, run:

```zsh
./Scripts/verify_package.sh
```

For source-only app integration, also run the host app's required verification, usually:

```zsh
plutil -lint ./TchopApp.xcodeproj/project.pbxproj
./scripts/verify.sh low
git diff --check
```

## More Documentation

- `./PackageContract.md`
- `./REUSE.md`
- `./USAGE.md`

## Documentation Maintenance

Every new reusable package must include this level of README detail and the package must be listed in `./PackagesForReuse/PACKAGE_CATALOG.md`. If the package is copied into `./PackagesInUse`, update `./PackagesInUse/README.md` and keep both package README files consistent.
