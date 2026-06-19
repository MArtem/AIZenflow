# 08_Error_Loading_Empty_State_Rules — MVC / Massive ViewController / Migration

## 1. Purpose

Rules for extracting loading/error/empty state from Massive ViewController.

---

## 2. Bad Pattern

```text
isLoading
hasError
errorLabel.isHidden
emptyView.isHidden
tableView.isHidden
```

spread across many methods.

---

## 3. First Improvement

Create explicit view state:

```swift
enum ScreenViewState {
    case loading
    case content([CellViewState])
    case empty(EmptyViewState)
    case error(ErrorViewState)
}
```

---

## 4. Render Function

ViewController should have one rendering entry:

```swift
func render(_ state: ScreenViewState)
```

---

## 5. Refresh State

Do not replace content on refresh.

```swift
struct ScreenState {
    var content: ContentState
    var refresh: RefreshState
}
```

---

## 6. Pagination State

Model separately:

```text
pagination idle/loading/failed/reachedEnd
```

---

## 7. Per-item State

Move cell action loading out of cell when action affects server/domain.

---

## 8. Error Mapping

ViewController should receive:

```text
ErrorViewState
```

not raw `Error`.

---

## 9. Empty Semantics

Differentiate:

```text
empty from server
no search results
offline no cache
filtered empty
```

---

## 10. Rule

```text
Rendering should become a pure consequence of ViewState, not scattered boolean visibility updates.
```
