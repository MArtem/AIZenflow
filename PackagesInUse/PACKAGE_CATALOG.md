# Active Package Catalog

## Purpose

This catalog lists the source-only packages currently compiled into `TchopApp`, share-extension or widget targets from `./PackagesInUse`. For the full reusable vault, use `./PackagesForReuse/PACKAGE_CATALOG.md`.

## Active Root Packages

| Package | Products | What It Does |
| --- | --- | --- |
| `./PackagesInUse/AppAnalytics` | `AppAnalyticsCore`, `AppAnalytics` | Analytics event modeling and reporting primitives for app, navigation, networking and push events. |
| `./PackagesInUse/AppAppleAuthentication` | `AppAppleAuthentication` | Sign in with Apple request, credential and authorization helper mechanics. |
| `./PackagesInUse/AppBranding` | `AppBranding` | Reusable branding values and app identity presentation primitives. |
| `./PackagesInUse/AppConfiguration` | `AppConfiguration` | Configuration snapshot storage and refresh mechanics. |
| `./PackagesInUse/AppDatabase` | `AppDatabaseCore`, `AppSwiftDataDatabase`, `AppCoreDataDatabase`, `AppDatabaseComposition`, `AppDatabase` | Database execution boundaries for SwiftData/Core Data and backend-neutral database contracts. |
| `./PackagesInUse/AppEnvironment` | `AppEnvironment` | Environment/runtime provider for app mode, configuration source and build/runtime context. |
| `./PackagesInUse/AppErrors` | `AppErrorsCore`, `AppErrors` | Generic app error contracts, mapping and user-facing/reporting boundaries. |
| `./PackagesInUse/AppFileStorage` | `AppFileStorage` | Safe local file storage domains and file copy/write helpers. |
| `./PackagesInUse/AppFormValidation` | `AppFormValidation` | Form state, field validation and save/load controller mechanics. |
| `./PackagesInUse/AppGlassUI` | `AppGlassUI` | Reusable SwiftUI glass-style visual primitives for modern iOS UI. |
| `./PackagesInUse/AppIntentSupport` | `AppIntentSupport` | Reusable helper mechanics for App Intents input validation and package composition markers. |
| `./PackagesInUse/AppLifecycle` | `AppLifecycle` | Application lifecycle event and state helper mechanisms. |
| `./PackagesInUse/AppLocalization` | `AppLocalization` | Localization lookup/provider mechanics independent of any product string catalog. |
| `./PackagesInUse/AppNavigation` | `AppNavigation` | Navigation route/event/snapshot contracts and diagnostic reporting helpers. |
| `./PackagesInUse/AppNetworking` | `AppNetworking` | HTTP/API networking mechanics: requests, retries, interceptors, auth refresh, uploads/downloads and offline queue support. |
| `./PackagesInUse/AppOnDeviceAI` | `AppOnDeviceAI` | On-device AI capability, prompt/request and result helper mechanisms. |
| `./PackagesInUse/AppPermissions` | `AppPermissions` | Permission status/request helper mechanics for Apple platform capabilities. |
| `./PackagesInUse/AppPushNotifications` | `AppPushNotifications` | Push notification registration, token and payload event helper mechanics. |
| `./PackagesInUse/AppShareExtensionSupport` | `AppShareExtensionSupport` | Share extension import, app-group JSON storage and pending-item transfer support. |
| `./PackagesInUse/AppWidgetSupport` | `AppWidgetSupport` | Widget snapshot storage and generic widget data handoff support. |
| `./PackagesInUse/TchopProductLocalizationResources` | `TchopProductLocalizationResources` | TchopApp-specific localization resource package. |

## Active Integration Helpers

| Helper | Products | What It Does |
| --- | --- | --- |
| `./PackagesInUse/IntegrationHelpers/AppAnalyticsNavigationIntegration` | `AppAnalyticsNavigationIntegration` | Integration helper connecting AppNavigation events to AppAnalytics reporting. |
| `./PackagesInUse/IntegrationHelpers/AppAnalyticsNetworkingIntegration` | `AppAnalyticsNetworkingIntegration` | Integration helper connecting AppNetworking events/failures to AppAnalytics reporting. |
| `./PackagesInUse/IntegrationHelpers/AppAnalyticsPushNotificationsIntegration` | `AppAnalyticsPushNotificationsIntegration` | Integration helper connecting AppPushNotifications events to AppAnalytics reporting. |
| `./PackagesInUse/IntegrationHelpers/CopyFiles` | — | Source-only copy-file helper snippets for integrating package resources into Xcode targets. |

## Maintenance Rule

If a package is added to or removed from `./PackagesInUse`, update this file, `./PackagesInUse/README.md`, and the Xcode logical `PackagesInUse/<PackageName>` group through `./scripts/migrate_packages_in_use_project.py`.
