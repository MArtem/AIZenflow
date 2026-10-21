# Networking, Web, And Realtime Systems

## Load When
Use for URLSession, API clients, authentication transport, uploads/downloads, background transfer, WebSockets, server-sent events, gRPC, WebKit, reachability, caching, or network diagnostics.

## Boundary Model

For an authorized client/server contract migration, define deployment sequencing, the compatibility
window for old/new clients and servers, coexistence, rollback limits and cleanup criteria. A new
schema that decodes locally does not prove every deployed counterpart can interoperate. Keep the
staged rollout decision with the actual backend/app owners; this reference grants no deployment or
network action.

Separate transport, wire DTO, domain mapping, persistence, and UI state. HTTP success does not imply semantic success. A response becomes trusted domain data only after status, headers, size, content type, decoding, and business validation.

## Request Contract
Define method, URL construction, headers, body encoding, authentication, timeout, cache behavior, idempotency, accepted status codes, response limits, cancellation, retry eligibility, and observability. Redact credentials and personal data from logs and errors.

## Reliability
- Retry only classified transient failures when replay is semantically safe through an idempotent
  operation or a documented server idempotency contract.
- Use bounded attempts, exponential backoff, jitter, cancellation, and server hints such as `Retry-After`.
- Do not use reachability as permission to send; attempt the operation and interpret the result.
- Preserve offline mutations durably before optimistic success when loss is unacceptable.
- Pagination needs stable cursors/order, duplicate handling, cancellation, and refresh semantics.

Retry budgets bound attempts, pending delay and total time, including interaction with auth replay.
Cancellation stops both backoff waiting and the next attempt. Review actual Retry-After parsing,
request-body replayability, partial/streaming uploads and deployed background-session behavior.
Neither URLSession nor a client-generated key establishes safe server replay. For a permitted
verification plan, use controlled clock/transport cases for delay, cancellation, terminal error
and duplicate-effect prevention; this recommendation creates no tests or execution permission.

Pagination review covers cursor invalidation and refresh-versus-load-more ownership; late pages
or chunks must not overwrite newer state or falsely report completeness. Connected/reconnected
transport alone does not prove delivery of every application event.

## Uploads And Downloads
- Stream large bodies and files instead of materializing them in memory.
- Validate file size/type and server response; use atomic destination replacement.
- Define resume-data compatibility and fallback when resume fails.
- Background URLSession requires stable identifiers, delegate/lifecycle ownership, relaunch reconciliation, and file cleanup.
- Inspect transfer integrity, temporary-file ownership and cleanup under storage pressure, including
  partial completion and the actual request-body replayability contract.
- Progress is approximate unless the protocol provides a trustworthy total.

For a background transfer, identify the session/delegate and completion-handler owner across
relaunch, temporary-file handoff and duplicate/absent delivery. Review discretionary power/network
policy and honest delayed/expired telemetry; scheduling alone does not prove transfer completion.

## Realtime Protocols
- Define connection state, authentication refresh, heartbeat, reconnect/backoff, message ordering, duplication, gaps, replay, and resume tokens. Include foreground/background transitions in the connection state contract under the actual platform execution limits.
- Bound inbound buffering and message size.
- Reconnect must not duplicate subscriptions or replay non-idempotent commands.
- Use application-level sequence/version checks when delivery order matters.

### Reconnect, Gap And Replay Trace
Choose WebSocket for an actual bidirectional session; a one-way server event stream or bounded
refresh may be sufficient for a read-only consumer. RFC6455 describes transport framing and
backoff after abnormal closure; it does not supply the app's durable event log or exactly-once
mutation contract. For SSE, Last-Event-ID reports the stream cursor on reconnection; that
header alone cannot ensure that a server still retains every missing event. Keep browser
EventSource behavior distinct from a native parser/client implementation.

For example, the client applied event41, disconnects before42, then reconnects and receives41
again followed by44. Deduplicate by the owned event identity, detect a gap only under the
server's defined sequence model, and obtain replay or a versioned snapshot before publishing
complete state. Persist an applied cursor consistently with the local effects; advancing it
first can permanently skip work after a crash. Account changes invalidate the old subscription
and its cursor. Backoff/jitter bounds reconnect load; cancellation stops the old session.
A successful socket handshake is not successful reconciliation or acknowledgment of a command.
Primary theory: [RFC6455 §7.2.3](https://www.rfc-editor.org/rfc/rfc6455.html#section-7.2.3)
and [SSE processing and Last-Event-ID](https://html.spec.whatwg.org/multipage/server-sent-events.html#the-last-event-id-header).
This counterexample is unexecuted; replay retention, identity and snapshot policy are application
contracts, not extra guarantees inferred from either protocol.

## WebKit

For an asynchronous JavaScript bridge, define request identity, completion/error/cancellation and
ordering at the native/web boundary. Bound pending work and reject stale replies after navigation,
session replacement or cancellation; do not leave a caller waiting indefinitely or report a
cancelled request as success.

- Treat web content, script messages, navigation requests, redirects, and downloaded files as untrusted input.
- Use an allowlist for navigations and message names; validate payload shape and origin assumptions.
- Prefer ephemeral data stores for flows that should not retain cookies/history.
- Never interpolate secrets or untrusted text into executable JavaScript.
- Define process termination recovery, authentication handoff, downloads, external URL opening, and accessibility.

Review redirects, JS bridge inputs/content-world scope, file-read access, downloads and
cookie/session isolation throughout the actual flow; an allowlisted initial URL is insufficient.
Content worlds separate JavaScript variable namespaces, while DOM changes remain shared; do
not claim complete document isolation from a content-world choice.

## TLS And Trust
Use platform trust evaluation by default. Certificate pinning adds rotation, expiry, recovery, and outage risk and requires an explicit threat model. Never disable trust checks in production. Mutual TLS and custom anchors require secure identity provisioning and renewal design.

Inspect the actual transport and ATS configuration; ATS protection of URL Loading System traffic
must not be assumed for lower-level networking. Existing trust decisions need supported-project
evidence; this review grants no insecure exception or authentication/configuration mutation.

Before retiring an old path in an authorized security migration, assess deployed compatibility,
revocation and containment. This review grants neither credential rotation nor an insecure fallback.

## Caching
Review Cache-Control directives, ETag/Last-Modified validation, actual URLCache/session policy and
invalidation together. Respect HTTP cache semantics where possible. Application caches need a key, freshness model, size bound, eviction policy, privacy classification, invalidation strategy, and offline behavior. Never cache authenticated responses across users.

For diagnosis, use redacted request IDs, status/timing or permitted session metrics to separate
transport, server, decode and application-auth hypotheses. Approved transport migration preserves
endpoint/cancellation semantics at every caller; controlled contract evidence avoids repeating
real side-effecting requests as an informal comparison.

## Lost Acknowledgment And Cache Isolation Example
A mutation reaches the server, but the connection fails before the response. The client cannot
infer that the mutation failed or blindly repeat it. Use the endpoint's established idempotency
or reconciliation contract and a bounded retry budget; a locally generated request ID alone
proves no server deduplication. Cancellation stops future publication/attempts under the known
contract, not a side effect already committed remotely.

Likewise, a successful authenticated response for account A must not be served as account B's
local cache entry after switching accounts. Trace cache key, storage lifetime, HTTP directives
and account invalidation together. RFC shared-cache exceptions do not waive the app's stricter
user-data isolation policy. A permitted fixture can model lost responses and account switches;
this trace is not an executed endpoint request or test.

## Evidence

When permitted metrics expose them, distinguish DNS resolution, connection, TLS, server/response,
cache, authentication and decode phases. Do not infer a DNS or connection diagnosis from aggregate
latency alone; unavailable phase timing remains unknown. Use supplied redacted evidence within
current permissions, not an implicit live request or configuration change.

- Contract fixtures for success, malformed, partial, oversized, and version-skewed responses.
- Timeout, cancellation, offline, reconnect, duplicate, retry, and auth-refresh scenarios.
- Large upload/download memory and storage-pressure checks.
- Background relaunch and completion-handler checks on supported environments.
- Network Instruments or equivalent traces with secrets redacted.

## Primary Sources
- [HTTP semantics and retry guidance: RFC 9110](https://www.rfc-editor.org/rfc/rfc9110.html)
- [Apple: Handling an authentication challenge](https://developer.apple.com/documentation/foundation/handling-an-authentication-challenge)
- [HTTP caching: RFC 9111](https://www.rfc-editor.org/rfc/rfc9111.html)
- [Apple: Preventing insecure network connections](https://developer.apple.com/documentation/security/preventing-insecure-network-connections)
- [URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system)
- [Network framework](https://developer.apple.com/documentation/network)
- [WebKit](https://developer.apple.com/documentation/webkit)
- Applicable protocol RFCs and the backend's versioned API contract.
