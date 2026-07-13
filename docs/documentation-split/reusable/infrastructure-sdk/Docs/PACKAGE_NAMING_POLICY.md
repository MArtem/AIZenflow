# Package Naming Policy

## Prefix

Use `App` prefix for generic infrastructure packages in this SDK:

```text
AppSecureStorage
AppSession
AppFeatureFlags
AppLogging
```

This is a neutral app-infrastructure namespace, not a product namespace.

## Avoid product names

Avoid:

```text
source-appNews
source-appProfile
FeedCardManager
ProfileRouter
```

inside reusable root packages.

Product-specific packages must be clearly marked:

```text
source-appProductLocalizationResources
```

## Type names

Prefer domain-generic names:

```swift
SecureStorageManager
FeatureFlagManaging
AnalyticsEvent
LogEvent
PermissionState
```

Avoid app-specific names:

```swift
NewsAnalyticsEvent
ProfileFeatureFlag
source-appUserSession
```

## Integration helpers

Use explicit names:

```text
AppAnalyticsNetworkingIntegration
AppErrorsNetworkingIntegration
```
