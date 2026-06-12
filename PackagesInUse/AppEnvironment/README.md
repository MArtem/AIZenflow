# AppEnvironment

`AppEnvironment` is a single-folder standalone Swift package for app-independent runtime environment snapshots.

It answers generic infrastructure questions such as:

- which deployment environment is active: development, staging, production or custom;
- what selected build identity is available: bundle identifier, app version, build number, build configuration;
- whether the app is running in tests, UI tests, previews or simulator;
- what locale, time zone and calendar identifiers are active.

The package does not know product features, screens, routes, API clients, analytics domains, user sessions or brand-specific values.

## Installation / copy mode

Copy the `AppEnvironment/` folder into any repository and open it as a Swift Package.

```bash
cd AppEnvironment
./Scripts/verify_package.sh
```

The package has no `.package(...)` dependencies and no sibling imports.

## Basic usage

```swift
let provider = DefaultAppEnvironmentProvider(
    environmentVariableName: "APP_ENVIRONMENT"
)

let snapshot = await provider.snapshot()

if snapshot.kind == .staging {
    // configure app composition root for staging
}
```

## Test usage

```swift
let provider = StaticEnvironmentProvider(
    AppEnvironmentSnapshot(
        kind: .development,
        buildInfo: AppBuildInfo(version: "1.0", buildNumber: "1"),
        runtimeFlags: AppRuntimeFlags(isDebugBuild: true, isSimulator: true),
        localeContext: AppLocaleContext(
            localeIdentifier: "en_US",
            languageCode: "en",
            regionCode: "US",
            timeZoneIdentifier: "UTC",
            calendarIdentifier: "gregorian"
        )
    )
)
```

## Privacy stance

`AppEnvironment` reads only allowlisted metadata. It does not expose the full process environment, full bundle info dictionary, command line arguments, secrets, tokens or backend URLs.

Diagnostic descriptions intentionally avoid dumping process names, full environment dictionaries or arbitrary runtime values.

## What belongs here

- Environment kind parsing.
- Build/version metadata allowlist.
- Runtime flags for tests/previews/simulator.
- Locale/time-zone/calendar context as primitive `Sendable` values.
- Static providers for tests and previews.

## What does not belong here

- API base URL selection.
- Feature flags.
- Session state.
- Secure storage.
- Product-specific environment names.
- Analytics/logging integrations.
- Remote configuration fetching.

Those integrations belong in app composition code or optional `IntegrationHelpers`.

## Synchronous launch usage

App entry points that cannot `await` during initialization can resolve runtime flags synchronously:

```swift
let flags = ProcessRuntimeFlagsProvider.makeRuntimeFlags()
```

Use this only for generic runtime flags. Product-specific launch switches remain app-owned.
