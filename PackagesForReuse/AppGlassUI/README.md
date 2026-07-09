# AppGlassUI

## Summary

Reusable SwiftUI glass-style visual primitives for modern iOS UI.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Centralizes repeated glass background/elevation styling.
- Keeps visual effects consistent across screens.
- Avoids one-off Liquid Glass approximations.

## What It Does

- SwiftUI glass surface primitives.
- Reusable visual modifiers/styles.
- Small design-system-adjacent components.

## When To Use It

- multiple screens need the same glass visual language.
- you need a reusable native SwiftUI style primitive.

## When Not To Use It

- the design requires app-specific layout/business behavior.
- the effect is one-off and clearer inline.

## Ownership Boundary

Package owns generic visual primitives; host apps own screen layout, design tokens, accessibility tradeoffs and product-specific components.

## Products And Targets

- **Library products**: `AppGlassUI`
- **SwiftPM targets**: `AppGlassUI`
- **Repository path**: `./PackagesForReuse/AppGlassUI`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppGlassUI")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppGlassUI"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppGlassUI`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppGlassUI.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppGlassUI"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppGlassUI`.
2. Copy/sync it into `./PackagesInUse/AppGlassUI`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppGlassUI

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
