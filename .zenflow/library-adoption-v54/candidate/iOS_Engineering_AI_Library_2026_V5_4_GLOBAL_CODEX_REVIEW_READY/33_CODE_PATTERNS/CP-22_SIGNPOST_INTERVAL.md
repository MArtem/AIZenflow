# CP-22 — Measure a meaningful interval

```swift
import os

let signposter = OSSignposter(subsystem: "com.example.app", category: "feed")
let state = signposter.beginInterval("InitialLoad")
defer { signposter.endInterval("InitialLoad", state) }

try await loadInitialFeed()
```

Use stable semantic intervals and compare representative workloads. Signposts are evidence infrastructure, not an optimization by themselves.
