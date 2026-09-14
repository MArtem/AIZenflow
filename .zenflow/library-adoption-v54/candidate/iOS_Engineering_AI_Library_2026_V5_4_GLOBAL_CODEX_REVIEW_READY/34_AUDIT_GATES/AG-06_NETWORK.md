# AG-06 — Networking gate

- [ ] HTTP method/status/content-type semantics корректны.
- [ ] Request cancellable end-to-end.
- [ ] Timeout configured intentionally.
- [ ] Retry только semantic-safe/idempotent; budget+jitter/Retry-After where relevant.
- [ ] Auth refresh single-flight; logout race определена.
- [ ] 401/403/transport/decoding errors не смешаны без причины.
- [ ] Sensitive headers/payload redacted.
- [ ] Cache validators/invalidation/offline semantics определены.
- [ ] Network tests покрывают success/error/cancel/retry/auth paths.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
