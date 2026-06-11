# AppObservability Package Contract

## Purpose

Provide app-independent, privacy-aware observability primitives for spans, breadcrumbs, operation measurements, propagation state, and structured failure descriptors.

## Public API groups

- trace/span/correlation identifiers;
- trace propagation and diagnostic context;
- observability attributes and privacy classification;
- observability events and span statuses;
- observability manager and span lifecycle;
- recorders and redacting wrappers;
- clock and ID-generation helpers.

## Runtime policy

- `NoopObservabilityRecorder` is the safe default dependency.
- `MemoryObservabilityRecorder` is for tests and local diagnostics.
- Correlation IDs are caller-owned; the package propagates only values explicitly supplied through `DiagnosticContext` or `TraceContext`.
- `ObservabilitySpan.end(...)` is single-shot. Hosts may call it from multiple cleanup paths without emitting duplicate `spanEnded` events.
- `DefaultObservability.measure(...)` must record `CancellationError` as `.cancelled` and must not degrade cancellation into `operation_failed`.
- Unknown failures must not expose raw error text.

## Non-goals

`AppObservability` is not:

- analytics;
- crash reporting;
- network instrumentation;
- session management;
- sync policy;
- remote exporter SDK integration;
- product-specific telemetry taxonomy.

## Dependency rules

This package must not depend on sibling packages. Forbidden examples:

```swift
import AppNetworking
import AppAnalytics
import AppErrors
import AppLogging
```

Any bridge to networking, logging, analytics, sync, crash reporting, or remote telemetry SDKs must live in optional integration helpers.

## Privacy rules

The package must never encourage raw sensitive telemetry.

Forbidden by default:

- access tokens;
- refresh tokens;
- Authorization headers;
- cookies;
- passwords;
- raw emails and phone numbers;
- raw URLs with query/fragment;
- raw request/response bodies;
- raw error strings;
- event/span/breadcrumb names built from user input, URLs, emails, tokens, IDs, or other sensitive/high-cardinality values.

`ObservabilityRedactor` must sanitize URL-like strings for:

- absolute URLs;
- relative paths such as `/feed?token=secret`;
- scheme-less URLs such as `//example.com/path?token=secret`;
- single-segment relative routes such as `feed?token=secret`.

## Concurrency rules

- Public API values must remain `Sendable` where practical.
- Recording contracts are async and `Sendable`.
- `MemoryObservabilityRecorder` is actor-isolated.
- Span end-state must remain concurrency-safe and single-shot.
- No `unsafeFlags` in `Package.swift`.
- Strict concurrency is verified by script and must pass without warnings.

## Testing requirements

The package must cover:

- span start recording;
- span end duration/status;
- parent trace propagation;
- caller-owned correlation behavior;
- breadcrumb recording;
- measurement success and failure;
- `CancellationError` mapping to `.cancelled`;
- redaction by sensitive key;
- relative/scheme-less URL query/fragment removal;
- redacting recorder forwarding;
- multiplex forwarding;
- double span-end idempotency;
- strict concurrency verification.

## Iteration Standards Hardening

This package follows the hardened single-folder standalone rules:

- DocC is source-owned: `Sources/AppObservability/Documentation.docc/`.
- Verification uses an external SwiftPM scratch path and must not create `.build` or `.swiftpm` inside the package folder.
- The package has no sibling path dependencies and no imports of sibling SDK modules.
- Multi-target package layouts are allowed only when every target, test, fixture, script, and documentation file remains inside this package folder.
- Swift source and package metadata must not contain unresolved template placeholders.
