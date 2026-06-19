# 06_Navigation_Rules — MVVM

## 1. Purpose

Этот документ описывает, как управлять навигацией в MVVM.

Главная цель — не превратить ViewModel в Router и не размазать navigation logic по SwiftUI View.

---

## 2. Main Rule

```text
ViewModel can decide that navigation should happen.
Coordinator/Router should perform navigation.
```

---

## 3. Forbidden Rule

ViewModel не должна создавать SwiftUI destination views.

Плохо:

```swift
final class NewsFeedViewModel {
    func openDetails(id: ArticleID) -> ArticleDetailsView {
        ArticleDetailsView(id: id)
    }
}
```

ViewModel не должна импортировать конкретные feature views для навигации.

---

## 4. Route Model

Используй route enum:

```swift
enum NewsFeedRoute: Equatable {
    case articleDetails(ArticleID)
    case comments(ArticleID)
    case loginRequired
    case share(ArticleID)
}
```

---

## 5. ViewModel Emits Route

```swift
@MainActor
final class NewsFeedViewModel {
    private(set) var state: NewsFeedViewState

    func send(_ action: NewsFeedAction) {
        switch action {
        case .articleTapped(let id):
            state.route = .articleDetails(id)

        case .commentsTapped(let id):
            state.route = .comments(id)

        default:
            break
        }
    }
}
```

---

## 6. View Handles Route Boundary

SwiftUI View may observe route and pass it to Coordinator/Router.

```swift
.onChange(of: viewModel.state.route) { _, route in
    guard let route else { return }
    onRoute(route)
    viewModel.send(.routeHandled)
}
```

---

## 7. Coordinator Performs Navigation

```swift
final class NewsFeedCoordinator {
    func handle(_ route: NewsFeedRoute) {
        switch route {
        case .articleDetails(let id):
            showArticleDetails(id)

        case .comments(let id):
            showComments(id)

        case .loginRequired:
            showLogin()

        case .share(let id):
            presentShare(id)
        }
    }
}
```

---

## 8. SwiftUI NavigationStack Alternative

Для простых фич можно использовать `NavigationPath` или route binding на уровне container view.

Но все равно желательно отделять:

```text
route decision
from
destination construction
```

---

## 9. Navigation with Async Preconditions

Пример:

```text
User taps comments
 → ViewModel checks auth/session
 → if logged in: route = .comments(articleID)
 → if not: route = .loginRequired
```

View не должна сама проверять auth для бизнес-решения.

---

## 10. Deep Links

Deep link должен маппиться в route model:

```text
URL
 → DeepLinkParser
 → AppRoute
 → FeatureRoute
 → Coordinator
```

Не делать deep link parsing внутри ViewModel конкретного экрана, если это app-level concern.

---

## 11. Modal/Sheet Rules

Sheet state может быть:

```swift
enum NewsFeedSheet: Identifiable, Equatable {
    case filters
    case share(ArticleID)

    var id: String {
        switch self {
        case .filters: return "filters"
        case .share(let id): return "share-\(id.rawValue)"
        }
    }
}
```

Для простого UI-only sheet можно держать локально во View. Для business-driven sheet — во ViewModel route/sheet state.

---

## 12. Tab Navigation

Tab selection обычно app-level state.

Feature ViewModel не должна управлять глобальным tab flow напрямую.

Использовать:

```text
AppCoordinator
TabCoordinator
AppRoute
```

---

## 13. Back Navigation

ViewModel может request back только через route/event:

```swift
case closeTapped
```

Coordinator решает:

```text
dismiss modal
pop navigation stack
close flow
```

---

## 14. Navigation Tests

Тестировать:

```text
- article tap emits articleDetails route
- comments tap emits comments route
- unauthorized action emits loginRequired
- routeHandled clears route
```

---

## 15. Rule

```text
MVVM owns navigation intent, not navigation mechanics.
```
