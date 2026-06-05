# Integration Helpers Catalog

Root packages are intentionally 100% single-folder standalone. Cross-package composition is kept outside root packages. This catalog lists the optional integrations that were removed from root packages and preserved as host-app helpers.

## Helpers

| Helper | Required root packages | Why it is not inside a root package | Preferred use |
|---|---|---|---|
| `AppAnalyticsNavigationIntegration` | `AppAnalytics`, `AppNavigation` | Analytics must not depend on navigation and navigation must not depend on analytics. | Add when a host app wants to report navigation diagnostics. |
| `AppAnalyticsNetworkingIntegration` | `AppAnalytics`, `AppNetworking` | Analytics must not depend on networking and networking must not depend on analytics. | Add when a host app wants networking telemetry events. |
| `AppAnalyticsPushNotificationsIntegration` | `AppAnalytics`, `AppPushNotifications` | Push core must stay analytics-free. | Add when a host app wants push lifecycle analytics. |
| `AppErrorsNetworkingIntegration` | `AppErrors`, `AppNetworking` | Error semantics must stay networking-agnostic. | Add when a host app wants HTTP/network failures mapped to user-facing errors. |
| `TchopProductLocalizationResourcesAppLocalizationIntegration` | `TchopProductLocalizationResources`, `AppLocalization` | Product resources must not make the localization mechanism product-specific. | Add when Tchop product resources should back `AppLocalization.LocalizationManager`. |

## Delivery forms

Each helper is available in two forms:

1. **Copy file:** `IntegrationHelpers/CopyFiles/<Helper>.swift` for direct inclusion in a host app/integration target.
2. **Testable helper package:** `IntegrationHelpers/<Helper>/` for isolated helper tests and package-style integration.

## Privacy rules

Helpers must not emit raw sensitive values into telemetry. Forbidden patterns include raw `String(describing: error)`, HTTP bodies, HTTP headers, URL query/fragment, notification titles/body text, raw user IDs, tokens, and backend debug text.
