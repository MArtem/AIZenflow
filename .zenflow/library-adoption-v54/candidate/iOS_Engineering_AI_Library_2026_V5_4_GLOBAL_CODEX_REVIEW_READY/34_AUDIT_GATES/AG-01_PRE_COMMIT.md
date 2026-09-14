# AG-01 — Pre-commit code gate

- [ ] Изменение соответствует ticket/observable outcome и не содержит unrelated refactor.
- [ ] Нет новых force unwrap/cast/try! без доказанного invariant.
- [ ] Нет suppression warning/lint/concurrency вместо исправления причины.
- [ ] Новые async tasks имеют owner/cancellation story.
- [ ] Errors/cancellation/empty/offline path определены по применимости.
- [ ] Tests добавлены/обновлены для изменённого поведения.
- [ ] Secrets/PII не попали в source/fixtures/logs.
- [ ] Availability соответствует deployment target.
- [ ] Diff перечитан целиком после автоматических edits.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
