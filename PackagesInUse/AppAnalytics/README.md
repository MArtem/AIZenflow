# AppAnalytics

`AppAnalytics` is a 100% single-folder standalone Swift package. You can copy this folder into a new project, open it as a Swift Package, and run its tests without copying any sibling packages from this repository.

## Ownership

- **Package owns**: generic analytics primitives, typed analytics values, event contracts, in-memory/no-op collectors, documentation, and package-owned tests.
- **App/integration layer owns**: concrete provider SDK adapters, cross-package event mappers, product analytics taxonomy, upload policy, sampling, privacy policy, and user-consent decisions.

## Products

- `AppAnalyticsCore`
- `AppAnalytics`

## Structure

```text
AppAnalytics/
  Package.swift
  README.md
  Sources/
  Tests/
```

The package is self-contained and keeps its tests beside its source.

## Verification

Run from this folder:

```bash
swift test
```

## Portability

Required sibling packages: **None**

Copy modes:
- **Standalone copy mode:** supported.
- **Local path dependency mode:** not required.
- **Git URL dependency mode:** supported as a normal independent package.
- **Bundle copy mode:** supported, but not required.

## Cross-package integrations

Navigation/networking/push analytics adapters intentionally do **not** live inside this package anymore. They are optional host-level composition files under:

```text
../IntegrationHelpers/
  AppAnalyticsNavigationIntegration.swift
  AppAnalyticsNetworkingIntegration.swift
  AppAnalyticsPushNotificationsIntegration.swift
```

Copy only the helpers you need into the app/integration target after adding the corresponding root packages.


## Usage guide

See `./USAGE.md` for package/app boundary rules and host integration guidance.
