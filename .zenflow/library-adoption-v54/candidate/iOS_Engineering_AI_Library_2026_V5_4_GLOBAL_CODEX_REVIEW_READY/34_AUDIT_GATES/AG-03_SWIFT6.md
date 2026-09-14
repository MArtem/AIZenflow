# AG-03 — Swift 6 concurrency gate

- [ ] Affected modules проходят strict/complete concurrency expectations проекта.
- [ ] Mutable shared state имеет явную isolation strategy.
- [ ] Cross-actor values/captures Sendable либо ownership переработан.
- [ ] Каждый @unchecked Sendable имеет документированный synchronization invariant и review.
- [ ] Task.detached используется только при конкретной необходимости.
- [ ] Task lifetime/cancellation owner определён.
- [ ] Actor invariants пересмотрены после каждого await.
- [ ] Heavy CPU/I-O не помещены на MainActor для подавления diagnostics.
- [ ] Continuation resume exactly once; cancellation story определена.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
