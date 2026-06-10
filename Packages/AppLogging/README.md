# AppLogging

`AppLogging` is a standalone Swift Package that provides privacy-aware structured logging primitives for iOS, macOS, tvOS, watchOS, visionOS, and SwiftPM-compatible test environments.

The package is intentionally app-independent. It does not know about screens, features, routes, networking, analytics, crash reporting, or product-specific log domains.

## What belongs here

- `LogLevel`
- `LogEvent`
- `LogMetadata`
- `LogMetadataValue`
- `LogPrivacy`
- `LogRedactor`
- `AppLogging` protocol
- `NoopLogger`
- `MemoryLogger`
- `ConsoleLogger`
- `MultiplexLogger`
- `RedactingLogger`
- Apple `OSLogAppLogger` adapter behind `canImport(os)`

## What must not belong here

- app-specific event names;
- user/profile/news/order-specific fields;
- networking request/response models;
- analytics adapters;
- crash reporting SDK adapters;
- raw server error bodies;
- raw token/password/cookie/session values;
- sibling package imports.

## Runtime guidance

- Use `NoopLogger` as the default dependency when a feature should not emit logs.
- Use `MemoryLogger` for tests and local diagnostics; do not treat it as a production log export store unless the host app first applies an explicit redaction/export policy.
- Use `RedactingLogger` or `OSLogAppLogger` at app boundaries where events may contain host-app metadata.
- Public messages are rendered as provided except for explicit `LogRedactor.stringMasks`; mark sensitive messages `.private` or `.sensitive`.

## Usage

```swift
import AppLogging

let logger = ConsoleLogger(minimumLevel: .debug)

await logger.info(
    "Loaded cache snapshot",
    subsystem: "storage",
    category: "cache",
    metadata: LogMetadata([
        "key": .string("home-feed"),
        "duration_ms": .integer(14)
    ])
)
```

## Privacy

Metadata can be explicitly marked private:

```swift
let metadata = LogMetadata([
    "email": .string("person@example.com", privacy: .private),
    "access_token": .string("secret-token")
])
```

`LogRedactor.default` redacts known sensitive keys such as `token`, `access_token`, `refresh_token`, `authorization`, `password`, `secret`, `cookie`, `session`, and `api_key`.

URLs are rendered without query and fragment by default:

```swift
.url("https://example.com/path?token=secret#fragment")
// -> https://example.com/path
```

## Standalone contract

`AppLogging` has no sibling dependencies and can be copied as a single folder into another project.

```bash
cd AppLogging
swift test
swift test -Xswiftc -strict-concurrency=complete
```

Or use:

```bash
./Scripts/verify_package.sh
```

## Integration

Cross-package integration must live outside this root package, for example:

- `AppLoggingNetworkingIntegration`
- `AppLoggingAnalyticsIntegration`
- `AppLoggingCrashReportingIntegration`
- `AppLoggingObservabilityIntegration`

Those helpers may import multiple packages, but this root package must remain standalone.
