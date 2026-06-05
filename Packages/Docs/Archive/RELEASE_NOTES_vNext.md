# vNext Release Notes

## Major packaging changes

- Removed public SwiftPM unsafe strict-concurrency flags from all package manifests.
- Added platform-aware verification scripts.
- Added strict-concurrency verification through command-line build flags instead of package manifest unsafe flags.
- Added distribution hygiene rules via `.gitignore`.

## Major source changes

- `AppOnDeviceAI`: FoundationModels implementation is now compiled only when the SDK provides `FoundationModels`.
- `AppNetworking`: added conditional `FoundationNetworking` imports for portable SwiftPM builds on Linux.
- `AppAnalyticsCore`: added neutral compatibility aliases: `AnalyticsEvent`, `AnalyticsCollecting`, `AnalyticsMemoryCollector`, and `AnalyticsNoopCollector`.
- `AppBranding`: documented built-in variants/roles as compatibility/sample values and directed product apps to define their own variants/roles.

## Verification

Foundation-compatible packages were verified on this Linux environment where possible. Apple-only packages should be verified on macOS/Xcode using the included scripts.
