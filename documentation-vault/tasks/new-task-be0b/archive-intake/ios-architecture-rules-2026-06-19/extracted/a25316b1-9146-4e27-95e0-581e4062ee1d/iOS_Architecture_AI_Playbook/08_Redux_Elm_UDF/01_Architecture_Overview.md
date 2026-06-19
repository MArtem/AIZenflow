# 01_Architecture_Overview — Redux / Elm / UDF

## 1. Purpose

Этот документ описывает Redux / Elm-style / Unidirectional Data Flow architecture для iOS/SwiftUI.

Цель — научить ИИ строить state-driven features, где поведение идет по явному циклу:

```text
State → View → Action → Reducer → New State → View
```

Для production iOS это полезно, когда нужно контролировать сложное состояние, действия пользователя, async effects, side effects, logging, debugging и тестирование.

---

## 2. Core Idea

Главная идея:

```text
State is the single source of truth.
Actions describe events.
Reducer calculates new State.
Effects/Middleware handle side effects.
View renders State and dispatches Actions.
```

Базовый flow:

```text
View observes State
 → user sends Action
 → Store dispatches Action
 → Reducer creates new State
 → Middleware/Effect performs async work
 → async result dispatches another Action
 → Reducer updates State
 → View re-renders
```

---

## 3. Key Components

### State

Состояние feature или приложения.

```swift
struct NewsFeedState: Equatable {
    var content: ContentState<[ArticleCardState]> = .idle
    var searchQuery: String = ""
    var pagination: PaginationState = .idle
}
```

---

### Action

Событие, которое произошло.

```swift
enum NewsFeedAction: Equatable {
    case onAppear
    case refreshPulled
    case searchQueryChanged(String)
    case articleTapped(ArticleID)
    case likeTapped(ArticleID)
    case feedLoaded(Result<[Article], AppError>)
}
```

---

### Reducer

Чистая или почти чистая функция:

```text
(State, Action) → State
```

Иногда:

```text
(State, Action) → (State, Effect)
```

---

### Store

Хранит State, принимает Actions, запускает Reducer и публикует новый State.

---

### Middleware / Effects

Отвечают за side effects:

```text
- API calls
- DB operations
- analytics
- debounce
- cancellation
- logging
- navigation commands if architecture allows
```

---

## 4. Elm-style Architecture

Elm-style flow:

```text
Model
Update
View
Cmd
```

iOS-аналог:

```text
State
Reducer
SwiftUI View
Effect
```

---

## 5. Redux-style Architecture

Redux-style flow:

```text
Store
Action
Reducer
Middleware
State
```

В iOS это может быть:

```text
AppStore
FeatureStore
Reducer
EffectRunner
Dependency clients
```

---

## 6. UDF

UDF — более общий термин.

```text
Data flows in one direction.
Mutation happens through controlled actions.
```

---

## 7. Difference From MVVM

MVVM:

```text
View → ViewModel methods → state changes
```

Redux/UDF:

```text
View → Action → Reducer → State
```

Redux/UDF лучше, когда нужно:

```text
- action log
- deterministic state transitions
- complex state machine
- predictable async result handling
- easier replay/debugging
```

---

## 8. Difference From TCA

TCA — production-grade Swift implementation of composable UDF with strong patterns for dependencies, effects, testing, navigation, and composition.

Redux/UDF может быть:

```text
- custom lightweight implementation
- framework-independent
- less opinionated
- simpler than TCA for some teams
```

Но custom UDF требует дисциплины.

---

## 9. Recommended Production Shape

```text
FeatureName/
├── FeatureNameState.swift
├── FeatureNameAction.swift
├── FeatureNameReducer.swift
├── FeatureNameStore.swift
├── FeatureNameEffects.swift
├── FeatureNameView.swift
├── FeatureNameDependencies.swift
└── Tests/
```

С Clean:

```text
Presentation/
  State
  Action
  Reducer
  Store
  View

Domain/
  UseCases
  Entities

Data/
  Repositories
  DTO
  DBModels
```

---

## 10. Healthy UDF

Здоровая UDF architecture:

```text
- State explicit
- Actions event-like
- Reducer deterministic
- Effects outside reducer
- View only renders and dispatches
- no random state mutation
- tests cover reducer behavior
- DTO/DBModel not in State/View
```

---

## 11. Unhealthy UDF

Нездоровая UDF:

```text
- global AppState contains everything
- one giant reducer
- actions are imperative commands
- side effects inside reducer
- state mutated outside store
- middleware becomes God Object
- no cancellation
- no tests
```

---

## 12. Summary

Redux/Elm/UDF хороши, если нужно сделать feature predictable, testable, loggable and state-driven.

Правило:

```text
Use UDF when predictability of state transitions is more important than minimal boilerplate.
```
