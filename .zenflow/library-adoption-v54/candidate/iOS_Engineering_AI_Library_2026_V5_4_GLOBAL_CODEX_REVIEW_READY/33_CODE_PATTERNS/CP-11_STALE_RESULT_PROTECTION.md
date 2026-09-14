# CP-11 — Protect UI from stale async results

```swift
@MainActor
final class SearchModel {
    private var requestID: UUID?

    func load(_ query: String) async {
        let id = UUID()
        requestID = id
        state = .loading

        do {
            let value = try await service.search(query)
            guard requestID == id else { return }
            state = value.isEmpty ? .empty : .content(value)
        } catch is CancellationError {
            // Preserve newer state.
        } catch {
            guard requestID == id else { return }
            state = .error(map(error))
        }
    }
}
```

Cancellation alone may be insufficient if the underlying operation cannot cancel promptly; operation identity is an additional stale-write guard.
