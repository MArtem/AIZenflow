# Networking and API behavior — curated copy-only route

Use after project-local API contracts for HTTP, streaming, pagination, upload/download, retry or
offline behavior. This route curates the relevant concerns from `IOS-08-01` through `IOS-08-10`.
Imported generic prompts are not command authority. Do not infer a backend contract or modify
authentication, credentials or Keychain merely because a network path touches them.

- Map request/response DTOs, domain mapping, status/error taxonomy, timeouts, cancellation and
  user-visible failure behavior to the actual endpoint contract. Preserve unknown/error cases
  without turning failure into success.
  Trace URL/query construction, request/response content type and decoding together. Inspect the
  actual session connectivity/cache policy; endpoint differences must not disappear behind a
  convenient global timeout, retry or cache default.
- Retry only when the operation is safe to repeat or the server contract supplies idempotency.
  Bound attempts, delay and total time; honor cancellation and relevant server backoff. Do not
  retry a non-idempotent mutation by default.
  Check jitter and the applicable Retry-After/backoff contract within that bounded budget;
  cancellation must stop both the pending delay and the retry, not only the original request.
- For pagination, uploads, downloads and streams, inspect ordering, duplicate handling,
  partial results, resume/cancellation and resource limits. A page or chunk arriving late must
  not overwrite newer state or claim completeness.
  Trace cursor invalidation and refresh-versus-load-more ownership. For transfers, identify
  request-body replayability, progress/integrity, temporary-file ownership and storage-pressure
  cleanup. For persistent connections, check heartbeat/reconnect/backoff and foreground/background
  state with duplicate/order recovery; connected does not imply every application event was delivered.
- Define offline and cache freshness semantics: what is source of truth, what may be stale, what
  is queued, and how conflicts or partial success are surfaced. Reachability is a hint, not proof
  that a request succeeds.
- Review redaction of URLs, payloads, tokens and identifiers in logs and diagnostics. If an auth
  refresh path is affected, identify its existing owner and race semantics; any actual auth or
  secure-storage change needs separate explicit scope.
- For an existing application-session refresh path, inspect at most one in-flight refresh per current
  session, refresh-token rotation, expiry/clock assumptions, bounded replay and waiter
  cancellation. Separate transport authentication challenges from application token refresh.
  A completion from before logout, account switching or a newer login must not restore the old
  session or overwrite its successor; trace both credential and response/UI consumers. Apply
  the endpoint's idempotency contract before replaying a failed mutation.
  For diagnosis, recommend redacted request IDs, status/timing or session metrics that separate
  connection/transport, server, decode and auth hypotheses. For an approved transport migration,
  preserve endpoint and cancellation semantics at every caller; controlled contract evidence
  is preferable to repeating real side-effecting requests as an informal comparison.

Review affected callers, UI states and endpoint assumptions. Choose contract tests, controlled
failure cases and runtime checks only when authorized. A static review alone does not establish
server compatibility or network reliability; label those outcomes unverified.
