# AG-19 — Migration gate

- [ ] Business/maintenance reason and success metric explicit.
- [ ] Inventory of legacy usage complete enough for blast radius.
- [ ] Behavior characterized by tests/metrics before migration.
- [ ] Old/new compatibility window defined.
- [ ] Data/public API/backend compatibility tested.
- [ ] Staged rollout/rollback exists for R3+.
- [ ] Cleanup criteria for legacy path explicit.
- [ ] Feature work not mixed into migration unnecessarily.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
