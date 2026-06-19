# 05_State_Management_Rules — Redux / Elm / UDF

## 1. Purpose

Этот документ описывает state management в UDF.

---

## 2. Main Rule

```text
State changes only through Actions and Reducers.
```

---

## 3. State Should Contain

```text
- data required to render
- loading/error/empty states
- user input
- filters/search/sort
- pagination
- per-item states
- navigation state
```

---

## 4. State Should Not Contain

```text
- APIClient
- Repository instance
- DTO
- DBModel
- SwiftUI View
- UIKit controller
- unmanaged Task
- random closures
```

---

## 5. Feature State vs App State

Prefer feature state.

Avoid giant global state unless needed.

```text
AppState
  AuthState
  SettingsState
  NewsState
```

can work, but only if disciplined.

---

## 6. Global State Risks

Risks:

```text
- too many unrelated actions
- slow mental model
- accidental coupling
- every feature observes too much
- hard refactoring
```

---

## 7. Local UI State

Do not force all local state into global store.

Local SwiftUI `@State` is acceptable for:

```text
- purely visual expansion
- focus
- animation
- transient local UI flags
```

---

## 8. Per-item State

For feed:

```swift
struct NewsFeedState: Equatable {
    var cards: [ArticleID: ArticleCardState]
    var visibleIDs: [ArticleID]
}
```

or identified array style.

---

## 9. Loading State

Avoid one isLoading for all operations.

Use:

```text
content loading
refresh loading
pagination loading
per-item loading
```

---

## 10. Error State

Model error explicitly:

```text
full-screen error
inline error
toast/banner
per-item error
```

---

## 11. Rule

```text
State must be explicit enough to reproduce UI and behavior from action history.
```
