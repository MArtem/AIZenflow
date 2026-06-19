# 01_Architecture_Overview — MVVM

## 1. Purpose

Этот документ описывает MVVM как production-level архитектуру для сложного iOS-продукта.

Цель документа — научить ИИ и разработчика использовать MVVM не как “View + огромная ViewModel”, а как контролируемый presentation-layer паттерн, который может работать вместе с Clean Architecture, Repository, UseCase, Coordinator, SwiftUI Native State и модульной структурой.

---

## 2. Core Idea

MVVM разделяет экран на три основные роли:

```text
Model
ViewModel
View
```

В реальном production iOS-приложении это обычно выглядит так:

```text
SwiftUI View
    ↓ user events
ViewModel
    ↓ use case calls
UseCase / Service / Repository
    ↓ data access
API / DB / Cache / Local JSON
```

Главная идея:

```text
View отвечает за отображение.
ViewModel отвечает за состояние экрана и реакцию на действия пользователя.
Model/Data/Domain слои отвечают за данные и бизнес-логику.
```

---

## 3. What MVVM Solves

MVVM помогает:

```text
- убрать бизнес-логику из View
- держать состояние экрана в одном месте
- тестировать presentation logic без UI
- отделить UI rendering от загрузки данных
- сделать SwiftUI View декларативной
- централизовать loading/error/empty state
- отделить user actions от UI layout
```

---

## 4. What MVVM Does Not Solve

MVVM сам по себе не решает:

```text
- модульную структуру приложения
- offline-first architecture
- cache policy
- сложную навигацию
- dependency inversion
- separation DTO/DB/Domain/UI
- app-wide state
- feature composition
```

Для этих задач MVVM нужно комбинировать с другими подходами:

```text
MVVM + Clean Architecture
MVVM + Repository
MVVM + Coordinator
MVVM + Feature-Sliced Modules
MVVM + Hexagonal data boundaries
```

---

## 5. Recommended Production Shape

Для сложного SwiftUI-продукта MVVM лучше использовать в таком виде:

```text
Feature/
├── Presentation/
│   ├── NewsFeedView.swift
│   ├── NewsFeedViewModel.swift
│   ├── NewsFeedViewState.swift
│   ├── NewsFeedAction.swift
│   ├── ArticleCardView.swift
│   └── ArticleCardViewState.swift
│
├── Domain/
│   ├── Article.swift
│   ├── ArticleID.swift
│   ├── FetchArticlesUseCase.swift
│   └── ArticleRepositoryProtocol.swift
│
├── Data/
│   ├── ArticleRepository.swift
│   ├── ArticleRemoteDataSource.swift
│   ├── ArticleLocalDataSource.swift
│   ├── ArticleDTO.swift
│   ├── ArticleDBModel.swift
│   └── ArticleMapper.swift
│
└── Navigation/
    └── NewsFeedRoute.swift
```

---

## 6. Responsibilities

### View

View может:

```text
- отображать ViewState
- держать простой local UI state
- отправлять события во ViewModel
- показывать loading/error/empty/content states
- вызывать callbacks для navigation intent
```

View не должна:

```text
- напрямую вызывать Repository
- напрямую вызывать APIClient
- декодировать JSON
- знать DTO/DBModel
- содержать бизнес-логику
- содержать cache policy
```

---

### ViewModel

ViewModel может:

```text
- владеть состоянием экрана
- принимать user actions
- вызывать UseCase/Repository boundary
- управлять loading/error/empty/content state
- делать presentation mapping Domain → ViewState
- запускать async операции
- обрабатывать cancellation
- отдавать navigation intent наружу
```

ViewModel не должна:

```text
- напрямую работать с URLSession
- напрямую работать с raw DB API без repository/use case
- декодировать DTO из JSON
- становиться God Object
- знать layout details
- хранить DTO как state
- хранить DBModel как state
```

---

### Model

В MVVM слово `Model` часто слишком размытое. В production-проекте нужно различать:

```text
DTO
Domain Model
DB Model
UI Model / ViewState
Route Model
Error Model
```

Нельзя использовать один `ArticleModel` для всего.

---

## 7. Data Flow

Базовый data flow:

```text
View appears
 → ViewModel.load()
 → FetchArticlesUseCase.execute()
 → ArticleRepository.fetch()
 → Remote/LocalDataSource
 → DTO/DBModel
 → Domain Model
 → ViewModel maps Domain → ViewState
 → View renders ViewState
```

---

## 8. Action Flow

Базовый action flow:

```text
User taps Like
 → View sends .likeTapped(articleID)
 → ViewModel validates state
 → ViewModel applies optimistic state
 → ViewModel calls LikeArticleUseCase
 → Repository sends API request
 → ViewModel confirms or rolls back
 → View updates from state
```

---

## 9. MVVM with SwiftUI

Для современного SwiftUI можно использовать:

```text
@Observable
@State
@StateObject / ObservableObject for older code
@Environment for injected screen object when justified
async/await
.task
```

Но SwiftUI state property wrappers не заменяют архитектуру.

Плохо:

```swift
struct NewsFeedView: View {
    @State private var articles: [ArticleDTO] = []

    var body: some View {
        List(articles) { article in
            Text(article.title)
        }
        .task {
            articles = try! await APIClient.shared.fetchArticles()
        }
    }
}
```

Хорошо:

```swift
struct NewsFeedView: View {
    @State private var viewModel: NewsFeedViewModel

    var body: some View {
        NewsFeedContentView(
            state: viewModel.state,
            onAction: viewModel.send
        )
        .task {
            await viewModel.send(.onAppear)
        }
    }
}
```

---

## 10. MVVM Is Not Enough for Everything

Если экран имеет:

```text
- много nested state
- complex effects
- many child features
- undo/replay
- strict action testing
- complex reducer logic
```

то стоит рассмотреть:

```text
TCA
Redux/UDF
MVVM + reducer-like state
```

Если проблема в навигации, MVVM не должен решать ее в одиночку. Нужно добавить:

```text
Coordinator
Router
Route models
Navigation events
```

---

## 11. Default Recommendation

Для большинства production SwiftUI экранов:

```text
MVVM light + UseCase/Repository + explicit ViewState
```

Для сложных экранов:

```text
MVVM + reducer-style actions/state
```

Для очень сложных state-heavy features:

```text
TCA/UDF instead of plain MVVM
```

---

## 12. Summary

MVVM хорош, если:

```text
- ViewModel тонкая и контролируемая
- ViewState явный
- DTO/DBModel не попадают в UI
- navigation имеет boundary
- async операции управляемы
- бизнес-логика вынесена в UseCase/Domain
- data access идет через Repository
```

MVVM плох, если:

```text
- ViewModel превращается в 1000 строк
- ViewModel знает все обо всем
- View напрямую работает с API
- DTO используются в SwiftUI
- navigation, cache, analytics, formatting и business logic смешаны
```
