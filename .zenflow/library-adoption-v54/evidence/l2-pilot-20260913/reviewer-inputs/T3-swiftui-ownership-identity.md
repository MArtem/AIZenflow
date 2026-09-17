# L2-T3 — SwiftUI ownership and view identity

Review this Swift snippet against the supplied canonical engineering review instructions. Return
only the required structured findings and explicitly state when the control case is valid.

```swift
struct DetailView: View {
    let itemID: UUID
    @ObservedObject var model: DetailModel

    var body: some View {
        Form {
            TextField("Name", text: $model.name)
        }
        .task {
            await model.load(itemID: itemID)
        }
    }
}

struct ParentView: View {
    @State private var selectedID: UUID?

    var body: some View {
        if let selectedID {
            DetailView(itemID: selectedID, model: DetailModel())
        }
    }
}
```

Control: a child may legitimately use `@ObservedObject` when its parent owns and injects one
stable instance. The issue here is the unstable construction at the call site, not the wrapper
in isolation.
