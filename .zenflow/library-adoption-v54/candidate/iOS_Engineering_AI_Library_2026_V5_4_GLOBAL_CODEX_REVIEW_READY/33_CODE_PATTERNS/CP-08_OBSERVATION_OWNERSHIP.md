# CP-08 — SwiftUI Observation ownership

For iOS 17+ where Observation is the project choice:

```swift
@Observable
@MainActor
final class ProfileModel {
    var state: State = .idle
    // dependencies and commands...
}

struct ProfileScreen: View {
    @State private var model: ProfileModel

    init(model: ProfileModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        ProfileContent(state: model.state)
    }
}
```

`@State` here expresses that the view owns the observable reference's lifetime. If the model is injected and owned elsewhere, model that ownership instead. Do not mechanically migrate every `ObservableObject` without checking deployment target and semantics.
