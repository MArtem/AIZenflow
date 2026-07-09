# CopyFiles

## Summary

Source-only copy-file helper snippets for integrating package resources into Xcode targets.

## Status In This Repository

Active source-only package compiled directly into `TchopApp` targets from `./PackagesInUse`.

> This is an integration helper, not a root domain package. Use it only when both connected packages are intentionally present.

## What Problem It Solves

- Keeps source-only migration steps reproducible.
- Avoids losing resource-copy details when packages are not linked through SwiftPM.

## What It Does

- Copy helper files/snippets.
- Resource integration references.

## When To Use It

- a source-only package needs resources copied into app/extension bundles.

## When Not To Use It

- the package is consumed through SwiftPM and Bundle.module handles resources.

## Ownership Boundary

This is not a standalone package product. It supports current TchopApp source-only integration only.

## Products And Targets

- **Library products**: `none`
- **SwiftPM targets**: `none`
- **Repository path**: `./PackagesInUse/IntegrationHelpers/CopyFiles`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesInUse/IntegrationHelpers/CopyFiles")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "CopyFiles"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesInUse/IntegrationHelpers/CopyFiles`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/CopyFiles.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "CopyFiles"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/IntegrationHelpers/CopyFiles`.
2. Copy/sync it into `./PackagesInUse/IntegrationHelpers/CopyFiles`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/IntegrationHelpers/CopyFiles` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import CopyFiles

// Use the package APIs from the target that owns product-specific policy.
```

## Verification

From this package folder, run:

```zsh
not available; run host-project verification after integration
```

For source-only app integration, also run the host app's required verification, usually:

```zsh
plutil -lint ./TchopApp.xcodeproj/project.pbxproj
./scripts/verify.sh low
git diff --check
```

## Documentation Maintenance

Every new reusable package must include this level of README detail and the package must be listed in `./PackagesForReuse/PACKAGE_CATALOG.md`. If the package is copied into `./PackagesInUse`, update `./PackagesInUse/README.md` and keep both package README files consistent.
