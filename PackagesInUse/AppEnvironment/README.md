# AppEnvironment

## Summary

Environment/runtime provider for app mode, configuration source and build/runtime context.

## Status In This Repository

Active source-only package compiled directly into `TchopApp` targets from `./PackagesInUse`.

## What Problem It Solves

- Avoids scattered environment checks.
- Makes dev/staging/production decisions explicit.
- Keeps environment injection testable.

## What It Does

- Environment snapshot/provider contracts.
- Default provider helpers.
- Sendable date/runtime injection surfaces.

## When To Use It

- the app has multiple environments or runtime modes.
- configuration and networking need one environment source.

## When Not To Use It

- environment can be a compile-time constant only.
- you need product behavior fallback; keep policy in the app.

## Ownership Boundary

Package owns environment mechanics; host apps own environment definitions, secrets, URLs and release policy.

## Products And Targets

- **Library products**: `AppEnvironment`
- **SwiftPM targets**: `AppEnvironment`
- **Repository path**: `./PackagesInUse/AppEnvironment`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesInUse/AppEnvironment")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppEnvironment"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesInUse/AppEnvironment`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppEnvironment.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppEnvironment"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppEnvironment`.
2. Copy/sync it into `./PackagesInUse/AppEnvironment`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppEnvironment

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
