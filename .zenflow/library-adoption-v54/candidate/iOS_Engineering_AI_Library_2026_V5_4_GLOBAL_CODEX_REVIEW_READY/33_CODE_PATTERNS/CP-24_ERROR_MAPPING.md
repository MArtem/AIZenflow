# CP-24 — Preserve technical cause, expose product-safe error

```swift
enum DomainError: Error {
    case unavailable
    case unauthorized
    case invalidData
}

func map(_ error: Error) -> DomainError {
    switch error {
    case HTTPError.status(401): .unauthorized
    case is DecodingError: .invalidData
    default: .unavailable
    }
}
```

Keep the original error available for privacy-safe diagnostics where architecture allows. Do not display raw transport/decoding messages to users.
