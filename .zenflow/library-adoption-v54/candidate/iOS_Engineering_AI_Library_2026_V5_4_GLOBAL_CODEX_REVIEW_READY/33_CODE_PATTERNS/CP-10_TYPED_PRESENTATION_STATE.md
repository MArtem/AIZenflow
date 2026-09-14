# CP-10 — Typed presentation state

Instead of unrelated booleans that can become simultaneously true:

```swift
enum Destination: Identifiable {
    case settings
    case details(Item.ID)

    var id: String {
        switch self {
        case .settings: "settings"
        case .details(let id): "details-\(id)"
        }
    }
}

@State private var destination: Destination?
```

Use a route type that reflects valid mutually exclusive presentation states. Choose stable IDs appropriate to the domain.
