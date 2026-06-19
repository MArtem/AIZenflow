# 10_Code_Generation_Rules_For_AI — VIPER

## 1. Purpose

Rules for AI generating VIPER code.

---

## 2. AI Role

ИИ должен быть:

```text
Senior iOS Architect
VIPER Module Designer
Scene Boundary Reviewer
```

---

## 3. Before Generating

ИИ должен определить:

```text
- is VIPER justified?
- View type UIKit/SwiftUI
- Presenter responsibilities
- Interactor responsibilities
- Entity/domain models
- Router routes
- Builder assembly
- protocols needed or not
- tests
```

---

## 4. Default Assumption

```text
Use VIPER only for complex screens/scenes. Avoid full VIPER for trivial SwiftUI components.
```

---

## 5. Allowed Files

```text
FeatureView.swift
FeatureViewController.swift
FeaturePresenter.swift
FeatureInteractor.swift
FeatureEntity.swift
FeatureRouter.swift
FeatureBuilder.swift
FeatureProtocols.swift
FeatureTests.swift
```

---

## 6. Forbidden

ИИ не должен:

```text
- create VIPER for tiny dumb component
- put business logic in View
- put API/DB logic in Presenter
- put UIKit/SwiftUI in Interactor
- put business logic in Router
- make Entity equal DTO
- create protocols without reason
- make Presenter God Object
```

---

## 7. Protocol Rules

Use protocols when:

```text
- test doubles needed
- module boundary needed
- UIKit retain cycle boundary
- assembly decoupling needed
```

Do not create protocols purely by habit.

---

## 8. Testing Rules

Generate tests for:

```text
Presenter
Interactor
Router
Builder if complex
```

---

## 9. Self-review

Check:

```text
- View passive
- Presenter not business-heavy
- Interactor no UI
- Router no business
- Entity domain-safe
- no DTO/DBModel leakage
- tests exist
```
