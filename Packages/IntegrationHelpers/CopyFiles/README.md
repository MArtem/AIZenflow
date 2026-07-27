# Integration Helper Copy Files

These files are optional host-app composition helpers for active helper packages connected to `TchopApp`. Use them when the required root packages are already present and you prefer to add one Swift file to an app/integration target instead of adding a helper Swift Package.

Active copy-file helpers:

- `AppAnalyticsNavigationIntegration.swift` → `../AppAnalyticsNavigationIntegration`
- `AppAnalyticsNetworkingIntegration.swift` → `../AppAnalyticsNetworkingIntegration`
- `AppAnalyticsPushNotificationsIntegration.swift` → `../AppAnalyticsPushNotificationsIntegration`

Vault-only copy-file helpers are preserved under `./PackagesForReuse/IntegrationHelpers/CopyFiles`.

Privacy rule: helpers must emit sanitized diagnostics only. Do not add raw error descriptions, HTTP bodies, headers, notification titles, notification body text, user IDs, tokens, or URL query/fragment values to telemetry.
