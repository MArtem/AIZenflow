# Neutral Package Promotion Guide

## Purpose
This package currently uses `Tchop*` target names because it is embedded in the TchopApp worktree. When any module is copied or promoted into an unrelated project, the promoted package must use neutral names and must not carry source-app branding.

## Rule
Reusable infrastructure must provide mechanisms, not app/product decisions. Product payloads, feature constants, concrete prompts, brand variants, and app-specific runtime policy stay in the app or feature layer.

## Required Promotion Mapping

| Current module | Neutral promoted name | Ownership after promotion |
| --- | --- | --- |
| `TchopNetworking` | `AppNetworking` | HTTP request/response primitives, client runtime, retry/offline support, test doubles |
| `TchopErrorsCore` | `AppErrorsCore` or `AppErrors` | Generic error descriptors, reporting contracts, presentation descriptors |
| `TchopNetworkingErrorAdapter` | `AppNetworkingErrorAdapter` | Networking-to-error mapping only |
| `TchopLocalization` | `AppLocalization` | Localization lookup mechanism; app strings stay in app/feature resources |
| `TchopCache` | `AppCache` | Memory/disk cache mechanisms and tests |
| `TchopWidgets` | `AppWidgetSupport` | Generic widget snapshot storage; concrete widget payloads stay in app/widget target |
| `TchopUIConfiguration` | `AppConfiguration` or `AppRemoteConfiguration` | Generic remote/local configuration manager; app shell payloads stay in app target |
| `TchopAnalyticsCore` | `AppAnalyticsCore` | Analytics event/value/collector contracts |
| analytics adapter targets | `AppNavigationAnalytics`, `AppNetworkingAnalytics`, `AppPushAnalytics` | Adapter-only modules; no core dependency inversion |
| database targets | `AppDatabaseCore`, `AppSwiftDataDatabase`, `AppCoreDataDatabase` | Database mechanism only; feature repositories stay in app/feature layer |
| `TchopShareSupport` | `AppShareExtensionSupport` | Share-extension import/storage mechanisms |
| `TchopAppleAuthentication` | `AppAppleAuthentication` | Sign in with Apple platform adapter |
| `TchopPushNotifications` | `AppPushNotifications` | Push state/payload contracts and platform bridge |

## Tests Move With Packages
Every promoted package must carry its matching tests from `Tests/`. If a product has no package-level test target, promotion is incomplete.

## Compatibility Wrappers
Do not create neutral wrapper targets inside this TchopApp package only to rename modules. Rename during extraction/promotion, or add explicit compatibility umbrellas only when a consuming app requires a staged migration.

## Verification Before Promotion
1. Run package tests in the source worktree.
2. Copy source target, matching test target, DocC catalog, and README/contract docs together.
3. Rename modules in source, tests, and imports.
4. Run package tests in the destination project.
5. Run the destination app build after imports are updated.
