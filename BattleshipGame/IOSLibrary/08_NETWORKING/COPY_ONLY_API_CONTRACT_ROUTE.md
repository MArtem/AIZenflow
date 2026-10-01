# API contract and mapping — copy-only reference route

Use when a request/response schema, DTO, mapping, endpoint version or API error behavior changes.
Apply the project's local API-contract and integration rules first. This independent pass checks
whether the *observed* producer and every consumer agree; it does not invent a backend contract,
contact a server or authorize authentication/Keychain changes.

1. Identify the exact server/schema evidence and supported client versions. Trace wire DTO →
   domain model → persistence → UI, plus outbound request construction. Distinguish absent,
   explicit null, unknown enum, extra field, malformed value and version skew where relevant.
2. Check dates/time zones, ordering/cursors, identifiers and defaults for silent meaning changes.
   A successful decode may still be a wrong business state; a failed decode must not become a
   success-shaped placeholder. Review transport, auth, validation, permission, rate-limit,
   server and decode errors when they require different behavior.
3. Trace every caller's retry, cancellation, partial-result and offline handling. Repeated
   mutation requires a known idempotency contract; an assumed one is not evidence. Check that
   logs/metrics identify failure classes without retaining private payloads.
4. For an authorized change, inspect old/new fixtures and affected readers/writers; recommend
   the smallest contract and compatibility check. If the backend or old-client behavior cannot
   be observed, mark that claim `INSUFFICIENT_EVIDENCE`, not compatible by default.

`AUTO` performs the in-scope static producer/consumer challenge after the local pass;
`ADVISORY` prioritizes contract evidence and negative cases. Network calls, tests, builds and
auth work still need separate permission. This distills the useful former `ioslib-api-contract`
checklist without its global installation/runtime references.
