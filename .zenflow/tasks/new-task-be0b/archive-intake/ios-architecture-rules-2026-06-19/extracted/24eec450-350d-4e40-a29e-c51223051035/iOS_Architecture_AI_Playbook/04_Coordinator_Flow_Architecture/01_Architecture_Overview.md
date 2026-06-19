# 01_Architecture_Overview — Coordinator / Flow Architecture

## 1. Purpose

Coordinator / Flow Architecture отвечает за навигацию и управление пользовательскими flow в iOS-приложении.

Это не полная архитектура приложения. Coordinator не заменяет MVVM, Clean Architecture, TCA, VIP или SwiftUI Native State.

Coordinator решает отдельную задачу:

```text
Who creates screens?
Who owns navigation flow?
Who handles deep links?
Who decides push/modal/tab/onboarding/auth transitions?
```

---

## 2. Core Idea

Главная идея:

```text
Views and ViewModels should not construct navigation destinations directly.
```

Экран сообщает о navigation intent, а Coordinator/Router выполняет навигацию.

```text
View
 → user action
 → ViewModel/Store/Presenter
 → Route intent
 → Coordinator/Router
 → creates destination
 → performs navigation
```

---

## 3. What Coordinator Solves

Coordinator помогает:

```text
- убрать navigation construction из View/ViewModel
- централизовать flow logic
- поддерживать deep links
- управлять onboarding/auth/main app flow
- переиспользовать feature screens
- отделить route decision от route execution
- тестировать navigation decisions
- собирать зависимости через assemblies
```

---

## 4. What Coordinator Does Not Solve

Coordinator не решает:

```text
- state management
- business logic
- API/DB/cache architecture
- domain model separation
- DTO mapping
- offline sync
- UI rendering
```

Для этого нужны:

```text
MVVM
Clean Architecture
TCA/UDF
SwiftUI Native State
Hexagonal
Modular Architecture
```

---

## 5. Main Components

```text
Route
Coordinator
Router
Flow
Assembly
Navigation Container
```

---

## 6. Route

Route описывает намерение перейти куда-то.

```swift
enum NewsFeedRoute: Equatable {
    case articleDetails(ArticleID)
    case comments(ArticleID)
    case loginRequired
}
```

Route должен содержать:

```text
- IDs
- small value objects
- route parameters
```

Route не должен содержать:

```text
- DTO
- DBModel
- SwiftUI View
- UIViewController
- Repository
- ViewModel instance
```

---

## 7. Coordinator

Coordinator отвечает за flow:

```text
- handles route
- creates destination through assembly
- performs push/sheet/modal/tab switch
- starts child coordinators
- finishes flow
```

Coordinator не должен:

```text
- делать business logic
- вызывать API напрямую
- хранить DTO/DBModel
- форматировать UI
- быть God Object
```

---

## 8. Router

Router — технический исполнитель навигации.

Пример ответственности:

```text
- push
- pop
- present
- dismiss
- set root
- switch tab
```

Coordinator решает “куда”, Router делает “как”.

---

## 9. Flow

Flow — группа экранов, объединенных пользовательским сценарием:

```text
AuthFlow
OnboardingFlow
MainTabFlow
NewsFlow
ProfileFlow
CheckoutFlow
```

---

## 10. Assembly

Assembly создает feature screen со всеми dependencies:

```text
Coordinator
 → Assembly.makeArticleDetails(articleID)
 → ArticleDetailsView/ViewController
```

Coordinator может знать assemblies, потому что он composition/navigation layer.

---

## 11. SwiftUI Shape

SwiftUI вариант:

```text
Route enum
NavigationPath / sheet item / fullScreenCover item
Coordinator object or navigation model
Feature assembly
```

---

## 12. UIKit Shape

UIKit вариант:

```text
Coordinator owns UINavigationController
Router wraps UINavigationController
Coordinator pushes/presents UIViewControllers
Child coordinator for nested flow
```

---

## 13. Recommended Production Approach

Для SwiftUI production app:

```text
Simple screen navigation:
Route enum + NavigationStack

Medium flow:
Feature Coordinator + Route enum

Complex app flow:
AppCoordinator + Flow Coordinators + Feature Coordinators

Deep links:
DeepLinkParser → AppRoute → Coordinator
```

---

## 14. Summary

Coordinator Architecture здорова, если:

```text
- View не создает destination screens
- ViewModel emits route intent
- Coordinator owns flow
- Router performs mechanics
- Route uses IDs/value objects
- business logic outside Coordinator
- dependencies created through Assembly
```

Нездорова, если:

```text
- Coordinator знает все обо всем
- Coordinator делает API calls
- Coordinator содержит business rules
- ViewModel создает Views
- Routes содержат DTO/DBModel/ViewModel
- deep links парсятся хаотично в разных местах
```
