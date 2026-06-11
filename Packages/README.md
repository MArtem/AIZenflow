# Packages

`./Packages` is the active local SwiftPM package area for packages that are connected to, verified with, or immediately relevant to `TchopApp`. `./PackagesForReuse` is the lightweight vault for all reviewed reusable package folders, including packages that are not connected to the app yet.

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
- `./Packages/AppConfiguration`
- `./Packages/AppDatabase`
- `./Packages/AppErrors`
- `./Packages/AppLocalization`
- `./Packages/AppNavigation`
- `./Packages/AppNetworking`
- `./Packages/AppOnDeviceAI`
- `./Packages/AppPushNotifications`
- `./Packages/AppShareExtensionSupport`
- `./Packages/AppWidgetSupport`
- `./Packages/TchopProductLocalizationResources`

`./Packages/TchopProductLocalizationResources` is standalone but product-specific; copy it only with TchopApp product strings.

## Vault-only packages

Reusable packages that are not connected to the app now live under `./PackagesForReuse`. Copy a package back into `./Packages` only when the app has a concrete current use for it. See `./PackagesForReuse/ADOPTION_AUDIT.md`.

## SDK Creation Baseline

`./Packages/SDKCreation` contains the reusable documentation, templates, and verification scripts for creating future standalone infrastructure packages. It is not a runtime package and must not be linked into app targets. Use it when creating new root packages or integration helpers.

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

The scripts use centralized build paths under `/Users/Artem/.zenflow/worktrees/.package-build-cache/` and clean generated `.swiftpm` state from package folders so package directories remain portable. Do not route package verification, Xcode DerivedData, or cloned package state outside `/Users/Artem/.zenflow/worktrees/`.

## Distribution Hygiene

Before sharing package archives, exclude generated metadata and local SwiftPM/Xcode state:

```text
.DS_Store
__MACOSX/
.swiftpm/
.build/
.package-build-cache/
.xcode-derived-data/
.xcode-package-cache/
xcuserdata/
*.xcuserstate
```


## Liquid Glass / visual effects

Use `./Packages/AppGlassUI` for reusable SwiftUI Liquid Glass availability and fallback mechanics. Keep product-specific colors, semantic roles, and layout decisions in the host app or compose them with `./Packages/AppBranding` in app code.
