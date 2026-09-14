# CP-23 — Model mutually exclusive async states

```swift
enum LoadState<Value> {
    case idle
    case loading(previous: Value?)
    case loaded(Value)
    case empty
    case failed(UserFacingError, previous: Value?)
}
```

Adapt the cases to product semantics. The point is to prevent impossible combinations such as `isLoading == true`, `error != nil`, and stale content flags with no defined meaning.
