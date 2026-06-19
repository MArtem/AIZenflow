# 13_Feature_Implementation_Prompt — MVVM

## 1. Purpose

Этот документ содержит промпт для генерации новой фичи в MVVM.

---

## 2. Full Feature Implementation Prompt

```text
Ты Senior/Staff iOS Architect.

Нужно реализовать новую iOS SwiftUI feature в MVVM.

Сначала не пиши код. Сначала проанализируй feature и выведи:

1. MVVM variant:
   - MVVM light
   - MVVM + UseCase
   - MVVM + Clean
   - MVVM + Coordinator
   - MVVM + reducer-like state

2. Почему выбран этот вариант.

3. File structure:
   - Presentation
   - Domain
   - Data
   - Navigation
   - Assembly
   - Tests

4. Data flow:
   - API/local JSON/DB/cache → DTO/DBModel → Domain → ViewState → View

5. State flow:
   - initial
   - loading
   - loaded
   - empty
   - failed
   - refresh
   - pagination
   - per-item/per-card state if needed

6. Action flow:
   - user actions
   - ViewModel send(_:)
   - use case calls
   - optimistic updates if needed

7. Navigation flow:
   - route enum
   - coordinator/router boundary
   - no destination View creation inside ViewModel

8. Testing plan:
   - ViewModel tests
   - mapper tests
   - use case tests
   - repository tests if data layer exists
   - route tests

После этого сгенерируй код в таком порядке:

1. Domain models
2. DTO/DBModel if needed
3. Mappers
4. Repository protocol
5. Data sources
6. Repository implementation
7. UseCases
8. ViewState
9. Action enum
10. ViewModel
11. SwiftUI View
12. Route/Coordinator boundary
13. Tests

Обязательные правила:

- View не знает APIClient, Repository, DTO, DBModel.
- ViewModel не знает raw API endpoint, URLSession, DB query, JSON decoder.
- DTO не используется в UI.
- DBModel не используется в UI.
- Repository не возвращает ViewState.
- UseCase не возвращает DTO.
- ViewState должен быть готов для отображения.
- Loading/error/empty states должны быть explicit.
- async/await должен учитывать MainActor и cancellation.
- Не создавать протоколы без причины.
- Не создавать отдельный ViewModel для каждого маленького component.
```

---

## 3. Input Template for User

```text
Feature name:
...

Screen type:
...

UI framework:
SwiftUI / UIKit / Mixed

Data source:
local JSON / API / DB / cache / unknown

Offline/cache required:
yes / no / later

Actions:
...

Navigation:
...

State complexity:
simple / medium / complex

Special requirements:
pagination / search / optimistic update / per-card loading / filters / forms / deep links / analytics
```

---

## 4. Example Feature Request

```text
Feature name:
NewsFeed

Screen:
List of articles with search, likes, comments button, display mode per card, pagination and pull-to-refresh.

Data:
Local JSON first, real API later. Cache/DB required later.

Architecture:
SwiftUI MVVM + UseCase + Repository + Coordinator.

Requirements:
- DTO → Domain → ViewState
- per-card like loading
- optimistic like update
- comments navigation
- no Repository in View
- ViewModel tests
```

---

## 5. Expected AI Output Structure

```text
1. Architecture choice
2. File tree
3. Data flow
4. State flow
5. Navigation flow
6. Tests plan
7. Code
8. Self-review checklist
```
