# Release Notes — vNext5

## Highlights

vNext5 completes the single-folder standalone isolation pass by turning optional cross-package adapters into explicit, testable helper packages and adding semantic privacy gates.

## Added

- `Packages/IntegrationHelpers/AppAnalyticsNavigationIntegration`
- `Packages/IntegrationHelpers/AppAnalyticsNetworkingIntegration`
- `Packages/IntegrationHelpers/AppAnalyticsPushNotificationsIntegration`
- `Packages/IntegrationHelpers/AppErrorsNetworkingIntegration`
- `Packages/IntegrationHelpers/TchopProductLocalizationResourcesAppLocalizationIntegration`
- `Packages/verify_integration_helpers.sh`

## Changed

- `IntegrationHelpers` are now optional Swift packages, not loose copy-only files.
- Networking analytics helper emits sanitized error descriptors instead of raw error descriptions.
- Push analytics helper no longer emits notification titles.
- Navigation analytics helper redacts deep-link query/fragment values and hashes user identifiers.
- Networking error-to-app-error helper avoids raw fallback debug descriptions.
- `verify_single_folder_standalone.sh` now performs structural and semantic checks.
- `verify_standalone_packages.sh` now includes integration helper verification.

## Fixed

- Addressed review feedback that helper files needed their own package contracts and tests.
- Addressed raw telemetry leakage risks in integration helpers.
- Made `TchopInfrastructure` compatibility status explicit in docs.

## Verification

Portable verification performed in this environment:

- `verify_single_folder_standalone.sh`
- integration helper package tests for portable helpers

Run on macOS/Xcode before final merge:

```bash
./Packages/verify_foundation_only_packages.sh
./Packages/verify_apple_packages_macos.sh
./Packages/verify_strict_concurrency_macos.sh
./Packages/verify_integration_helpers.sh
```
