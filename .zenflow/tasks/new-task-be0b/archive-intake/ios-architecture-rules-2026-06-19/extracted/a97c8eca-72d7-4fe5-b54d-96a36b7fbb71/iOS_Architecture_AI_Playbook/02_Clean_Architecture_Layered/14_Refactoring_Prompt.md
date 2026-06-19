# 14_Refactoring_Prompt — Clean Architecture / Layered Architecture

## 1. Purpose

Prompt for refactoring existing code toward Clean Architecture.

---

## 2. Full Refactoring Prompt

```text
Ты Senior/Staff iOS Architect.

Нужно отрефакторить существующий iOS-код в Clean Architecture.

Не делай big bang rewrite. Сначала проанализируй код.

Найди нарушения:

1. Dependency Rule:
   - Domain зависит от SwiftUI/UIKit/API/DB/DTO
   - Presentation знает infrastructure details
   - Data зависит от Presentation

2. Model leakage:
   - DTO используется в UI
   - DBModel используется в UI
   - ViewState используется в Repository
   - UseCase возвращает DTO

3. Responsibility violations:
   - View делает API/DB
   - ViewModel декодирует JSON
   - Repository форматирует UI
   - UseCase работает с URLSession
   - Domain знает navigation

4. Missing boundaries:
   - нет UseCase
   - нет Repository protocol
   - нет mappers
   - нет error mapping
   - нет cache policy

После анализа предложи incremental migration plan:

Step 1:
Добавить characterization tests around current behavior.

Step 2:
Выделить DTO из UI.

Step 3:
Создать Domain Model.

Step 4:
Создать mapper DTO → Domain.

Step 5:
Создать Repository protocol in Domain.

Step 6:
Перенести API/DB logic в Data layer.

Step 7:
Создать UseCase for business/application flow.

Step 8:
Создать ViewState and Domain → ViewState mapper.

Step 9:
Перенести navigation в Presentation/Coordinator.

Step 10:
Добавить tests for use cases, mappers, repository and presentation.

Правила:
- каждый шаг должен быть small and safe
- не менять UI behavior без причины
- не смешивать refactor and redesign
- не вводить все слои, если feature trivial
- не создавать protocol explosion
```

---

## 3. Output Format

```text
1. Current architecture problems
2. Dependency violations
3. Model leakage
4. Target Clean structure
5. Incremental migration steps
6. Files to create/change
7. Tests to add
8. Risks
9. Example code for first safe step
10. Final review checklist
```

---

## 4. Common Migrations

### From API in ViewModel

```text
ViewModel API call
 → RemoteDataSource
 → DTO
 → Repository
 → UseCase
 → ViewModel gets Domain
```

### From DTO in UI

```text
ArticleDTO in View
 → Article Domain Model
 → ArticleCardViewState
 → View renders ViewState
```

### From DBModel in UI

```text
DBModel in View
 → DBModel → Domain mapper
 → Domain → ViewState mapper
```

### From God Repository

```text
Repository with everything
 → split RemoteDataSource
 → split LocalDataSource
 → split Mapper
 → keep Repository as policy coordinator
```
