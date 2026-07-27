# Release Notes — vNext6 Final Single-Folder Standalone Baseline

## Goal

Make the package set match the target architecture exactly:

- every root package is a complete copyable Swift Package folder;
- root packages have no sibling package dependencies;
- root packages do not import sibling modules;
- cross-package composition lives only in optional integration helpers;
- integration helpers are available both as copy-in Swift files and testable helper packages.

## Added

- `PackageContract.md` for every root package.
- `PackageContract.md` for every integration helper package.
- `Scripts/verify_package.sh` inside every root package and helper package.
- DocC documentation for every integration helper.
- `IntegrationHelpers/CopyFiles/` with direct copy-in helper Swift files.
- `IntegrationHelpers/INTEGRATION_HELPERS_CATALOG.md`.
- `verify_everything.sh` as a single top-level verification entry point.

## Strengthened

- `verify_single_folder_standalone.sh` now validates:
  - required package files/folders;
  - package contracts;
  - local verify scripts;
  - DocC presence;
  - zero `.package(...)` dependencies in root packages;
  - zero sibling module imports from root sources/tests;
  - zero `unsafeFlags` in root manifests;
  - zero `.build`, `.swiftpm`, `xcuserdata`, `.DS_Store`, or `__MACOSX` leakage inside `Packages/`;
  - integration helper package shape;
  - integration helper copy-file availability;
  - privacy-oriented telemetry rules.
- `verify_integration_helpers.sh` now verifies that copy files stay byte-equivalent to packaged helper source files.
- `verify_strict_concurrency_macos.sh` now includes portable integration helpers and Apple-only helpers where the platform supports them.

## Integration helpers

Root packages remain standalone. Optional cross-package composition is provided by helpers:

- `AppAnalyticsNavigationIntegration`
- `AppAnalyticsNetworkingIntegration`
- `AppAnalyticsPushNotificationsIntegration`
- `AppErrorsNetworkingIntegration`
- `TchopProductLocalizationResourcesAppLocalizationIntegration`

Each helper has two delivery forms:

1. `IntegrationHelpers/CopyFiles/<Helper>.swift` for direct inclusion in a host app target.
2. `IntegrationHelpers/<Helper>/` as a small testable Swift Package.

## Verification

Run:

```bash
./Packages/verify_everything.sh
```

On macOS/Xcode also run directly if needed:

```bash
./Packages/verify_apple_packages_macos.sh
./Packages/verify_strict_concurrency_macos.sh
```
