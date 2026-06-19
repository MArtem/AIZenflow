# 13_Feature_Implementation_Prompt — TCA

## 1. Purpose

Prompt for implementing a feature in TCA.

---

## 2. Full Prompt

```text
Ты Senior/Staff iOS Architect and TCA expert.

Implement a SwiftUI feature using TCA.

First, do not write code. Produce architecture plan:

1. Why TCA is justified.
2. State model:
   - content
   - loading
   - error
   - navigation
   - per-item
   - pagination/search if needed

3. Action model:
   - lifecycle
   - user actions
   - internal actions
   - response actions
   - child actions
   - navigation actions

4. Dependencies:
   - clients
   - live/test behavior
   - clock/date/uuid if needed

5. Reducer flow:
   - action handling
   - state mutations
   - effects
   - cancellation/debounce

6. View:
   - observe store
   - send actions
   - scope child stores

7. Navigation:
   - destination/path state
   - sheet/alert if needed

8. Tests:
   - success/failure
   - empty
   - navigation
   - cancellation
   - optimistic update
   - pagination/search

Rules:
- no APIClient.shared in reducer
- no DTO/DBModel in State
- no side effects in View
- no direct state mutation from View
- no child reducer for trivial component
- use TestStore tests
```
