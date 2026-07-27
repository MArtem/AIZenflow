# AppLogging

A standalone structured logging package for reusable iOS infrastructure.

## Overview

`AppLogging` defines a small, privacy-aware logging surface that can be used by apps or optional integration helpers. It intentionally avoids dependencies on networking, analytics, crash reporting, observability, navigation, or any product-specific domain.

## Core idea

Use structured events rather than raw strings:

```swift
let event = LogEvent(
    level: .warning,
    subsystem: "sync",
    category: "retry",
    message: "Retry scheduled",
    metadata: LogMetadata([
        "attempt": .integer(2),
        "url": .url("https://api.example.com/items?token=secret")
    ])
)
```

The URL is rendered without query and fragment by default.

## Privacy model

`LogPrivacy` allows metadata values to be public, private, or sensitive with a custom mask.

`LogRedactor` also redacts common sensitive keys automatically.

Public messages are rendered as public unless the host app marks them private/sensitive or configures string masks. Use private message privacy for token-bearing or user-entered text.

## Logger implementations

- `NoopLogger`
- `MemoryLogger`
- `ConsoleLogger`
- `MultiplexLogger`
- `RedactingLogger`
- `OSLogAppLogger` on Apple platforms with `os` support

## Integration model

Root packages must not import `AppLogging` unless they intentionally depend on it. For this SDK baseline, cross-package connections should generally be implemented as optional helpers outside root packages.
