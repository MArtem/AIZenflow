# 01_Architecture_Overview — MVP / Passive View

## 1. Purpose

MVP / Passive View — это presentation architecture, где View максимально пассивна, а Presenter управляет логикой отображения и реакцией на user input.

Основная цель:

```text
- убрать presentation logic из View/ViewController
- сделать UI testable через Presenter tests
- разделить View rendering и decision logic
- упростить legacy UIKit screens
```

MVP особенно полезен для UIKit, но его идеи можно использовать и в SwiftUI, если нужно отделить presentation logic от View.

---

## 2. Core Idea

Главный flow:

```text
View
 → Presenter
 → Model / UseCase / Repository
 → Presenter
 → View
```

Passive View означает:

```text
View displays what Presenter tells it to display.
View forwards user events to Presenter.
View does not make business/presentation decisions.
```

---

## 3. Main Components

### View

View отвечает за:

```text
- rendering UI
- forwarding user events
- exposing display methods/properties
- UIKit/SwiftUI mechanics
```

View не отвечает за:

```text
- business logic
- API/DB/cache
- navigation decisions
- formatting complex domain data
- validation rules
```

---

### Presenter

Presenter отвечает за:

```text
- user event handling
- presentation logic
- view state preparation
- calling use cases/services
- deciding what View should display
- asking Router/Coordinator to navigate
```

Presenter не должен:

```text
- own raw infrastructure
- decode JSON
- query DB directly
- become God Object
- know layout details
```

---

### Model

Model в MVP может означать разные вещи:

```text
- Domain Entity
- UseCase
- Repository
- Service
- data provider
```

Для production iOS лучше не использовать vague Model, а явно:

```text
UseCase
Repository
Domain Model
```

---

## 4. Passive View vs Supervising Controller

### Passive View

```text
View is dumb.
Presenter prepares almost everything.
View only displays.
```

### Supervising Controller

```text
View can bind simple data directly.
Presenter handles complex logic.
```

Для production testability Passive View обычно проще тестировать.

---

## 5. MVP vs MVVM

MVVM:

```text
View observes ViewModel state.
```

MVP:

```text
Presenter commands View through View protocol/display methods.
```

MVVM лучше для SwiftUI data binding.

MVP часто лучше для UIKit screens where imperative display methods are natural.

---

## 6. MVP vs VIPER

VIPER:

```text
View / Interactor / Presenter / Entity / Router
```

MVP:

```text
View / Presenter / Model
```

MVP проще, меньше ролей, меньше ceremony.

---

## 7. Recommended Production Shape

```text
FeatureName/
├── FeatureNameViewController.swift / FeatureNameView.swift
├── FeatureNamePresenter.swift
├── FeatureNameViewProtocol.swift
├── FeatureNameViewState.swift
├── FeatureNameRouter.swift
├── Domain/
│   ├── UseCases/
│   └── Entities/
├── Data/
└── Tests/
    └── FeatureNamePresenterTests.swift
```

---

## 8. Healthy MVP

Healthy MVP:

```text
- View is passive
- Presenter is testable without UI rendering
- View protocol is small
- Presenter depends on UseCase/Repository boundary
- navigation is via Router/Coordinator
- DTO/DBModel do not enter View
```

---

## 9. Unhealthy MVP

Unhealthy MVP:

```text
- View still has business logic
- Presenter becomes Massive Presenter
- View protocol has 100 methods
- Presenter calls APIClient directly
- Presenter knows layout too deeply
- no tests
```

---

## 10. Summary

MVP / Passive View is useful when you want clear imperative presentation control and easy Presenter unit tests.

Rule:

```text
Use MVP when a passive UI and testable Presenter give more value than binding-based ViewModel state.
```
