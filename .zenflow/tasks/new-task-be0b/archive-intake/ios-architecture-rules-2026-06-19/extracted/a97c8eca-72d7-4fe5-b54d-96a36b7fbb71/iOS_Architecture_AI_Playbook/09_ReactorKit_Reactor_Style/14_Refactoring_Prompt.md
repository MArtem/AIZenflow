# 14_Refactoring_Prompt — ReactorKit / Reactor-style Architecture

## 1. Purpose

Prompt for refactoring RxSwift code into Reactor-style architecture.

---

## 2. Full Prompt

```text
Ты Senior iOS Architect and RxSwift/ReactorKit expert.

Analyze current RxSwift/iOS code and decide if Reactor-style is appropriate.

Find:
1. Business logic in ViewController bindings.
2. API calls in View binding.
3. Multiple scattered subscriptions.
4. Inconsistent loading/error state.
5. DTO/DBModel in UI state.
6. No single state output.
7. Navigation hidden in random subscriptions.
8. Massive Reactor or ViewController.
9. Side effects in reduce().
10. Missing tests.

Migration:
Step 1: Identify view events → Actions.
Step 2: Identify state changes → Mutations.
Step 3: Define State.
Step 4: Move side effects to mutate().
Step 5: Move state transitions to reduce().
Step 6: Move API/DB to UseCase/Repository dependencies.
Step 7: Move navigation to route/output/coordinator.
Step 8: Add reduce/mutate tests.
Step 9: Simplify bindings.

Rules:
- no big bang rewrite
- migrate one screen/flow at a time
- keep Rx chains readable
- preserve behavior
```
