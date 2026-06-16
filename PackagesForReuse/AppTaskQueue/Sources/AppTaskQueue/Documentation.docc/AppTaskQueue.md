# ``AppTaskQueue``

Standalone task queue primitives for Swift apps and libraries.

## Overview

`AppTaskQueue` provides a small, app-independent foundation for queuing and executing local tasks.

The package intentionally separates mechanism from application policy:

- `AppTaskEnqueueRequest` describes work to enqueue.
- `AppQueuedTask` represents immutable queue state.
- `AppTaskQueueStore` is the persistence boundary.
- `InMemoryAppTaskQueueStore` is the included actor-backed implementation.
- `AppTaskQueueService` owns state transitions.
- `AppTaskExecutor` owns host-app execution work.
- `AppTaskQueueRunner` reserves one due task and applies the executor result.

`AppTaskQueueStore` implementations own durable backend atomicity. The included in-memory store is actor-serialized, but a file/database/cloud-backed store must prevent duplicate reservation if multiple runners or processes can see the same queue.

Terminal success/failure requires explicit reservation first. Queued tasks can be cancelled or removed, but they are not completed until a runner/service has claimed execution ownership.

## Topics

### Identity

- ``AppTaskID``
- ``AppTaskKind``

### Payloads

- ``AppTaskPayload``

### Queue Model

- ``AppTaskEnqueueRequest``
- ``AppQueuedTask``
- ``AppQueuedTaskState``
- ``AppTaskPriority``
- ``AppTaskSchedule``
- ``AppTaskRetryPolicy``

### Store and Service

- ``AppTaskQueueStore``
- ``InMemoryAppTaskQueueStore``
- ``AppTaskQueueService``
- ``AppTaskQueueSnapshot``

### Execution

- ``AppTaskExecutor``
- ``AppTaskExecutionContext``
- ``AppTaskExecutionDecision``
- ``AppTaskQueueRunner``
- ``AppTaskRunReport``
- ``AppTaskRunOutcome``

### Time

- ``AppTaskQueueClock``
- ``SystemAppTaskQueueClock``
- ``FixedAppTaskQueueClock``

### Failures

- ``AppTaskQueueFailure``
