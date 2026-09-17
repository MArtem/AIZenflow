# L2-H — holdout: actor-isolated repository and cancellation

This task is frozen before scoring. Review the sample against the supplied canonical
engineering review instructions. Do not infer a defect from the control case.

```swift
actor MessageRepository {
    private let transport: Transport

    init(transport: Transport) { self.transport = transport }

    func loadMessages() async throws -> [Message] {
        try await Retry.run(maxAttempts: 3) {
            try await transport.fetchMessages()
        }
    }
}

@MainActor
final class MessageViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []
    private let repository: MessageRepository

    init(repository: MessageRepository) { self.repository = repository }

    func refresh() {
        Task {
            messages = (try? await repository.loadMessages()) ?? []
        }
    }
}

@MainActor
final class OwnedMessageViewModel: ObservableObject {
    private var task: Task<Void, Never>?

    func start() {
        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            _ = try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            self.markReady()
        }
    }

    deinit { task?.cancel() }
    private func markReady() {}
}
```

The second type is the control case: it owns and cancels its task during replacement and
lifecycle teardown. Review the first type's retry/cancellation/state semantics independently.
