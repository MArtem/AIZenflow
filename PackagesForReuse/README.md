# PackagesForReuse

## Purpose

`./PackagesForReuse` is a lightweight, non-connected vault for reusable Swift packages.

It exists so package source, tests, DocC, scripts, and usage documentation are preserved without forcing every package to be connected to `TchopApp` through SwiftPM.

## Rules

- Packages in this folder are **not connected to the app by default**.
- Do not place generated artifacts here: `.build`, `.swiftpm`, `build`, `DerivedData`, logs, or Xcode user data.
- A package may be copied from here into `./PackagesInUse` when `TchopApp` can use it now, or into another project when it is actually needed.
- Before wiring a package into app code, run the package-local verification script when using SwiftPM mode; in source-only mode, run project verification after adding the package source/resources to Xcode targets.
- Keep package code self-contained: `Package.swift`, `README.md`, `PackageContract.md`, `Sources`, `Tests`, DocC, and `Scripts/verify_package.sh` travel together.
- Integration helpers are optional composition files/packages and must stay outside root standalone packages.

## Current Vault Index

| Path | Kind | Products |
| --- | --- | --- |
| `./PackagesForReuse/AppAnalytics` | root-package | `AppAnalyticsCore`, `AppAnalytics` |
| `./PackagesForReuse/AppAppleAuthentication` | root-package | `AppAppleAuthentication` |
| `./PackagesForReuse/AppBranding` | root-package | `AppBranding` |
| `./PackagesForReuse/AppCache` | root-package | `AppCache` |
| `./PackagesForReuse/AppConfiguration` | root-package | `AppConfiguration` |
| `./PackagesForReuse/AppConnectivity` | root-package | `AppConnectivity` |
| `./PackagesForReuse/AppDatabase` | root-package | `AppDatabaseCore`, `AppSwiftDataDatabase`, `AppCoreDataDatabase`, `AppDatabaseComposition`, `AppDatabase` |
| `./PackagesForReuse/AppDeviceInfo` | root-package | `AppDeviceInfo` |
| `./PackagesForReuse/AppEnvironment` | root-package | `AppEnvironment` |
| `./PackagesForReuse/AppErrors` | root-package | `AppErrorsCore`, `AppErrors` |
| `./PackagesForReuse/AppFeatureFlags` | root-package | `AppFeatureFlags` |
| `./PackagesForReuse/AppGlassUI` | root-package | `AppGlassUI` |
| `./PackagesForReuse/AppLocalization` | root-package | `AppLocalization` |
| `./PackagesForReuse/AppLifecycle` | root-package | `AppLifecycle` |
| `./PackagesForReuse/AppLogging` | root-package | `AppLogging` |
| `./PackagesForReuse/AppNavigation` | root-package | `AppNavigation` |
| `./PackagesForReuse/AppNetworking` | root-package | `AppNetworking` |
| `./PackagesForReuse/AppObservability` | root-package | `AppObservability` |
| `./PackagesForReuse/AppOnDeviceAI` | root-package | `AppOnDeviceAI` |
| `./PackagesForReuse/AppPermissions` | root-package | `AppPermissions` |
| `./PackagesForReuse/AppPushNotifications` | root-package | `AppPushNotifications` |
| `./PackagesForReuse/AppSecureStorage` | root-package | `AppSecureStorage` |
| `./PackagesForReuse/AppShareExtensionSupport` | root-package | `AppShareExtensionSupport` |
| `./PackagesForReuse/AppSync` | root-package | `AppSyncCore`, `AppSyncObservation` |
| `./PackagesForReuse/AppWidgetSupport` | root-package | `AppWidgetSupport` |
| `./PackagesForReuse/TchopProductLocalizationResources` | root-package | `TchopProductLocalizationResources` |
| `./PackagesForReuse/IntegrationHelpers/AppAnalyticsNavigationIntegration` | integration-helper | `AppAnalyticsNavigationIntegration` |
| `./PackagesForReuse/IntegrationHelpers/AppAnalyticsNetworkingIntegration` | integration-helper | `AppAnalyticsNetworkingIntegration` |
| `./PackagesForReuse/IntegrationHelpers/AppAnalyticsPushNotificationsIntegration` | integration-helper | `AppAnalyticsPushNotificationsIntegration` |
| `./PackagesForReuse/IntegrationHelpers/AppErrorsNetworkingIntegration` | integration-helper | `AppErrorsNetworkingIntegration` |
| `./PackagesForReuse/IntegrationHelpers/TchopProductLocalizationResourcesAppLocalizationIntegration` | integration-helper | `TchopProductLocalizationResourcesAppLocalizationIntegration` |

## Standard Connection Flow

1. For current TchopApp source-only mode, copy the needed package folder into `./PackagesInUse/<PackageName>`. For future SwiftPM mode in another project, copy it under that project's package folder, usually `./Packages/<PackageName>`.
2. Run the local verification script:

```zsh
cd ./PackagesForReuse/<PackageName>
./Scripts/verify_package.sh
```

3. In current TchopApp source-only mode, add only required `Sources/**/*.swift` files/resources from `./PackagesInUse/<PackageName>` to the relevant Xcode targets.
4. In future SwiftPM mode, add the package to Xcode or to the target project's `Package.swift` and link only needed products.
5. Replace app-local duplicated mechanics with the package API only when the package surface matches without decorative wrappers.
6. Run project verification after app imports, source references, resources, or package references change.

See `./PackagesForReuse/CONNECTING_PACKAGES.md` for concrete examples.
