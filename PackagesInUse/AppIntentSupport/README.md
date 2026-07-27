# AppIntentSupport

## Summary

Reusable helper mechanics for App Intents input validation and package composition markers.

## Status In This Repository

Active source-only package compiled directly into `TchopApp` targets from `./PackagesInUse`.

## What Problem It Solves

- Keeps concrete intents small and product-focused.
- Avoids duplicating required-text validation across App Intents.
- Provides a future package marker for App Intents composition.

## What It Does

- Text normalization and validation.
- Stable validation failures.
- AppIntentsPackage marker when AppIntents is available.

## When To Use It

- an app exposes App Intents and needs shared validation helpers.
- multiple intents require the same input normalization.

## When Not To Use It

- you need concrete AppIntent declarations; keep them in the host app target.
- you need Siri phrases/product behavior; keep that app-owned.

## Ownership Boundary

Package owns generic App Intents support mechanics; host apps own concrete intents, phrases, shortcuts provider, dialogs and product actions.

## Products And Targets

- **Library products**: `AppIntentSupport`
- **SwiftPM targets**: `AppIntentSupport`
- **Repository path**: `./PackagesInUse/AppIntentSupport`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesInUse/AppIntentSupport")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppIntentSupport"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesInUse/AppIntentSupport`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppIntentSupport.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppIntentSupport"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppIntentSupport`.
2. Copy/sync it into `./PackagesInUse/AppIntentSupport`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppIntentSupport

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
- `./Docs/README.md`

## Documentation Maintenance

Every new reusable package must include this level of README detail and the package must be listed in `./PackagesForReuse/PACKAGE_CATALOG.md`. If the package is copied into `./PackagesInUse`, update `./PackagesInUse/README.md` and keep both package README files consistent.
