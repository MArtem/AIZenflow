# 01_Architecture_Overview — ReactorKit / Reactor-style Architecture

## 1. Purpose

Этот документ описывает ReactorKit / Reactor-style Architecture для iOS.

ReactorKit — это reactive + unidirectional architecture, особенно популярная в RxSwift-based проектах.

Цель — научить ИИ и разработчика использовать Reactor-style подход так, чтобы:

```text
- View не содержала бизнес-логику
- Action описывал user interaction
- Mutation был мостом между Action и State
- State был единственным выходом Reactor для View
- side effects жили в mutate()
- state mutation жила в reduce()
```

---

## 2. Core Idea

Главная идея:

```text
View sends Action.
Reactor transforms Action into Mutation.
Reactor reduces Mutation into State.
View observes State.
```

Flow:

```text
View
 → Action
 → Reactor.mutate(action:)
 → Mutation
 → Reactor.reduce(state:mutation:)
 → State
 → View
```

---

## 3. Main Components

### Action

Action описывает событие из View:

```swift
enum Action {
    case viewDidLoad
    case refresh
    case searchQueryChanged(String)
    case likeTapped(ArticleID)
}
```

Action не должен называться как implementation command:

```text
callAPI
setLoadingFalse
doNetworkRequest
```

---

### Mutation

Mutation — изменение, которое должно быть применено к State.

```swift
enum Mutation {
    case setLoading(Bool)
    case setArticles([ArticleCardState])
    case setError(ErrorState?)
    case updateLikeState(ArticleID, LikeState)
}
```

Mutation is a bridge between Action and State.

---

### State

State — view state.

```swift
struct State {
    var isLoading: Bool = false
    var articles: [ArticleCardState] = []
    var error: ErrorState?
}
```

State должен быть UI-facing, но не должен содержать DTO/DBModel.

---

### Reactor

Reactor принимает Action, создает Mutation, редьюсит Mutation в State.

```swift
final class NewsFeedReactor: Reactor {
    enum Action { ... }
    enum Mutation { ... }
    struct State { ... }

    let initialState: State

    func mutate(action: Action) -> Observable<Mutation> {
        ...
    }

    func reduce(state: State, mutation: Mutation) -> State {
        ...
    }
}
```

---

## 4. What Reactor-style Solves

Reactor-style помогает:

```text
- отделить View binding от state logic
- сделать unidirectional flow
- централизовать side effects
- управлять Rx streams
- тестировать state transitions
- моделировать loading/error/content
- контролировать async chains
```

---

## 5. What Reactor-style Does Not Solve

ReactorKit сам не решает:

```text
- Clean Architecture boundaries
- DTO/Domain/DB/UI separation
- module structure
- app navigation architecture
- offline/cache policy
```

Его нужно комбинировать с:

```text
Clean Architecture
Repository
Coordinator/RxFlow
Modular Architecture
Hexagonal Ports/Adapters
```

---

## 6. Recommended Production Shape

```text
FeatureName/
├── Presentation/
│   ├── FeatureNameViewController.swift / FeatureNameView.swift
│   ├── FeatureNameReactor.swift
│   ├── FeatureNameState.swift
│   ├── FeatureNameMutation.swift
│   ├── FeatureNameViewStateMapper.swift
│   └── Components/
│
├── Domain/
│   ├── Entities/
│   ├── UseCases/
│   └── Repositories/
│
├── Data/
│   ├── DTO/
│   ├── DBModels/
│   ├── Mappers/
│   └── Repositories/
│
├── Navigation/
└── Tests/
```

---

## 7. Healthy Reactor

Здоровый Reactor:

```text
- Action describes user/system event
- mutate() handles side effects
- reduce() is pure state transition
- State is explicit
- View binds Action and State only
- dependencies injected
- no DTO/DBModel in State
- no business logic in View binding
- Rx subscriptions disposed correctly
```

---

## 8. Unhealthy Reactor

Нездоровый Reactor:

```text
- View binding contains business logic
- mutate() becomes massive service layer
- reduce() has side effects
- State contains API DTO
- Reactor directly owns too many services
- Rx chains unreadable
- navigation mixed randomly
- no tests
```

---

## 9. Summary

ReactorKit / Reactor-style подходит, если проект уже использует RxSwift/RxCocoa и нужен строгий unidirectional flow.

Правило:

```text
Use Reactor-style when reactive streams and state transitions are central to the feature.
```
