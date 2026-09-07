# 13 — Error Handling and Resilience

## Errors are data

Every external/side-effect boundary can fail. Model failures at the level where meaningful recovery decisions can be made.

## MUST

- distinguish cancellation from failure when behavior differs;
- avoid empty `catch {}` for correctness-critical work;
- avoid converting all failures into empty/default success values;
- surface user-actionable errors in an understandable way;
- preserve diagnostic context in logs/underlying error chains without leaking secrets;
- ensure retry paths are bounded and safe.

## Error taxonomy

SHOULD distinguish where useful:

- validation/input error;
- transport/offline error;
- server/API contract error;
- authentication/authorization error;
- decoding/schema error;
- persistence/migration error;
- cancellation;
- programmer invariant failure.

## Fatal failures

`fatalError`/`preconditionFailure` are acceptable for truly unrecoverable programmer invariants, not ordinary production errors such as failed network requests or missing optional content.

## Partial failure

When operations aggregate multiple results, define whether behavior is fail-fast, best-effort, or partial-success. Tests should reflect that contract.

## Idempotency

Operations that may be retried after unknown network outcome must consider whether the server operation can safely execute twice.

## User experience

Error UI SHOULD avoid leaking implementation details. Preserve retry/recovery paths where product semantics allow them.
