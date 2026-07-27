# AppSync

## Summary

Sync engine mechanics plus optional observable sync status layer.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Separates sync core from UI observation.
- Makes sync operations/status reporting reusable.
- Avoids duplicating sync queue/state logic in repositories.

## What It Does

- SyncCore engine/status contracts.
- Sync status reporting.
- Observation-backed status store in optional product.

## When To Use It

- features need reusable sync orchestration.
- sync status should be reportable without binding core to SwiftUI.

## When Not To Use It

- there is no offline/sync model.
- conflict resolution and backend semantics are undefined.

## Ownership Boundary

Package owns sync mechanics; host apps own record mapping, conflict policy, backend contracts, retry strategy and user-visible states.

## Products And Targets

- **Library products**: `AppSyncCore`, `AppSyncObservation`
- **SwiftPM targets**: `AppSyncCore`, `AppSyncObservation`
- **Repository path**: `./PackagesForReuse/AppSync`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppSync")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppSyncCore"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppSync`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppSync.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppSyncCore"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppSync`.
2. Copy/sync it into `./PackagesInUse/AppSync`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppSyncCore

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
