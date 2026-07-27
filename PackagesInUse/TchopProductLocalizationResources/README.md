# TchopProductLocalizationResources

## Summary

TchopApp-specific localization resource package.

## Status In This Repository

Active source-only package compiled directly into `TchopApp` targets from `./PackagesInUse`.

## What Problem It Solves

- Keeps Tchop product strings/resources portable with the app.
- Separates product resources from generic localization mechanics.
- Allows app, widgets and extensions to share the same resources.

## What It Does

- Localized resource bundle.
- Resource access token.
- Product string files.

## When To Use It

- working on TchopApp or a TchopApp-derived target.
- multiple Tchop targets need the same localized resources.

## When Not To Use It

- building an unrelated app; this package is product-specific.
- you need generic localization lookup; use AppLocalization.

## Ownership Boundary

This is intentionally product-specific. Generic projects should copy/adapt only if they also adopt Tchop product resources.

## Products And Targets

- **Library products**: `TchopProductLocalizationResources`
- **SwiftPM targets**: `TchopProductLocalizationResources`
- **Repository path**: `./PackagesInUse/TchopProductLocalizationResources`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesInUse/TchopProductLocalizationResources")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "TchopProductLocalizationResources"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesInUse/TchopProductLocalizationResources`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/TchopProductLocalizationResources.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "TchopProductLocalizationResources"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/TchopProductLocalizationResources`.
2. Copy/sync it into `./PackagesInUse/TchopProductLocalizationResources`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import TchopProductLocalizationResources

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
