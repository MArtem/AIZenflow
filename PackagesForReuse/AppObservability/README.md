# AppObservability

`AppObservability` is a standalone Swift package for privacy-aware spans, breadcrumbs, measurements, and correlation propagation across iOS, macOS, tvOS, watchOS, visionOS, and SwiftPM test environments.

It is intentionally app-independent. The package does not know about screens, routes, user models, network payloads, analytics providers, crash SDKs, or product-specific telemetry policy.

## What belongs here

- `TraceID`, `SpanID`, `CorrelationID`
- `TraceContext` and `DiagnosticContext`
- `ObservabilityEvent` and `SpanStatus`
- `ObservabilityManaging` and `DefaultObservability`
- `ObservabilitySpan`
- `ObservabilityRedactor`
- `ObservabilityErrorDescriptor`
- no-op, memory, redacting, and multiplex recorders

## What must not belong here

- app-specific event names or feature taxonomy;
- networking/session/sync adapters;
- concrete Firebase/Sentry/OpenTelemetry SDK adapters;
- raw request/response bodies or headers;
- raw token/password/cookie/session values;
- raw URLs with query/fragment secrets;
- event/span/breadcrumb names containing user input, URLs, emails, tokens, or other high-cardinality sensitive values;
- sibling package imports.

## Runtime guidance

- `NoopObservabilityRecorder` is the safe default dependency.
- `MemoryObservabilityRecorder` is for tests and local diagnostics.
- `RedactingObservabilityRecorder` is useful at host boundaries where upstream data may still need sanitization.
- Correlation IDs are **caller-owned**. `DefaultObservability` reuses `diagnosticContext.correlationID` or `parent.correlationID` when provided and otherwise leaves `correlationID` unset.
- `ObservabilitySpan.end(...)` is single-shot and idempotent. Repeated end calls are ignored.
- `DefaultObservability.measure(...)` records `CancellationError` as `.cancelled` instead of a generic failure.

## Usage

```swift
import AppObservability

let recorder = MemoryObservabilityRecorder()
let observability = DefaultObservability(recorder: recorder)
let context = DiagnosticContext(
    correlationID: CorrelationID(rawValue: "corr-42"),
    attributes: ["screen": .string("home")]
)

let span = await observability.startSpan(
    "feed.load",
    attributes: [
        "source": .string("remote"),
        "url": .string("/feed?token=secret")
    ],
    diagnosticContext: context
)

await observability.addBreadcrumb("feed.refresh_tapped", diagnosticContext: context)
await span.end(status: .ok, attributes: ["items": .integer(20)])
```

## Privacy

The default redactor:

- masks explicit private/sensitive attributes;
- masks common sensitive keys such as `token`, `access_token`, `refresh_token`, `authorization`, `password`, `cookie`, `email`, and `phone`;
- removes query and fragment data from absolute URLs, relative paths, and scheme-less URL strings.

Examples:

```swift
.string("https://example.com/feed?token=secret#frag")
// -> https://example.com/feed

.string("/feed?token=secret#frag")
// -> /feed

.string("feed?token=secret#frag")
// -> feed

.string("//example.com/path?token=secret")
// -> //example.com/path
```

## Cancellation behavior

When `measure` throws `CancellationError`, the package records a measurement with `.cancelled` status and rethrows the cancellation.

Errors conforming to `ObservabilityErrorDescribing` are recorded as structured failure descriptors. Unknown errors fall back to `.operationFailed` without exposing raw error text.

## Standalone contract

`AppObservability` has no sibling package dependencies and can be copied as a single folder into another project.

```bash
cd AppObservability
swift test
swift test -Xswiftc -strict-concurrency=complete
./Scripts/verify_package.sh
```

## Integration

Cross-package integration must live outside this root package, for example:

- `AppObservabilityNetworkingIntegration`
- `AppObservabilityLoggingIntegration`
- `AppObservabilityCrashReportingIntegration`
- `AppObservabilityAnalyticsIntegration`
