# AppTaskQueue Package Contract

## Purpose

`AppTaskQueue` provides app-independent primitives for building a local task queue in Swift applications and libraries.

It owns only the queue mechanism:

- task identity and kind value types;
- payload envelope validation;
- priority ordering;
- deferred scheduling;
- retry and backoff policy;
- queue state transitions;
- explicit store and executor boundaries;
- in-memory actor-backed queue storage.

It does not own application workflows, network clients, file storage, diagnostics, logging, analytics, feature flags, session state, or product-specific task types.

## Standalone guarantees

This root package must remain fully standalone:

1. No sibling package imports.
2. No sibling path dependencies.
3. No remote package dependencies.
4. No app-specific or product-specific logic.
5. No Tchop/news/profile/feed-specific models.
6. All sources, tests, docs, fixtures, and scripts must live inside this package folder.
7. Multi-target structure is allowed only if every target lives inside this package folder.
8. Cross-package composition belongs in optional integration helpers, not in this root package.

## Source-owned DocC

DocC must stay under:

```text
Sources/AppTaskQueue/Documentation.docc/AppTaskQueue.md
```

A root-level `.docc` catalog is not allowed.

## Execution boundary

The package uses actors for queue service, in-memory storage, and runner coordination.

The root package must not hide blocking file, database, or network operations inside decorative async wrappers. Persistent storage belongs behind `AppTaskQueueStore`; execution work belongs behind `AppTaskExecutor`.

`AppTaskQueueService` serializes its own actor entry points, but `AppTaskQueueStore` implementations still own backend-level atomicity. Durable stores must prevent duplicate reservation when multiple runners/processes can observe the same queued task. Hosts that need leases, reserved-task expiry, or crash recovery must implement that policy in their store/integration layer instead of relying on the root package to guess product-specific timing.

Tasks can be marked succeeded or failed only after they are reserved. This preserves the queue invariant that execution ownership is explicit before terminal completion.

Retry policy values must stay finite and bounded. `maximumAttempts` must be within the package-supported range, and `maximumDelay` must not be lower than `initialDelay`.

## Privacy baseline

The package must not expose payload contents, task identifiers, or task kinds through descriptions or debug descriptions.

Diagnostics must be redacted by default. The package must not log or report analytics by itself.

## Verifier scratch policy

`Scripts/verify_package.sh` must use a worktree-local scratch path outside the package folder:

```text
../WorktreeScratch/AppTaskQueue
```

The verifier must clean that scratch path after verification and must not leave `.build`, `.swiftpm`, `Package.resolved`, `.DS_Store`, `__MACOSX`, or `xcuserdata` inside the package folder.

## Forbidden source patterns

Sources must not introduce privacy, security, or concurrency shortcuts such as:

- unsafe diagnostic exposure of errors;
- localized user-facing error strings as diagnostics;
- unchecked sendability;
- stable privacy hashes;
- telemetry content leakage;
- backend payload/header leakage;
- credential leakage;
- silent security fallback;
- hidden blocking I/O inside async APIs.
