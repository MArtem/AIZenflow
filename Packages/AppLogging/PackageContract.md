# AppLogging Package Contract

## Purpose

Provide app-independent, privacy-aware, structured logging primitives.

## Public API groups

- Log levels
- Log events
- Log metadata values
- Privacy classification
- Redaction policy
- Logger protocol
- No-op logger
- In-memory logger for tests
- Console logger
- Multiplex logger
- Redacting wrapper
- Apple OSLog adapter where available

## Runtime policy

- `NoopLogger` is the safe default dependency.
- `MemoryLogger` is for tests and local diagnostics; production export of in-memory events requires a host-app redaction/export policy.
- `ConsoleLogger` and `OSLogAppLogger` must format events through a redactor before emission.
- Public messages are not magically classified; host apps must mark sensitive messages private/sensitive or provide explicit string masks.

## Non-goals

`AppLogging` is not:

- analytics;
- crash reporting;
- observability/tracing;
- networking instrumentation;
- app diagnostics export;
- remote telemetry transport;
- product-specific logging schema.

## Dependency rules

This package must not depend on sibling packages. Forbidden examples:

```swift
import AppNetworking
import AppAnalytics
import AppErrors
import AppSession
import AppObservability
```

Any bridge from another subsystem to logging must live in optional integration helpers.

## Privacy rules

The package must never encourage raw sensitive telemetry.

Forbidden by default:

- access tokens;
- refresh tokens;
- Authorization headers;
- cookies;
- passwords;
- raw URLs with query/fragment;
- raw server response bodies;
- raw user identifiers unless explicitly marked public by host app.

## Concurrency rules

- Public values must be `Sendable` where practical.
- Logger contracts are async and `Sendable`.
- In-memory logger is actor-isolated.
- No `unsafeFlags` in `Package.swift`.
- Strict concurrency is verified by script.

## Testing requirements

The package must cover:

- level ordering;
- metadata merging;
- codable roundtrips;
- redaction by sensitive key;
- explicit private metadata;
- URL query/fragment removal;
- console formatting;
- in-memory logging;
- multiplex forwarding;
- strict concurrency.


## Iteration Standards Hardening

This package follows the hardened single-folder standalone rules:

- DocC is source-owned: `Sources/AppLogging/Documentation.docc/`.
- Verification uses an external SwiftPM scratch path and must not create `.build` or `.swiftpm` inside the package folder.
- The package has no sibling path dependencies and no imports of sibling SDK modules.
- Multi-target package layouts are allowed only when every target, test, fixture, script, and documentation file remains inside this package folder.
- Swift source and package metadata must not contain unresolved template placeholders.
