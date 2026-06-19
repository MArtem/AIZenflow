# 03_Module_And_Folder_Structure — TCA

## 1. Purpose

Этот документ задает структуру файлов для TCA feature.

---

## 2. Minimal Feature Structure

```text
FeatureName/
├── FeatureNameFeature.swift
├── FeatureNameView.swift
└── FeatureNameFeatureTests.swift
```

Подходит для небольшой TCA-фичи.

---

## 3. Production Structure

```text
FeatureName/
├── Presentation/
│   ├── FeatureNameFeature.swift
│   ├── FeatureNameView.swift
│   ├── FeatureNameViewState.swift
│   ├── FeatureNameModels.swift
│   └── Components/
│
├── ChildFeatures/
│   ├── CardFeature/
│   └── FilterFeature/
│
├── Dependencies/
│   ├── FeatureNameClient.swift
│   └── FeatureNameClient+Live.swift
│
├── Domain/
│   ├── Entities/
│   └── UseCases/
│
├── Data/
│   ├── DTO/
│   ├── Mappers/
│   └── Repositories/
│
└── Tests/
    └── FeatureNameFeatureTests.swift
```

---

## 4. Feature File

`FeatureNameFeature.swift` содержит:

```text
@Reducer
State
Action
Dependencies
body
Reduce
child reducer composition
```

---

## 5. View File

`FeatureNameView.swift` содержит:

```text
SwiftUI rendering
Store observation
send actions
navigation destinations
child stores
```

View не должна:

```text
- call API directly
- create DTO
- mutate state outside store
- hold feature business logic
```

---

## 6. Dependencies Folder

Dependency client:

```swift
struct ArticleClient {
    var fetchFeed: @Sendable () async throws -> [Article]
    var like: @Sendable (ArticleID) async throws -> Void
}
```

Live implementation in separate file.

Test dependency in tests.

---

## 7. Child Features

Child feature if:

```text
- child has independent state/actions/effects
- child needs tests
- child is reusable
- parent reducer is too large
```

Do not create child feature for every small View.

---

## 8. Models

TCA State should use:

```text
Domain models
ViewState models
IDs
small value objects
```

Avoid in State:

```text
DTO
DBModel
API response objects
SDK objects
```

---

## 9. Tests Structure

```text
Tests/
├── FeatureNameFeatureTests.swift
├── ChildFeatureTests.swift
└── DependencyClientTests.swift if needed
```

---

## 10. Naming

Good:

```text
NewsFeedFeature
NewsFeedFeature.State
NewsFeedFeature.Action
ArticleCardFeature
ArticleClient
```

Avoid:

```text
NewsManager
TCAHelper
BaseReducer
CommonFeature
```

---

## 11. Rule

```text
A TCA folder should make state/action/effect ownership obvious.
```
