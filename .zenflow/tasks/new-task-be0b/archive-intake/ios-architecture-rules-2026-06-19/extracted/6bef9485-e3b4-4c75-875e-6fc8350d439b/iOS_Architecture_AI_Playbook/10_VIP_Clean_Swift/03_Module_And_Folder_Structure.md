# 03_Module_And_Folder_Structure — VIP / Clean Swift

## 1. Purpose

Этот документ задает структуру файлов для VIP/Clean Swift scene.

---

## 2. Classic Clean Swift Structure

```text
FeatureScene/
├── FeatureViewController.swift
├── FeatureInteractor.swift
├── FeaturePresenter.swift
├── FeatureRouter.swift
├── FeatureWorker.swift
└── FeatureModels.swift
```

---

## 3. SwiftUI-compatible Structure

```text
FeatureScene/
├── FeatureView.swift
├── FeatureInteractor.swift
├── FeaturePresenter.swift
├── FeatureRouter.swift
├── FeatureWorker.swift
├── FeatureModels.swift
└── FeatureAssembly.swift
```

---

## 4. Production Structure

```text
FeatureScene/
├── View/
│   ├── FeatureViewController.swift
│   └── FeatureView.swift
├── Interactor/
│   └── FeatureInteractor.swift
├── Presenter/
│   └── FeaturePresenter.swift
├── Router/
│   └── FeatureRouter.swift
├── Worker/
│   └── FeatureWorker.swift
├── Models/
│   └── FeatureModels.swift
├── Assembly/
│   └── FeatureAssembly.swift
└── Tests/
    ├── FeatureInteractorTests.swift
    ├── FeaturePresenterTests.swift
    └── FeatureRouterTests.swift
```

---

## 5. Models File

`FeatureModels.swift` can contain:

```swift
enum Feature {
    enum Load {
        struct Request { }
        struct Response { let items: [DomainItem] }
        struct ViewModel { let items: [ItemViewState] }
    }
}
```

For large scenes, split models by use case.

---

## 6. Interactor File

Contains:

```text
business logic
input protocol implementation
worker/use case calls
response creation
```

---

## 7. Presenter File

Contains:

```text
response → view model mapping
formatting
display state construction
```

---

## 8. Router File

Contains:

```text
route enum
navigation methods
destination construction or assembly calls
data passing for navigation
```

---

## 9. Worker File

Contains:

```text
API/DB/cache operation wrapper
repository/use case delegation
```

Worker should not become God Service.

---

## 10. Assembly

Creates and wires:

```text
View
Interactor
Presenter
Router
Worker/dependencies
```

---

## 11. Tests Structure

```text
Tests/
├── Interactor/
├── Presenter/
├── Router/
└── Worker/
```

---

## 12. Rule

```text
Each VIP file must have a unique responsibility. If files are pass-through only, VIP may be too heavy.
```
