# Final Single-Folder Standalone Baseline

## Definition

A root package is complete when this folder can be copied by itself into a new repository and used as a Swift Package without copying any sibling packages:

```text
PackageName/
  Package.swift
  README.md
  PackageContract.md
  Scripts/verify_package.sh
  Sources/
  Tests/
```

The root package must not contain:

- `.package(path: "../...")`;
- any `.package(...)` dependency at all in the current baseline;
- source/test imports of sibling root package modules;
- generated build state such as `.build`, `.swiftpm`, `xcuserdata`;
- public `unsafeFlags` in `Package.swift`.

## Root package status

All root packages now satisfy this contract structurally:

- AppAnalytics
- AppAppleAuthentication
- AppBranding
- AppCache
- AppConfiguration
- AppDatabase
- AppErrors
- AppLocalization
- AppNavigation
- AppNetworking
- AppOnDeviceAI
- AppPushNotifications
- AppShareExtensionSupport
- AppSync
- AppWidgetSupport
- TchopProductLocalizationResources

## Integration boundary

Cross-package adapters intentionally do not live inside root packages. They are optional composition helpers for host apps that already include the relevant root packages.

The helpers are delivered in two forms:

- copy-in files: `IntegrationHelpers/CopyFiles/*.swift`;
- testable helper packages: `IntegrationHelpers/<HelperName>/`.

## Verification entry point

Run:

```bash
./Packages/verify_everything.sh
```

This runs structural gates, portable package tests, integration helper tests, and macOS-only checks when the host supports them.
