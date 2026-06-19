# 03_Module_And_Folder_Structure — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

Этот документ задает структуру папок для Hexagonal Architecture.

---

## 2. Recommended Structure

```text
FeatureName/
├── Core/
│   ├── Domain/
│   │   ├── Entities/
│   │   ├── ValueObjects/
│   │   ├── Services/
│   │   └── Errors/
│   ├── Application/
│   │   └── UseCases/
│   └── Ports/
│       ├── Inbound/
│       └── Outbound/
│
├── Adapters/
│   ├── Driving/
│   │   └── Presentation/
│   └── Driven/
│       ├── API/
│       ├── Persistence/
│       ├── Cache/
│       ├── Analytics/
│       └── LocalJSON/
│
├── Navigation/
└── Assembly/
```

---

## 3. iOS-friendly Structure

Более привычный iOS вариант:

```text
FeatureName/
├── Domain/
│   ├── Entities/
│   ├── UseCases/
│   └── Ports/
│
├── Presentation/
│   ├── Views/
│   ├── ViewModels/
│   └── ViewStates/
│
├── Adapters/
│   ├── API/
│   ├── DB/
│   ├── Cache/
│   ├── LocalJSON/
│   └── Analytics/
│
└── Assembly/
```

---

## 4. Ports Folder

```text
Domain/Ports/
├── ArticleFeedPort.swift
├── ArticleLikePort.swift
├── SessionPort.swift
└── AnalyticsPort.swift
```

Ports should describe capabilities needed by Domain/Application.

---

## 5. Adapter Folder

```text
Adapters/API/
├── ArticleAPIAdapter.swift
├── ArticleDTO.swift
└── ArticleDTOMapper.swift

Adapters/DB/
├── ArticleDBAdapter.swift
├── ArticleDBModel.swift
└── ArticleDBMapper.swift
```

---

## 6. Driving Adapters

```text
Presentation/
├── SwiftUI Views
├── ViewModels
├── Stores
├── Presenters
└── ViewState mappers
```

Driving adapters call use cases.

---

## 7. Driven Adapters

```text
API Adapter
DB Adapter
Cache Adapter
Keychain Adapter
Analytics Adapter
Push Adapter
```

Driven adapters implement outbound ports.

---

## 8. Assembly

Assembly wires ports to adapters:

```swift
enum ArticleFeatureAssembly {
    static func makeFeedView() -> ArticleFeedView {
        let adapter = ArticleFeedCompositeAdapter(...)
        let useCase = LoadArticleFeedUseCase(feedPort: adapter)
        let viewModel = ArticleFeedViewModel(loadFeed: useCase)
        return ArticleFeedView(viewModel: viewModel)
    }
}
```

---

## 9. Naming Rules

Good:

```text
ArticleFeedPort
ArticleFeedAPIAdapter
ArticleFeedLocalJSONAdapter
ArticleFeedCacheAdapter
LoadArticleFeedUseCase
```

Bad:

```text
ArticleManagerProtocol
ArticleHelperAdapter
CommonServicePort
DataManager
```

---

## 10. Tests Structure

```text
FeatureTests/
├── Domain/
├── Ports/
├── Adapters/
└── Presentation/
```

---

## 11. Rule

```text
Ports belong near the core. Adapters belong near technology.
```
