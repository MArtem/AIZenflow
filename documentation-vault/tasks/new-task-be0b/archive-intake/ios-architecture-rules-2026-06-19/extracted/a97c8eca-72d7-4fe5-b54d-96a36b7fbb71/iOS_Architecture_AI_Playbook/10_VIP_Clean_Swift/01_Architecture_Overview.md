# 01_Architecture_Overview — VIP / Clean Swift

## 1. Purpose

VIP / Clean Swift — это scene-based architecture, чаще применяемая в UIKit-проектах, но ее идеи можно адаптировать и к SwiftUI.

VIP разделяет экран на роли:

```text
View
Interactor
Presenter
Router
Worker
Models
```

Главная цель — убрать бизнес-логику из View/ViewController и явно разделить:

```text
- user input
- business logic
- presentation formatting
- navigation
- external work
```

---

## 2. Core Flow

Классический flow:

```text
View / ViewController
 → Interactor
 → Presenter
 → View / ViewController
```

С Router:

```text
View
 → Router
 → next scene
```

С Worker:

```text
Interactor
 → Worker
 → API/DB/cache/use case
```

---

## 3. Request / Response / ViewModel

Clean Swift часто использует отдельные модели:

```text
Request
Response
ViewModel
```

Example:

```text
View creates Request from user input
Interactor processes Request and returns Response
Presenter formats Response into ViewModel
View displays ViewModel
```

---

## 4. Component Roles

### View / ViewController

Отвечает за:

```text
- UI rendering
- user input forwarding
- display methods
- lifecycle forwarding
```

Не отвечает за:

```text
- business logic
- API calls
- DB/cache
- formatting complex data
- navigation construction
```

---

### Interactor

Отвечает за:

```text
- business logic
- use case orchestration
- validation
- deciding what data is needed
- calling Workers/UseCases/Repositories
- producing Response
```

Не отвечает за:

```text
- UI formatting
- UIKit/SwiftUI rendering
- navigation mechanics
```

---

### Presenter

Отвечает за:

```text
- formatting Response into ViewModel/ViewState
- user-facing strings
- date/number formatting
- display state preparation
```

Не отвечает за:

```text
- business decisions
- API calls
- DB/cache
- navigation
```

---

### Router

Отвечает за:

```text
- navigation
- passing route parameters
- scene construction
- segue handling in UIKit legacy
```

Не отвечает за:

```text
- business logic
- data loading
- API/DB/cache
```

---

### Worker

Отвечает за:

```text
- external operation abstraction
- API/DB/cache access
- delegating to Repository/UseCase
```

В modern Clean Swift worker часто заменяется или дополняется UseCase/Repository.

---

## 5. Why VIP Exists

VIP полезен, когда ViewController становится Massive ViewController:

```text
ViewController:
- handles UI
- validates input
- fetches API
- formats dates
- navigates
- stores state
- handles errors
```

VIP разрезает это на понятные роли.

---

## 6. SwiftUI Adaptation

SwiftUI вариант:

```text
SwiftUI View
 → Interactor / SceneModel
 → Presenter
 → ViewState
 → SwiftUI View
```

Но для SwiftUI часто проще MVVM/TCA. VIP стоит использовать, если команда уже следует Clean Swift или нужно сохранить scene boundaries.

---

## 7. Recommended Production Shape

```text
FeatureScene/
├── FeatureView.swift / FeatureViewController.swift
├── FeatureInteractor.swift
├── FeaturePresenter.swift
├── FeatureRouter.swift
├── FeatureWorker.swift
├── FeatureModels.swift
└── FeatureAssembly.swift
```

С Clean/Data слоями:

```text
FeatureScene/
├── Presentation/
│   ├── View
│   ├── Presenter
│   └── ViewModel/ViewState
├── Business/
│   └── Interactor
├── Routing/
│   └── Router
├── Data/
│   └── Worker
└── Models/
```

---

## 8. Healthy VIP

VIP здоров, если:

```text
- View only displays and sends input
- Interactor owns business/use case logic
- Presenter formats output
- Router navigates
- Worker handles external work
- Request/Response/ViewModel boundaries clear
- tests cover Interactor and Presenter
```

---

## 9. Unhealthy VIP

VIP нездоров, если:

```text
- Presenter contains business logic
- Interactor formats UI
- View calls Worker directly
- Router contains business rules
- Worker becomes God Service
- protocols exist only as ceremony
- tiny screen has huge VIP boilerplate
```

---

## 10. Summary

VIP / Clean Swift — хороший выбор для UIKit enterprise screens and legacy refactoring, но требует дисциплины.

Правило:

```text
Use VIP when scene responsibilities are complex enough to justify explicit View/Interactor/Presenter/Router separation.
```
