# L2 evaluator key — T1/T2/T3

Frozen 2026-09-13 before any independent output. Do not expose before all A/B outputs are sealed.

## T1

- The unstructured task is not retained/cancelled/replaced, so an older response can overwrite a
  newer query result.
- `try?` collapses transport failure into an empty-result success-looking state; no explicit
  failure contract exists.
- The cancellation checkpoint is useful but not a generation/order gate for a newer request.

## T2

- Mutable token state and refresh are unsynchronized; concurrent 401s can trigger duplicate
  refreshes and lose a rotated token. Single-flight ownership is absent.
- Every request is replayed after 401 without an explicit idempotency/replay-safety contract or
  retry budget; this is dangerous for non-idempotent requests.
- Refresh can complete after logout and publish a fresh token; logout/refresh generation or
  cancellation semantics are absent.

## T3

- `ParentView` constructs `DetailModel()` during body evaluation while the child treats it as
  externally owned; identity/ownership is unstable and work/state can reset.
- `.task` has no explicit identity key tied to `itemID`, so a changed item can receive stale work;
  model-side cancellation/generation gating is also required.

## Controls

Do not flag the post-await cancellation check in T1 by itself, the conditional single retry in T2
when a backend contract guarantees safety, or `@ObservedObject` in T3 when a stable parent-owned
instance is actually injected.
