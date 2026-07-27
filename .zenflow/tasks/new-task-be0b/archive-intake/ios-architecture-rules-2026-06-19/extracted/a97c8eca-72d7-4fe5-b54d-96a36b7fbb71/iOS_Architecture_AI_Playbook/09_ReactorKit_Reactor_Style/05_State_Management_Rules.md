# 05_State_Management_Rules — ReactorKit / Reactor-style Architecture

## 1. Purpose

Этот документ описывает State в Reactor-style architecture.

---

## 2. Main Rule

```text
State represents View state and is the only output View should render.
```

---

## 3. State Should Contain

```text
- content
- loading state
- error state
- search query
- filters
- pagination
- per-item loading
- route/output if chosen
```

---

## 4. State Should Not Contain

```text
- DTO
- DBModel
- APIClient
- Repository object
- DisposeBag
- Observable chains
- UIViewController
- SwiftUI View
```

---

## 5. Mutation Rules

Mutation should represent state changes:

```text
setLoading
setItems
appendItems
setError
updateCard
setRoute
```

Mutation should not represent raw user event.

---

## 6. Action vs Mutation

Action:

```text
user/system event
```

Mutation:

```text
state change intent
```

Example:

```text
Action.likeTapped(id)
Mutation.setLiked(id, true)
Mutation.setLikeLoading(id, false)
```

---

## 7. Loading State

Avoid one isLoading for all complex screens.

Use:

```text
initial loading
refresh loading
pagination loading
per-item loading
```

---

## 8. Error State

Model:

```text
full-screen error
inline error
toast/banner
per-item error
```

---

## 9. Derived State

Avoid heavy derived computation in View binding.

Prepare state in Reactor or mapper.

---

## 10. Rule

```text
If View needs it to render or bind behavior, it belongs in State. If it is technical mechanism, it does not.
```
