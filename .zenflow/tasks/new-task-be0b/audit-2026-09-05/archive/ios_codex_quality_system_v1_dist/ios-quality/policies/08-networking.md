# 08 — Networking

## Transport

Prefer `URLSession` unless project requirements justify another client. Respect App Transport Security; broad ATS exceptions require explicit security approval.

## Request design

Every request path MUST define as applicable:

- method;
- URL/path/query encoding;
- headers/content type;
- authentication behavior;
- timeout policy;
- status-code handling;
- decoding/validation;
- cancellation;
- retry/idempotency behavior;
- sensitive logging policy.

## Status codes

Do not treat “transport completed” as success. Validate HTTP response/status and map expected server error payloads where useful.

## Retries

MUST NOT blindly retry non-idempotent operations. Retry policy should consider:

- HTTP method/idempotency key;
- transient vs permanent errors;
- backoff/jitter;
- reachability misconceptions (do not gate every request solely on reachability);
- cancellation;
- server `Retry-After` when relevant.

## Cancellation

Async networking should propagate task cancellation. Superseded requests must not overwrite newer state.

## Decoding

- Treat decoding failures as real contract errors, not “empty data.”
- Keep DTO/schema assumptions explicit.
- Date/number strategies should be centralized when API contracts require consistency.

## Authentication

Token refresh coordination is high risk. MUST avoid concurrent refresh storms and stale-token races. A refresh coordinator/actor/task-sharing mechanism should ensure one in-flight refresh when that is the protocol requirement.

Do not log access/refresh tokens.

## TLS / trust

Use platform trust evaluation by default. Certificate/public-key pinning is a specialized security decision with operational rollback risks and requires explicit project policy.

## Offline/cache

Caching policy must define staleness, eviction, privacy sensitivity, and source-of-truth precedence. Do not silently present stale data as fresh when product semantics care.

## Tests

Networking changes SHOULD test:

- success;
- representative non-2xx response;
- malformed/contract-breaking payload;
- cancellation;
- auth refresh or retry path when touched;
- duplicate/stale completion behavior where relevant.
