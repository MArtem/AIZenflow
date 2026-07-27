# 05_State_Management_Rules — MVP / Passive View

## 1. Purpose

Этот документ описывает state ownership in MVP.

---

## 2. Main Rule

```text
Presenter owns presentation state.
View owns rendered controls.
Domain/Data own business and persistent state.
```

---

## 3. View State

View may own:

```text
- UIKit control state
- text field current text
- local animation
- currently displayed ViewState
```

View should not own:

```text
- business rules
- loaded domain cache
- API state
- navigation decisions
```

---

## 4. Presenter State

Presenter may own:

```text
- current ViewState
- loading state
- selected item ID
- current page/cursor if presentation-level
- form validation presentation
```

But Presenter should not own raw persistence/cache mechanics.

---

## 5. Domain State

Domain owns:

```text
- business entities
- validation rules
- domain statuses
```

---

## 6. Data State

Data owns:

```text
- cache
- DB
- sync
- freshness metadata
```

---

## 7. Loading State

Presenter decides what loading state to display.

For complex screen, use explicit ViewState:

```swift
enum ContentState {
    case loading
    case loaded(ContentViewState)
    case empty(EmptyViewState)
    case failed(ErrorViewState)
}
```

---

## 8. Error State

Presenter maps error to user-facing state.

---

## 9. Navigation State

Presenter may hold pending route intent, but Router/Coordinator executes navigation.

---

## 10. Rule

```text
Presenter may remember presentation state, but should not become app state or data store.
```
