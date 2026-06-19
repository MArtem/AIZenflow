# 03_Module_And_Folder_Structure — MVVM

## 1. Purpose

Этот документ задает production-level структуру файлов для MVVM в iOS/SwiftUI проекте.

Цель — чтобы ИИ всегда понимал:

```text
- куда класть View
- куда класть ViewModel
- куда класть ViewState
- где живут UseCases
- где живут DTO
- где живут DB models
- где живут mappers
- где navigation
- где tests
```

---

## 2. Minimal MVVM Structure

Для простой фичи:

```text
FeatureName/
├── FeatureNameView.swift
├── FeatureNameViewModel.swift
└── FeatureNameViewState.swift
```

Допустимо только если:

```text
- нет API
- нет DB/cache
- нет сложного domain layer
- нет отдельной navigation logic
```

---

## 3. Recommended Production Structure

Для production фичи:

```text
FeatureName/
├── Presentation/
│   ├── FeatureNameView.swift
│   ├── FeatureNameViewModel.swift
│   ├── FeatureNameViewState.swift
│   ├── FeatureNameAction.swift
│   ├── Components/
│   │   ├── FeatureNameHeaderView.swift
│   │   ├── FeatureNameEmptyView.swift
│   │   └── FeatureNameErrorView.swift
│   └── Mappers/
│       └── FeatureNameViewStateMapper.swift
│
├── Domain/
│   ├── Models/
│   │   └── FeatureEntity.swift
│   ├── UseCases/
│   │   └── FetchFeatureDataUseCase.swift
│   └── Repositories/
│       └── FeatureRepositoryProtocol.swift
│
├── Data/
│   ├── DTO/
│   │   └── FeatureDTO.swift
│   ├── DB/
│   │   └── FeatureDBModel.swift
│   ├── DataSources/
│   │   ├── FeatureRemoteDataSource.swift
│   │   └── FeatureLocalDataSource.swift
│   ├── Mappers/
│   │   └── FeatureDataMapper.swift
│   └── Repositories/
│       └── FeatureRepository.swift
│
├── Navigation/
│   ├── FeatureRoute.swift
│   └── FeatureCoordinator.swift
│
└── Assembly/
    └── FeatureAssembly.swift
```

---

## 4. Presentation Folder Rules

`Presentation/` содержит только UI-facing типы:

```text
- SwiftUI Views
- ViewModel
- ViewState
- UI Actions
- UI-specific mappers
- UI-only components
```

`Presentation/` не должен содержать:

```text
- DTO
- DBModel
- APIClient
- raw URLSession logic
- database queries
- cache policy implementation
```

---

## 5. View Naming Rules

Основной экран:

```swift
NewsFeedView
ProfileView
ArticleDetailsView
```

Компоненты:

```swift
ArticleCardView
NewsFeedSearchView
NewsFeedEmptyStateView
NewsFeedErrorView
PaginationFooterView
```

Нельзя:

```swift
MainView
CustomView
CellView
DataView
CommonView
```

если имя не раскрывает доменную роль.

---

## 6. ViewModel Naming Rules

Основная ViewModel:

```swift
NewsFeedViewModel
ProfileViewModel
ArticleDetailsViewModel
```

Не использовать:

```swift
NewsFeedVM
NewsFeedManager
NewsFeedController
NewsFeedHandler
```

---

## 7. ViewState Naming Rules

State должен быть явным:

```swift
NewsFeedViewState
ArticleCardViewState
ProfileHeaderViewState
```

Не использовать:

```swift
NewsFeedModel
NewsFeedData
ScreenState
DataModel
```

---

## 8. Action Naming Rules

Если экран action-driven:

```swift
enum NewsFeedAction {
    case onAppear
    case refreshPulled
    case searchQueryChanged(String)
    case articleTapped(ArticleID)
    case likeTapped(ArticleID)
    case commentsTapped(ArticleID)
    case displayModeChanged(ArticleID, ArticleDisplayMode)
}
```

Action должен описывать событие пользователя/системы, а не команду реализации.

Лучше:

```swift
case likeTapped(ArticleID)
```

Хуже:

```swift
case callLikeAPI(ArticleID)
```

---

## 9. Domain Folder Rules

`Domain/` содержит:

```text
- entities
- value objects
- use cases
- repository protocols
- domain errors
```

`Domain/` не должен импортировать:

```text
SwiftUI
UIKit
URLSession-specific infrastructure
SwiftData/CoreData-specific models
```

---

## 10. Data Folder Rules

`Data/` содержит:

```text
- DTO
- DBModel
- API-specific data sources
- local data sources
- repository implementations
- data mappers
```

`Data/` не должен содержать SwiftUI ViewState.

---

## 11. Navigation Folder Rules

`Navigation/` содержит:

```text
- Route enum/model
- Coordinator
- Router
- navigation factory
```

ViewModel может эмитить navigation intent:

```swift
enum NewsFeedRoute: Equatable {
    case articleDetails(ArticleID)
    case comments(ArticleID)
    case loginRequired
}
```

Но ViewModel не должна создавать destination View напрямую.

---

## 12. Assembly Folder Rules

`Assembly/` отвечает за сборку dependency graph:

```swift
enum NewsFeedAssembly {
    static func makeView() -> NewsFeedView {
        let remoteDataSource = ArticleRemoteDataSource()
        let localDataSource = ArticleLocalDataSource()
        let repository = ArticleRepository(
            remote: remoteDataSource,
            local: localDataSource
        )
        let useCase = FetchArticlesUseCase(repository: repository)
        let viewModel = NewsFeedViewModel(fetchArticles: useCase)

        return NewsFeedView(viewModel: viewModel)
    }
}
```

Assembly может знать concrete dependencies. View и ViewModel — нет.

---

## 13. Tests Structure

```text
FeatureNameTests/
├── Presentation/
│   ├── FeatureNameViewModelTests.swift
│   └── FeatureNameViewStateMapperTests.swift
├── Domain/
│   └── FetchFeatureDataUseCaseTests.swift
├── Data/
│   ├── FeatureRepositoryTests.swift
│   └── FeatureDataMapperTests.swift
└── Navigation/
    └── FeatureRouteTests.swift
```

---

## 14. Forbidden Structure

Нельзя:

```text
FeatureName/
├── FeatureNameView.swift
├── FeatureNameViewModel.swift
├── FeatureNameAPI.swift
├── FeatureNameDatabase.swift
├── FeatureNameDTO.swift
└── FeatureNameEverything.swift
```

если все лежит рядом и слои не различаются.

---

## 15. Rule of Practicality

Для маленькой фичи не нужно создавать все папки сразу.

Но ИИ должен понимать будущую точку роста:

```text
Start simple, but leave a clear path to scale.
```
