# 13_Feature_Implementation_Prompt — Clean Architecture / Layered Architecture

## 1. Purpose

Prompt for implementing a new feature with Clean Architecture.

---

## 2. Full Prompt

```text
Ты Senior/Staff iOS Architect.

Нужно реализовать новую iOS SwiftUI feature по Clean Architecture.

Сначала не пиши код. Сначала сделай архитектурный план:

1. Определи вариант:
   - Clean light
   - Full Clean
   - Clean + MVVM
   - Clean + TCA/UDF
   - Clean + Coordinator

2. Опиши layers:
   - Presentation
   - Domain
   - Data
   - Infrastructure if needed
   - Navigation
   - Assembly
   - Tests

3. Опиши dependency direction.

4. Опиши model types:
   - DTO
   - DBModel if needed
   - Domain Model
   - ViewState
   - Error model
   - Route model

5. Опиши data flow:
   API/local JSON/DB/cache → Data → Domain → Presentation → View

6. Опиши mapping:
   - DTO → Domain
   - DTO → DBModel
   - DBModel → Domain
   - Domain → ViewState

7. Опиши cache/offline behavior:
   - cache policy
   - stale data
   - fallback
   - sync if needed

8. Опиши navigation:
   - Route enum
   - Coordinator/Router
   - no navigation in Domain/Data

9. Опиши testing plan:
   - UseCase tests
   - mapper tests
   - Repository tests
   - Presentation tests
   - cache/offline tests

После плана сгенерируй код по слоям:

1. Domain:
   - Entity
   - ValueObject
   - RepositoryProtocol
   - UseCase
   - Domain errors

2. Data:
   - DTO
   - DBModel if needed
   - RemoteDataSource
   - LocalDataSource
   - Mappers
   - Repository implementation

3. Presentation:
   - ViewState
   - ViewStateMapper
   - ViewModel/Store
   - View

4. Navigation:
   - Route
   - Coordinator boundary

5. Assembly:
   - dependency composition

6. Tests:
   - domain/data/presentation tests

Обязательные запреты:
- no DTO in View
- no DBModel in View
- no SwiftUI in Domain
- no APIClient in UseCase
- no ViewState in Repository
- no DTO returned from UseCase
- no cache policy in View
```

---

## 3. User Input Template

```text
Feature name:
...

UI:
SwiftUI / UIKit / mixed

Data:
local JSON / real API / DB / cache / offline

Business rules:
...

Actions:
...

Navigation:
...

State:
simple / medium / complex

Special:
pagination / search / sync / optimistic update / validation / auth / deep links
```
