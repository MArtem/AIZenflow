# 14_Refactoring_Prompt — SwiftUI Native State Architecture

## 1. Purpose

Prompt for refactoring SwiftUI code with bad state ownership.

---

## 2. Full Refactoring Prompt

```text
Ты Senior/Staff iOS Architect и Senior SwiftUI Engineer.

Нужно отрефакторить SwiftUI code с проблемным state management.

Сначала найди:

1. State ownership issues:
   - too many @State vars
   - unclear owner
   - duplicated state
   - derived state stored unnecessarily
   - app state in local View

2. Data boundary issues:
   - APIClient in View
   - Repository in small component
   - DTO in @State/View
   - DBModel in View
   - cache policy in View

3. Body issues:
   - heavy work in body
   - side effects in body
   - unstable identity
   - expensive mapping/sorting/filtering

4. Async issues:
   - raw API in .task
   - no cancellation
   - try? swallowing errors
   - Task.detached in View

5. Environment issues:
   - Environment as service locator
   - hidden dependencies
   - too many environment objects

6. Navigation issues:
   - DTO/DBModel in route
   - complex flow in local View
   - deep link parsing in body

После анализа предложи migration plan:

Step 1:
Classify all state by ownership.

Step 2:
Keep local visual state in @State.

Step 3:
Convert parent-child editable state to @Binding.

Step 4:
Move screen state to @Observable model or ViewModel.

Step 5:
Move API/DB/cache to Repository/UseCase boundary.

Step 6:
Replace many booleans with explicit state enum.

Step 7:
Move heavy derived work outside body.

Step 8:
Replace business-sensitive bindings with actions.

Step 9:
Extract route model/coordinator if needed.

Step 10:
Add tests for moved state logic.

Rules:
- do not rewrite entire feature if small steps enough
- do not introduce MVVM/TCA if state is purely local
- do not keep raw API in View
- preserve UI behavior unless explicitly changed
```

---

## 3. Output Format

```text
1. Current state problems
2. State ownership table
3. Target structure
4. Step-by-step refactor
5. Code examples
6. Tests to add
7. Final checklist
```

---

## 4. Common Refactors

### Many @State vars → ScreenState

```text
isLoading/isError/isEmpty/items
 → ContentState
```

### API in View → Model/ViewModel

```text
.task raw API
 → .task { await model.load() }
 → model calls UseCase/Repository
```

### DTO in View → ViewState

```text
ArticleDTO
 → Article
 → ArticleCardViewState
```

### Heavy body → prepared state

```text
body sorting/filtering
 → model.visibleItems
```
