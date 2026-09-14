# AG-07 — Persistence/data gate

- [ ] Schema change имеет migration plan до release.
- [ ] Production-like previous store fixtures мигрируются в tests.
- [ ] Context/actor ownership корректен; thread-bound objects не передаются незаконно.
- [ ] Uniqueness/delete rules/transactions защищают domain invariants.
- [ ] Destructive reset не является default recovery.
- [ ] Offline conflict/idempotency определены.
- [ ] Large fetch/blob/cache memory budget учтён.
- [ ] Rollback/downgrade semantics определены если продукт их требует.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
