# 01_Architecture_Overview — VIPER

## 1. Purpose

VIPER — это архитектура, которая делит feature/screen на пять ролей:

```text
View
Interactor
Presenter
Entity
Router
```

Она особенно часто встречается в UIKit enterprise проектах, где нужно жестко разделить UI, бизнес-логику, навигацию и сборку модулей.

Цель этого документа — научить ИИ использовать VIPER как инструмент разделения ответственностей, а не как generator boilerplate.

---

## 2. Core Idea

VIPER flow:

```text
View
 → Presenter
 → Interactor
 → Entity / Domain
 → Presenter
 → View

Presenter
 → Router
 → next module
```

Главная идея:

```text
View displays.
Presenter coordinates.
Interactor owns business logic.
Entity represents business/domain data.
Router owns navigation.
```

---

## 3. Components

### View

Отвечает за:

```text
- UI rendering
- user input forwarding
- display methods
- UIKit/SwiftUI rendering details
```

Не отвечает за:

```text
- business logic
- API/DB/cache
- navigation construction
- domain decisions
```

---

### Interactor

Отвечает за:

```text
- business logic
- use case orchestration
- repository/service calls
- validation
- domain operations
```

Не отвечает за:

```text
- UI formatting
- navigation mechanics
- UIKit/SwiftUI
```

---

### Presenter

Отвечает за:

```text
- receiving events from View
- calling Interactor
- formatting output for View
- coordinating screen behavior
- asking Router to navigate
```

Presenter — центр коммуникации, но не должен стать God Object.

---

### Entity

Entity — domain/business model.

В modern iOS VIPER можно использовать:

```text
Domain Entity
Value Object
Input/Output Models
```

Entity не должен быть DTO или DBModel по умолчанию.

---

### Router

Отвечает за:

```text
- navigation
- module creation
- passing route parameters
- presentation style
```

Не отвечает за:

```text
- business rules
- API calls
- formatting
```

---

## 4. Assembly / Builder

VIPER почти всегда требует сборку:

```text
Builder / Assembly
 → View
 → Presenter
 → Interactor
 → Router
 → Dependencies
```

Example:

```swift
enum ArticleDetailsBuilder {
    static func build(articleID: ArticleID) -> ArticleDetailsViewController {
        let view = ArticleDetailsViewController()
        let interactor = ArticleDetailsInteractor(...)
        let router = ArticleDetailsRouter(viewController: view)
        let presenter = ArticleDetailsPresenter(
            view: view,
            interactor: interactor,
            router: router,
            articleID: articleID
        )

        view.presenter = presenter
        return view
    }
}
```

---

## 5. VIPER vs VIP/Clean Swift

VIP/Clean Swift:

```text
View → Interactor → Presenter → View
Router separate
```

VIPER:

```text
View ↔ Presenter → Interactor
Presenter → Router
Interactor → Entity/Domain
```

VIPER Presenter is usually more central than Clean Swift Presenter.

---

## 6. VIPER vs MVVM

MVVM:

```text
View ↔ ViewModel
```

VIPER:

```text
View ↔ Presenter → Interactor/Router
```

VIPER has more separation but more ceremony.

---

## 7. What VIPER Solves

VIPER helps with:

```text
- Massive ViewController
- complex UIKit screens
- strict team boundaries
- testable Presenter/Interactor
- explicit navigation Router
- enterprise modular scenes
```

---

## 8. What VIPER Does Not Solve

VIPER does not automatically solve:

```text
- DTO/Domain/DB separation
- cache/offline policy
- app modularization
- async cancellation
- SwiftUI state ownership
```

It must be combined with:

```text
Clean Architecture
Repository
Coordinator if app flow is complex
Modular Architecture
```

---

## 9. Healthy VIPER

Healthy VIPER:

```text
- View is passive
- Presenter coordinates but not business-heavy
- Interactor owns business/use cases
- Router owns navigation
- Entity is domain-safe
- dependencies injected
- tests cover Presenter and Interactor
```

---

## 10. Unhealthy VIPER

Unhealthy VIPER:

```text
- Presenter becomes God Object
- Interactor knows UIKit/SwiftUI
- Router contains business logic
- Entity is just DTO
- protocols for everything without purpose
- module has 8 files for trivial screen
```

---

## 11. Summary

VIPER is useful when screen complexity justifies strict separation.

Rule:

```text
Use VIPER for complex scenes that need clear role separation, not for every screen by default.
```
