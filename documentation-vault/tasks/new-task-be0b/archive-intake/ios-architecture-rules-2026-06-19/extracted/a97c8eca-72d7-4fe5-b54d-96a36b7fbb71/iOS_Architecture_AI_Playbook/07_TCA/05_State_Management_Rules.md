# 05_State_Management_Rules — TCA

## 1. Purpose

Этот документ описывает правила State в TCA.

---

## 2. Main Rule

```text
State must contain the minimal source of truth required to render and drive feature behavior.
```

---

## 3. State Should Contain

```text
- content state
- loaded domain/UI data
- search query
- filters
- pagination state
- per-item states
- destination/navigation state
- alert/sheet state
- in-flight flags where needed
```

---

## 4. State Should Not Contain

```text
- DTO
- DBModel
- APIClient
- Repository
- URLSession task
- SwiftData ModelContext
- UIViewController
- SwiftUI View
- closures
```

---

## 5. Content State

```swift
enum ContentState: Equatable {
    case idle
    case loading
    case loaded([ArticleCardFeature.State])
    case empty(EmptyState)
    case failed(ErrorState)
}
```

---

## 6. Per-card State

Use child feature state if card has behavior:

```swift
var cards: IdentifiedArrayOf<ArticleCardFeature.State>
```

Use simple ViewState if card is dumb.

---

## 7. Derived State

Avoid duplicating derived state.

Good:

```text
store raw source + query
compute visible items in reducer when query changes
```

Avoid expensive computation in View body.

---

## 8. Global State

Do not put entire app state into one giant TCA State by default.

Prefer:

```text
feature state
scoped child state
shared dependencies/stores if needed
```

---

## 9. Navigation State

Use explicit destination/path state.

Do not navigate through random closures.

---

## 10. Loading State

Avoid one `isLoading` for everything.

Use:

```text
initial loading
refresh loading
pagination loading
per-card loading
```

---

## 11. Rule

```text
If state can change feature behavior, it should be modeled explicitly.
```
