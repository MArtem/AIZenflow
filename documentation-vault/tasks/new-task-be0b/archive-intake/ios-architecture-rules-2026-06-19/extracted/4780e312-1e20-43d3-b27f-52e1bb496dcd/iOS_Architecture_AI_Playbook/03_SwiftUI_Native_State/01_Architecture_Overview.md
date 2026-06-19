# 01_Architecture_Overview — SwiftUI Native State Architecture

## 1. Purpose

Этот документ описывает SwiftUI Native State Architecture для production iOS-приложения.

Цель — научить ИИ и разработчика использовать нативные механизмы SwiftUI правильно:

```text
@State
@Binding
@Observable
@Bindable
@Environment
@FocusState
.task
.onChange
NavigationStack
```

SwiftUI Native State — это не полноценная app architecture. Это архитектура владения UI-состоянием на уровне View/Presentation.

---

## 2. Core Idea

Главная идея SwiftUI:

```text
UI is a function of state.
```

В практическом виде:

```text
State changes
 → SwiftUI invalidates dependent views
 → body recomputes
 → UI updates
```

Поэтому главный вопрос не “какой property wrapper использовать”, а:

```text
Who owns this state?
How long does it live?
Who is allowed to mutate it?
Does it represent UI-only state, screen state, feature state, app state, or persistent state?
```

---

## 3. What SwiftUI Native State Solves

SwiftUI Native State хорошо решает:

```text
- локальное UI-состояние
- simple screen state
- reusable component state
- binding-based form controls
- focus/selection/animation flags
- simple navigation state
- environment-driven configuration
- lightweight observable screen models
```

---

## 4. What SwiftUI Native State Does Not Solve

SwiftUI Native State сам по себе не решает:

```text
- API architecture
- database/cache/offline
- DTO/Domain/UI separation
- complex business logic
- feature-level effects
- advanced testing of actions/effects
- modularization
- dependency boundaries
- complex navigation flows
```

Для этого нужно комбинировать:

```text
SwiftUI Native State + MVVM
SwiftUI Native State + Clean Architecture
SwiftUI Native State + Coordinator
SwiftUI Native State + TCA/UDF
```

---

## 5. Main Property Wrappers and Roles

### `@State`

Владелец локального state внутри View.

Использовать для:

```text
- local expansion
- selected local segment
- simple local text
- animation flags
- temporary UI-only state
```

---

### `@Binding`

Controlled child state.

Использовать для:

```text
- child modifies parent-owned state
- reusable form component
- simple two-way UI control
```

---

### `@Observable`

Observable model/state object.

Использовать для:

```text
- screen state model
- app settings model
- session model
- lightweight ViewModel-like object
```

---

### `@Environment`

Ambient dependency or context.

Использовать для:

```text
- theme
- locale
- color scheme
- app-wide models
- navigation context when designed
- feature environment if explicitly allowed
```

Не использовать как хаотичный service locator.

---

### `.task`

Lifecycle-bound async work.

Использовать для:

```text
- load on appear
- reload on id change
- async side effect tied to View lifetime
```

Не использовать для raw API call прямо из View, если архитектура требует ViewModel/UseCase.

---

## 6. Recommended Production Use

SwiftUI Native State хорошо как lower-level layer:

```text
Local visual state:
SwiftUI Native State

Screen state:
@Observable model / ViewModel / Store

Data/domain:
Clean/MVVM/Repository/UseCase

Complex effects:
TCA/UDF/Reactor/MVVM reducer-like

Navigation:
NavigationStack + Route/Coordinator
```

---

## 7. Example: Healthy Local State

```swift
struct ArticleCardView: View {
    let state: ArticleCardViewState
    let onLikeTap: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(state.title)

            if isExpanded {
                Text(state.summary)
            }

            Button(isExpanded ? "Show less" : "Show more") {
                isExpanded.toggle()
            }

            Button("Like", action: onLikeTap)
        }
    }
}
```

`isExpanded` is local visual state. It does not need ViewModel.

---

## 8. Example: Unhealthy State

```swift
struct NewsFeedView: View {
    @State private var articles: [ArticleDTO] = []
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        List(articles) { dto in
            Text(dto.title)
        }
        .task {
            isLoading = true
            articles = try! await APIClient.shared.fetchArticles()
            isLoading = false
        }
    }
}
```

Проблемы:

```text
- DTO in UI
- APIClient in View
- no error mapping
- no repository/use case boundary
- one isLoading
- try!
```

---

## 9. SwiftUI Native State as Architecture Boundary

SwiftUI Native State should own:

```text
- state required only for rendering and local interaction
```

It should not own:

```text
- API data source mechanics
- DB/cache state
- business rules
- domain invariants
- sync engine
```

---

## 10. When It Becomes Not Enough

SwiftUI Native State становится недостаточным, если появляются:

```text
- multiple async effects
- pagination
- optimistic updates
- per-card server actions
- complex error/retry
- offline/stale state
- child feature composition
- deep links
- testable action sequences
```

Тогда переходить к:

```text
MVVM
TCA/UDF
Clean + ViewModel/Store
Coordinator
```

---

## 11. Summary

SwiftUI Native State здоров, если:

```text
- state ownership clear
- local state stays local
- View body cheap
- business/data logic outside View
- Environment not abused
- .task lifecycle controlled
- derived state not recomputed expensively in body
```

Нездоров, если:

```text
- View becomes ViewModel
- @Environment becomes service locator
- @State holds server/domain/cache state
- API/DB calls inside View
- body performs heavy work
- property wrappers chosen randomly
```
