# AppRateLimiter Package Contract

## Purpose

`AppRateLimiter` provides standalone, app-independent rate limiting primitives for Swift apps and libraries.

It owns:

- safe rate-limit keys;
- cost and quota values;
- fixed-window policies;
- sliding-window policies;
- token-bucket policies;
- rate-limit decisions;
- a clock protocol for deterministic tests;
- a store protocol for host-owned persistence boundaries;
- an in-memory actor-backed store;
- a high-level actor service.

## Standalone guarantee

The package must remain a single-folder standalone Swift Package:

```text
AppRateLimiter/
├── Package.swift
├── README.md
├── PackageContract.md
├── Sources/AppRateLimiter/Documentation.docc/AppRateLimiter.md
├── Tests/AppRateLimiterTests/
├── Docs/
└── Scripts/verify_package.sh
```

Rules:

1. No `.package(path: "../...")` dependencies.
2. No `.package(url:)` dependencies.
3. No imports of sibling Infrastructure SDK packages.
4. No app-specific, product-specific, or feature-specific entities.
5. No coupling to networking, logging, analytics, persistence, or diagnostics packages.
6. All sources, tests, docs, and scripts must remain inside this package folder.
7. Cross-package composition belongs in optional integration helpers outside this root package.

## Privacy and diagnostics

The package must not disclose application identifiers through default textual representations.

Required behavior:

- `RateLimitKey.description` must not expose the key value.
- `RateLimitRequest.description` must not expose the key value.
- decisions must contain operational timing and remaining-unit information only.
- the package must not own logging sinks or analytics sinks.

## Execution boundary

`AppRateLimiter` and `InMemoryRateLimitStore` are actors. They provide an explicit concurrency boundary for mutable limiter state.

The package must not hide file system, database, or network work behind the in-memory API. Durable and distributed limiter storage belongs behind `RateLimitStore` in the host app or in a separate integration helper.

`RateLimitStore` operations must be throwing. Storage failures must propagate to the host application or integration layer so product code can explicitly choose fail-open, fail-closed, retry, or fallback behavior.

`InMemoryRateLimitStore` is process-local and unbounded by default. Hosts are responsible for avoiding high-cardinality keys or for providing a durable/bounded store when rate-limit keys can grow without a controlled reset lifecycle.

Rejected decisions must distinguish ordinary rate limiting from `costExceedsLimit`, because an over-cost request cannot be made valid by waiting.

## Verification contract

`Scripts/verify_package.sh` must be executable and fail fast.

The verifier must use a worktree-local scratch path outside the package folder:

```bash
WORKTREE_DIR="$(cd "${PACKAGE_DIR}/.." && pwd)"
SCRATCH_ROOT="${WORKTREE_DIR}/WorktreeScratch/${PACKAGE_NAME}"
```

The verifier must clean that scratch path and must not leave `.build`, `.swiftpm`, `Package.resolved`, `.DS_Store`, `__MACOSX`, or `xcuserdata` inside the package folder.

The verifier must run:

```bash
swift test
swift test -Xswiftc -strict-concurrency=complete
```

It must also fail when SwiftPM emits `warning:` or `error:` output.
