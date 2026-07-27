# AppConfiguration

## Summary

Configuration snapshot storage and refresh mechanics.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Keeps runtime configuration access consistent.
- Separates generic config state from app-specific shell/settings payloads.
- Makes stale/failure state visible.

## What It Does

- Generic configuration snapshot model.
- Configuration manager/store contracts.
- Refresh/fallback state handling.

## When To Use It

- you need typed app configuration that can refresh or persist.
- several features need the same configuration boundary.

## When Not To Use It

- you only need compile-time constants.
- you want to hide failed remote config under silent defaults.

## Ownership Boundary

Package owns configuration mechanics; host apps own payload type, defaults, remote source, rollout policy and user-visible fallback behavior.

## Products And Targets

- **Library products**: `AppConfiguration`
- **SwiftPM targets**: `AppConfiguration`
- **Repository path**: `./PackagesForReuse/AppConfiguration`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppConfiguration")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppConfiguration"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppConfiguration`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppConfiguration.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppConfiguration"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppConfiguration`.
2. Copy/sync it into `./PackagesInUse/AppConfiguration`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppConfiguration

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
