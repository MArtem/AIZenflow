# 05_State_Management_Rules — MVVM

## 1. Purpose

Этот документ определяет, как управлять состоянием в MVVM.

Главная цель — не допустить Massive ViewModel и хаотичного `@State`.

---

## 2. Main Rule

```text
ViewModel owns screen state.
View owns local visual state.
Domain/Data layers own no UI state.
```

---

## 3. State Categories

В MVVM нужно различать:

```text
- Local UI State
- Screen State
- Feature State
- App State
- Persistent State
- Derived State
- Per-item State
- Navigation State
```

---

## 4. Local UI State

Живет во View:

```text
- локальная анимация
- local expanded/collapsed flag
- focus state
- temporary UI-only toggle
```

Пример:

```swift
@State private var isSearchFocused = false
@State private var isFilterPanelExpanded = false
```

Но если state влияет на загрузку данных, фильтрацию или business logic — он должен перейти во ViewModel.

---

## 5. Screen State

Живет во ViewModel:

```swift
@Observable
@MainActor
final class NewsFeedViewModel {
    private(set) var state: NewsFeedViewState

    func send(_ action: NewsFeedAction) async {
        // handle action
    }
}
```

---

## 6. Recommended ViewState Shape

```swift
struct NewsFeedViewState: Equatable {
    var searchQuery: String
    var content: NewsFeedContentState
    var refreshState: RefreshState
    var paginationState: PaginationState
    var selectedDisplayMode: ArticleDisplayMode
    var route: NewsFeedRoute?
}
```

Content state:

```swift
enum NewsFeedContentState: Equatable {
    case idle
    case loading
    case loaded([ArticleCardViewState])
    case empty(EmptyViewState)
    case failed(ErrorViewState)
}
```

---

## 7. Loading State

Не использовать один `isLoading` для всего сложного экрана.

Плохо:

```swift
var isLoading: Bool
```

Лучше:

```swift
var initialLoadingState: LoadingState
var refreshState: RefreshState
var paginationState: PaginationState
var cardLoading: [ArticleID: CardLoadingState]
```

---

## 8. Error State

Ошибка должна быть частью ViewState:

```swift
struct ErrorViewState: Equatable {
    let title: String
    let message: String
    let retryAction: NewsFeedAction?
}
```

Различать:

```text
- full-screen error
- inline error
- card-level error
- toast/banner error
- stale data warning
```

---

## 9. Empty State

Empty state не равен loading и не равен error.

```swift
struct EmptyViewState: Equatable {
    let title: String
    let message: String
    let actionTitle: String?
}
```

Различать:

```text
- truly empty
- no search results
- no filter results
- offline and no cache
```

---

## 10. Per-card State

Для feed/card-heavy экранов:

```swift
struct ArticleCardViewState: Identifiable, Equatable {
    let id: ArticleID
    var title: String
    var summary: String
    var isLiked: Bool
    var likeState: LoadingState
    var commentsState: LoadingState
    var displayMode: ArticleDisplayMode
}
```

Можно хранить:

```swift
var cards: [ArticleCardViewState]
```

или:

```swift
var cardStatesByID: [ArticleID: ArticleCardViewState]
var visibleCardIDs: [ArticleID]
```

Для больших списков второй вариант может быть лучше.

---

## 11. Derived State

Derived state не должен дублироваться без причины.

Плохо:

```swift
var articles: [Article]
var visibleArticles: [Article]
var filteredArticles: [Article]
var searchResults: [Article]
```

если все они синхронно зависят друг от друга.

Лучше:

```swift
var allArticles: [Article]
var searchQuery: String

var visibleArticles: [Article] {
    filter(allArticles, by: searchQuery)
}
```

Но для тяжелой фильтрации large datasets derived result можно кешировать во ViewModel, не в View body.

---

## 12. App State

App-wide state не должен жить в feature ViewModel.

Не хранить в `NewsFeedViewModel`:

```text
- auth session
- user profile global state
- app settings global state
- feature flags global state
```

Использовать:

```text
SessionStore
SettingsStore
AppEnvironment
Dependency container
```

---

## 13. Navigation State

ViewModel может иметь route intent:

```swift
var route: NewsFeedRoute?
```

Но она не должна создавать destination View:

```swift
// Forbidden inside ViewModel
ArticleDetailsView(articleID: id)
```

---

## 14. State Mutation Rule

State должен изменяться только внутри ViewModel methods.

Плохо:

```swift
viewModel.state.cards[0].isLiked = true
```

из View.

Лучше:

```swift
viewModel.send(.likeTapped(articleID))
```

---

## 15. Massive ViewModel Warning

Если ViewModel содержит:

```text
- 15+ dependencies
- 50+ public methods
- API parsing
- DB logic
- navigation construction
- analytics everywhere
- formatting everywhere
- 800+ lines
```

она требует декомпозиции.
