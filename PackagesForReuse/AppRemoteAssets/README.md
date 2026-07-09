# AppRemoteAssets

## Summary

Remote asset manifest validation and asset retrieval mechanics.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Keeps remote asset metadata validation explicit.
- Enforces secure URL/status/checksum/size policies.
- Avoids ad-hoc asset manifest parsing.

## What It Does

- Manifest request/validation models.
- Asset metadata and checksum validation.
- Transport and response-size handling.

## When To Use It

- an app downloads versioned remote assets from a manifest.
- assets require checksum/size/status validation.

## When Not To Use It

- assets are bundled or local-only.
- product asset rollout policy is not defined.

## Ownership Boundary

Package owns remote asset mechanics; host apps own manifest endpoint, rollout behavior, storage, UI and cache policy.

## Products And Targets

- **Library products**: `AppRemoteAssets`
- **SwiftPM targets**: `AppRemoteAssets`
- **Repository path**: `./PackagesForReuse/AppRemoteAssets`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppRemoteAssets")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppRemoteAssets"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppRemoteAssets`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppRemoteAssets.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppRemoteAssets"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppRemoteAssets`.
2. Copy/sync it into `./PackagesInUse/AppRemoteAssets`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppRemoteAssets

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
