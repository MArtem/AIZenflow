# Package Portability Contract

This package set is designed around **100% single-folder standalone root packages**.

A root package is standalone when you can copy exactly one folder into another project, open it as a Swift Package, and run its package tests without copying any sibling packages from this repository.

```text
PackageName/
  Package.swift
  README.md
  PackageContract.md
  Scripts/verify_package.sh
  Sources/
  Tests/
```

## Non-negotiable root-package rules

1. A root package manifest must not contain sibling path dependencies such as `.package(path: "../AppNetworking")`.
2. In the current baseline, root packages must not contain any `.package(...)` dependency at all. They rely only on Swift/Apple SDKs.
3. A root package source/test file must not import a module owned by another sibling root package.
4. Root packages must include `README.md`, `PackageContract.md`, `Sources/`, `Tests/`, source DocC documentation, and `Scripts/verify_package.sh`.
5. Root packages must not contain generated local state: `.build`, `.swiftpm`, `xcuserdata`, `.DS_Store`, or `__MACOSX`.
6. Public package manifests must not use `unsafeFlags`. Strict concurrency is verified by scripts/CI.
7. Cross-package adapters must live outside root packages, either in a host app/integration target or in `Packages/IntegrationHelpers/`.
8. Root packages provide mechanisms. Host apps compose mechanisms.

## Root packages

| Package | Required sibling packages | Notes |
|---|---|---|
| AppAnalytics | None | Generic analytics primitives only. Navigation/networking/push adapters live in `IntegrationHelpers`. |
| AppErrors | None | Generic app-facing error semantics only. Networking mapping lives in `IntegrationHelpers`. |
| TchopProductLocalizationResources | None | Product-specific resources, but standalone. AppLocalization integration lives in `IntegrationHelpers`. |
| AppCache | None | Foundation-only standalone. |
| AppConfiguration | None | Foundation-only standalone. |
| AppLocalization | None | Foundation-only standalone localization mechanism. |
| AppNetworking | None | Foundation/FoundationNetworking standalone. |
| AppWidgetSupport | None | Foundation-only standalone. |
| AppPushNotifications | None | Foundation-only core/state package. |
| AppOnDeviceAI | None | Standalone fallback path; optional FoundationModels adapter is compile-gated. |
| AppNavigation | None | Apple-platform standalone package. |
| AppAppleAuthentication | None | Apple-platform standalone package. |
| AppShareExtensionSupport | None | Apple-platform standalone package. |
| AppBranding | None | Apple-platform standalone package. |
| AppDatabase | None | Apple-platform standalone package with internal CoreData/SwiftData targets. |
| AppSync | None | Standalone package with internal core/observation targets. |

## Integration helpers

The following cross-package compositions were intentionally removed from root packages and preserved as optional helpers:

| Helper | Requires | Purpose |
|---|---|---|
| `AppAnalyticsNavigationIntegration` | `AppAnalytics`, `AppNavigation` | Maps navigation diagnostics into analytics events. |
| `AppAnalyticsNetworkingIntegration` | `AppAnalytics`, `AppNetworking` | Maps networking metrics into analytics events. |
| `AppAnalyticsPushNotificationsIntegration` | `AppAnalytics`, `AppPushNotifications` | Maps push notification lifecycle events into analytics events. |
| `AppErrorsNetworkingIntegration` | `AppErrors`, `AppNetworking` | Maps networking failures into app-facing error semantics. |
| `TchopProductLocalizationResourcesAppLocalizationIntegration` | `TchopProductLocalizationResources`, `AppLocalization` | Creates an `AppLocalization.LocalizationManager` backed by product string resources. |

Each helper is available in two forms:

1. **Copy-file mode:** copy `Packages/IntegrationHelpers/CopyFiles/<Helper>.swift` into a host app/integration target that already imports the required root packages.
2. **Helper-package mode:** use `Packages/IntegrationHelpers/<Helper>/` as a small testable Swift Package when the required root packages are available beside it or after adapting its manifest to Git URL dependencies.

## Verification

Primary gate:

```bash
./Packages/verify_everything.sh
```

Focused gates:

```bash
./Packages/verify_single_folder_standalone.sh
./Packages/verify_foundation_only_packages.sh
./Packages/verify_integration_helpers.sh
./Packages/verify_apple_packages_macos.sh
./Packages/verify_strict_concurrency_macos.sh
```

`verify_single_folder_standalone.sh` fails if any root package violates the portability contract or if helper copy files/packages drift from the required shape.
