# CP-14 — Parse external URLs into a validated internal route

```swift
enum AppRoute: Equatable {
    case item(id: Item.ID)
}

func route(from url: URL) -> AppRoute? {
    guard url.scheme == "https",
          url.host == "example.com" else { return nil }

    let parts = url.pathComponents.filter { $0 != "/" }
    guard parts.count == 2,
          parts[0] == "item",
          let id = Item.ID(rawValue: parts[1]) else { return nil }
    return .item(id: id)
}
```

Parsing does not grant authorization. Privileged routes must still pass app/backend authorization gates.
