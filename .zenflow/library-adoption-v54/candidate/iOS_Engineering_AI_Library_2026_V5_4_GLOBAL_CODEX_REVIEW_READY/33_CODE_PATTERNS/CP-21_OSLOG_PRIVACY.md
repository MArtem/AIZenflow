# CP-21 — Privacy-aware structured logging

```swift
import OSLog

private let logger = Logger(subsystem: "com.example.app", category: "auth")

logger.info("Token refresh finished for account=\(accountID, privacy: .private(mask: .hash))")
```

Never log access/refresh tokens, passwords, full payment data or sensitive payloads. Stable event/category names are more useful than dumping entire objects.
