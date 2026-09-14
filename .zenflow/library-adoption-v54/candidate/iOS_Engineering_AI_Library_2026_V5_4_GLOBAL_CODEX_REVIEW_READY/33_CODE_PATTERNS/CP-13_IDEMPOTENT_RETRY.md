# CP-13 — Retry is a semantic policy, not a loop

Before retrying check:
- Is the operation idempotent or protected by an idempotency key?
- Is the failure transient?
- Did the server provide `Retry-After`?
- Is cancellation still active?
- Is there a retry budget and jitter?

Never attach a global "retry 3 times" interceptor to all HTTP methods without operation semantics.
