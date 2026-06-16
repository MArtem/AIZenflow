# PackagesForReuse Adoption Audit

## Purpose

Evidence-based record for which reusable packages are connected to `TchopApp` and which are preserved only in `./PackagesForReuse` until a concrete need exists.

## Connected And Currently Needed

| Package | State | Evidence |
| --- | --- | --- |
| `./Packages/AppNetworking` | connected | Imported by app auth/API composition. |
| `./Packages/AppDatabase` | connected | Imported by app persistence/repositories. |
| `./Packages/AppLocalization` | connected | Used by app localization bridge and extension target dependencies. |
| `./Packages/TchopProductLocalizationResources` | connected | Used by app/widget/share product strings. |
| `./Packages/AppBranding` | connected | Used by app theme and share extension branding. |
| `./Packages/AppGlassUI` | connected | Used by shell/top/bottom/FAB Liquid Glass UI. |
| `./Packages/AppWidgetSupport` | connected | Used by widget bridge and widget extension. |
| `./Packages/AppShareExtensionSupport` | connected | Used by share extension and app-group sync/session context. |
| `./Packages/AppConfiguration` | connected | Used by app UI configuration runtime. |
| `./Packages/AppPushNotifications` | connected | Used by app delegate and push bridge. |
| `./Packages/AppNavigation` | connected | Used by coordinator/routes/tab shells. |
| `./Packages/AppAnalytics` | connected | Used by app analytics collector. |
| `./Packages/AppAppleAuthentication` | connected | Used by login/session Apple auth flows. |
| `./Packages/AppErrors` | connected | Used by app error mapping and view models. |
| `./Packages/AppOnDeviceAI` | connected | Used by feed translation/card contracts. |
| `./Packages/AppFileStorage` | connected | Used source-only through `./PackagesInUse/AppFileStorage` for composer/feed media storage path safety and stable `TchopComposerMedia` fallback resolution. |
| `./Packages/IntegrationHelpers/AppAnalyticsNetworkingIntegration` | connected | Used by app DI analytics wiring. |
| `./Packages/IntegrationHelpers/AppAnalyticsPushNotificationsIntegration` | connected | Used by app DI push analytics wiring. |
| `./Packages/IntegrationHelpers/AppAnalyticsNavigationIntegration` | connected | Used by app DI navigation analytics wiring. |

## Preserved In Vault, Not Connected Now

| Package | State | Reason |
| --- | --- | --- |
| `./PackagesForReuse/AppSecureStorage` | vault-only | Overlaps auth token storage, but current app token protocol is synchronous while the package API is async. Do not force this migration without a focused auth/session refactor and build/test pass. |
| `./PackagesForReuse/AppFeatureFlags` | vault-only | No current feature-flag runtime in app; connecting it now would be speculative. |
| `./PackagesForReuse/AppFormValidation` | vault-only | Current app has a small product-specific login validation surface; safe migration would require app/runtime and test updates, while `./TchopAppTests` is currently off-limits. Keep package ready for a focused validation migration instead of connecting it speculatively. |
| `./PackagesForReuse/AppImagePipeline` | vault-only | Current app image work is local composer/feed media preview generation with platform-specific downsampling and local file references; adopting the generic remote/provided image-byte pipeline now would be speculative. |
| `./PackagesForReuse/AppCache` | vault-only | Current feed/composer media caches store UIImage previews; this package is Codable value/file cache. Do not replace media cache without a focused media-cache design. |
| `./PackagesForReuse/AppBackgroundTasks` | vault-only | No current background task registration/submission requirement exists in app; adoption would require entitlements, Info.plist identifiers, scheduling policy, and manual lifecycle QA. |
| `./PackagesForReuse/AppLogging` | vault-only | Current app uses limited OSLog signposts. Full logging taxonomy/export policy is not defined yet. |
| `./PackagesForReuse/AppObservability` | vault-only | No product telemetry/span policy is connected yet; package is ready for later observability integration. |
| `./PackagesForReuse/AppConnectivity` | vault-only | No app-level reachability/offline UI contract is currently wired; package is ready for later networking/offline integration. |
| `./PackagesForReuse/AppDownloads` | vault-only | Current app has no product-level generic download feature to migrate; `./PackagesInUse/AppNetworking` already owns API-oriented request/download behavior, so connecting this package now would duplicate mechanisms. |
| `./PackagesForReuse/AppSync` | vault-only | No backend sync runtime is active; connecting sync now would create unused infrastructure. |
| `./PackagesForReuse/AppUploads` | vault-only | Current app has no product-level generic upload feature to migrate; `./PackagesInUse/AppNetworking` already owns API-oriented file upload behavior, so connecting this package now would duplicate mechanisms. |
| `./PackagesForReuse/AppPagination` | vault-only | Current app has no active backend pagination/feed pagination runtime to migrate; the existing feed is local-first and channel-scoped, so connecting this package now would add unused infrastructure. |
| `./PackagesForReuse/AppRemoteAssets` | vault-only | Current app has no product-level remote asset manifest runtime; feed/composer media uses local persisted card media, so connecting this package now would add unused infrastructure. |
| `./PackagesForReuse/AppRateLimiter` | vault-only | Current app has only a small synchronous login submission throttle and no generic product rate-limit runtime; replacing it with an async actor-backed rate limiter now would add complexity without a broader rate-limiting requirement. |
| `./PackagesForReuse/AppStateMachine` | vault-only | Current app already has product-specific app/session/navigation/lifecycle state owners; adopting a generic state-machine runtime would require a deliberate product/architecture decision and should not be done mechanically. |
| `./PackagesForReuse/AppTaskQueue` | vault-only | Current app has no generic product task queue runtime to migrate; `./PackagesInUse/AppNetworking` already owns API-specific offline queue behavior, so connecting this package now would duplicate mechanisms. |
| `./PackagesForReuse/IntegrationHelpers/AppErrorsNetworkingIntegration` | vault-only | Not linked by current Xcode targets; keep for future networking/error composition. |
| `./PackagesForReuse/IntegrationHelpers/TchopProductLocalizationResourcesAppLocalizationIntegration` | vault-only | Not linked by current Xcode targets; keep for future localization-resource composition. |

## Build Artifact Policy

- `./.build` is generated SwiftPM build/cache output and can be deleted safely; it will be recreated by future SwiftPM/Xcode package builds.
- Package-local `.swiftpm` folders are generated local SwiftPM/Xcode state and must not be committed or copied into reusable package vault snapshots.
- `./PackagesForReuse` must stay source-only: no `.build`, `.swiftpm`, `build`, `DerivedData`, logs, or user-specific Xcode metadata.

## Future Package Intake Rule

For every new archive:

1. Review and harden the package before adoption.
2. Copy the package into `./PackagesForReuse` without generated artifacts.
3. Decide whether the app has an immediate concrete use.
4. If yes, also connect/use it in app code and run project verification.
5. If no, leave it vault-only and document the reason here or in the package `REUSE.md`.
