# 06_Navigation_Rules — Coordinator / Flow Architecture

## 1. Purpose

This is the core navigation rules document for Coordinator Architecture.

---

## 2. Main Rule

```text
Views emit events.
Feature presentation emits routes.
Coordinator executes navigation.
```

---

## 3. View Rule

View should not construct destination screens for non-trivial flows.

Allowed for simple local NavigationLink.

Forbidden for flow-heavy features:

```swift
NavigationLink {
    ArticleDetailsView(
        viewModel: ArticleDetailsViewModel(
            repository: ArticleRepository(...)
        )
    )
} label: {
    ArticleRow(...)
}
```

---

## 4. ViewModel Rule

ViewModel may emit route intent:

```swift
state.route = .articleDetails(id)
```

ViewModel must not:

```text
- create destination View
- push/present screens
- access UINavigationController
- parse deep links
```

---

## 5. Coordinator Rule

Coordinator handles:

```text
- route interpretation
- destination assembly
- push/present/dismiss
- child coordinator lifecycle
- deep link route dispatch
```

---

## 6. Router Rule

Router performs mechanics:

```text
push
pop
present
dismiss
setRoot
switchTab
```

Coordinator uses Router.

---

## 7. Deep Link Rule

Deep links go through:

```text
URL
 → DeepLinkParser
 → AppRoute
 → AppCoordinator
 → FeatureCoordinator
```

---

## 8. Auth Gate Rule

For protected route:

```text
route requested
 → auth/session check
 → if allowed: continue
 → if not: login flow
 → after login: resume pending route if needed
```

Auth check can be in RouteGuard service injected into Coordinator, but business/session truth lives outside Coordinator.

---

## 9. Modal Rule

Modals should be route-driven:

```swift
enum AppSheet: Identifiable {
    case login
    case share(ArticleID)
}
```

---

## 10. Flow Completion Rule

Child coordinator should emit finish:

```swift
onFinish: () -> Void
```

Parent removes child coordinator.

---

## 11. UIKit Rule

UIKit Coordinator owns navigation controller:

```swift
final class NewsCoordinator {
    private let navigationController: UINavigationController
}
```

---

## 12. SwiftUI Rule

SwiftUI Coordinator may own:

```swift
var path: [Route]
var sheet: Sheet?
var fullScreenCover: FullScreenCover?
```

---

## 13. Rule

```text
Navigation mechanics are centralized.
Navigation intent stays near feature presentation.
```
