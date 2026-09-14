# AG-23 — Observability gate

- [ ] Logs use stable subsystem/category/event semantics.
- [ ] Sensitive data privacy modifiers/redaction applied.
- [ ] Correlation IDs/state transitions sufficient to debug feature.
- [ ] Signposts cover meaningful latency intervals.
- [ ] Production metrics measure success/failure/latency/cancellation.
- [ ] Dimensions avoid PII/high-cardinality explosion.
- [ ] Alert/SLO or investigation threshold defined for critical path.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
