# 03_Module_And_Folder_Structure — Redux / Elm / UDF

## 1. Purpose

Этот документ задает структуру файлов для UDF feature.

---

## 2. Minimal Structure

```text
FeatureName/
├── FeatureNameState.swift
├── FeatureNameAction.swift
├── FeatureNameReducer.swift
├── FeatureNameStore.swift
└── FeatureNameView.swift
```

---

## 3. Production Structure

```text
FeatureName/
├── Presentation/
│   ├── FeatureNameView.swift
│   ├── FeatureNameState.swift
│   ├── FeatureNameAction.swift
│   ├── FeatureNameReducer.swift
│   ├── FeatureNameStore.swift
│   ├── FeatureNameEffects.swift
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
│   └── FeatureNameRoute.swift
│
└── Tests/
    ├── FeatureNameReducerTests.swift
    ├── FeatureNameStoreTests.swift
    └── FeatureNameEffectsTests.swift
```

---

## 4. State File

Contains feature state:

```swift
struct NewsFeedState: Equatable {
    var content: ContentState<[ArticleCardState]> = .idle
    var searchQuery: String = ""
}
```

---

## 5. Action File

Contains events:

```swift
enum NewsFeedAction: Equatable {
    case onAppear
    case refreshPulled
    case searchQueryChanged(String)
    case feedResponse(Result<[Article], AppError>)
}
```

---

## 6. Reducer File

Contains state transition logic.

```swift
func newsFeedReducer(
    state: inout NewsFeedState,
    action: NewsFeedAction
) -> Effect<NewsFeedAction> {
    // mutate state and return effect
}
```

---

## 7. Store File

Owns state and dispatch:

```swift
@Observable
final class Store<State, Action> {
    private(set) var state: State

    func send(_ action: Action) {
        // reducer + effects
    }
}
```

---

## 8. Effects File

Contains side-effect logic or effect factories.

---

## 9. Dependencies

Could be separate:

```text
FeatureNameEnvironment.swift
FeatureNameDependencies.swift
FeatureNameClients.swift
```

---

## 10. Tests

Reducer tests should be central.

---

## 11. Rule

```text
UDF files should make the State → Action → Reducer → Effect loop obvious.
```
