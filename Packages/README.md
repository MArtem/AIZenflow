# Packages

This folder contains the active standalone package baseline for `TchopApp`.

## Contract

Each root package folder is intended to be copyable as one self-contained Swift Package:

```text
PackageName/
  Package.swift
  README.md
  PackageContract.md
  Scripts/verify_package.sh
  Sources/
  Tests/
```

Root packages must not depend on sibling packages via `.package(path: "../...")`, and their tests/docs/scripts travel with the package folder. Cross-package composition belongs in `./Packages/IntegrationHelpers`, not inside root packages.

## Active Root Packages

- `./Packages/AppAnalytics`
- `./Packages/AppAppleAuthentication`
- `./Packages/AppBranding`
- `./Packages/AppCache`
- `./Packages/AppConfiguration`
- `./Packages/AppDatabase`
- `./Packages/AppErrors`
- `./Packages/AppLocalization`
- `./Packages/AppNavigation`
- `./Packages/AppNetworking`
- `./Packages/AppOnDeviceAI`
- `./Packages/AppPushNotifications`
- `./Packages/AppShareExtensionSupport`
- `./Packages/AppSync`
- `./Packages/AppWidgetSupport`
- `./Packages/TchopProductLocalizationResources`

`./Packages/TchopProductLocalizationResources` is standalone but product-specific; copy it only with TchopApp product strings.

## Integration Helpers

Optional helper packages and copy-in source files live under `./Packages/IntegrationHelpers`. They compose multiple root packages while preserving root-package standalone portability.

## Verification

Use the main entry point:

```bash
./Packages/verify_everything.sh
```

Useful focused checks:

```bash
./Packages/verify_single_folder_standalone.sh
./Packages/verify_foundation_only_packages.sh
./Packages/verify_integration_helpers.sh
./Packages/verify_apple_packages_macos.sh
./Packages/verify_strict_concurrency_macos.sh
```

The scripts use centralized build paths under `./.build/` and clean generated `.swiftpm` state from package folders so package directories remain portable.

## Distribution Hygiene

Before sharing package archives, exclude generated metadata and local SwiftPM/Xcode state:

```text
.DS_Store
__MACOSX/
.swiftpm/
.build/
xcuserdata/
*.xcuserstate
```
