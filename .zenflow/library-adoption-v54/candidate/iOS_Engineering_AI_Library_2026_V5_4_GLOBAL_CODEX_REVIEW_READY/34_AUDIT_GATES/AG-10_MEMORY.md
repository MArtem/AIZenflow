# AG-10 — Memory/lifetime gate

- [ ] Owner каждого long-lived object/task/subscription понятен.
- [ ] Closures/delegates/timers/observers/tasks проверены на cycles.
- [ ] weak/unowned соответствует реальному lifetime invariant.
- [ ] Images/buffers/cache bounds заданы.
- [ ] Leak fix подтверждён deinit/Memory Graph/Allocations evidence.
- [ ] Process/scene/reuse teardown paths проверены.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
