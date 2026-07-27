# 10_Code_Generation_Rules_For_AI — Clean Architecture / Layered Architecture

## 1. Purpose

Этот документ задает правила для ИИ, который генерирует Clean Architecture код.

---

## 2. AI Role

ИИ должен вести себя как:

```text
Senior/Staff iOS Architect
Clean Architecture Guardian
Production SwiftUI Engineer
Code Reviewer
```

---

## 3. Before Generating Code

ИИ обязан определить:

```text
- feature complexity
- нужен ли full Clean или Clean light
- какие слои нужны
- есть ли API
- есть ли local JSON mock
- нужна ли DB/cache/offline
- какие модели нужны
- какие mappings нужны
- нужен ли UseCase
- нужен ли Repository protocol
- нужна ли Navigation boundary
```

---

## 4. Default Assumption

```text
Assumption:
Use Clean Architecture light with Presentation, Domain, Data, explicit DTO/Domain/ViewState separation, UseCase boundary, Repository protocol in Domain, Repository implementation in Data, and SwiftUI-first Presentation.
```

---

## 5. Required Output Before Code

Перед кодом:

```text
1. Selected Clean variant
2. Layer structure
3. Dependency direction
4. Data flow
5. Model mapping plan
6. Error handling plan
7. Cache/offline plan if applicable
8. Testing plan
```

---

## 6. Allowed Types

ИИ может создавать:

```text
Entity
ValueObject
UseCase
RepositoryProtocol
RepositoryImplementation
RemoteDataSource
LocalDataSource
DTO
DBModel
Mapper
ViewState
ViewModel/Store/Presenter
Route
Coordinator
Assembly
Tests
```

---

## 7. Forbidden by Default

ИИ не должен создавать:

```text
Manager
Helper
BaseUseCase
BaseRepository
GenericService
ServiceManager
CommonData
```

без сильной причины.

---

## 8. Dependency Rules

ИИ обязан соблюдать:

```text
Presentation → Domain
Data → Domain
Infrastructure → abstractions
Domain → nothing outer
```

Запрещено:

```text
Domain imports SwiftUI
Domain imports DTO
Domain imports DBModel
Domain imports APIClient
Repository returns ViewState
UseCase returns DTO
View uses DTO
```

---

## 9. Model Rules

ИИ обязан разделять:

```text
DTO — external API/local JSON contract
DBModel — persistence schema
Domain Model — business meaning
ViewState — UI-ready state
```

---

## 10. Mapping Rules

```text
DTO → Domain: Data layer
DTO → DBModel: Data layer
DBModel → Domain: Data layer
Domain → ViewState: Presentation layer
```

---

## 11. UseCase Rules

UseCase должен:

```text
- represent business/application scenario
- depend on repository protocol
- return Domain result
- not know SwiftUI
- not return ViewState
- not decode JSON
```

Do not create use case for every trivial property access.

---

## 12. Repository Rules

Repository implementation должен:

```text
- coordinate remote/local/cache
- implement cache policy
- map data models to Domain
- hide API/DB details
```

Repository protocol должен жить в Domain.

---

## 13. Error Rules

ИИ должен создавать error mapping:

```text
Infrastructure/Data error → Domain/App error → ErrorViewState
```

Raw error should not be shown directly.

---

## 14. Testing Rules

ИИ должен генерировать tests for:

```text
- UseCase
- mapper
- repository policy
- ViewModel/Presenter/Store
- error mapping
```

---

## 15. Self-review

После генерации проверить:

```text
- dependency direction correct
- no DTO in UI
- no DBModel in UI
- no SwiftUI in Domain
- Repository returns Domain
- UseCase returns Domain
- ViewState only in Presentation
- API/DB hidden in Data/Infrastructure
```
