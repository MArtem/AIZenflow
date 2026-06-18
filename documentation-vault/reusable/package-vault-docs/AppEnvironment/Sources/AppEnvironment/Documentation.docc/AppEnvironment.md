# ``AppEnvironment``

Create a privacy-aware runtime environment snapshot without coupling infrastructure code to a specific app.

## Overview

`AppEnvironment` provides a small set of app-independent primitives:

- ``EnvironmentKind`` for development/staging/production/custom classification;
- ``AppBuildInfo`` for selected allowlisted build metadata;
- ``AppRuntimeFlags`` for simulator, tests, UI tests and previews;
- ``AppLocaleContext`` for locale, time zone and calendar identifiers;
- ``AppEnvironmentSnapshot`` as the composed result.

The package intentionally does not select API base URLs, feature flags or product-specific behavior. Use app composition or optional integration helpers for that.

## Standalone contract

The package is designed to be copied as one folder and tested independently.

```bash
cd AppEnvironment
./Scripts/verify_package.sh
```

## Privacy

The default provider reads only allowlisted values. It does not expose full environment variables, command line arguments or bundle dictionaries.

## Synchronous launch usage

App entry points that cannot `await` during initialization can resolve runtime flags synchronously:

```swift
let flags = ProcessRuntimeFlagsProvider.makeRuntimeFlags()
```

Use this only for generic runtime flags. Product-specific launch switches remain app-owned.
