# AG-04 — SwiftUI production gate

- [ ] Source of truth и ownership очевидны.
- [ ] Нет duplicated derived state без controlled invalidation.
- [ ] ForEach/navigation identity стабильна семантически.
- [ ] body не выполняет side effects/expensive uncontrolled work.
- [ ] Async work cancel/stale-result safe.
- [ ] Loading/content/empty/error/offline states определены.
- [ ] Presentation state не допускает impossible competing presentations.
- [ ] Dynamic Type/VoiceOver/RTL/adaptive layout проверены по scope.
- [ ] Observation availability соответствует target.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
