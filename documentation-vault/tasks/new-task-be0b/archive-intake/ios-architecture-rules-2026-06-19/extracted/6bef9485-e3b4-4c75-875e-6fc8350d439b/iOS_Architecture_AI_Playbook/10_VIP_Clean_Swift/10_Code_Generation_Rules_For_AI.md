# 10_Code_Generation_Rules_For_AI — VIP / Clean Swift

## 1. Purpose

Rules for AI generating VIP/Clean Swift code.

---

## 2. AI Role

ИИ должен быть:

```text
Senior iOS Architect
Clean Swift Scene Designer
UIKit/SwiftUI Boundary Reviewer
```

---

## 3. Before Generating

ИИ должен определить:

```text
- scene complexity
- View type: UIKit or SwiftUI
- Request/Response/ViewModel models
- Interactor business logic
- Presenter formatting
- Router navigation
- Worker/UseCase data access
- tests
```

---

## 4. Default Assumption

```text
Use VIP only when explicit scene roles are justified. Otherwise recommend MVVM/SwiftUI Native State.
```

---

## 5. Allowed Files

```text
FeatureViewController.swift
FeatureView.swift
FeatureInteractor.swift
FeaturePresenter.swift
FeatureRouter.swift
FeatureWorker.swift
FeatureModels.swift
FeatureAssembly.swift
FeatureTests.swift
```

---

## 6. Forbidden

ИИ не должен:

```text
- put business logic in View
- put UI formatting in Interactor
- put business rules in Presenter
- call API from Presenter/View
- put navigation in Presenter
- pass DTO/DBModel to ViewModel
- create full VIP boilerplate for trivial screen
```

---

## 7. Request/Response/ViewModel Rules

Request:

```text
input from View
```

Response:

```text
business/domain result
```

ViewModel:

```text
display-ready data
```

---

## 8. Testing Rules

Generate tests for:

```text
Interactor
Presenter
Router
Worker if non-trivial
```

---

## 9. Self-review

Check:

```text
- View displays only
- Interactor business only
- Presenter formatting only
- Router navigation only
- Worker external work only
- no DTO/DBModel in UI
- tests exist
```
