# 08_Error_Loading_Empty_State_Rules — Redux / Elm / UDF

## 1. Purpose

Rules for loading/error/empty state in UDF.

---

## 2. Main Rule

```text
User-visible state should be represented in State.
```

---

## 3. Content State

```swift
enum ContentState<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case empty(EmptyState)
    case failed(ErrorState)
}
```

---

## 4. Refresh

Refresh separate from content.

```swift
var refreshState: RefreshState
```

---

## 5. Pagination

```swift
var paginationState: PaginationState
```

---

## 6. Per-item Loading

```swift
struct ArticleCardState {
    var likeState: LoadingState
}
```

---

## 7. Error Handling

Effect catches error and dispatches failure action.

Reducer maps to UI state.

---

## 8. Empty State

Reducer determines empty after successful response with no items or filtered no results.

---

## 9. Offline

Offline with cache:

```text
state.content remains loaded
state.banner = offline/stale
```

Offline no cache:

```text
state.content = .failed/offlineEmpty
```

---

## 10. Rule

```text
No hidden loading or error state outside Store.
```
