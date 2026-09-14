# AG-09 — Performance gate

- [ ] Есть explicit user-visible metric и baseline.
- [ ] Bottleneck подтверждён Instruments/MetricKit/signposts/measurements.
- [ ] Before/after workload сопоставим.
- [ ] Optimization не создаёт unbounded cache/task/buffer.
- [ ] Main-thread stalls/image decode/DB/network payload проверены по issue class.
- [ ] CPU/memory/energy trade-off записан.
- [ ] Regression guard/production metric определён для high-risk change.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
