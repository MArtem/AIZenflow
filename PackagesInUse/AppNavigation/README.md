# AppNavigation

## Summary

Navigation route/event/snapshot contracts and diagnostic reporting helpers.

## Status In This Repository

Active source-only package compiled directly into `TchopApp` targets from `./PackagesInUse`.

## What Problem It Solves

- Keeps navigation state serializable and restorable.
- Separates route value contracts from SwiftUI destination rendering.
- Provides navigation event diagnostics.

## What It Does

- Route and snapshot models.
- Navigation event reporting.
- Snapshot restore/migration helpers.

## When To Use It

- apps need restorable navigation state or route diagnostics.
- navigation events should be reportable/testable.

## When Not To Use It

- you need screen-specific destination UI; keep that in the app.
- a single local NavigationStack is enough.

## Ownership Boundary

Package owns navigation value mechanics; host apps own route graph, destination rendering, deep-link policy and UX decisions.

## Products And Targets

- **Library products**: `AppNavigation`
- **SwiftPM targets**: `AppNavigation`
- **Repository path**: `./PackagesInUse/AppNavigation`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesInUse/AppNavigation")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppNavigation"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesInUse/AppNavigation`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppNavigation.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppNavigation"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppNavigation`.
2. Copy/sync it into `./PackagesInUse/AppNavigation`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppNavigation

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
- `./USAGE.md`

## Documentation Maintenance

Every new reusable package must include this level of README detail and the package must be listed in `./PackagesForReuse/PACKAGE_CATALOG.md`. If the package is copied into `./PackagesInUse`, update `./PackagesInUse/README.md` and keep both package README files consistent.
