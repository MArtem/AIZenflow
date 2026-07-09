# Package Catalog

## Purpose

This catalog is the high-level selector for the reusable package library. Read this file first when deciding which package to adopt, then open the package-specific `README.md` for setup, boundaries and verification.

## Counts

- **Reusable root packages**: 39
- **Integration helper packages**: 5
- **Currently active in `./PackagesInUse`**: 21 root packages and 4 helper folders

## Root Packages

| Package | Active In TchopApp | Products | What It Does |
| --- | --- | --- | --- |
| `./PackagesForReuse/AppAnalytics` | Yes | `AppAnalyticsCore`, `AppAnalytics` | Analytics event modeling and reporting primitives for app, navigation, networking and push events. |
| `./PackagesForReuse/AppAppleAuthentication` | Yes | `AppAppleAuthentication` | Sign in with Apple request, credential and authorization helper mechanics. |
| `./PackagesForReuse/AppBackgroundTasks` | No | `AppBackgroundTasks` | Background task registration and execution coordination helpers. |
| `./PackagesForReuse/AppBranding` | Yes | `AppBranding` | Reusable branding values and app identity presentation primitives. |
| `./PackagesForReuse/AppCache` | No | `AppCache` | Generic cache storage, expiration and cleanup mechanics. |
| `./PackagesForReuse/AppConfiguration` | Yes | `AppConfiguration` | Configuration snapshot storage and refresh mechanics. |
| `./PackagesForReuse/AppConnectivity` | No | `AppConnectivity` | Network connectivity observation and reachability-state helpers. |
| `./PackagesForReuse/AppDatabase` | Yes | `AppDatabaseCore`, `AppSwiftDataDatabase`, `AppCoreDataDatabase`, `AppDatabaseComposition`, `AppDatabase` | Database execution boundaries for SwiftData/Core Data and backend-neutral database contracts. |
| `./PackagesForReuse/AppDeviceInfo` | No | `AppDeviceInfo` | Device, OS and runtime information provider utilities. |
| `./PackagesForReuse/AppDownloads` | No | `AppDownloads` | Secure generic download service with URL, size, cancellation and destination-file policies. |
| `./PackagesForReuse/AppEnvironment` | Yes | `AppEnvironment` | Environment/runtime provider for app mode, configuration source and build/runtime context. |
| `./PackagesForReuse/AppErrors` | Yes | `AppErrorsCore`, `AppErrors` | Generic app error contracts, mapping and user-facing/reporting boundaries. |
| `./PackagesForReuse/AppFeatureFlags` | No | `AppFeatureFlags` | Feature flag definition, evaluation and storage mechanics. |
| `./PackagesForReuse/AppFileStorage` | Yes | `AppFileStorage` | Safe local file storage domains and file copy/write helpers. |
| `./PackagesForReuse/AppFormValidation` | Yes | `AppFormValidation` | Form state, field validation and save/load controller mechanics. |
| `./PackagesForReuse/AppGlassUI` | Yes | `AppGlassUI` | Reusable SwiftUI glass-style visual primitives for modern iOS UI. |
| `./PackagesForReuse/AppImagePipeline` | No | `AppImagePipeline` | Image loading, decoding, caching and prefetch pipeline. |
| `./PackagesForReuse/AppIntentSupport` | Yes | `AppIntentSupport` | Reusable helper mechanics for App Intents input validation and package composition markers. |
| `./PackagesForReuse/AppLifecycle` | Yes | `AppLifecycle` | Application lifecycle event and state helper mechanisms. |
| `./PackagesForReuse/AppLocalization` | Yes | `AppLocalization` | Localization lookup/provider mechanics independent of any product string catalog. |
| `./PackagesForReuse/AppLogging` | No | `AppLogging` | Structured logging primitives and safe log-level/category contracts. |
| `./PackagesForReuse/AppNavigation` | Yes | `AppNavigation` | Navigation route/event/snapshot contracts and diagnostic reporting helpers. |
| `./PackagesForReuse/AppNetworking` | Yes | `AppNetworking` | HTTP/API networking mechanics: requests, retries, interceptors, auth refresh, uploads/downloads and offline queue support. |
| `./PackagesForReuse/AppObservability` | No | `AppObservability` | Observability primitives for diagnostics, metrics and operational event reporting. |
| `./PackagesForReuse/AppOnDeviceAI` | Yes | `AppOnDeviceAI` | On-device AI capability, prompt/request and result helper mechanisms. |
| `./PackagesForReuse/AppPagination` | No | `AppPagination` | Generic pagination state and page loading/merge mechanics. |
| `./PackagesForReuse/AppPermissions` | Yes | `AppPermissions` | Permission status/request helper mechanics for Apple platform capabilities. |
| `./PackagesForReuse/AppPushNotifications` | Yes | `AppPushNotifications` | Push notification registration, token and payload event helper mechanics. |
| `./PackagesForReuse/AppRateLimiter` | No | `AppRateLimiter` | Fixed-window and token-bucket rate limiting mechanics. |
| `./PackagesForReuse/AppRemoteAssets` | No | `AppRemoteAssets` | Remote asset manifest validation and asset retrieval mechanics. |
| `./PackagesForReuse/AppSecureStorage` | No | `AppSecureStorage` | Secure storage/keychain-style boundary for tokens and secret-like values. |
| `./PackagesForReuse/AppShareExtensionSupport` | Yes | `AppShareExtensionSupport` | Share extension import, app-group JSON storage and pending-item transfer support. |
| `./PackagesForReuse/AppStateMachine` | No | `AppStateMachine` | Generic async state-machine runtime with guarded transitions and persistence hooks. |
| `./PackagesForReuse/AppSync` | No | `AppSyncCore`, `AppSyncObservation` | Sync engine mechanics plus optional observable sync status layer. |
| `./PackagesForReuse/AppTaskQueue` | No | `AppTaskQueue` | Durable task queue, reservation, retry and payload-limit mechanics. |
| `./PackagesForReuse/AppUploads` | No | `AppUploads` | Secure generic upload service with URL, size, retry and cancellation policies. |
| `./PackagesForReuse/AppValidationCore` | No | `AppValidationCore` | Low-level validation engine with safe identifiers, typed values and rule evaluation. |
| `./PackagesForReuse/AppWidgetSupport` | Yes | `AppWidgetSupport` | Widget snapshot storage and generic widget data handoff support. |
| `./PackagesForReuse/TchopProductLocalizationResources` | Yes | `TchopProductLocalizationResources` | TchopApp-specific localization resource package. |

## Integration Helpers

Integration helpers intentionally compose two or more root packages while keeping root packages independent. Use them only when both sides are already intentionally adopted.

| Helper | Active In TchopApp | Products | What It Does |
| --- | --- | --- | --- |
| `./PackagesForReuse/IntegrationHelpers/AppAnalyticsNavigationIntegration` | Yes | `AppAnalyticsNavigationIntegration` | Integration helper connecting AppNavigation events to AppAnalytics reporting. |
| `./PackagesForReuse/IntegrationHelpers/AppAnalyticsNetworkingIntegration` | Yes | `AppAnalyticsNetworkingIntegration` | Integration helper connecting AppNetworking events/failures to AppAnalytics reporting. |
| `./PackagesForReuse/IntegrationHelpers/AppAnalyticsPushNotificationsIntegration` | Yes | `AppAnalyticsPushNotificationsIntegration` | Integration helper connecting AppPushNotifications events to AppAnalytics reporting. |
| `./PackagesForReuse/IntegrationHelpers/AppErrorsNetworkingIntegration` | No | `AppErrorsNetworkingIntegration` | Integration helper mapping AppNetworking failures into AppErrors surfaces. |
| `./PackagesForReuse/IntegrationHelpers/TchopProductLocalizationResourcesAppLocalizationIntegration` | No | `TchopProductLocalizationResourcesAppLocalizationIntegration` | Integration helper connecting TchopProductLocalizationResources to AppLocalization. |

## Selection Rules

1. Start with the package whose problem statement matches the current feature.
2. Prefer one direct package API over app-local wrappers, facades or duplicate managers.
3. Keep product policy in the app: UI copy, routing, DTO mapping, persistence schema, secrets, privacy and rollout decisions.
4. Use integration helpers only for cross-package mapping; do not move app policy into helper packages.
5. Before adding a package to `./PackagesInUse`, verify the vault package and then run app/project verification after source-only wiring.

## Documentation Rule For Future Packages

Every new reusable package must include:

- a package-level `README.md` with summary, solved problem, capabilities, usage, local SwiftPM setup, remote SwiftPM setup, source-only integration notes and verification;
- `PackageContract.md` defining ownership and boundaries;
- `REUSE.md` for copy/adoption guidance;
- package-local `Scripts/verify_package.sh` where applicable;
- an entry in this `./PackagesForReuse/PACKAGE_CATALOG.md`;
- if active in TchopApp, a matching `./PackagesInUse/<PackageName>/README.md` and `./PackagesInUse/README.md` entry.
