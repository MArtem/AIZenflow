# Integration Helper Copy Files

These files are optional host-app composition helpers. Use them when the required root packages are already present in your project and you prefer to add one Swift file to an app/integration target instead of adding a helper Swift Package.

Each file has a matching testable helper package one level up:

- `AppAnalyticsNavigationIntegration.swift` → `../AppAnalyticsNavigationIntegration`
- `AppAnalyticsNetworkingIntegration.swift` → `../AppAnalyticsNetworkingIntegration`
- `AppAnalyticsPushNotificationsIntegration.swift` → `../AppAnalyticsPushNotificationsIntegration`
- `AppErrorsNetworkingIntegration.swift` → `../AppErrorsNetworkingIntegration`
- `TchopProductLocalizationResourcesAppLocalizationIntegration.swift` → `../TchopProductLocalizationResourcesAppLocalizationIntegration`

Privacy rule: helpers must emit sanitized diagnostics only. Do not add raw error descriptions, HTTP bodies, headers, notification titles, notification body text, user IDs, tokens, or URL query/fragment values to telemetry.
