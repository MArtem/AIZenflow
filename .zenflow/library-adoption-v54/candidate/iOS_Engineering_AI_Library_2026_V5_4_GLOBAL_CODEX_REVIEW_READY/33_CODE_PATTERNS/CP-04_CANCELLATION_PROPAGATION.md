# CP-04 — Cooperative cancellation

```swift
func load() async throws -> Model {
    let (data, response) = try await session.data(for: request)
    try Task.checkCancellation()
    let payload = try decoder.decode(Payload.self, from: data)
    try Task.checkCancellation()
    return map(payload, response: response)
}
```

For CPU loops, check cancellation at meaningful intervals. Do not turn `CancellationError` into a retry or user-facing failure unless product semantics explicitly require it.
