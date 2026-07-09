# AppOnDeviceAI

## Summary

On-device AI capability, prompt/request and result helper mechanisms.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Keeps AI-provider interaction behind a reusable boundary.
- Makes availability and fallback behavior explicit.
- Avoids putting AI request logic inside UI.

## What It Does

- AI manager/request/result contracts.
- Availability checks.
- No-op/fallback helper surfaces.

## When To Use It

- features need local AI operations with testable boundaries.
- AI availability differs by device/runtime.

## When Not To Use It

- you need cloud AI API transport; use networking/API layers.
- you need product prompt/copy policy; keep it in app code.

## Ownership Boundary

Package owns AI mechanism contracts; host apps own prompts, privacy policy, feature behavior, model choice and fallback UX.

## Products And Targets

- **Library products**: `AppOnDeviceAI`
- **SwiftPM targets**: `AppOnDeviceAI`
- **Repository path**: `./PackagesForReuse/AppOnDeviceAI`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppOnDeviceAI")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppOnDeviceAI"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppOnDeviceAI`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppOnDeviceAI.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppOnDeviceAI"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppOnDeviceAI`.
2. Copy/sync it into `./PackagesInUse/AppOnDeviceAI`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppOnDeviceAI

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
