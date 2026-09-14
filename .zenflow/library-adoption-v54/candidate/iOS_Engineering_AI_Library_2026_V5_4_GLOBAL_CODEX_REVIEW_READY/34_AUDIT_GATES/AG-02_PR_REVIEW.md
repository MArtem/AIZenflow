# AG-02 — Risk-based PR gate

- [ ] Проверен diff и surrounding callers/owners, не только изменённые строки.
- [ ] Для каждого finding есть failure scenario и violated invariant.
- [ ] Severity отражает blast radius/likelihood, а не вкусовщину.
- [ ] Проверены concurrency/ARC/lifecycle/errors/tests/security/privacy/a11y/performance по применимости.
- [ ] Public/API/schema/deeplink/event changes имеют compatibility analysis.
- [ ] Review не перегружен style findings, принадлежащими formatter/linter.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
