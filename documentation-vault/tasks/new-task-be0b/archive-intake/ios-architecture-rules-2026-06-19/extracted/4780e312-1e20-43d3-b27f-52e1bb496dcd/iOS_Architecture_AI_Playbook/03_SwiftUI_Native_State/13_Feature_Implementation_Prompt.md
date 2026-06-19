# 13_Feature_Implementation_Prompt — SwiftUI Native State Architecture

## 1. Purpose

Prompt for implementing a feature using SwiftUI Native State where appropriate.

---

## 2. Full Prompt

```text
Ты Senior/Staff iOS Architect и Senior SwiftUI Engineer.

Нужно реализовать SwiftUI feature с правильным использованием нативного состояния.

Сначала не пиши код. Сначала проанализируй:

1. State inventory:
   - local visual state
   - screen state
   - feature state
   - app state
   - persistent state

2. State ownership:
   - @State
   - @Binding
   - @Observable
   - @Environment
   - external ViewModel/Store/Repository if needed

3. Complexity decision:
   - pure SwiftUI Native State enough?
   - need @Observable screen model?
   - need MVVM?
   - need Clean Architecture?
   - need TCA/UDF?
   - need Coordinator?

4. Data flow:
   - local only
   - model/ViewModel boundary
   - repository/use case boundary if API/DB/cache exists

5. Navigation:
   - local NavigationStack
   - route enum
   - coordinator if complex

6. Loading/error/empty:
   - booleans if trivial
   - explicit state enum if non-trivial

После анализа сгенерируй код.

Обязательные правила:
- no raw API/DB/cache in View
- no heavy work in body
- no DTO/DBModel in UI for production feature
- property wrapper must match state ownership
- use actions for business-sensitive mutations
- do not create ViewModel for tiny dumb component
- do not keep complex feature state as many unrelated @State vars
```

---

## 3. Input Template

```text
Feature:
...

State:
local / screen / feature / app / persistent

Data:
none / local only / API / DB / cache

Actions:
...

Navigation:
simple / complex / deep links

Complexity:
simple / medium / complex

Special:
forms / focus / search / pagination / offline / optimistic updates
```

---

## 4. Expected Output

```text
1. State ownership plan
2. Property wrapper choices
3. Escalation decision
4. File structure
5. Data flow
6. Navigation flow
7. Code
8. Self-review
```
