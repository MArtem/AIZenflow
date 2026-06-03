# Packages

This folder now contains two package layers:

1. **Compatibility baseline**: `./Packages/TchopInfrastructure` remains the app-connected package bundle used by the current Xcode project.
2. **Standalone neutral packages**: `./Packages/App*` folders are portable package units. Each folder owns its own manifest, README, source, DocC docs, tests, and local SwiftPM verification.

## Standalone Package Contract

Every standalone package must be copyable as one folder into another project:

```text
PackageName/
  Package.swift
  README.md
  Sources/
  Tests/
```

Package-owned tests must live under the same package folder and must pass with:

```bash
cd PackageName
swift test
```

## Current Standalone Packages

- `./Packages/AppAnalytics`
- `./Packages/AppAppleAuthentication`
- `./Packages/AppBranding`
- `./Packages/AppCache`
- `./Packages/AppConfiguration`
- `./Packages/AppDatabase`
- `./Packages/AppErrors`
- `./Packages/AppLocalization`
- `./Packages/AppNavigation`
- `./Packages/AppNetworking`
- `./Packages/AppOnDeviceAI`
- `./Packages/AppPushNotifications`
- `./Packages/AppShareExtensionSupport`
- `./Packages/AppSync`
- `./Packages/AppWidgetSupport`
- `./Packages/TchopProductLocalizationResources`

`./Packages/TchopProductLocalizationResources` is intentionally product-specific and should move with TchopApp only. It is standalone, but not reusable generic infrastructure.

## Migration Rule

Do not delete or rewire `./Packages/TchopInfrastructure` until the app has been switched package-by-package and each switch has passed app build verification.
