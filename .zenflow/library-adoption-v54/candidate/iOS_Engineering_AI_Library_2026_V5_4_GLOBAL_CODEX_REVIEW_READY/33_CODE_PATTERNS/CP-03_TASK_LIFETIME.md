# CP-03 — Owner-bounded unstructured task lifetime

Use this pattern when unstructured work must stop being able to update the owner after the owner disappears or a newer request replaces it. The key point is **not** to promote `weak self` to a strong `self` before a long suspension.

```swift
@MainActor
final class SearchModel {
    private let service: SearchService
    private var searchTask: Task<Void, Never>?
    private var generation: UInt64 = 0

    init(service: SearchService) {
        self.service = service
    }

    func search(query: String) {
        searchTask?.cancel()
        generation &+= 1

        let requestGeneration = generation
        let service = service // Capture the dependency, not the owner, across await.

        searchTask = Task { [weak self, service, requestGeneration] in
            do {
                let result = try await service.search(query)
                try Task.checkCancellation()

                guard let self, self.generation == requestGeneration else { return }
                self.apply(result)
            } catch is CancellationError {
                // Expected control flow for replacement/lifecycle cancellation.
            } catch {
                // A dependency may fail with a non-CancellationError after cancellation.
                guard !Task.isCancelled,
                      let self,
                      self.generation == requestGeneration else { return }
                self.show(error)
            }
        }
    }

    deinit {
        searchTask?.cancel()
    }
}
```

## Semantics and constraints

- `service` is captured independently so the task does not keep `SearchModel` alive across `await`. This assumes `service` itself does not strongly retain the owner; if it does, fix that ownership contract separately.
- Cancellation is cooperative. `cancel()` only marks the task cancelled and propagates cancellation; the awaited operation may still run until it observes cancellation. Therefore the task checks cancellation after suspension.
- The generation check rejects stale success and stale generic failure from an older replaced request even if the dependency ignores cancellation.
- `deinit` cancellation is useful only because the task closure does not itself strongly retain the owner through the suspension.
- `@MainActor` makes the generation/state checks and UI-facing updates serialized on the owner actor. If the owner is not main-actor isolated, use the appropriate actor/serialization boundary.
- This is a conceptual pattern for ownership, not a guarantee that the underlying network/database operation is physically stopped immediately. If the operation must outlive the owner deliberately, model that lifetime separately instead of storing it as owner-bounded work.

Primary references (checked 2026-09-11):
- Apple `Task.cancel()`: https://developer.apple.com/documentation/swift/task/cancel%28%29
- Apple `Task.checkCancellation()`: https://developer.apple.com/documentation/swift/task/checkcancellation%28%29
- Swift ARC: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/automaticreferencecounting/

Cancellation is cooperative; cancelling a task does not automatically stop arbitrary code that fails to observe cancellation.
