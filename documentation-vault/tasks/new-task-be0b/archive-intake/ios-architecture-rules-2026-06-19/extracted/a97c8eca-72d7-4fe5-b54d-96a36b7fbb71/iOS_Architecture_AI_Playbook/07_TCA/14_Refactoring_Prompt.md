# 14_Refactoring_Prompt — TCA

## 1. Purpose

Prompt for refactoring existing code to TCA or cleaning existing TCA.

---

## 2. Full Prompt

```text
Ты Senior/Staff iOS Architect and TCA expert.

Analyze code and decide if TCA is justified.

Find problems:
1. ViewModel with many actions/state/effects.
2. Async race conditions.
3. Missing cancellation/debounce.
4. Scattered loading/error/per-item state.
5. DTO/DBModel in UI.
6. Existing TCA reducer too large.
7. Action enum not event-like.
8. Effects not tested.
9. Dependencies via singleton.
10. Navigation not state-driven.

Migration plan:
Step 1: Identify feature State.
Step 2: Identify Actions.
Step 3: Extract dependencies into clients.
Step 4: Move async work into Effects.
Step 5: Model navigation as State.
Step 6: Add TestStore tests.
Step 7: Split child features only where needed.
Step 8: Remove DTO/DBModel from State/UI.

Rules:
- no big bang app rewrite
- migrate one feature at a time
- preserve behavior
- do not TCA-ify trivial components
- write tests during migration
```
