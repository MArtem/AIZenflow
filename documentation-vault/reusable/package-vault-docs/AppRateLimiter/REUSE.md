# AppRateLimiter Reuse Notes

## Purpose

`AppRateLimiter` is a standalone reusable package for app-independent rate limiting primitives: safe keys, fixed-window policies, sliding-window policies, token-bucket policies, deterministic clocks, explicit store boundary, and actor-backed in-memory evaluation.

## SwiftPM Usage

Copy this folder into a project's package area and add it as a local package or dependency. The package has no sibling package dependencies and no remote dependencies.

Run package verification before adoption:

```zsh
cd ./PackagesForReuse/AppRateLimiter
./Scripts/verify_package.sh
```

## Source-Only Usage

For source-only integration, copy this package to the target project's active package/source area and add only `Sources/AppRateLimiter/**/*.swift` to the relevant target. Keep `README.md`, `PackageContract.md`, DocC, tests, and `Scripts/verify_package.sh` with the package folder so it remains portable.

## Host Ownership

The package owns rate-limit mechanism only. Host apps own product-specific key taxonomy, where limits apply, UX copy, telemetry, backend response mapping, durable/distributed storage, fail-open/fail-closed policy, and high-cardinality key bounds.

`RateLimitStore` is throwing by design so durable storage failures remain visible to host policy. `InMemoryRateLimitStore` is process-local and should not be used with unbounded high-cardinality keys unless the host has a reset/bounding strategy.

## Current TchopApp Decision

Vault-only. Current `TchopApp` has a small synchronous login submission throttle and no product-level generic rate-limit policy/runtime to migrate. Replacing that one local UI throttle with an async actor-backed package path now would add unnecessary complexity without a current broader rate-limiting requirement.
