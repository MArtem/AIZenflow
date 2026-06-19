# 08_Error_Loading_Empty_State_Rules — MVP / Passive View

## 1. Purpose

Rules for loading/error/empty state in MVP.

---

## 2. Main Rule

```text
Presenter creates user-facing loading/error/empty ViewState.
View only displays it.
```

---

## 3. Loading

Simple:

```swift
view.display(.loading)
```

Complex:

```swift
view.display(ContentState.loading)
view.displayRefreshState(.refreshing)
view.displayPaginationState(.loading)
```

---

## 4. Error

Presenter maps error:

```swift
let errorState = ErrorViewState(
    title: "Something went wrong",
    message: "Try again later"
)
view.displayError(errorState)
```

---

## 5. Empty

Presenter decides semantic empty state:

```text
No items
No search results
No saved content
Offline no cache
```

---

## 6. Refresh

Refresh should not remove content unless intended.

---

## 7. Pagination

Pagination loading/error should be inline/bottom, not full-screen.

---

## 8. Per-item Loading

Presenter can update a specific card ViewState.

---

## 9. Rule

```text
View should not decide what error/empty/loading means.
```
