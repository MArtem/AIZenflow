# Integration Helpers Catalog

Root packages are intentionally standalone. Cross-package composition is kept outside root packages.

## Active helpers in `./Packages`

| Helper | Required root packages | Preferred use |
|---|---|---|
| `AppAnalyticsNavigationIntegration` | `AppAnalytics`, `AppNavigation` | Add when a host app wants to report navigation diagnostics. |
| `AppAnalyticsNetworkingIntegration` | `AppAnalytics`, `AppNetworking` | Add when a host app wants networking telemetry events. |
| `AppAnalyticsPushNotificationsIntegration` | `AppAnalytics`, `AppPushNotifications` | Add when a host app wants push lifecycle analytics. |

## Vault-only helpers in `./PackagesForReuse`

| Helper | Required root packages | Why it is vault-only now |
|---|---|---|
| `AppErrorsNetworkingIntegration` | `AppErrors`, `AppNetworking` | Current app error/network integration does not use this helper package directly. |
| `TchopProductLocalizationResourcesAppLocalizationIntegration` | `TchopProductLocalizationResources`, `AppLocalization` | Current app has direct product-resource localization wiring. |

## Delivery forms

Active helpers keep both package form and copy-file form under `./Packages/IntegrationHelpers`. Vault-only helpers keep both forms under `./PackagesForReuse/IntegrationHelpers`.

## Privacy rules

Helpers must not emit raw sensitive values into telemetry. Forbidden patterns include raw `String(describing: error)`, HTTP bodies, HTTP headers, URL query/fragment, notification titles/body text, raw user IDs, tokens, and backend debug text.
