# CP-01 — Actor-owned mutable state

Use when mutable state is shared across concurrent callers. The actor owns the invariant; callers exchange `Sendable` values.

## Avoid
```swift
final class TokenCache {
    var token: String?
}
```
A reference being "usually called from one queue" is not an isolation contract.

## Prefer
```swift
actor TokenCache {
    private var token: String?

    func value() -> String? { token }

    func store(_ token: String?) {
        self.token = token
    }
}
```

## Review questions
- Is the actor protecting an actual invariant, or merely wrapping every method?
- Are non-Sendable references escaping the actor?
- Does any method keep an invariant half-updated across `await`?
