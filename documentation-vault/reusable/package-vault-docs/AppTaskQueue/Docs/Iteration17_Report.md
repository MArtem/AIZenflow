# InfrastructureSDK Iteration 17 — AppTaskQueue

## Summary

Created `AppTaskQueue`, a standalone Swift Package that provides app-independent task queue primitives.

## Implemented

- Safe task identifier and task kind wrappers.
- Payload envelope with size limit validation.
- Redacted descriptions for identifiers, kinds, payloads, tasks, and reports.
- Priority ordering.
- Deferred scheduling.
- Retry policy with bounded exponential backoff.
- Task states and immutable state transitions.
- `AppTaskQueueStore` protocol.
- `InMemoryAppTaskQueueStore` actor.
- `AppTaskQueueService` actor.
- `AppTaskExecutor` protocol.
- `AppTaskQueueRunner` actor.
- Source-owned DocC.
- Fail-fast package verifier.

## Design notes

Persistence is intentionally a protocol boundary. The root package does not perform file, database, Core Data, SwiftData, SQLite, or network persistence.

This avoids hidden blocking I/O inside async APIs and keeps the package independent from `AppFileStorage`, `AppDownloads`, `AppUploads`, `AppDiagnostics`, and `AppLogging`.

## Verification

Expected command:

```bash
./Scripts/verify_package.sh
```

The verifier runs regular Swift tests and strict concurrency tests.

## Known limitations

- In-memory storage is not durable.
- Durable persistence should be provided by host apps or optional integration helpers.
- No macOS/Xcode-only verification is claimed unless run separately on Apple tooling.
