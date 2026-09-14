# CP-16 — Typed feature flag

```swift
enum FeatureFlag: String, CaseIterable {
    case redesignedCheckout
}

protocol FeatureFlagging {
    func isEnabled(_ flag: FeatureFlag) -> Bool
}
```

Define defaults, cache/TTL, experiment ownership, kill-switch behavior, offline behavior and cleanup date. Avoid raw string keys scattered across feature code.
