# Integration Helpers

## Summary

`./PackagesForReuse/IntegrationHelpers` contains reusable helper packages that compose two or more root packages while preserving root-package independence.

## What Problem It Solves

- Prevents root packages from importing each other just to support optional integrations.
- Keeps cross-package mapping reusable and auditable.
- Lets host apps opt into integrations only when both sides are intentionally adopted.

## What It Does

- Stores standalone SwiftPM helper packages.
- Documents helper ownership and dependency direction.
- Provides optional adapters for analytics, networking, navigation, push and localization composition.

## When To Use It

- both root packages are already adopted;
- the integration is generic rather than product-specific;
- the mapping would otherwise create a bad dependency direction in a root package.

## When Not To Use It

- the behavior is app-specific policy, UI routing, copy, privacy or DTO mapping;
- the helper only forwards calls without adding meaningful mapping;
- one direct host-app composition call is clearer.

## Ownership Boundary

Integration helpers own generic package-to-package mapping. Host apps own product enablement, redaction, consent, telemetry taxonomy, routing and user-visible behavior.

## Helpers

| Helper | Requires | Purpose |
| --- | --- | --- |
| `./AppAnalyticsNavigationIntegration` | `AppAnalytics`, `AppNavigation` | Maps navigation diagnostics into analytics events. |
| `./AppAnalyticsNetworkingIntegration` | `AppAnalytics`, `AppNetworking` | Maps networking metrics/failures into sanitized analytics events. |
| `./AppAnalyticsPushNotificationsIntegration` | `AppAnalytics`, `AppPushNotifications` | Maps push notification lifecycle events into analytics without titles/tokens. |
| `./AppErrorsNetworkingIntegration` | `AppErrors`, `AppNetworking` | Maps generic networking failures into app-error surfaces. |
| `./TchopProductLocalizationResourcesAppLocalizationIntegration` | `TchopProductLocalizationResources`, `AppLocalization` | Connects Tchop product resources to generic localization lookup. |

## Local SwiftPM Usage

Each helper can be consumed locally as a SwiftPM package:

```swift
.package(path: "../PackagesForReuse/IntegrationHelpers/AppAnalyticsNavigationIntegration")
```

Link only the helper product you need.

## Remote SwiftPM Usage

SwiftPM Git URL mode requires the helper folder to be published as the root of its own repository:

```swift
.package(url: "https://github.com/<org>/AppAnalyticsNavigationIntegration.git", from: "0.1.0")
```

Do not point SwiftPM at a nested helper folder inside a documentation/app repository.

## Verification

From a helper package folder, run:

```zsh
./Scripts/verify_package.sh
```

After copying a helper into a host app, run host-project verification.

## Documentation Maintenance

Every new helper must include:

- helper-level `README.md`;
- `PackageContract.md`;
- `REUSE.md`;
- package-local verification script where applicable;
- entries in `./PackagesForReuse/PACKAGE_CATALOG.md` and central documentation-vault package docs.
