# AG-08 — Test quality gate

- [ ] Tests проверяют behavior/contracts, а не private implementation trivia.
- [ ] Нет fixed sleeps, real network, uncontrolled wall clock/random/locale/timezone.
- [ ] Tests independent under parallel execution.
- [ ] Negative/cancellation/migration/race-prone paths покрыты по risk.
- [ ] Test doubles сохраняют semantic contract.
- [ ] Flaky/quarantined test имеет owner/reason, а не молчаливое игнорирование.
- [ ] Targeted suite и relevant regression suite запускались.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
