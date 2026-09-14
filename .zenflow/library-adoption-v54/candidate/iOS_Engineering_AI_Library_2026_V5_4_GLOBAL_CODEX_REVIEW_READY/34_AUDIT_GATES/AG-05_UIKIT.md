# AG-05 — UIKit production gate

- [ ] Lifecycle setup/binding/loading/teardown размещены корректно.
- [ ] Child containment add/remove contract соблюдён.
- [ ] UI mutations main-thread/MainActor safe.
- [ ] Reuse-bound tasks/observers отменяются/сбрасываются.
- [ ] Delegates/closures/timers/NotificationCenter/display links проверены на retain cycles.
- [ ] Auto Layout работает при Dynamic Type/rotation/supported sizes.
- [ ] Diffable/reload updates сохраняют identity/state.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
