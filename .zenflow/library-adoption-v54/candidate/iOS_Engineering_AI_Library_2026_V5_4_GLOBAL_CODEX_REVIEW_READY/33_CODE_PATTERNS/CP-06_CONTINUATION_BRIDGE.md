# CP-06 — Checked continuation bridge

Use only when no native async API exists.

```swift
func value() async throws -> Value {
    try await withCheckedThrowingContinuation { continuation in
        legacy.load { result in
            continuation.resume(with: result)
        }
    }
}
```

Before using this minimal pattern, prove the callback fires exactly once on every path. If the legacy API can call twice, never call, or needs cancellation, build an explicit state/locking adapter rather than assuming checked continuation solves it.
