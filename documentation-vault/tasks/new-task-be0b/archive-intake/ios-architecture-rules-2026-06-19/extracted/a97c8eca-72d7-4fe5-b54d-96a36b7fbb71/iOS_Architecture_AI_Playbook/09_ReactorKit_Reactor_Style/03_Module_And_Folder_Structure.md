# 03_Module_And_Folder_Structure — ReactorKit / Reactor-style Architecture

## 1. Purpose

Этот документ задает структуру файлов для ReactorKit/Reactor-style feature.

---

## 2. Minimal Structure

```text
FeatureName/
├── FeatureNameViewController.swift
├── FeatureNameReactor.swift
└── FeatureNameReactorTests.swift
```

---

## 3. Production Structure

```text
FeatureName/
├── Presentation/
│   ├── Views/
│   │   └── FeatureNameViewController.swift
│   ├── Reactors/
│   │   └── FeatureNameReactor.swift
│   ├── ViewStates/
│   ├── Mappers/
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
│   ├── DataSources/
│   ├── Repositories/
│   └── Mappers/
│
├── Navigation/
└── Tests/
```

---

## 4. Reactor File

`FeatureNameReactor.swift` contains:

```text
Action
Mutation
State
initialState
dependencies
mutate(action:)
reduce(state:mutation:)
transform if needed
```

---

## 5. View File

View/ViewController contains:

```text
bind(reactor:)
action bindings
state bindings
dispose bag
UI rendering
```

View should not contain:

```text
business logic
API call
DTO mapping
cache policy
complex state mutation
```

---

## 6. Dependencies

Inject dependencies:

```swift
final class NewsFeedReactor: Reactor {
    private let fetchFeedUseCase: FetchFeedUseCase
}
```

Avoid:

```swift
APIClient.shared
Database.shared
```

inside Reactor.

---

## 7. Mapper Files

Data mapper:

```text
DTO → Domain
DBModel → Domain
```

Presentation mapper:

```text
Domain → State/ViewState
```

---

## 8. Navigation Folder

Navigation can be:

```text
Coordinator
RxFlow Stepper
Route enum
Output relay
```

depending on project.

---

## 9. Tests Structure

```text
Tests/
├── FeatureNameReactorTests.swift
├── FeatureNameMapperTests.swift
├── FeatureNameUseCaseTests.swift
└── FeatureNameRepositoryTests.swift
```

---

## 10. Rule

```text
Reactor folder should make Action → Mutation → State flow obvious.
```
