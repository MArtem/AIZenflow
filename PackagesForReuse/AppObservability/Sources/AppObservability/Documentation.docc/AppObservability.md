# ``AppObservability``

Privacy-aware, app-independent observability primitives for spans, breadcrumbs, measurements, and correlation propagation.

## Overview

`AppObservability` provides a standalone runtime observability surface without taking ownership of product-specific telemetry policy.

Use it when you need:

- Traces and spans.
- Breadcrumb events.
- Async operation measurements.
- Structured error descriptors instead of raw error text.
- Privacy-aware attribute redaction.
- Caller-owned correlation propagation.

## Topics

### Core Types

- ``DefaultObservability``
- ``ObservabilityManaging``
- ``ObservabilitySpan``
- ``ObservabilityEvent``
- ``ObservabilityEventKind``
- ``SpanStatus``

### Propagation

- ``TraceContext``
- ``DiagnosticContext``
- ``TraceID``
- ``SpanID``
- ``CorrelationID``

### Privacy and Errors

- ``ObservabilityAttribute``
- ``ObservabilityAttributes``
- ``ObservabilityValue``
- ``ObservabilityPrivacy``
- ``ObservabilityRedactor``
- ``ObservabilityErrorDescriptor``
- ``ObservabilityErrorCategory``
- ``ObservabilityErrorDescribing``

### Recorders and Runtime Helpers

- ``ObservabilityRecording``
- ``NoopObservabilityRecorder``
- ``MemoryObservabilityRecorder``
- ``RedactingObservabilityRecorder``
- ``MultiplexObservabilityRecorder``
- ``ObservabilityClock``
- ``SystemObservabilityClock``
- ``ObservabilityIDGenerating``
- ``UUIDObservabilityIDGenerator``

## Privacy and lifecycle notes

`ObservabilityRedactor` strips query and fragment data from absolute URLs, relative paths, and scheme-less URL strings such as `/feed?token=secret`, `feed?token=secret`, and `//example.com/path?token=secret`. Event, span, and breadcrumb names are intentionally treated as stable taxonomy keys; do not build names from user input, raw URLs, emails, tokens, or high-cardinality identifiers.

`DefaultObservability.measure` records `CancellationError` as ``SpanStatus/cancelled`` instead of converting cancellation into a generic failure.

`ObservabilitySpan.end(status:attributes:)` is single-shot. Repeated calls are ignored so hosts can safely end spans from multiple cleanup paths.

Correlation IDs remain caller-owned. `AppObservability` only propagates a correlation ID when callers provide one in ``DiagnosticContext`` or ``TraceContext``.
