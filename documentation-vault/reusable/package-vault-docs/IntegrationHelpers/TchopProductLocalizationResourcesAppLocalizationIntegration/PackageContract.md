# TchopProductLocalizationResourcesAppLocalizationIntegration Integration Helper Contract

## Status

This is an optional integration helper, not a root infrastructure package. Root packages remain 100% single-folder standalone without this helper.

## Requires

TchopProductLocalizationResources + AppLocalization

## Purpose

Creates AppLocalization managers backed by product-specific resource bundles.

## Copy modes

1. **Copy-file mode:** copy the matching file from `Packages/IntegrationHelpers/CopyFiles/` into a host app/integration target that already imports the required root packages.
2. **Helper-package mode:** use this folder as a small Swift Package when the required root packages are available beside it or when its manifest is adapted to Git URL dependencies.

## Privacy rule

Helpers must not send raw backend bodies, HTTP headers, token-bearing URLs, notification copy, or raw `String(describing: error)` into analytics/telemetry.

## Verification

From this folder, run:

```bash
swift test
```

From the package workspace, run:

```bash
./Packages/verify_integration_helpers.sh
./Packages/verify_single_folder_standalone.sh
```
