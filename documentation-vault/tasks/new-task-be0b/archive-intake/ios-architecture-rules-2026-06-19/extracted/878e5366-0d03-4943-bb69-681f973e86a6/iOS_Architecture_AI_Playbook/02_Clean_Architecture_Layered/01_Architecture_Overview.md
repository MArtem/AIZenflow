# 01_Architecture_Overview — Clean Architecture / Layered Architecture

## 1. Purpose

Этот документ описывает Clean Architecture / Layered Architecture для production iOS/SwiftUI приложения.

Цель — научить ИИ и разработчика строить фичи так, чтобы UI, бизнес-логика, API, БД, cache и infrastructure не смешивались.

Clean Architecture особенно важна для проекта, где есть:

```text
- API сейчас или позже
- local JSON mock first
- database/cache/offline later
- сложные business rules
- долгосрочная поддержка
- несколько разработчиков
- необходимость тестируемости
```

---

## 2. Core Idea

Главная идея:

```text
Source code dependencies must point inward, toward business rules.
```

В iOS-практике это обычно выглядит так:

```text
Presentation
    ↓
Domain
    ↑
Data
    ↑
Infrastructure
```

Более прикладной вид:

```text
SwiftUI View
    ↓
ViewModel / Store / Presenter
    ↓
UseCase / Interactor
    ↓
Repository Protocol
    ↑
Repository Implementation
    ↓
RemoteDataSource / LocalDataSource
    ↓
API / DB / Cache / Local JSON
```

---

## 3. Main Layers

### Presentation Layer

Отвечает за:

```text
- SwiftUI/UIKit UI
- ViewState
- ViewModel/Presenter/Store
- user actions
- loading/error/empty/content state
- Domain → UI mapping
- navigation intent
```

Не отвечает за:

```text
- raw API calls
- DB queries
- DTO decoding
- cache policy implementation
- persistence schema
```

---

### Domain Layer

Отвечает за:

```text
- business entities
- value objects
- use cases
- repository protocols / ports
- domain errors
- business rules
```

Domain не должен зависеть от:

```text
- SwiftUI
- UIKit
- URLSession
- SwiftData/CoreData
- Firebase
- DTO
- DBModel
- concrete Repository implementation
```

---

### Data Layer

Отвечает за:

```text
- repository implementations
- DTO
- DB models
- API data sources
- local data sources
- DTO ↔ Domain mapping
- DBModel ↔ Domain mapping
- cache policy implementation
```

Data зависит от Domain, потому что реализует repository protocols и возвращает Domain models.

---

### Infrastructure Layer

Отвечает за:

```text
- APIClient
- HTTP transport
- Database stack
- Keychain
- File storage
- Analytics SDK adapter
- Push SDK adapter
- Logger
- configuration
```

Infrastructure — это детали реализации. Они не должны протекать в Domain и Presentation напрямую.

---

## 4. Dependency Rule

Разрешенное направление:

```text
Presentation → Domain
Data → Domain
Infrastructure → Domain abstractions if needed
App/Assembly → all layers for composition
```

Запрещенное направление:

```text
Domain → Presentation
Domain → Data
Domain → Infrastructure
Domain → SwiftUI
Domain → DTO
Domain → DBModel
```

---

## 5. Recommended Feature Shape

```text
Feature/
├── Presentation/
│   ├── View/
│   ├── ViewModel/
│   ├── ViewState/
│   ├── Actions/
│   └── Mappers/
│
├── Domain/
│   ├── Entities/
│   ├── ValueObjects/
│   ├── UseCases/
│   ├── Repositories/
│   └── Errors/
│
├── Data/
│   ├── DTO/
│   ├── DBModels/
│   ├── DataSources/
│   ├── Repositories/
│   └── Mappers/
│
├── Infrastructure/
│   ├── API/
│   ├── Persistence/
│   └── Cache/
│
├── Navigation/
└── Assembly/
```

---

## 6. Data Flow

Local JSON first:

```text
Local JSON
 → LocalJSONDataSource
 → DTO
 → Repository Implementation
 → Domain Entity
 → UseCase
 → ViewModel
 → ViewState
 → View
```

Real API later:

```text
API
 → RemoteDataSource
 → DTO
 → Repository Implementation
 → Domain Entity
 → UseCase
 → ViewModel
 → ViewState
 → View
```

DB/cache:

```text
API
 → DTO
 → DBModel
 → Database
 → DBModel
 → Domain Entity
 → UseCase
 → ViewState
```

---

## 7. Why Clean Architecture Matters in iOS

Без Clean Architecture часто возникает:

```text
SwiftUI View → APIClient → DTO → UI
```

или:

```text
ViewModel → URLSession + JSONDecoder + SwiftData + formatting + navigation
```

Это быстро работает в prototype, но плохо масштабируется.

Clean Architecture позволяет:

```text
- заменить local JSON на API
- заменить API provider
- добавить DB/cache
- тестировать UseCases без UI
- тестировать Repository без SwiftUI
- держать business rules независимо от frameworks
- уменьшить связность
```

---

## 8. Clean Architecture Is Not a UI Pattern

Clean Architecture не заменяет:

```text
- MVVM
- TCA
- VIP
- MVP
- SwiftUI Native State
```

Она работает вместе с ними.

Пример:

```text
Presentation architecture: MVVM
Data/domain architecture: Clean Architecture
Navigation architecture: Coordinator
App architecture: Modular / Feature-Sliced
```

---

## 9. Default Recommendation

Для сложного SwiftUI-продукта:

```text
Clean Architecture light by default.
Full Clean Architecture for complex features.
Avoid full ceremony for trivial screens.
```

---

## 10. Summary

Clean Architecture здорова, если:

```text
- Domain независим
- DTO не попадает в UI
- DBModel не попадает в UI
- Repository protocol отделен от implementation
- UseCase содержит business scenario
- UI получает ViewState
- Data layer скрывает API/DB/cache details
```

Clean Architecture нездорова, если:

```text
- слишком много use cases без смысла
- протоколы создаются ради протоколов
- простая кнопка требует 10 файлов
- Domain начинает зависеть от DTO/SwiftUI/DB
- Repository становится God Service
```
