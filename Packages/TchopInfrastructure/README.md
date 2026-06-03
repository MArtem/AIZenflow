# TchopInfrastructure

`TchopInfrastructure` is the package-owned infrastructure workspace for reusable iOS building blocks used by the app. Every reusable package target must be portable with its matching tests so a future project can copy the package and immediately verify the copied implementation.

## Package ownership rule

- **Mechanisms live in package targets**: networking, cache, localization, error normalization, navigation helpers, sync primitives, app-group stores, widget snapshot stores, UI-configuration loading, and platform adapters.
- **App/product policy lives in app targets**: feed/headline payloads, shell configuration payloads, feature-specific analytics semantics, app-specific localization copy, concrete widget kinds, and product UI decisions.
- **Tests live beside the package**: package behavior is covered under `./Tests/<TargetName>Tests/`; app tests may verify integration, but they must not be the only protection for package behavior.
- **No hidden umbrella coupling**: umbrella targets may re-export only directly related targets. Database packages must not implicitly export navigation, sync, analytics, or UI packages. Compatibility umbrellas such as `TchopAnalytics` and `TchopErrors` must also expose standalone core/adapter targets so future projects can import only the mechanisms they need.

## Current target map

- **Core/data**: `SyncCore`, `SyncObservation`, `TchopDatabaseCore`, `TchopCoreDataDatabase`, `TchopSwiftDataDatabase`, `TchopDatabaseComposition`, `TchopDatabase`.
- **Networking/runtime**: `TchopNetworking`, `TchopNetworkTesting`, `TchopCache`.
- **Error handling**: `TchopErrorsCore`, `TchopNetworkingErrorAdapter`, `TchopErrors` umbrella.
- **Analytics**: `TchopAnalyticsCore`, `TchopNavigationAnalytics`, `TchopNetworkingAnalytics`, `TchopPushNotificationAnalytics`, `TchopAnalytics` umbrella.
- **Platform support**: `TchopAppleAuthentication`, `TchopPushNotifications`, `TchopShareSupport`, `TchopWidgets`.
- **UI support**: `TchopBranding`, `TchopLocalization`, `TchopNavigation`, `TchopUIConfiguration`, `TchopOnDeviceAI`.

## Verification

Run package verification from this directory:

```zsh
swift test
```

When package public contracts change, also run the app-level integration build from the repository root:

```zsh
./scripts/verify.sh low
```

## Reusable-package quality bar

Package code is always reviewed as production infrastructure, not as demo/sample support. A package is not considered portable until these conditions are true:

1. The package exposes a neutral mechanism contract and does not encode a specific app feature as reusable infrastructure.
2. The target's behavior has package-level tests that can travel with the package into another project.
3. Public contracts document ownership, threading/concurrency expectations, failure behavior, and app-vs-package responsibility.
4. `@unchecked Sendable` is either removed or locally justified with the concrete synchronization primitive that protects mutable state.
5. Default URLs, fixture names, and placeholder values are neutral and do not carry source-app branding.
6. Large targets should be split into focused source files by responsibility even when they remain one product for API compatibility.
