# Package Toolkit vNext Review and Change Log

This document describes the hardening pass applied to the current package implementation. The goal of the pass was to move the package set closer to a production reusable SDK: portable manifests, platform-aware verification, safer availability boundaries, cleaner analytics naming, better Linux/FoundationNetworking compatibility, and archive hygiene.

## Executive summary

The package set was already architecturally strong: standalone package folders, `Package.swift`, tests, DocC/README material, generic localization, generic widget support, extensible analytics domains, typed analytics values, improved networking, and clearer database boundaries.

This pass focused on the remaining SDK-readiness issues:

1. Removed public `unsafeFlags(["-strict-concurrency=complete"])` from package manifests.
2. Moved strict concurrency enforcement to verification scripts instead of embedded public package products.
3. Added platform-aware verification scripts.
4. Made the FoundationModels-backed on-device AI implementation compile-safe on SDKs without `FoundationModels`.
5. Added `FoundationNetworking` imports for Linux-compatible networking builds and tests.
6. Added neutral analytics aliases while preserving backward compatibility.
7. Documented branding compatibility tokens as compatibility/sample values rather than preferred generic package defaults.
8. Added root package hygiene rules and cleaned generated metadata from the distributed tree.
9. Updated root documentation with the new verification and distribution contract.

## Verification performed in this environment

This environment is Linux-based, so only Foundation-compatible packages can be fully verified here. Apple-platform packages that import SwiftUI, Observation, CoreData, SwiftData, AuthenticationServices, UniformTypeIdentifiers, AppKit/UIKit, or FoundationModels must be verified on macOS/Xcode.

Verified successfully here:

- `AppCache` — 7 XCTest tests passed.
- `AppWidgetSupport` — 3 XCTest tests passed.
- `AppConfiguration` — 8 XCTest tests passed.
- `AppPushNotifications` — 6 Swift Testing tests passed.
- `AppLocalization` — 6 XCTest tests passed.
- `AppNetworking` — 27 XCTest tests passed.
- `AppErrors` — previously verified successfully during this pass: 9 Swift Testing tests passed.
- `TchopProductLocalizationResources` — 1 XCTest test passed.
- `AppOnDeviceAI` — 2 Swift Testing tests passed with FoundationModels unavailable fallback.

Packages intentionally routed to macOS/Xcode verification:

- `AppNavigation`
- `AppAppleAuthentication`
- `AppShareExtensionSupport`
- `AppBranding`
- `AppDatabase`
- `AppAnalytics`
- `AppSync`

Reason: these import or transitively link Apple-only frameworks or `Observation` on the current Linux toolchain.

## Cross-package changes

### 1. Removed public unsafe Swift settings

Before, most package manifests contained:

```swift
private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]
```

and passed `swiftSettings: strictConcurrencySettings` to targets.

That is useful for internal validation but problematic for reusable packages, because SwiftPM treats unsafe flags as a distribution/importability risk for dependent clients.

Now:

- Package manifests no longer embed `unsafeFlags`.
- Strict concurrency is checked by scripts/CI using command-line flags.
- Public package products remain easier to consume from other SwiftPM clients.

Affected packages:

- `AppAnalytics`
- `AppAppleAuthentication`
- `AppBranding`
- `AppCache`
- `AppConfiguration`
- `AppDatabase`
- `AppErrors`
- `AppLocalization`
- `AppNavigation`
- `AppNetworking`
- `AppOnDeviceAI`
- `AppPushNotifications`
- `AppShareExtensionSupport`
- `AppSync`
- `AppWidgetSupport`
- `TchopInfrastructure`
- `TchopProductLocalizationResources`

### 2. Added platform-aware verification scripts

New scripts:

```bash
./Packages/verify_foundation_only_packages.sh
./Packages/verify_apple_packages_macos.sh
./Packages/verify_strict_concurrency_macos.sh
./Packages/verify_standalone_packages.sh
```

`verify_foundation_only_packages.sh` runs portable packages that should work on a Foundation-only SwiftPM toolchain.

`verify_apple_packages_macos.sh` runs packages requiring macOS/Xcode because of Apple-only frameworks.

`verify_strict_concurrency_macos.sh` performs strict-concurrency checks via command-line Swift flags rather than Package.swift unsafe flags.

`verify_standalone_packages.sh` now runs portable packages everywhere and Apple packages only on macOS.

### 3. Added distribution hygiene rules

Added root `.gitignore` under `Packages/` for:

```text
.DS_Store
__MACOSX/
.swiftpm/
.build/
xcuserdata/
*.xcuserstate
```

The final archive is cleaned of generated metadata, local SwiftPM state, and macOS resource-fork files.

---

# Per-package review and changes

## AppNetworking

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.
- Added conditional `FoundationNetworking` imports to source files that use `URLRequest`, `URLSession`, `HTTPURLResponse`, or `URLProtocol`.
- Added conditional `FoundationNetworking` import to networking tests.
- Confirmed portable Linux build/test compatibility after the import fix.

### Verification

`AppNetworking` passed 27 XCTest tests in this environment.

### Current maturity

Approximate maturity after this pass: **90/100**.

### Remaining recommendations

- Keep `APIHTTPFailure` as the preferred rich HTTP failure type and gradually de-emphasize legacy `APIError.invalidStatusCode(Int)`.
- Add more tests for custom error mapping of rich HTTP failures into app-specific errors.
- Keep `APICancellationToken` as an optional bridge only; primary cancellation should remain Swift `Task` cancellation.
- Consider adding request/response redaction policies per endpoint for highly sensitive APIs.

## AppErrors

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.
- No API-breaking changes were made.

### Verification

`AppErrors` was verified during this pass: 9 Swift Testing tests passed.

### Current maturity

Approximate maturity after this pass: **86/100**.

### Remaining recommendations

- Consider neutral aliases for `AppError` if the package is intended as a public SDK. Names like `ErrorDescriptor`, `UserFacingError`, or `RecoverableErrorDescriptor` are more generic.
- Consider typed metadata values instead of only string metadata when the reporting destination supports typed payloads.
- Keep user-facing localized copy outside the error-core package where possible.

## AppAnalytics

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.
- Added preferred neutral aliases while preserving source compatibility:
  - `AnalyticsEvent = ProductAnalyticsEvent`
  - `AnalyticsCollecting = ProductAnalyticsCollecting`
  - `AnalyticsMemoryCollector = ProductAnalyticsMemoryCollector`
  - `AnalyticsNoopCollector = ProductAnalyticsNoopCollector`

### Verification

`AppAnalytics` currently routes to macOS verification because it depends on navigation analytics and transitively links `Observation` on this Linux toolchain.

### Current maturity

Approximate maturity after this pass: **86/100**.

### Remaining recommendations

- Gradually update internal and downstream code to prefer the neutral names (`AnalyticsEvent`, `AnalyticsCollecting`) while keeping the old product-specific names deprecated or compatibility-only.
- Consider separating `AppAnalyticsCore` into an independently testable portable package if full Linux portability is a goal.
- Keep adapters (`Navigation`, `Networking`, `Push`) separate so app targets can depend only on the analytics integrations they need.

## AppLocalization

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.
- No API-breaking changes were made.

### Verification

`AppLocalization` passed 6 XCTest tests in this environment.

### Current maturity

Approximate maturity after this pass: **90/100**.

### Remaining recommendations

- Keep this package mechanism-only: lookup, bundle resolving, fallback, formatting, and missing-key behavior.
- Keep all product copy in product/feature resource packages like `TchopProductLocalizationResources`.
- Consider explicit missing-key reporting hooks for analytics/debug overlays.

## TchopProductLocalizationResources

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.
- No resource/API changes were made.

### Verification

`TchopProductLocalizationResources` passed 1 XCTest test in this environment.

### Current maturity

Approximate maturity as a product package: **85/100**.

### Remaining recommendations

- Keep this package explicitly product-specific.
- Do not treat it as generic reusable infrastructure.
- Consider splitting by feature (`NewsLocalizationResources`, `ProfileLocalizationResources`, etc.) if the product grows and resource ownership becomes hard to maintain.

## AppWidgetSupport

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.
- No API-breaking changes were made.

### Verification

`AppWidgetSupport` passed 3 XCTest tests in this environment.

### Current maturity

Approximate maturity after this pass: **90/100**.

### Remaining recommendations

- Keep this package limited to generic snapshot support and app-group storage mechanics.
- Avoid widget-specific localization, feed models, or product copy in this package.
- If larger widget payloads are needed, consider file-backed snapshot storage in addition to `UserDefaults`.

## AppConfiguration

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.
- No API-breaking changes were made.

### Verification

`AppConfiguration` passed 8 XCTest tests in this environment.

### Current maturity

Approximate maturity after this pass: **88/100**.

### Remaining recommendations

- Consider first-class support for ETag/version/source metadata.
- Consider explicit kill-switch/minimum-app-version primitives if this package owns remote product safety configuration.
- Consider a typed feature-flag layer as a separate package or adapter.

## AppPushNotifications

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.
- No API-breaking changes were made.

### Verification

`AppPushNotifications` passed 6 Swift Testing tests in this environment.

### Current maturity

Approximate maturity after this pass: **82/100**.

### Remaining recommendations

- Keep this as push-core if it remains platform-neutral.
- Add a separate Apple-platform adapter for `UNUserNotificationCenter`, APNs registration, delegate bridging, and foreground presentation behavior.
- Consider `JSONValue` for custom payload data if nested values are needed.

## AppCache

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.
- No API-breaking changes were made.

### Verification

`AppCache` passed 7 XCTest tests in this environment.

### Current maturity

Approximate maturity after this pass: **84/100**.

### Remaining recommendations

- Add cache metadata reads: stored date, expiration date, age, stale state, estimated size.
- Add optional eviction policies: max entries, max disk size, remove expired, and LRU if needed.
- Consider file-system error diagnostics for production support.

## AppOnDeviceAI

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.
- Wrapped the FoundationModels-backed implementation in `#if canImport(FoundationModels)`.
- Updated `OnDeviceAIManagerFactory` to return `UnavailableOnDeviceAIManager` when the SDK does not provide FoundationModels.
- Fixed formatting around public methods in `FoundationModelsOnDeviceAIManager.swift`.

### Verification

`AppOnDeviceAI` passed 2 Swift Testing tests in this environment using the unavailable fallback path.

### Current maturity

Approximate maturity after this pass: **78/100**.

### Remaining recommendations

- Keep FoundationModels support in a platform adapter target if SDK availability gets more complex.
- Make prompt policy more configurable if this package should support more than translation.
- Add tests around segment identity preservation using a fake model/session abstraction if feasible.

## AppShareExtensionSupport

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.

### Verification

Routes to macOS/Xcode verification because it imports Apple-only frameworks such as `UniformTypeIdentifiers`.

### Current maturity

Approximate maturity after this pass: **80/100**.

### Remaining recommendations

- Add hard payload limits: max file size, max item count, allowed UTTypes.
- Consider `NSFileCoordinator` / file coordination for app-extension multi-process access if concurrent reads/writes become realistic.
- Document security-scoped resource behavior and cleanup guarantees.

## AppNavigation

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.

### Verification

Routes to macOS/Xcode verification because of `Observation`/Apple platform linking constraints in this environment.

### Current maturity

Approximate maturity after this pass: **80/100**.

### Remaining recommendations

- Continue treating this as a typed router/snapshot helper, not a full app navigation architecture by itself.
- Add examples for tab routers + app coordinator + auth gate.
- Consider explicit modal/sheet/full-screen route handling if used across apps.

## AppSync

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.

### Verification

Routes to macOS/Xcode verification in this environment because `AppSyncObservation` transitively links `Observation` on the Linux toolchain.

### Current maturity

Approximate maturity after this pass: **80/100**.

### Remaining recommendations

- Keep sync engine/core separate from observation/UI status stores when possible.
- Add `SyncRunReport` if callers need structured sync diagnostics.
- Add more tests for cancellation, partial failures, conflict UI handoff, idempotency, and retry policies.

## AppDatabase

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.

### Verification

Routes to macOS/Xcode verification because it imports CoreData/SwiftData.

### Current maturity

Approximate maturity after this pass: **76/100**.

### Remaining recommendations

- Keep documenting `DatabaseManaging` as main-context oriented.
- Use `CoreDataBackgroundDatabaseManager` for background import/sync/migration work.
- Use `SwiftDataModelActorDatabaseManager` for actor-confined SwiftData work.
- Avoid expanding the `Any`-based abstraction if it starts fighting the type system; prefer backend-specific adapters where needed.

## AppBranding

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.
- Added documentation comments clarifying that built-in `BrandVariant.classic`, `BrandVariant.ocean`, and `BrandGlassRole.floatingActionButton` are compatibility/sample values.
- Documented that generic consumers should define product-specific variants/roles in the app/product layer through extensions.

### Verification

Routes to macOS/Xcode verification because it imports SwiftUI/AppKit/UIKit.

### Current maturity

Approximate maturity after this pass: **80/100**.

### Remaining recommendations

- For a stricter public SDK, move concrete themes such as `classic` and `ocean` into a product branding package.
- Keep this package focused on token structures, theme resolving, and platform color bridging.
- Consider a separate `ProductBrandingResources` package for concrete themes.

## AppAppleAuthentication

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.

### Verification

Routes to macOS/Xcode verification because it imports `AuthenticationServices`.

### Current maturity

Approximate maturity after this pass: **78/100**.

### Remaining recommendations

- Add nonce/state support for server-backed Sign in with Apple flows.
- Add a clear server verification payload contract.
- Document MainActor/UI interaction expectations around presentation anchors.

## TchopInfrastructure compatibility bundle

### Applied changes

- Removed Package.swift unsafe strict-concurrency flags.
- Mirrored the FoundationModels compile guard changes in the compatibility on-device AI implementation.
- Mirrored `FoundationNetworking` imports for networking source and networking tests.
- Mirrored neutral analytics aliases.
- Mirrored branding compatibility documentation comments.

### Current maturity

This package remains a compatibility bundle, not the preferred source of truth.

### Recommendation

Retire this compatibility bundle once active apps fully depend on standalone packages.

Suggested plan:

1. v0.8 — standalone packages are source of truth.
2. v0.9 — app targets no longer depend on `TchopInfrastructure`.
3. v1.0 — remove `TchopInfrastructure` compatibility bundle.

---

# Remaining path to “near 100%”

The changes in this pass address the highest-value package-maturity issues. To reach a true “near 100%” public SDK level, the next work should be:

1. Run `verify_apple_packages_macos.sh` on macOS/Xcode and fix any Apple-only build issues.
2. Run `verify_strict_concurrency_macos.sh` in CI and fix any strict-concurrency warnings/errors.
3. Decide whether `App*` naming is final or whether public packages should become `NetworkingKit`, `CacheKit`, `LocalizationKit`, etc.
4. Move concrete branding themes out of `AppBranding` if the package must be fully product-neutral.
5. Add DocC examples for each package’s “happy path” and “composition in app target” usage.
6. Add a root example app or integration tests that consume the standalone packages the same way a real app would.
7. Add release/versioning policy and semantic versioning rules for public API changes.
