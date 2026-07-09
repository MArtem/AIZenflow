# AppValidationCore

## Summary

Low-level validation engine with safe identifiers, typed values and rule evaluation.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Provides reusable validation below form-specific state controllers.
- Validates missing configured values explicitly.
- Prevents raw identifier leakage through safe identifiers.

## What It Does

- Validation values/contexts.
- Rule sets and issue codes.
- Safe validation identifiers.

## When To Use It

- several packages/features need generic validation rules.
- validation is not tied to one UI form.

## When Not To Use It

- you only need form-level state; use AppFormValidation.
- localized copy/product field labels are needed; keep them in host app.

## Ownership Boundary

Package owns validation mechanics; host apps own localized messages, product policy and UI presentation.

## Products And Targets

- **Library products**: `AppValidationCore`
- **SwiftPM targets**: `AppValidationCore`
- **Repository path**: `./PackagesForReuse/AppValidationCore`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppValidationCore")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppValidationCore"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppValidationCore`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppValidationCore.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppValidationCore"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppValidationCore`.
2. Copy/sync it into `./PackagesInUse/AppValidationCore`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppValidationCore

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
