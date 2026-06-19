# 08_Error_Loading_Empty_State_Rules — TCA

## 1. Purpose

Rules for loading/error/empty states in TCA.

---

## 2. Main Rule

```text
Loading, error, empty, and content are explicit parts of State.
```

---

## 3. Initial Loading

```text
.onAppear
 → state.content = .loading
 → effect fetch
 → response action
```

---

## 4. Refresh Loading

Do not erase content:

```text
state.refreshState = .refreshing
```

---

## 5. Pagination Loading

```swift
enum PaginationState: Equatable {
    case idle
    case loading
    case reachedEnd
    case failed(ErrorState)
}
```

---

## 6. Per-item Loading

Per-item action state belongs to item state:

```swift
var likeState: LoadingState
```

---

## 7. Error State

```swift
struct ErrorState: Equatable {
    let title: String
    let message: String
    let retryAction: RetryAction?
}
```

---

## 8. Alert State

Use state-driven alert/destination.

Do not show alerts from random side effects.

---

## 9. Empty State

Use explicit empty state:

```text
empty from server
no search results
no filters results
offline no cache
```

---

## 10. Rule

```text
Every user-visible state should be reproducible from State.
```
