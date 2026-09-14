# CP-09 — Prefer derived state to synchronized duplicate state

## Avoid
```swift
@State private var items: [Item] = []
@State private var visibleItems: [Item] = []
```
when `visibleItems` is deterministically derived from `items` + filter and must be manually synchronized.

## Prefer
```swift
private var visibleItems: [Item] {
    items.filter(matchesFilter)
}
```

If derivation is expensive, cache deliberately with clear invalidation; don't create a second source of truth merely for convenience.
