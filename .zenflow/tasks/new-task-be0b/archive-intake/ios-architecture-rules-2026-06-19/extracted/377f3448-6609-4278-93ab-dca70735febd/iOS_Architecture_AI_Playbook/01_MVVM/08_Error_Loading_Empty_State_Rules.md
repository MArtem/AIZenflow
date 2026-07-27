# 08_Error_Loading_Empty_State_Rules — MVVM

## 1. Purpose

Этот документ задает правила loading, error, empty, offline и per-item states в MVVM.

---

## 2. Main Rule

```text
Every non-trivial MVVM screen must explicitly model loading, error, empty, and content states.
```

---

## 3. Content State

Рекомендуемый вариант:

```swift
enum ContentState<Content: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Content)
    case empty(EmptyViewState)
    case failed(ErrorViewState)
}
```

Для конкретного экрана:

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

## 4. Initial Loading

Initial loading используется при первом открытии экрана без данных.

```text
View appears
 → state.content = .loading
 → load data
 → loaded/empty/failed
```

---

## 5. Refresh Loading

Pull-to-refresh не должен стирать content.

Плохо:

```text
User pulls to refresh
 → state.content = .loading
 → old content disappears
```

Лучше:

```text
User pulls to refresh
 → state.refreshState = .refreshing
 → old content remains visible
```

---

## 6. Pagination Loading

Pagination loading отдельно:

```swift
enum PaginationState: Equatable {
    case idle
    case loadingNextPage
    case reachedEnd
    case failed(ErrorViewState)
}
```

Не использовать full-screen loader для pagination.

---

## 7. Per-card Loading

Для card actions:

```swift
enum CardActionState: Equatable {
    case idle
    case loading
    case failed(message: String)
}
```

Пример:

```swift
struct ArticleCardViewState: Equatable {
    var isLiked: Bool
    var likeState: CardActionState
    var commentsState: CardActionState
}
```

---

## 8. Error Types

Различать:

```text
- full-screen error
- inline error
- banner error
- toast error
- card-level error
- field-level error
- offline warning
- stale data warning
```

---

## 9. Full-screen Error

Использовать если:

```text
- нет данных
- невозможно показать основной content
- initial load failed
- cache empty and offline
```

---

## 10. Inline Error

Использовать если:

```text
- content уже есть
- refresh failed
- pagination failed
- part of screen failed
```

---

## 11. Empty State

Empty state должен объяснять причину:

```text
- no articles yet
- no search results
- no filters results
- no saved items
- no cache while offline
```

Не использовать один generic empty state для всех случаев.

---

## 12. No Search Results

```swift
EmptyViewState(
    title: "No results",
    message: "Try changing your search query.",
    actionTitle: "Clear search"
)
```

ViewModel должна понимать, что это не “server empty”, а search/filter empty.

---

## 13. Offline State

Offline не всегда ошибка.

Сценарии:

```text
- showing cached data + offline banner
- no cache + full-screen offline error
- stale data + retry button
- optimistic update pending until online
```

---

## 14. Retry

ErrorViewState должен содержать retry action или retry intent:

```swift
struct ErrorViewState<Action: Equatable>: Equatable {
    let title: String
    let message: String
    let retryAction: Action?
}
```

Если generic complicates UI, можно использовать explicit closure на View boundary, но state-driven retry легче тестировать.

---

## 15. Rule

```text
Loading, error, and empty are not booleans.
They are explicit user-facing states.
```
