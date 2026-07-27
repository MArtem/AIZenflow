# AppLocalization

## Summary

Localization lookup/provider mechanics independent of any product string catalog.

## Status In This Repository

Active source-only package compiled directly into `TchopApp` targets from `./PackagesInUse`.

## What Problem It Solves

- Avoids hard-coded string lookup patterns.
- Provides consistent fallback/missing-key behavior.
- Allows product resources to plug into generic localization APIs.

## What It Does

- Localized string provider contracts.
- Bundle/resource lookup helpers.
- Fallback behavior.

## When To Use It

- modules need a reusable localization lookup boundary.
- product resources are provided by a separate package or app bundle.

## When Not To Use It

- you need to define product copy; keep strings in app/product resource packages.
- preview-only mock strings are enough.

## Ownership Boundary

Package owns localization mechanics; host apps own actual translations, copy review, pluralization policy and resource bundles.

## Products And Targets

- **Library products**: `AppLocalization`
- **SwiftPM targets**: `AppLocalization`
- **Repository path**: `./PackagesInUse/AppLocalization`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesInUse/AppLocalization")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppLocalization"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesInUse/AppLocalization`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppLocalization.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppLocalization"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppLocalization`.
2. Copy/sync it into `./PackagesInUse/AppLocalization`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppLocalization

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
