# 03_Global_SwiftUI_Rules

## 1. Purpose

Этот документ описывает глобальные правила SwiftUI-кода.

Он применяется ко всем архитектурам, где есть SwiftUI.

---

## 2. Main SwiftUI Rule

```text
SwiftUI View should describe UI, not own business logic.
```

---

## 3. View Responsibility

SwiftUI View может:

```text
- отображать ViewState
- держать простой local UI state
- отправлять user events наверх
- выполнять простую локальную композицию UI
- запускать controlled task через .task, если это правило архитектуры
```

SwiftUI View не должна:

```text
- напрямую дергать API
- напрямую работать с DB
- парсить JSON
- маппить DTO в UI model
- принимать бизнес-решения
- содержать cache policy
- держать сложный feature state
```

---

## 4. Body Rule

`body` должен быть дешевым.

Нельзя делать в `body`:

```text
- network calls
- database queries без controlled wrapper
- тяжелую сортировку больших массивов
- сложный маппинг DTO → UI
- создание тяжелых объектов
- side effects
```

Плохо:

```swift
var body: some View {
    let sorted = articles.sorted { $0.date > $1.date }
    return List(sorted) { article in
        ArticleRow(article: article)
    }
}
```

Лучше:

```swift
struct NewsFeedView: View {
    let state: NewsFeedViewState

    var body: some View {
        List(state.visibleArticles) { article in
            ArticleRow(state: article)
        }
    }
}
```

---

## 5. State Ownership Rules

### `@State`

Использовать для:

```text
- локального UI state
- temporary view-only state
- animation flags
- local expansion
- local focus mode
```

Не использовать для:

```text
- loaded API data
- shared feature state
- domain entities
- cache
- app session
```

### `@Binding`

Использовать для:

```text
- child view edits parent-owned state
- controlled UI component
- local reusable component
```

Не использовать для:

```text
- deep business state mutation
- passing large feature state through many levels
- replacing proper action/event flow
```

### `@Observable`

Использовать для:

```text
- observable screen model
- app/session/settings model
- state object owned outside View
```

Не использовать как excuse для:

```text
- God object
- global mutable state
- service locator
- repository inside View
```

### `@Environment`

Использовать для:

```text
- theme
- locale
- app-wide dependencies
- navigation context when architecture allows
- modelContext only when SwiftData is intentionally part of View boundary
```

Не использовать как скрытый Service Locator для всего.

Плохо:

```swift
@Environment(\.articleRepository) private var repository
```

Лучше:

```swift
@Environment(NewsFeedStore.self) private var store
```

или dependency прокидывается через ViewModel/Store assembly.

---

## 6. `.task` Rules

SwiftUI `.task` можно использовать, но контролируемо.

Допустимо:

```swift
.task {
    await viewModel.loadInitialDataIfNeeded()
}
```

Лучше для id-driven reload:

```swift
.task(id: state.selectedCategoryID) {
    await viewModel.reload(categoryID: state.selectedCategoryID)
}
```

Нельзя:

```swift
.task {
    await repository.fetchArticles()
}
```

если View напрямую знает Repository.

---

## 7. Callback Rules

Для reusable View предпочтительно:

```swift
struct ArticleCard: View {
    let state: ArticleCardViewState
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onTap: () -> Void
}
```

Для сложных action-driven фич:

```swift
struct ArticleCard: View {
    let state: ArticleCardViewState
    let send: (ArticleCardAction) -> Void
}
```

Нельзя прокидывать внутрь карточки:

```text
- Repository
- UseCase
- APIClient
- Database
- Parent ViewModel целиком без причины
```

---

## 8. Per-card State Rules

Для сложного feed:

```text
- like loading per card
- comments loading per card
- display mode per card
- optimistic like state
- image loading
- card-level error
```

Не надо создавать ViewModel на каждую карточку автоматически.

Варианты:

```text
1. Screen-level state with item states dictionary
2. Feature Store with per-item state
3. TCA child state
4. Lightweight card local state only for purely visual flags
```

Плохо:

```text
ArticleCardViewModel for every simple card by default
```

Хорошо:

```swift
struct NewsFeedViewState {
    var cards: [ArticleCardViewState]
    var cardLoading: [ArticleID: CardLoadingState]
}
```

---

## 9. View Decomposition Rules

Разбивать View нужно по смыслу, а не ради уменьшения строк любой ценой.

Хорошо:

```text
- ArticleCard
- SearchBar
- EmptyStateView
- ErrorStateView
- PaginationFooter
```

Осторожно:

```text
- @ViewBuilder private var everySmallPiece
- functions returning some View for every minor subtree
```

Если decomposition ломает читаемость или усложняет state ownership, лучше оставить локально.

---

## 10. Lazy Rendering Rules

Для больших списков:

```text
- использовать LazyVStack/List осознанно
- сохранять стабильные ids
- избегать тяжелой работы в row body
- не создавать новые heavy objects на каждый render
- pagination trigger должен быть controlled
```

Нельзя:

```text
- держать 100,000 UI models в View без стратегии
- сортировать/фильтровать огромный массив в body
- создавать nested LazyVStack без причины
```
