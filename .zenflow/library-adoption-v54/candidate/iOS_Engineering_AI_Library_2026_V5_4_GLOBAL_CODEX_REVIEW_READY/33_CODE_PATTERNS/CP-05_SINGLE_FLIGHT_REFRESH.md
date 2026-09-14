# CP-05 — Single-flight token refresh

Conceptual pattern: one actor owns refresh state and all callers await the same in-flight task.

```swift
actor AuthSession {
    private var refreshTask: Task<Token, Error>?

    func validToken() async throws -> Token {
        if let token, !token.isExpiringSoon { return token }
        if let refreshTask { return try await refreshTask.value }

        let task = Task { try await api.refresh(using: refreshToken) }
        refreshTask = task
        defer { refreshTask = nil }

        let newToken = try await task.value
        token = newToken
        return newToken
    }
}
```

Production code must also define logout-vs-refresh ordering, cancellation semantics, replay safety and secure persistence. Do not blindly replay non-idempotent requests.
