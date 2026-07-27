# 01_Architecture_Overview — TCA / The Composable Architecture

## 1. Purpose

Этот документ описывает TCA как production-level state architecture для iOS/SwiftUI/UIKit.

TCA полезна, когда фича лучше описывается как:

```text
State
Action
Reducer
Effect
Dependency
Store
Composition
TestStore
```

Цель документа — научить ИИ писать не “похожий на TCA код”, а код с настоящим unidirectional data flow, явным состоянием, тестируемыми эффектами и строгими boundaries.

---

## 2. Core Idea

Главная идея:

```text
User/system events become Actions.
Reducer mutates State and returns Effects.
Effects perform async work and send Actions back.
View observes State and sends Actions.
```

Базовый flow:

```text
View
 → Store.send(Action)
 → Reducer
 → State mutation
 → Effect
 → Dependency/API/DB
 → Action result
 → Reducer
 → State mutation
 → View update
```

---

## 3. Main Components

### State

State — единственный источник правды для feature.

```swift
@ObservableState
struct State: Equatable {
    var cards: [ArticleCard.State] = []
    var isLoading = false
    var error: ErrorState?
}
```

State должен содержать UI/feature state, но не DTO/DBModel.

---

### Action

Action описывает событие:

```swift
enum Action: Equatable {
    case onAppear
    case refreshPulled
    case articleTapped(ArticleID)
    case likeButtonTapped(ArticleID)
    case articlesResponse(Result<[Article], AppError>)
}
```

Action — это не “команда вызвать API”, а событие, которое произошло или результат эффекта.

---

### Reducer

Reducer отвечает за:

```text
- синхронную мутацию State
- запуск Effects
- composition child reducers
- обработку result actions
```

Reducer не должен напрямую делать API call синхронно.

---

### Effect

Effect выполняет внешнюю работу:

```text
- API request
- DB read/write
- sleep/debounce
- analytics
- notification
- long-running stream
```

Effect возвращает Actions обратно в system.

---

### Dependencies

Dependencies инжектят внешние возможности:

```text
ArticleClient
DatabaseClient
AnalyticsClient
Clock
UUID generator
Date provider
```

Reducer использует dependencies через dependency system, а не через singleton.

---

### Store

Store — runtime feature, через который View наблюдает state и отправляет actions.

---

## 4. What TCA Solves

TCA хорошо решает:

```text
- сложное состояние
- много user actions
- async effects
- cancellation
- debounce
- pagination
- optimistic updates
- per-card state
- child feature composition
- navigation as state
- strict testing
- dependency injection
```

---

## 5. What TCA Does Not Solve Alone

TCA не заменяет:

```text
- app modularization
- domain modeling
- DTO/DBModel separation
- repository design
- design system
- API schema design
```

Для production лучше комбинировать:

```text
TCA + Clean Architecture
TCA + Modular / Feature-Sliced
TCA + Hexagonal Ports/Adapters
TCA + Coordinator for app-level flow when needed
```

---

## 6. Recommended Production Shape

```text
FeatureName/
├── FeatureNameFeature.swift
├── FeatureNameView.swift
├── FeatureNameModels.swift
├── FeatureNameClient.swift
├── FeatureNameMapper.swift
├── ChildFeatures/
└── Tests/
    └── FeatureNameFeatureTests.swift
```

Для Clean/Modular проекта:

```text
FeatureName/
├── Presentation/
│   ├── FeatureNameFeature.swift
│   ├── FeatureNameView.swift
│   ├── FeatureNameViewState.swift
│   └── ChildFeatures/
├── Domain/
│   ├── Entities/
│   ├── UseCases/
│   └── Repositories/
├── Data/
│   ├── DTO/
│   ├── Clients/
│   ├── Mappers/
│   └── Repositories/
└── Tests/
```

---

## 7. Healthy TCA

TCA здорова, если:

```text
- State explicit and minimal
- Actions describe events
- Reducer is readable
- Effects are cancellable where needed
- Dependencies are injected
- Child features composed intentionally
- Navigation is state-driven
- Tests cover state transitions and effects
- DTO/DBModel do not enter State/View
```

---

## 8. Unhealthy TCA

TCA нездорова, если:

```text
- один огромный AppFeature
- State содержит все приложение
- Action enum на 300 cases
- Reducer на 2000 строк
- Effects без cancellation
- dependencies через singletons
- DTO лежит в State
- every tiny view becomes feature
- navigation hacked through closures everywhere
```

---

## 9. Summary

TCA — сильный выбор для сложных state-heavy features. Но ее нужно использовать точечно и дисциплинированно.

Правило:

```text
Use TCA where explicit state/action/effect modeling gives more value than boilerplate cost.
```
