# 03_Module_And_Folder_Structure — RIBs

## 1. Purpose

Этот документ задает структуру файлов для RIBs.

---

## 2. Classic RIB Structure

```text
FeatureRIB/
├── FeatureBuilder.swift
├── FeatureRouter.swift
├── FeatureInteractor.swift
├── FeatureComponent.swift
├── FeatureViewController.swift
├── FeatureView.swift
├── FeatureProtocols.swift
└── Tests/
```

---

## 3. Production Structure

```text
FeatureRIB/
├── Builder/
│   └── FeatureBuilder.swift
├── Router/
│   └── FeatureRouter.swift
├── Interactor/
│   └── FeatureInteractor.swift
├── Component/
│   └── FeatureComponent.swift
├── View/
│   ├── FeatureViewController.swift
│   └── FeatureView.swift
├── Contracts/
│   ├── FeatureDependency.swift
│   ├── FeatureListener.swift
│   └── FeatureBuildable.swift
├── Domain/
│   ├── UseCases/
│   └── Entities/
└── Tests/
    ├── FeatureInteractorTests.swift
    ├── FeatureRouterTests.swift
    └── FeatureBuilderTests.swift
```

---

## 4. Root Structure

```text
RIBs/
├── Root/
├── LoggedOut/
│   ├── Login/
│   └── Signup/
└── LoggedIn/
    ├── Home/
    ├── Profile/
    └── Settings/
```

---

## 5. Builder File

Builder creates:

```text
Component
Interactor
Router
View
Child builders
```

---

## 6. Router File

Router contains:

```text
attachChild()
detachChild()
navigation operations
child router references
```

---

## 7. Interactor File

Interactor contains:

```text
business flow logic
listener calls
use case calls
routing decisions as requests to Router
```

---

## 8. Component File

Component exposes dependencies needed by this RIB and child RIBs.

Avoid exposing the whole app container.

---

## 9. Contracts File

Contracts may include:

```swift
protocol FeatureDependency: Dependency { }
protocol FeatureListener: AnyObject { }
protocol FeatureBuildable: Buildable { }
protocol FeatureRouting: ViewableRouting { }
```

Only create protocol complexity if needed.

---

## 10. Tests

Most valuable:

```text
Interactor tests
Router attach/detach tests
Builder wiring tests
```

---

## 11. Rule

```text
RIB file structure should represent lifecycle and dependency boundaries, not just ceremony.
```
