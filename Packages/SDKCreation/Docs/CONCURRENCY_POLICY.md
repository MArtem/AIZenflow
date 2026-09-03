# Concurrency Policy

## Target

All packages should be safe under Swift concurrency and designed for Swift 6 migration.

## Main rules

### Public async APIs

Prefer `async throws` for work that can suspend or fail:

```swift
public protocol SomeManaging: Sendable {
    func load(_ request: SomeRequest) async throws -> SomeResult
}
```

### MainActor

Use `@MainActor` only when the package truly owns UI-facing state or Apple API requires main-thread usage.

Do not mark low-level data/network/file/cache abstractions as `@MainActor` by default.

### Actors

Use actors for shared mutable state:

```swift
public actor InMemoryStore<Value: Sendable> { }
```

### Sendable

Public models used across async boundaries should conform to `Sendable` when possible. Do not use
or retain `@unchecked Sendable`, `nonisolated(unsafe)`, `@preconcurrency`, warning suppressions,
or blanket/fake `@MainActor` annotations as workarounds. Resolve diagnostics through actors,
global-actor ownership, immutable `Sendable` values, or correctly isolated APIs.

### Cancellation

Task cancellation is the primary cancellation mechanism.

Do not invent custom cancellation tokens unless the package bridges an imperative API that requires it.

### Clocks and sleepers

Time-dependent packages should use injected clocks/sleepers for tests:

```swift
public protocol Sleeper: Sendable {
    func sleep(for duration: Duration) async throws
}
```

## Verification

Each package should support a strict concurrency verification mode where possible:

```bash
swift test --build-path "$BUILD_DIR" -Xswiftc -strict-concurrency=complete
```

Apple-only packages may require macOS/Xcode-specific verification scripts.
