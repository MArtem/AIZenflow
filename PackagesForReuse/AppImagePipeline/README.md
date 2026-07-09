# AppImagePipeline

## Summary

Image loading, decoding, caching and prefetch pipeline.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Avoids synchronous image decoding in UI hot paths.
- Provides bounded memory/disk cache behavior.
- Centralizes remote/provided image byte handling.

## What It Does

- Image request/response models.
- Disk/memory cache policies.
- Prefetch and content-type validation.

## When To Use It

- images are loaded from remote/provided byte sources.
- scroll performance needs cached decoded previews.

## When Not To Use It

- the app only uses local already-prepared thumbnails.
- you need product-specific media authorization or asset policy.

## Ownership Boundary

Package owns image pipeline mechanics; host apps own image source policy, placeholders, product cache domains and UX behavior.

## Products And Targets

- **Library products**: `AppImagePipeline`
- **SwiftPM targets**: `AppImagePipeline`
- **Repository path**: `./PackagesForReuse/AppImagePipeline`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppImagePipeline")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppImagePipeline"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppImagePipeline`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppImagePipeline.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppImagePipeline"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppImagePipeline`.
2. Copy/sync it into `./PackagesInUse/AppImagePipeline`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppImagePipeline

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
