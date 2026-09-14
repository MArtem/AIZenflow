# CP-07 — AsyncStream termination owns subscription cleanup

```swift
func events() -> AsyncStream<Event> {
    AsyncStream { continuation in
        let token = source.observe { event in
            continuation.yield(event)
        }

        continuation.onTermination = { _ in
            source.removeObserver(token)
        }
    }
}
```

Check whether callbacks can arrive from arbitrary threads and whether `source`/`token` are safe to capture. Choose buffering policy consciously for high-rate streams.
