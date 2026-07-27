# AppTaskQueue

## Summary

Durable task queue, reservation, retry and payload-limit mechanics.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Provides reusable queued-work semantics.
- Makes reservation/completion rules explicit.
- Separates task queue engine from host storage atomicity.

## What It Does

- Queued task models.
- Retry policy.
- Reservation/complete/fail contracts.

## When To Use It

- background/offline work needs durable queue semantics.
- multiple task kinds share retry/reservation behavior.

## When Not To Use It

- one immediate async task is enough.
- you cannot provide a durable store with atomic reservation semantics.

## Ownership Boundary

Package owns queue mechanics; host apps own durable store implementation, task payload schema, runner lifecycle and crash/lease policy.

## Products And Targets

- **Library products**: `AppTaskQueue`
- **SwiftPM targets**: `AppTaskQueue`
- **Repository path**: `./PackagesForReuse/AppTaskQueue`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppTaskQueue")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppTaskQueue"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppTaskQueue`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppTaskQueue.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppTaskQueue"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppTaskQueue`.
2. Copy/sync it into `./PackagesInUse/AppTaskQueue`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppTaskQueue

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

## Documentation Maintenance

Every new reusable package must include this level of README detail and the package must be listed in `./PackagesForReuse/PACKAGE_CATALOG.md`. If the package is copied into `./PackagesInUse`, update `./PackagesInUse/README.md` and keep both package README files consistent.
