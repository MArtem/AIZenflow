# AppTaskQueue

`AppTaskQueue` is a standalone Swift package with app-independent task queue primitives for iOS, macOS, tvOS, watchOS, and Swift server/Linux test environments.

The package is intentionally self-contained. It does not depend on any sibling InfrastructureSDK package, remote package, application target, analytics layer, logging layer, persistence SDK, or product-specific model.

## What it provides

- Safe task identifiers and task kinds.
- Payload envelope with size limits and redacted descriptions.
- Task priority and deferred scheduling.
- Retry policy with bounded exponential backoff.
- Queue task states: queued, reserved, succeeded, failed, cancelled.
- `AppTaskQueueStore` protocol as an explicit host-app persistence boundary.
- `InMemoryAppTaskQueueStore` actor for tests, previews, and simple runtime use.
- `AppTaskQueueService` actor for enqueue/reserve/complete/retry/fail/cancel flows.
- `AppTaskExecutor` protocol as an explicit execution boundary.
- `AppTaskQueueRunner` actor for one-task-at-a-time execution.
- Source-owned DocC under `Sources/AppTaskQueue/Documentation.docc/AppTaskQueue.md`.

## Package layout

```text
AppTaskQueue/
├── Package.swift
├── README.md
├── PackageContract.md
├── Sources/
│   └── AppTaskQueue/
│       └── Documentation.docc/
├── Tests/
│   └── AppTaskQueueTests/
├── Docs/
│   └── Iteration17_Report.md
└── Scripts/
    └── verify_package.sh
```

## Quick start

```swift
import AppTaskQueue
import Foundation

let store = try InMemoryAppTaskQueueStore()
let queue = AppTaskQueueService(store: store)

let request = try AppTaskEnqueueRequest(
    id: AppTaskID("sync.article.001"),
    kind: AppTaskKind("sync.article"),
    payload: AppTaskPayload(data: Data([1, 2, 3])),
    priority: .high,
    retryPolicy: .standard
)

try await queue.enqueue(request)
```

## Runner example

```swift
struct ExampleExecutor: AppTaskExecutor {
    func execute(
        _ task: AppQueuedTask,
        context: AppTaskExecutionContext
    ) async -> AppTaskExecutionDecision {
        // Host app performs the real operation here.
        .succeeded
    }
}

let runner = AppTaskQueueRunner(
    queue: queue,
    executor: ExampleExecutor()
)

let report = try await runner.runOne()
```

## Persistence boundary

This root package does not perform file, SQLite, Core Data, SwiftData, Keychain, or network persistence. Host applications can provide persistence by implementing `AppTaskQueueStore`.

That choice is deliberate:

- no hidden blocking I/O inside async APIs;
- no dependency on AppFileStorage or any sibling package;
- persistence decisions stay owned by the host app or an optional integration helper;
- root package stays single-folder standalone.

`AppTaskQueueService.reserveNext()` is a queue-level operation, not a cross-process distributed lock. A custom durable `AppTaskQueueStore` must serialize reservation/update operations for its own backend, or the host must run one runner per logical queue. If a host needs multi-process claiming, expiration of reserved tasks, or crash recovery, that policy belongs in the durable store or an app-owned integration layer because the correct lease duration and conflict policy are product-specific.

Completion and failure are valid only for reserved tasks. Queued tasks can be cancelled or removed, but they cannot be marked succeeded/failed without first being reserved by the queue runner/service.

Retry policies are bounded. `maximumAttempts` must be between `1` and `AppTaskRetryPolicy.maximumSupportedAttempts`, delays must be finite, and `maximumDelay` must not be lower than `initialDelay`.

Payload size limits must be positive. Empty payloads are allowed only when the configured positive maximum still permits them; `maximumBytes == 0` is rejected as an invalid limit.

## Privacy and diagnostics

Descriptions intentionally redact task identifiers, task kinds, and payload contents. Payload descriptions expose only byte count and whether a media type was provided.

The package does not log, report analytics, collect diagnostics, or expose task payload contents through `description` / `debugDescription`.

## Verification

Run:

```bash
./Scripts/verify_package.sh
```

The verifier uses a worktree-local scratch directory outside the package folder:

```text
../WorktreeScratch/AppTaskQueue
```

It removes the scratch directory after verification and checks that package-local build artifacts are not left in the root package folder.
