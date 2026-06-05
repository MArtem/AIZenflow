# vNext2 Release Notes

vNext2 builds on the first hardening iteration and adds deeper runtime metadata, diagnostics, and contract tests for the portable package layer.

## Added

### AppCache

- Added `CacheRecord<Value>` with:
  - `value`
  - `storedAt`
  - `expirationDate`
  - `isExpired`
- Added `record(forKey:as:)` to `LocalCacheManaging`.
- Added `removeExpired()` to `LocalCacheManaging`.
- Added metadata support to both in-memory and file-backed cache managers.
- Added backward-tolerant decoding for older stored entries without `storedAt`.
- Added 3 new cache metadata/cleanup tests.

### AppConfiguration

- Added `UIConfigurationSnapshotSource`:
  - `fallback`
  - `cache`
  - `remote`
- Added `UIConfigurationRuntimeMetadata`.
- Added `runtimeMetadata()` to `UIConfigurationManaging`.
- `UIConfigurationManager` now tracks:
  - current snapshot source;
  - last successful fetch;
  - last failed fetch;
  - last failure description.
- Refresh failures now update diagnostics without replacing the current snapshot.
- Added 3 runtime metadata tests.

### AppNetworking / AppErrors

- Added `APIError.httpFailure(APIHTTPFailure)` as a typed bridge for rich HTTP failures.
- Updated default error mapping to preserve rich HTTP failure context inside `APIError` when mapping is used.
- Updated AppErrors networking adapter to handle `APIError.httpFailure`.

### AppAnalytics

- Completed neutral alias coverage by adding `AnalyticsMemoryCollector`.

### Verification scripts

- Added `AppOnDeviceAI` to `verify_foundation_only_packages.sh` because the fallback path now builds without FoundationModels.

## Verified in this environment

- AppCache: 10 XCTest tests passed.
- AppWidgetSupport: 3 XCTest tests passed.
- AppConfiguration: 11 XCTest tests passed.
- AppPushNotifications: 6 Swift Testing tests passed.
- AppLocalization: 6 XCTest tests passed.
- AppNetworking: 27 XCTest tests passed.
- AppErrors: 9 Swift Testing tests passed.
- TchopProductLocalizationResources: 1 XCTest test passed.
- AppOnDeviceAI: 2 Swift Testing tests passed.

## Still requiring macOS/Xcode verification

- AppNavigation
- AppAppleAuthentication
- AppShareExtensionSupport
- AppBranding
- AppDatabase
- AppAnalytics
- AppSync

Use:

```bash
./Packages/verify_apple_packages_macos.sh
./Packages/verify_strict_concurrency_macos.sh
```
