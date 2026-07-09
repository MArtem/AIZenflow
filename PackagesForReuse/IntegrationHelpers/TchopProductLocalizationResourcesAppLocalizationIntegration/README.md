# TchopProductLocalizationResourcesAppLocalizationIntegration

## Summary

Integration helper connecting TchopProductLocalizationResources to AppLocalization.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

> This is an integration helper, not a root domain package. Use it only when both connected packages are intentionally present.

## What Problem It Solves

- Keeps generic AppLocalization independent from Tchop resources.
- Provides optional composition for TchopApp resource lookup.

## What It Does

- Resource-provider adapter.
- Bundle/resource wiring.

## When To Use It

- a TchopApp target uses AppLocalization and TchopProductLocalizationResources together.

## When Not To Use It

- an unrelated app should not depend on Tchop resources.
- you use a different localization resource package.

## Ownership Boundary

Helper owns Tchop resource integration; host apps own product strings and localization QA.

## Products And Targets

- **Library products**: `TchopProductLocalizationResourcesAppLocalizationIntegration`
- **SwiftPM targets**: `TchopProductLocalizationResourcesAppLocalizationIntegration`
- **Repository path**: `./PackagesForReuse/IntegrationHelpers/TchopProductLocalizationResourcesAppLocalizationIntegration`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/IntegrationHelpers/TchopProductLocalizationResourcesAppLocalizationIntegration")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "TchopProductLocalizationResourcesAppLocalizationIntegration"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/IntegrationHelpers/TchopProductLocalizationResourcesAppLocalizationIntegration`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/TchopProductLocalizationResourcesAppLocalizationIntegration.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "TchopProductLocalizationResourcesAppLocalizationIntegration"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/IntegrationHelpers/TchopProductLocalizationResourcesAppLocalizationIntegration`.
2. Copy/sync it into `./PackagesInUse/IntegrationHelpers/TchopProductLocalizationResourcesAppLocalizationIntegration`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/IntegrationHelpers/TchopProductLocalizationResourcesAppLocalizationIntegration` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import TchopProductLocalizationResourcesAppLocalizationIntegration

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
