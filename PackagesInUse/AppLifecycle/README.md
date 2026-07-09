# AppLifecycle

## Summary

Application lifecycle event and state helper mechanisms.

## Status In This Repository

Active source-only package compiled directly into `TchopApp` targets from `./PackagesInUse`.

## What Problem It Solves

- Centralizes lifecycle event modeling.
- Keeps foreground/background handling testable.
- Avoids duplicated scene phase translation.

## What It Does

- Lifecycle event/status contracts.
- Observer/reporter helpers.
- No-op/testable lifecycle surfaces.

## When To Use It

- features need lifecycle-aware refresh, sync or cleanup behavior.
- multiple targets observe lifecycle state.

## When Not To Use It

- you need one local `.task` tied to a SwiftUI view.
- the behavior is product-specific and should stay in app coordination.

## Ownership Boundary

Package owns lifecycle mechanics; host apps own scene wiring, refresh policy, background-task decisions and UX side effects.

## Products And Targets

- **Library products**: `AppLifecycle`
- **SwiftPM targets**: `AppLifecycle`
- **Repository path**: `./PackagesInUse/AppLifecycle`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesInUse/AppLifecycle")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppLifecycle"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesInUse/AppLifecycle`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppLifecycle.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppLifecycle"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppLifecycle`.
2. Copy/sync it into `./PackagesInUse/AppLifecycle`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppLifecycle

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
- `./Docs/README.md`

## Documentation Maintenance

Every new reusable package must include this level of README detail and the package must be listed in `./PackagesForReuse/PACKAGE_CATALOG.md`. If the package is copied into `./PackagesInUse`, update `./PackagesInUse/README.md` and keep both package README files consistent.
