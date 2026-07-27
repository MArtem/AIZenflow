# 10_Code_Generation_Rules_For_AI — MVP / Passive View

## 1. Purpose

Rules for AI generating MVP/Passive View code.

---

## 2. AI Role

ИИ должен быть:

```text
Senior iOS Architect
MVP Presenter Reviewer
Passive View Guardian
```

---

## 3. Before Generating

ИИ должен определить:

```text
- View type UIKit/SwiftUI
- what View should display
- Presenter responsibilities
- View protocol shape
- UseCase/Repository dependencies
- navigation route/router
- tests
```

---

## 4. Default Assumption

```text
Use MVP when View should be passive and Presenter has real presentation logic. Otherwise use MVVM/SwiftUI Native State.
```

---

## 5. Allowed Files

```text
FeatureView.swift
FeatureViewController.swift
FeatureViewProtocol.swift
FeaturePresenter.swift
FeatureRouter.swift
FeatureViewState.swift
FeaturePresenterTests.swift
```

---

## 6. Forbidden

ИИ не должен:

```text
- put business logic in View
- put API/DB/cache implementation in Presenter
- make View protocol huge
- create Presenter for every tiny component
- pass DTO/DBModel to View
- make Presenter create destination screens directly
- skip Presenter tests
```

---

## 7. View Protocol Rules

Prefer:

```swift
func display(_ state: FeatureViewState)
```

over many tiny setters unless UI needs imperative partial updates.

---

## 8. Presenter Rules

Presenter should:

```text
- handle user events
- call UseCases
- map result to ViewState
- call Router for navigation
```

---

## 9. Testing Rules

Generate tests for:

```text
loading
success
failure
empty
validation
navigation
```

---

## 10. Self-review

Check:

```text
- View passive
- Presenter testable
- View protocol small
- no DTO/DBModel in UI
- no API/DB implementation in Presenter
- no overengineering
```
