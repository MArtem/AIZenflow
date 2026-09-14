# CP-19 — Delegate ownership

```swift
protocol PlayerDelegate: AnyObject {
    func playerDidFinish()
}

final class PlayerController {
    weak var delegate: PlayerDelegate?
}
```

Use `weak` only when delegate ownership is non-owning by design. `unowned` requires a stronger lifetime invariant and should not be chosen merely to avoid optional handling.
