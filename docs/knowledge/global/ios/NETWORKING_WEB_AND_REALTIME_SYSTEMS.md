# Networking, Web, And Realtime Systems

## Load When
Use for URLSession, API clients, authentication transport, uploads/downloads, background transfer, WebSockets, server-sent events, gRPC, WebKit, reachability, caching, or network diagnostics.

## Boundary Model
Separate transport, wire DTO, domain mapping, persistence, and UI state. HTTP success does not imply semantic success. A response becomes trusted domain data only after status, headers, size, content type, decoding, and business validation.

## Request Contract
Define method, URL construction, headers, body encoding, authentication, timeout, cache behavior, idempotency, accepted status codes, response limits, cancellation, retry eligibility, and observability. Redact credentials and personal data from logs and errors.

## Reliability
- Retry only transient and idempotent operations, or operations protected by an idempotency key.
- Use bounded attempts, exponential backoff, jitter, cancellation, and server hints such as `Retry-After`.
- Do not use reachability as permission to send; attempt the operation and interpret the result.
- Preserve offline mutations durably before optimistic success when loss is unacceptable.
- Pagination needs stable cursors/order, duplicate handling, cancellation, and refresh semantics.

## Uploads And Downloads
- Stream large bodies and files instead of materializing them in memory.
- Validate file size/type and server response; use atomic destination replacement.
- Define resume-data compatibility and fallback when resume fails.
- Background URLSession requires stable identifiers, delegate/lifecycle ownership, relaunch reconciliation, and file cleanup.
- Progress is approximate unless the protocol provides a trustworthy total.

## Realtime Protocols
- Define connection state, authentication refresh, heartbeat, reconnect/backoff, message ordering, duplication, gaps, replay, and resume tokens.
- Bound inbound buffering and message size.
- Reconnect must not duplicate subscriptions or replay non-idempotent commands.
- Use application-level sequence/version checks when delivery order matters.

## WebKit
- Treat web content, script messages, navigation requests, redirects, and downloaded files as untrusted input.
- Use an allowlist for navigations and message names; validate payload shape and origin assumptions.
- Prefer ephemeral data stores for flows that should not retain cookies/history.
- Never interpolate secrets or untrusted text into executable JavaScript.
- Define process termination recovery, authentication handoff, downloads, external URL opening, and accessibility.

## TLS And Trust
Use platform trust evaluation by default. Certificate pinning adds rotation, expiry, recovery, and outage risk and requires an explicit threat model. Never disable trust checks in production. Mutual TLS and custom anchors require secure identity provisioning and renewal design.

## Caching
Respect HTTP cache semantics where possible. Application caches need a key, freshness model, size bound, eviction policy, privacy classification, invalidation strategy, and offline behavior. Never cache authenticated responses across users.

## Evidence
- Contract fixtures for success, malformed, partial, oversized, and version-skewed responses.
- Timeout, cancellation, offline, reconnect, duplicate, retry, and auth-refresh scenarios.
- Large upload/download memory and storage-pressure checks.
- Background relaunch and completion-handler checks on supported environments.
- Network Instruments or equivalent traces with secrets redacted.

## Primary Sources
- [URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system)
- [Network framework](https://developer.apple.com/documentation/network)
- [WebKit](https://developer.apple.com/documentation/webkit)
- Applicable protocol RFCs and the backend's versioned API contract.
