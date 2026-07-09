# AppConnectivity

## Summary

Network connectivity observation and reachability-state helpers.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Avoids feature-level network reachability duplication.
- Provides one reusable connectivity status contract.
- Helps networking/offline features reason about current availability.

## What It Does

- Connectivity status model.
- Observer/provider contracts.
- No-op/testable status providers.

## When To Use It

- features need connectivity-aware behavior.
- networking/offline layers need a shared status source.

## When Not To Use It

- you plan to block every request solely based on reachability; requests should still handle real failures.
- you do not need connectivity UI or offline behavior.

## Ownership Boundary

Package owns connectivity mechanics; host apps own UX policy, offline messaging, retries and telemetry.

## Products And Targets

- **Library products**: `AppConnectivity`
- **SwiftPM targets**: `AppConnectivity`
- **Repository path**: `./PackagesForReuse/AppConnectivity`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppConnectivity")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppConnectivity"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppConnectivity`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppConnectivity.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppConnectivity"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppConnectivity`.
2. Copy/sync it into `./PackagesInUse/AppConnectivity`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppConnectivity

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
