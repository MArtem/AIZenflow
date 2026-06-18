# ``AppRateLimiter``

A standalone Infrastructure SDK package for app-independent rate limiting.

## Overview

`AppRateLimiter` provides safe primitives for deciding whether an operation should proceed now or wait until a later time.

The package includes:

- `RateLimitKey`
- `RateLimitLimit`
- `RateLimitCost`
- `RateLimitDuration`
- `RateLimitPolicy`
- `RateLimitRequest`
- `RateLimitDecision`
- `RateLimitClock`
- `InMemoryRateLimitStore`
- `AppRateLimiter`

## Example

```swift
let limiter = AppRateLimiter()
let request = RateLimitRequest(
    key: try RateLimitKey("route.login"),
    policy: .fixedWindow(limit: try RateLimitLimit(5), interval: try .minutes(1)),
    cost: try RateLimitCost(1)
)

let decision = try await limiter.evaluate(request)
```

## Privacy

Textual descriptions are redacted by default. Use host-app logging policies when recording decisions.

## Store Failures

`RateLimitStore` operations throw so durable storage failures remain visible to host policy. The package does not guess whether an app should fail open or fail closed.

## Cardinality

`InMemoryRateLimitStore` is actor-backed and process-local. Use app-owned key scoping, reset policy, or a durable/bounded store when rate-limit keys can grow without an upper bound.
