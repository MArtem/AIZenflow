# AppBackgroundTasks

## Summary

Background task registration and execution coordination helpers.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Keeps BGTaskScheduler-style mechanics in one reusable place.
- Makes background work registration explicit.
- Separates system scheduling from app-specific sync/import policy.

## What It Does

- Task identifiers and registration helpers.
- Execution result/cancellation boundaries.
- Documentation for host-owned scheduling policy.

## When To Use It

- you need reusable background task plumbing across apps.
- background work must be registered consistently.

## When Not To Use It

- you need product-specific sync behavior; implement it in the app layer.
- the task is simple foreground work.

## Ownership Boundary

Package owns background-task mechanics; host apps own identifiers, entitlement setup, Info.plist declarations, retry policy and task body.

## Products And Targets

- **Library products**: `AppBackgroundTasks`
- **SwiftPM targets**: `AppBackgroundTasks`
- **Repository path**: `./PackagesForReuse/AppBackgroundTasks`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppBackgroundTasks")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppBackgroundTasks"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppBackgroundTasks`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppBackgroundTasks.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppBackgroundTasks"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppBackgroundTasks`.
2. Copy/sync it into `./PackagesInUse/AppBackgroundTasks`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppBackgroundTasks

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
- `./Docs/README.md`

## Documentation Maintenance

Every new reusable package must include this level of README detail and the package must be listed in `./PackagesForReuse/PACKAGE_CATALOG.md`. If the package is copied into `./PackagesInUse`, update `./PackagesInUse/README.md` and keep both package README files consistent.
