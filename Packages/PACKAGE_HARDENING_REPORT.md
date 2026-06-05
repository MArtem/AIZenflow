# Package Hardening Report

This is the consolidated hardening report for the package toolkit. It supersedes the previous
versioned reports while preserving their key decisions.

## Iteration 1 summary

- Removed public `unsafeFlags(["-strict-concurrency=complete"])` from package manifests.
- Moved strict-concurrency checking into verification scripts.
- Added platform-aware verification scripts.
- Made AppOnDeviceAI compile-safe on SDKs without FoundationModels.
- Added portable FoundationNetworking imports where needed.
- Added neutral analytics aliases while preserving compatibility names.
- Improved package hygiene and archive cleanup.

## Iteration 2 summary

- Added `CacheRecord<Value>` and cache metadata access.
- Added `record(forKey:as:)` and `removeExpired()` to cache managers.
- Added runtime metadata to AppConfiguration.
- Added rich `APIError.httpFailure(APIHTTPFailure)` bridging.
- Added `AnalyticsMemoryCollector` alias.
- Added additional portable package tests.

## Iteration 3 summary

- Made file-backed cache cleanup resilient to corrupted/unreadable `.cache` files.
- Added corrupted-cache cleanup test coverage.
- Replaced raw AppConfiguration failure descriptions with sanitized failure descriptors.
- Cleared active failure description after successful remote refresh.
- Expanded strict-concurrency script to cover Apple-only packages on macOS.
- Added `PACKAGE_PORTABILITY_CONTRACT.md`.
- Added per-package README portability sections.

## Current merge recommendation

This package set is suitable for selective merge and continued integration hardening.
Before treating it as a final reusable SDK baseline, run on macOS/Xcode:

```bash
./Packages/verify_foundation_only_packages.sh
./Packages/verify_apple_packages_macos.sh
./Packages/verify_strict_concurrency_macos.sh
```

Then run the host app integration build and its regular medium/full verification pipeline.

## Remaining non-blocking roadmap

- Decide whether to publish packages as one bundle or split Git packages.
- Consider splitting AppAnalyticsCore and AppErrorsCore into dependency-free packages if true
  single-folder standalone mode is required for those cores.
- Continue AppDatabase boundary refinement as SwiftData/CoreData usage stabilizes.
- Add app-level examples for package integration.

---

# Iteration 4 — Single-Folder Standalone Isolation

## Objective

Convert every root package into a true single-folder standalone package. A package must be copyable by itself into a new project without any sibling path dependencies or sibling module imports.

## Package-level changes

### AppAnalytics

- Removed sibling path dependencies on `AppNavigation`, `AppNetworking`, and `AppPushNotifications`.
- Removed adapter targets from the root package manifest.
- Removed adapter source targets from the package.
- Kept only generic analytics primitives in `AppAnalyticsCore` and `AppAnalytics`.
- Updated tests to validate core analytics behavior only.
- Moved adapters to `IntegrationHelpers`.

### AppErrors

- Removed sibling path dependency on `AppNetworking`.
- Removed `AppNetworkingErrorAdapter` from the package manifest and sources.
- Kept only standalone app-facing error semantics in `AppErrorsCore` and `AppErrors`.
- Updated the default `AppErrorManager` convenience initializer to use `UnknownAppErrorMapper`.
- Moved networking mapping to `IntegrationHelpers/AppErrorsNetworkingIntegration.swift`.

### TchopProductLocalizationResources

- Removed sibling path dependency on `AppLocalization`.
- Replaced `makeManager()` with package-local resource APIs:
  - `bundle`
  - `localized(_:tableName:localeIdentifier:fallback:)`
- Added tests for direct resource lookup.
- Moved `AppLocalization` bridge to `IntegrationHelpers/TchopProductLocalizationResourcesAppLocalizationIntegration.swift`.

### Retired compatibility bundle

`TchopInfrastructure` was removed from the active package baseline after the standalone package split. New integration should use the `App*` root packages and optional `IntegrationHelpers`.

### IntegrationHelpers

`Packages/IntegrationHelpers` was changed from a folder of loose Swift files into a set of focused optional helper packages:

- `AppAnalyticsNavigationIntegration`
- `AppAnalyticsNetworkingIntegration`
- `AppAnalyticsPushNotificationsIntegration`
- `AppErrorsNetworkingIntegration`
- `TchopProductLocalizationResourcesAppLocalizationIntegration`

Each helper package now owns:

- `Package.swift`
- `README.md`
- `Sources/<HelperName>/`
- `Tests/<HelperName>Tests/`

The helper packages are not root standalone infrastructure packages. They are optional composition packages that may use local path dependencies because their purpose is to compose multiple root packages when a host app already has them.

### Telemetry privacy hardening

`AppAnalyticsNetworkingIntegration` no longer records raw `String(describing: error)` values. It emits a sanitized descriptor:

- `error_category`
- `error_code`
- `status_code`, when available
- `is_retryable`

It also removes URL query strings and fragments before emitting URL attributes.

`AppAnalyticsPushNotificationsIntegration` no longer records notification titles. It records `has_title` instead. Route/reason strings are normalized into stable code-like values.

`AppAnalyticsNavigationIntegration` now removes deep-link query strings and fragments and hashes user identifiers before sending navigation restore events to analytics.

`AppErrorsNetworkingIntegration` no longer falls back to raw `String(describing: error)` for unknown transport/response cases.

### Verification improvements

`verify_single_folder_standalone.sh` now checks:

- root packages have `Package.swift`, `README.md`, and `Tests/`;
- root packages do not have sibling path dependencies;
- root packages do not import sibling-owned modules;
- root packages do not contain `.build` or `.swiftpm` generated state;
- package archives do not contain `__MACOSX` or `.DS_Store` metadata;
- integration helpers are packaged and testable;
- integration helper source does not contain raw error/string telemetry patterns.

A new `verify_integration_helpers.sh` script verifies helper packages. On non-macOS hosts it runs portable helpers and skips Apple-only helpers. On macOS it also verifies Apple-only helpers.

`verify_standalone_packages.sh` now runs:

1. single-folder standalone structural/semantic gate;
2. Foundation-only package tests;
3. integration helper tests;
4. Apple package tests and strict concurrency checks when running on macOS.

### Retired compatibility policy

The compatibility bundle has been retired from the active worktree. The standalone `App*` packages and optional `IntegrationHelpers` packages are now the source of truth.

## Verification in this environment

Successfully verified in this Linux environment:

- `verify_single_folder_standalone.sh`
- `AppAnalyticsNetworkingIntegration` tests
- `AppAnalyticsPushNotificationsIntegration` tests
- `AppErrorsNetworkingIntegration` tests
- `TchopProductLocalizationResourcesAppLocalizationIntegration` tests

Apple-only verification still needs to be run on macOS/Xcode:

```bash
./Packages/verify_apple_packages_macos.sh
./Packages/verify_strict_concurrency_macos.sh
./Packages/verify_integration_helpers.sh
```

## Current recommendation

vNext5 is the first version where the main architecture matches the target model:

- root packages are single-folder standalone;
- cross-package behavior is outside root packages;
- optional helpers are packaged and testable;
- telemetry helpers have privacy-oriented semantic tests;
- verification scripts enforce structural and semantic rules.

This is a better baseline for controlled merge than vNext4.

## Iteration 6 — Final single-folder standalone baseline

### Goal

Make the package set match the target rule exactly: each root package folder is a complete, copyable Swift Package with no sibling package dependencies and no sibling module imports.

### Changes

- Added `PackageContract.md` to every root package.
- Added `Scripts/verify_package.sh` to every root package.
- Added `PackageContract.md` to every integration helper package.
- Added `Scripts/verify_package.sh` to every integration helper package.
- Added DocC documentation to every integration helper package.
- Added `IntegrationHelpers/CopyFiles/` with direct copy-in Swift files for each helper.
- Added `IntegrationHelpers/INTEGRATION_HELPERS_CATALOG.md`.
- Added `FINAL_SINGLE_FOLDER_STANDALONE_BASELINE.md`.
- Added `verify_everything.sh` as the top-level verification entry point.
- Strengthened `verify_single_folder_standalone.sh` to enforce:
  - root package `PackageContract.md`;
  - root package `Scripts/verify_package.sh`;
  - source DocC presence;
  - zero `.package(...)` dependencies in root packages;
  - zero sibling module imports;
  - zero `unsafeFlags` in public manifests;
  - zero generated build state inside `Packages/`;
  - helper package contracts;
  - helper copy-file presence;
  - privacy-oriented telemetry restrictions.
- Strengthened `verify_integration_helpers.sh` to ensure copy-file helpers stay byte-equivalent to their packaged source files.
- Extended strict-concurrency verification to cover portable helper packages and Apple helper packages where the platform supports them.

### Result

Root packages now satisfy the structural and semantic single-folder standalone contract. Cross-package composition is explicitly outside the root packages and is available as optional helpers in copy-file and testable-package forms.

### Remaining platform note

Apple-only packages still require macOS/Xcode for actual compile/test verification because they depend on Apple SDK frameworks. The package structure and scripts are ready for that verification, but Linux hosts cannot honestly compile those packages.
