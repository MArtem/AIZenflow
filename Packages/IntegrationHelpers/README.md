# Integration Helpers

Root packages under `./Packages` are standalone. Cross-package composition lives here only when a helper is actively connected to `TchopApp`. Vault-only helpers live under `./PackagesForReuse/IntegrationHelpers`.

## Active helper packages

| Helper package | Requires | Purpose |
|---|---|---|
| `AppAnalyticsNavigationIntegration` | `AppAnalytics`, `AppNavigation` | Maps navigation diagnostics into sanitized analytics events. |
| `AppAnalyticsNetworkingIntegration` | `AppAnalytics`, `AppNetworking` | Maps networking metrics into sanitized analytics events. |
| `AppAnalyticsPushNotificationsIntegration` | `AppAnalytics`, `AppPushNotifications` | Maps push notification lifecycle events into analytics without titles/tokens. |

## Vault-only helpers

The following helpers are preserved in `./PackagesForReuse/IntegrationHelpers` and are not connected to this app now:

- `AppErrorsNetworkingIntegration`
- `TchopProductLocalizationResourcesAppLocalizationIntegration`

Copy a vault-only helper back only when the app has a concrete current integration need.

## Verification

```bash
./Packages/verify_integration_helpers.sh
```

## Privacy rule

Helpers must not emit raw error descriptions, HTTP bodies, authorization headers, notification titles, URL query strings, or URL fragments into telemetry.
