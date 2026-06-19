# 14_Refactoring_Prompt — Redux / Elm / UDF

## 1. Purpose

Prompt for refactoring existing code into UDF.

---

## 2. Full Prompt

```text
Ты Senior/Staff iOS Architect.

Analyze existing iOS feature and decide if UDF is appropriate.

Find:
1. Hidden state mutations.
2. Too many ViewModel methods.
3. Async race conditions.
4. Missing cancellation/debounce.
5. Side effects in View.
6. Side effects mixed with state mutation.
7. DTO/DBModel in UI state.
8. Loading/error booleans conflicts.
9. Navigation hidden in closures.
10. Missing tests.

Migration:
Step 1: Identify feature State.
Step 2: Identify Actions from user/system/effect events.
Step 3: Move state changes into Reducer.
Step 4: Move side effects into Effects/Middleware.
Step 5: Introduce Store.
Step 6: Make View render State and dispatch Actions.
Step 7: Model navigation as State/Output.
Step 8: Add reducer/effect tests.
Step 9: Keep local visual state local.

Rules:
- migrate one feature at a time
- no big bang rewrite
- do not create global store for everything
- preserve behavior
```
