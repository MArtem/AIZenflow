# AppBranding

## Summary

Reusable branding values and app identity presentation primitives.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Centralizes app-name/logo/theme-adjacent branding data.
- Keeps branding reads consistent across UI, widgets and extensions.
- Avoids scattering literal product identity strings.

## What It Does

- Brand snapshot/configuration contracts.
- Brand asset/value lookup helpers.
- Default/fallback branding shape.

## When To Use It

- multiple targets need the same branding contract.
- you need a small package-level identity surface.

## When Not To Use It

- the values are deeply product-specific and will never be reused.
- you need a full design system; use a dedicated UI/design package.

## Ownership Boundary

Package owns generic branding value mechanics; host apps own actual product name, assets, legal copy and localization.

## Products And Targets

- **Library products**: `AppBranding`
- **SwiftPM targets**: `AppBranding`
- **Repository path**: `./PackagesForReuse/AppBranding`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppBranding")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppBranding"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppBranding`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppBranding.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppBranding"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppBranding`.
2. Copy/sync it into `./PackagesInUse/AppBranding`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppBranding

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
