# Packages

This folder now contains two package layers:

1. **Compatibility baseline**: `./Packages/TchopInfrastructure` remains as the historical/source compatibility bundle.
2. **Standalone packages**: `./Packages/App*` folders and `./Packages/TchopProductLocalizationResources` are the active package units used by the app project. Each folder owns its own manifest, README, source, DocC docs, tests, and local SwiftPM verification.

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

Repository verification should prefer the centralized helper:

```bash
./Packages/verify_standalone_packages.sh
```

The helper passes SwiftPM a root-level `--build-path` under `./.build/standalone-packages/` so package folders stay clean and portable. Local `./Packages/*/.build` folders are disposable artifacts and should not be committed.

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

Do not delete `./Packages/TchopInfrastructure` until its compatibility role has been explicitly retired. The app project currently resolves active package products from the standalone package folders.
