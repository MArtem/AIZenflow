# AppDatabase

## Summary

Database execution boundaries for SwiftData/Core Data and backend-neutral database contracts.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Prevents UI code from owning persistence execution details.
- Separates main-context UI persistence from background database work.
- Makes database operation boundaries explicit and testable.

## What It Does

- Database core protocols.
- SwiftData manager variants.
- Core Data manager variants.
- Composition helpers for host apps.

## When To Use It

- an app needs reusable persistence execution contracts.
- you need both UI-oriented and background persistence boundaries.

## When Not To Use It

- you want package code to know app schema semantics.
- you need a one-off in-memory dictionary.

## Ownership Boundary

Package owns database execution mechanics; host apps own schemas, migrations, data-loss policy, repositories and product-specific queries.

## Products And Targets

- **Library products**: `AppDatabaseCore`, `AppSwiftDataDatabase`, `AppCoreDataDatabase`, `AppDatabaseComposition`, `AppDatabase`
- **SwiftPM targets**: `AppDatabaseCore`, `AppSwiftDataDatabase`, `AppCoreDataDatabase`, `AppDatabaseComposition`, `AppDatabase`
- **Repository path**: `./PackagesForReuse/AppDatabase`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppDatabase")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppDatabaseCore"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppDatabase`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppDatabase.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppDatabaseCore"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppDatabase`.
2. Copy/sync it into `./PackagesInUse/AppDatabase`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppDatabaseCore

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
