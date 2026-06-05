# Release Notes — vNext4 Single-Folder Standalone Isolation

## Added

- `IntegrationHelpers/` folder for optional cross-package adapter files.
- `verify_single_folder_standalone.sh` structural verification script.
- `SINGLE_FOLDER_STANDALONE_REPORT.md`.

## Changed

- `AppAnalytics` is now dependency-free and ships only analytics core primitives.
- `AppErrors` is now dependency-free and ships only app-facing error semantics.
- `TchopProductLocalizationResources` is now dependency-free and exposes direct bundle/localized lookup.
- `PACKAGE_PORTABILITY_CONTRACT.md` now defines true standalone mode as the primary package contract.
- Root README now documents vNext4 standalone isolation.

## Moved to IntegrationHelpers

- Navigation analytics mapping.
- Networking analytics mapping.
- Push notification analytics mapping.
- Networking error mapping.
- Product localization resources → AppLocalization manager bridge.

## Fixed

- Corrected compatibility imports inside `TchopInfrastructure/Sources/TchopNetworkingErrorAdapter`.

## Verified here

- Single-folder standalone structural gate passed.
- Portable package tests passed for changed packages and foundation-compatible packages available in this environment.
- Strict concurrency spot-check passed for packages changed in this iteration.

## Still requires macOS/Xcode

- Full Apple-only package build/tests.
- Full Apple-only strict concurrency verification.
