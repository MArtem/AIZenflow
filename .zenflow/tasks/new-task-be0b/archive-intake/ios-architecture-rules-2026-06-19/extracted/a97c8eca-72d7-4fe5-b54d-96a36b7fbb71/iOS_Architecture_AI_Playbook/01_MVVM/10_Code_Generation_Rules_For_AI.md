# 10_Code_Generation_Rules_For_AI — MVVM

## 1. Purpose

Этот документ задает жесткие правила для ИИ-модели, которая генерирует MVVM-код.

---

## 2. AI Role

При работе с MVVM ИИ должен действовать как:

```text
Senior/Staff iOS Architect
Senior SwiftUI Engineer
Production MVVM Reviewer
Architecture Boundary Guardian
```

---

## 3. Before Generating MVVM Code

ИИ обязан определить:

```text
- SwiftUI or UIKit
- simple MVVM or MVVM + Clean
- нужен ли API
- нужен ли local JSON mock
- нужна ли БД/cache/offline
- есть ли navigation
- есть ли pagination
- есть ли optimistic update
- есть ли per-card state
- нужны ли UseCases
- нужны ли DTO/DB/Domain/UI models
```

---

## 4. Default Assumption

Если пользователь не уточнил, ИИ может принять:

```text
Assumption:
Use SwiftUI-first MVVM with explicit ViewState, async/await, UseCase boundary, Repository abstraction, and no direct API/DB access from View or ViewModel.
```

---

## 5. Required Output Before Code

Для крупной фичи ИИ сначала пишет:

```text
1. Selected MVVM variant
2. File structure
3. Data flow
4. State flow
5. Navigation flow
6. Dependency flow
7. Testing plan
```

---

## 6. Allowed Files

ИИ может создавать:

```text
FeatureView.swift
FeatureViewModel.swift
FeatureViewState.swift
FeatureAction.swift
FeatureRoute.swift
FeatureAssembly.swift
FeatureViewStateMapper.swift
UseCase.swift
RepositoryProtocol.swift
Repository.swift
RemoteDataSource.swift
LocalDataSource.swift
DTO.swift
DBModel.swift
DataMapper.swift
Tests.swift
```

---

## 7. Forbidden Files by Default

ИИ не должен создавать без причины:

```text
FeatureManager.swift
FeatureHelper.swift
FeatureServiceManager.swift
BaseViewModel.swift
GenericViewModel.swift
CommonViewModel.swift
SuperViewModel.swift
```

---

## 8. View Generation Rules

SwiftUI View должна:

```text
- принимать ViewModel или ViewState/action boundary
- отображать state
- отправлять action
- не содержать API/DB/cache
- не маппить DTO
- не держать сложный state
```

---

## 9. ViewModel Generation Rules

ViewModel должна:

```text
- быть @MainActor, если мутирует UI state
- иметь private dependencies
- получать dependencies через init
- иметь private(set) state
- принимать actions через send(_:)
- использовать async/await контролируемо
- маппить Domain → ViewState
```

---

## 10. ViewModel Must Not

```text
- create URLRequest
- decode JSON
- import SwiftData just to fetch feature data
- hold DTO state
- hold DBModel state
- create destination SwiftUI views
- use APIClient.shared directly
- become a giant method dump
```

---

## 11. Action Rules

Для не-trivial экранов ИИ должен создавать Action enum:

```swift
enum FeatureAction {
    case onAppear
    case refreshPulled
    case retryTapped
    case itemTapped(ItemID)
}
```

Не генерировать 20 public methods, если лучше один action вход.

---

## 12. State Rules

ИИ должен создавать explicit ViewState.

Плохо:

```swift
@Published var articles: [Article] = []
@Published var isLoading = false
@Published var error: String?
```

Лучше:

```swift
private(set) var state: NewsFeedViewState
```

---

## 13. Async Rules

ИИ должен:

```text
- обрабатывать CancellationError
- не блокировать MainActor тяжелой работой
- не делать Task.detached без причины
- не запускать network call в body
- не использовать try? для важной операции
```

---

## 14. Mapping Rules

ИИ должен разделять:

```text
DTO → Domain
Domain → ViewState
DBModel → Domain
```

---

## 15. AI Final Self-Review

После генерации ИИ должен проверить:

```text
- View does not know Repository
- View does not know DTO
- ViewModel does not know API endpoint
- ViewModel does not return destination View
- DTO/DBModel are not in ViewState
- loading/error/empty states exist
- tests cover ViewModel logic
```
