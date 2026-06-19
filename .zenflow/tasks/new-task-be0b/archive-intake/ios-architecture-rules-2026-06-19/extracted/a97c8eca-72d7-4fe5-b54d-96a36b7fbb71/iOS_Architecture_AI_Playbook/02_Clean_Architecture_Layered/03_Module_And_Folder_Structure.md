# 03_Module_And_Folder_Structure — Clean Architecture / Layered Architecture

## 1. Purpose

Этот документ задает структуру папок и файлов для Clean Architecture в iOS-проекте.

---

## 2. Standard Feature Structure

```text
FeatureName/
├── Presentation/
│   ├── Views/
│   ├── ViewModels/
│   ├── ViewStates/
│   ├── Actions/
│   ├── Mappers/
│   └── Components/
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
│   ├── Cache/
│   └── Storage/
│
├── Navigation/
│   ├── Routes/
│   └── Coordinators/
│
└── Assembly/
    └── FeatureNameAssembly.swift
```

---

## 3. Clean Light Structure

Для небольшой feature:

```text
FeatureName/
├── Presentation/
├── Domain/
├── Data/
└── Assembly/
```

Infrastructure может быть shared/app-level.

---

## 4. Presentation Rules

`Presentation/` содержит:

```text
- SwiftUI Views
- UIKit Views/Controllers if needed
- ViewModels / Presenters / Stores
- ViewState
- UI actions
- Domain → UI mappers
- UI components
```

Не содержит:

```text
- DTO
- DBModel
- APIClient
- URLSession
- raw database calls
- cache implementation
```

---

## 5. Domain Rules

`Domain/` содержит:

```text
- entities
- value objects
- use cases
- repository protocols
- domain errors
- domain services if needed
```

Domain запрещено импортировать:

```text
SwiftUI
UIKit
SwiftData
CoreData
URLSession-specific infrastructure
Firebase
Alamofire
DTO modules
DBModel modules
```

---

## 6. Data Rules

`Data/` содержит:

```text
- DTO
- DBModel
- repository implementation
- remote/local data sources
- data mappers
- cache policy implementation
```

Data может импортировать Domain.

Data не должна импортировать Presentation.

---

## 7. Infrastructure Rules

`Infrastructure/` содержит concrete technical details:

```text
- HTTPClient
- APIClient
- DatabaseClient
- KeychainClient
- FileStorage
- Logger adapter
- Analytics adapter
- Push adapter
```

Infrastructure should be replaceable behind abstractions.

---

## 8. Repository Location

Repository protocol:

```text
Domain/Repositories/ArticleRepositoryProtocol.swift
```

Repository implementation:

```text
Data/Repositories/ArticleRepository.swift
```

---

## 9. UseCase Location

```text
Domain/UseCases/FetchArticlesUseCase.swift
Domain/UseCases/LikeArticleUseCase.swift
Domain/UseCases/SearchArticlesUseCase.swift
```

UseCase names should describe business action.

---

## 10. DTO Location

```text
Data/DTO/ArticleDTO.swift
Data/DTO/AuthorDTO.swift
Data/DTO/PageDTO.swift
```

DTO should represent API/local JSON contract.

---

## 11. DBModel Location

```text
Data/DBModels/ArticleDBModel.swift
Data/DBModels/AuthorDBModel.swift
```

DBModel should represent persistence schema.

---

## 12. Mapper Location

Data mapping:

```text
Data/Mappers/ArticleDTOToDomainMapper.swift
Data/Mappers/ArticleDBModelToDomainMapper.swift
Data/Mappers/ArticleDTOToDBModelMapper.swift
```

Presentation mapping:

```text
Presentation/Mappers/ArticleCardViewStateMapper.swift
```

---

## 13. Assembly Rules

Assembly can know all layers:

```text
Assembly
 → creates Infrastructure
 → creates DataSources
 → creates Repository
 → creates UseCases
 → creates ViewModel
 → creates View
```

Assembly is composition root for the feature.

---

## 14. Naming Rules

Good names:

```text
FetchArticlesUseCase
ArticleRepositoryProtocol
ArticleRepository
ArticleRemoteDataSource
ArticleLocalDataSource
ArticleDTO
ArticleDBModel
Article
ArticleCardViewState
```

Bad names:

```text
ArticleManager
DataHelper
ServiceManager
MainModel
CommonData
BaseUseCase
```

---

## 15. Tests Structure

```text
FeatureNameTests/
├── Presentation/
├── Domain/
├── Data/
└── Infrastructure/
```

Tests mirror production layers.

---

## 16. Rule

```text
Folders must communicate architectural boundaries, not just file categories.
```
