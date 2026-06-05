# Integration Helpers

Root packages under `Packages/` are 100% single-folder standalone. Cross-package composition lives here as optional helper packages.

Each helper is its own small Swift Package with sources, tests, README, and explicit local-path dependencies on the root packages it composes. You can either copy a single helper source file into your app target or add the corresponding helper package when the required root packages are already available.

## Helper packages

| Helper package | Requires | Purpose |
|---|---|---|
| `AppAnalyticsNavigationIntegration` | `AppAnalytics`, `AppNavigation` | Maps navigation diagnostics into sanitized analytics events. |
| `AppAnalyticsNetworkingIntegration` | `AppAnalytics`, `AppNetworking` | Maps networking metrics into sanitized analytics events. |
| `AppAnalyticsPushNotificationsIntegration` | `AppAnalytics`, `AppPushNotifications` | Maps push notification lifecycle events into analytics without titles/tokens. |
| `AppErrorsNetworkingIntegration` | `AppErrors`, `AppNetworking` | Maps networking failures into app-facing error semantics. |
| `TchopProductLocalizationResourcesAppLocalizationIntegration` | `TchopProductLocalizationResources`, `AppLocalization` | Creates an `AppLocalization.LocalizationManager` backed by product string resources. |

## Verification

Portable helpers can be tested on Linux/macOS. Apple-only helpers, such as `AppAnalyticsNavigationIntegration`, should be verified on macOS/Xcode if the composed package requires Apple frameworks.

```bash
./Packages/verify_integration_helpers.sh
```

## Privacy rule

Helpers must not emit raw error descriptions, HTTP bodies, authorization headers, notification titles, URL query strings, or URL fragments into telemetry.

## Copy-file helpers

For the host-app integration style you originally requested, every helper is also available as a standalone Swift source file:

```text
IntegrationHelpers/CopyFiles/
  AppAnalyticsNavigationIntegration.swift
  AppAnalyticsNetworkingIntegration.swift
  AppAnalyticsPushNotificationsIntegration.swift
  AppErrorsNetworkingIntegration.swift
  TchopProductLocalizationResourcesAppLocalizationIntegration.swift
```

Use copy-file mode when the root packages are already added to the app and you want the adapter to live in the app/integration target instead of adding one more Swift Package.

`verify_integration_helpers.sh` checks that every copy-file helper is byte-equivalent to the package source version, so the two delivery forms do not drift.
