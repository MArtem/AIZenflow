# 05_State_Management_Rules — MVC / Massive ViewController / Migration

## 1. Purpose

Этот документ описывает state management problems in Massive ViewController and migration targets.

---

## 2. Massive VC State Symptoms

```text
var isLoading = false
var isRefreshing = false
var isPaginating = false
var hasError = false
var selectedItem: DTO?
var cachedItems: [DTO]
var routeToOpen: UIViewController?
```

Проблема: state is mixed and implicit.

---

## 3. Local UI State Can Stay

ViewController/View can keep:

```text
- local animation flags
- selected segmented control if purely visual
- text field first responder
- scroll offset if UI-only
```

---

## 4. Screen State Should Move

Move to:

```text
ViewModel
Presenter
Store
Interactor
```

if it controls behavior:

```text
content
loading
error
empty
pagination
search
filters
per-item server state
```

---

## 5. Persistent State Should Move

Persistent/cache state belongs to:

```text
Repository
LocalDataSource
Database layer
Sync service
```

---

## 6. Navigation State Should Move

Navigation state belongs to:

```text
Coordinator
Router
Route model
ViewModel route intent
```

---

## 7. Explicit State

Replace conflicting booleans with:

```swift
enum ContentState<Value> {
    case idle
    case loading
    case loaded(Value)
    case empty
    case failed(ErrorViewState)
}
```

---

## 8. Per-item State

For list/card server actions:

```text
Move per-item loading/optimistic state out of cells and into screen state owner.
```

---

## 9. Derived State

Avoid recomputing heavy derived data in `viewDidLayoutSubviews`, `cellForRow`, or SwiftUI `body`.

Prepare in mapper/ViewModel/Presenter.

---

## 10. Rule

```text
State should move to the layer that owns the decision it represents.
```
