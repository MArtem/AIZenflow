# AppBackgroundTasks

`AppBackgroundTasks` is a product-independent Swift package for background task registration, scheduling models, manual/test scheduling, execution orchestration and diagnostics.

It is a mechanism package. It does not know about app screens, sync engines, networking clients, analytics domains, session state or product-specific jobs.

## What belongs here

- Background task identifiers and task kinds.
- Registration and scheduling request models.
- Manual scheduler for tests, previews and deterministic host-app orchestration.
- Execution context and result models.
- Privacy-safe diagnostics.
- Compile-gated helpers for native `BackgroundTasks` request creation when available.

## What must not belong here

- Concrete app job names such as feed refresh or profile sync.
- Networking clients.
- Database writes.
- Analytics tracking.
- Session restoration policy.
- Background task entitlement or Info.plist ownership.
- Hidden native scheduler side effects during tests.

## Quick example

```swift
let manager = DefaultBackgroundTaskManager()

try await manager.register(
    BackgroundTaskRegistration(identifier: "refresh", kind: .appRefresh),
    handler: AnyBackgroundTaskHandler { context in
        // Host app performs its own work here.
        return .success
    }
)

try await manager.schedule(
    BackgroundTaskRequest(identifier: "refresh", kind: .appRefresh)
)

let result = try await manager.runPending(identifier: "refresh")
```

## Standalone contract

This package is 100% single-folder standalone:

- no sibling path dependencies;
- no remote package dependencies;
- no imports of sibling SDK packages;
- source-owned DocC under `Sources/AppBackgroundTasks/Documentation.docc/`;
- verification uses a worktree-local scratch path outside this package folder;
- verification must not leave SwiftPM build artifacts inside this package folder.

## Native platform note

The package intentionally keeps native `BGTaskScheduler` submission outside the root package. Background task registration and submission are tightly coupled to app lifecycle, entitlements and Info.plist configuration, so host apps should own that boundary.

When `BackgroundTasks` is available, the package provides `BGTaskRequestFactory` to convert portable requests into native `BGTaskRequest` values. Actual submission should be host-app or integration-helper code.


## Hardening notes

- Failure diagnostic codes are sanitized before storage or error descriptions.
- `runPending(identifier:)` checks that a handler exists before removing a pending request, so a composition error does not silently drop scheduled work.
- Native `BackgroundTasks` request factory code is excluded on macOS/watchOS where `BGTaskRequest` types are unavailable even though the framework may be importable.
