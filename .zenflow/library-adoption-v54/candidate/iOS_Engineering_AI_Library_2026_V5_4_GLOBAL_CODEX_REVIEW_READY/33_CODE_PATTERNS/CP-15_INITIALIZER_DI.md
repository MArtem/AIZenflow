# CP-15 — Explicit initializer dependency injection

```swift
struct Dependencies {
    let clock: any Clock<Duration>
    let analytics: Analytics
    let service: ProfileService
}

@MainActor
final class ProfileModel {
    private let service: ProfileService
    private let analytics: Analytics

    init(service: ProfileService, analytics: Analytics) {
        self.service = service
        self.analytics = analytics
    }
}
```

Do not wrap everything in a `Dependencies` bag if it hides what each consumer needs. The simplest explicit initializer is usually the strongest default.
