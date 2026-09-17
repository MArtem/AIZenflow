# L2-T1 — cancellation and stale response

Review this Swift snippet against the supplied canonical engineering review instructions. Return
only the required structured findings and explicitly state when the control case is not a defect.

```swift
@MainActor
final class SearchViewModel: ObservableObject {
    @Published private(set) var results: [Result] = []
    @Published private(set) var isLoading = false
    private let service: SearchService

    init(service: SearchService) { self.service = service }

    func reload(query: String) {
        isLoading = true
        Task {
            let value = try? await service.search(query: query)
            guard !Task.isCancelled else { return }
            results = value ?? []
            isLoading = false
        }
    }
}
```

Control: checking `Task.isCancelled` after an async boundary can be appropriate as one
cooperative checkpoint. Do not report the existence of that check alone as the defect.
