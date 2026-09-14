# AG-16 — AI feature gate

- [ ] Model/provider/profile/OS/device availability handled.
- [ ] Machine-consumed output structured/validated.
- [ ] Tool calls enforce authorization/idempotency in app code.
- [ ] Sensitive context minimized and routing policy explicit.
- [ ] Context/token budget and context-exceeded fallback defined.
- [ ] Eval dataset/threshold covers representative and adversarial cases.
- [ ] Prompt/model/profile updates regression-tested.
- [ ] Unavailable/invalid model path has product fallback.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
