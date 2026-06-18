# AppRateLimiter

`AppRateLimiter` is a standalone Swift package for app-independent rate limiting primitives. It provides safe keys, fixed-window limits, sliding-window limits, token-bucket limits, deterministic test clocks, an explicit store protocol, and an in-memory actor-backed implementation.

The package is designed as a root Infrastructure SDK package:

- no sibling package imports;
- no remote package dependencies;
- no app-specific domain entities;
- no logging, analytics, networking, persistence, or diagnostics package coupling;
- no hidden file system or database work;
- privacy-safe descriptions by default.

## Core API

```swift
let limiter = AppRateLimiter()

let request = RateLimitRequest(
    key: try RateLimitKey("route.login"),
    policy: .fixedWindow(
        limit: try RateLimitLimit(5),
        interval: try .minutes(1)
    ),
    cost: try RateLimitCost(1)
)

let decision = try await limiter.evaluate(request)

if decision.isAllowed {
    // Continue the operation.
} else {
    // Respect decision.retryAfter.
}
```

## Policies

### Fixed window

A fixed-window policy counts cost units from the beginning of a window. Once the window expires, usage resets.

### Sliding window

A sliding-window policy retains recent usage entries and releases them as they become older than the configured interval.

### Token bucket

A token-bucket policy starts full, consumes units per accepted request, and refills by completed intervals.

```swift
let policy = try RateLimitPolicy.makeTokenBucket(
    capacity: try RateLimitLimit(20),
    refillAmount: try RateLimitLimit(5),
    refillInterval: try .seconds(10)
)
```

## Privacy baseline

`RateLimitKey`, `RateLimitRequest`, and related descriptions are intentionally redacted. The package does not log or expose app-specific identifiers through `description` / `debugDescription`.

## Persistence boundary

The root package ships with `InMemoryRateLimitStore`. Durable or distributed storage belongs to the host app and should be implemented behind `RateLimitStore` without importing sibling SDK packages into this package.

`RateLimitStore` operations are throwing by design. A durable store must propagate file, database, or distributed-storage failures to the host so the host can choose its own fail-open or fail-closed policy. The package must not hide storage failures as allowed or rejected decisions.

`InMemoryRateLimitStore` is actor-backed and suitable for tests, previews, process-local limits, and small bounded runtime scopes. Hosts must not feed unbounded high-cardinality user/device/request identifiers into the in-memory store without an app-owned key strategy, reset policy, or durable bounded store.

Rejected decisions expose `RateLimitRejection.reason` so hosts can distinguish normal rate limiting from a request whose cost can never fit the configured policy.

## Verification

Run:

```bash
./Scripts/verify_package.sh
```

The verifier uses a worktree-local scratch path outside the package folder:

```text
../WorktreeScratch/AppRateLimiter
```
