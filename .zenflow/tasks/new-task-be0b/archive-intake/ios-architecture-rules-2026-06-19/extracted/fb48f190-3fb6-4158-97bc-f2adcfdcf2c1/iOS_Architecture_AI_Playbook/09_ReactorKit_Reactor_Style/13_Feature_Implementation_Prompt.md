# 13_Feature_Implementation_Prompt — ReactorKit / Reactor-style Architecture

## 1. Purpose

Prompt for implementing a Reactor-style feature.

---

## 2. Full Prompt

```text
Ты Senior iOS Architect and ReactorKit/RxSwift expert.

Implement feature using Reactor-style architecture.

First, do not write code. Produce plan:

1. Is Reactor-style justified?
   - RxSwift/RxCocoa usage
   - reactive inputs
   - async streams
   - state complexity

2. Action model:
   - user actions
   - lifecycle actions
   - system actions

3. Mutation model:
   - loading
   - content
   - error
   - pagination
   - per-item updates
   - route/output if needed

4. State model:
   - UI-facing state
   - no DTO/DBModel

5. mutate(action:) flows:
   - side effects
   - use case/repository calls
   - debounce/cancellation
   - error mapping

6. reduce(state:mutation:) transitions:
   - pure state updates

7. View binding:
   - action binding
   - state binding
   - dispose bag

8. Navigation:
   - route/output/coordinator/RxFlow

9. Tests:
   - reduce
   - mutate
   - async success/failure
   - debounce/cancellation
   - optimistic update

Rules:
- no business logic in View binding
- no side effects in reduce()
- no DTO/DBModel in State
- no APIClient.shared
- no Reactor for tiny dumb component
```
