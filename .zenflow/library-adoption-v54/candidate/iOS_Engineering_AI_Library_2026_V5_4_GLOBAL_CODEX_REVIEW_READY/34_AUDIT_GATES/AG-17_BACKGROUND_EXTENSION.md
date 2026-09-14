# AG-17 — Background/extensions gate

- [ ] Code assumes process can be killed at any time.
- [ ] Work idempotent/resumable and handles expiration/cancellation.
- [ ] System scheduling quotas not treated as exact timers.
- [ ] Shared containers/stores safe across processes/targets.
- [ ] Widget/watch/extension memory/time limits respected.
- [ ] Authorization/account changes handled without main app process.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
