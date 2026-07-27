# AppObservability

## Summary

Observability primitives for diagnostics, metrics and operational event reporting.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Separates operational diagnostics from feature code.
- Provides reusable reporting contracts.
- Keeps privacy boundaries visible.

## What It Does

- Diagnostic event models.
- Metric/reporting contracts.
- No-op/testable reporters.

## When To Use It

- you need package-neutral observability hooks.
- features should report operational state without vendor coupling.

## When Not To Use It

- you do not have privacy/redaction policy.
- analytics events are enough and operational metrics are unnecessary.

## Ownership Boundary

Package owns observability mechanics; host apps own sinks, retention, redaction, alerting and compliance requirements.

## Products And Targets

- **Library products**: `AppObservability`
- **SwiftPM targets**: `AppObservability`
- **Repository path**: `./PackagesForReuse/AppObservability`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppObservability")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppObservability"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppObservability`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppObservability.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppObservability"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppObservability`.
2. Copy/sync it into `./PackagesInUse/AppObservability`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppObservability

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
