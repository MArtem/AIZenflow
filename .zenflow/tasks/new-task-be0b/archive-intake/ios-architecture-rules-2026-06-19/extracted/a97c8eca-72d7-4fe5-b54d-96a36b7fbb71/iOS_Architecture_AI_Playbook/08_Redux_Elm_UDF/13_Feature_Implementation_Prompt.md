# 13_Feature_Implementation_Prompt — Redux / Elm / UDF

## 1. Purpose

Prompt for implementing a UDF feature.

---

## 2. Full Prompt

```text
Ты Senior/Staff iOS Architect.

Implement feature using Redux/Elm/UDF.

First produce plan:

1. Why UDF is justified.
2. State:
   - content
   - loading
   - error
   - search/filter/sort
   - pagination
   - per-item
   - navigation

3. Actions:
   - lifecycle
   - user actions
   - internal actions
   - effect response actions

4. Reducer:
   - state transitions
   - effect descriptors

5. Effects:
   - API/DB/cache calls
   - dependency clients
   - cancellation/debounce
   - error mapping

6. Store:
   - ownership
   - observation
   - dispatch

7. View:
   - renders state
   - dispatches actions

8. Tests:
   - reducer tests
   - effect tests
   - navigation tests
   - optimistic update tests

Rules:
- no state mutation outside reducer/store
- no side effects inside pure reducer
- no DTO/DBModel in state
- no APIClient in View
- no global AppState unless needed
- local visual state can remain local
```
