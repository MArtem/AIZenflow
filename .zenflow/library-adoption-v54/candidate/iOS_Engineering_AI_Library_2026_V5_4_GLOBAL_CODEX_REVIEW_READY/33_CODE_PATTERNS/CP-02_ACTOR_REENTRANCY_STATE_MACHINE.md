# CP-02 — Actor reentrancy-safe transition

## Fragile
```swift
actor Session {
    private var state: State = .idle

    func connect() async throws {
        state = .connecting
        try await transport.connect()
        state = .connected // another call may have changed state while suspended
    }
}
```

## Safer pattern
Capture an operation identity and validate it after suspension.
```swift
actor Session {
    enum State { case idle, connecting(UUID), connected }
    private var state: State = .idle

    func connect() async throws {
        let id = UUID()
        state = .connecting(id)

        do {
            try await transport.connect()
            guard case .connecting(id) = state else { return }
            state = .connected
        } catch {
            guard case .connecting(id) = state else { throw error }
            state = .idle
            throw error
        }
    }
}
```

The exact state model should be project-specific; the key is to revalidate invariants after every suspension point.
