# 06_Navigation_Rules — Clean Architecture / Layered Architecture

## 1. Purpose

Этот документ описывает навигацию при Clean Architecture.

---

## 2. Main Rule

```text
Navigation is a Presentation/Navigation concern.
Domain and Data must not know screens.
```

---

## 3. Forbidden Dependencies

Domain не должен знать:

```text
- SwiftUI NavigationStack
- UIViewController
- Coordinator
- Route enum if route describes screens
- Sheet/Modal state
```

Data не должен знать:

```text
- navigation
- screens
- route
```

---

## 4. Route Model

Routes live in Presentation/Navigation:

```swift
enum NewsFeedRoute: Equatable {
    case articleDetails(ArticleID)
    case comments(ArticleID)
    case loginRequired
}
```

Route can use Domain identifiers/value objects, not DTO/DBModel.

Good:

```swift
case articleDetails(ArticleID)
```

Bad:

```swift
case articleDetails(ArticleDTO)
case articleDetails(ArticleDBModel)
```

---

## 5. UseCase and Navigation

UseCase should not return a screen route.

Usually bad:

```swift
func execute() async throws -> NewsFeedRoute
```

Better:

```swift
func execute() async throws -> LikeArticleResult
```

Presentation decides route based on result.

Exception: Domain can return business outcome:

```swift
enum CommentAccessResult {
    case allowed(ArticleID)
    case requiresLogin
    case forbidden
}
```

Presentation maps this to route:

```text
.allowed → comments screen
.requiresLogin → login screen
.forbidden → error
```

---

## 6. Coordinator Role

Coordinator/Router:

```text
- creates destination screens
- owns flow
- handles deep links
- handles modal/push/pop mechanics
- composes feature assemblies
```

Coordinator may depend on assemblies.

Coordinator should not contain business logic.

---

## 7. Deep Links

Deep link flow:

```text
URL
 → DeepLinkParser
 → AppRoute
 → FeatureRoute
 → Coordinator
 → Feature Assembly
```

DeepLinkParser should not live in Domain unless it parses business identifiers only.

---

## 8. Auth Navigation

Auth decision may involve domain/session use case:

```text
User taps protected action
 → Presentation asks CheckSessionUseCase
 → result: authenticated/unauthenticated
 → Presentation emits route
```

---

## 9. Navigation from Repository Is Forbidden

Bad:

```text
Repository detects unauthorized → opens login
```

Correct:

```text
Repository returns unauthorized error
UseCase returns error/result
Presentation maps to route .loginRequired
```

---

## 10. Navigation Tests

Test:

```text
- business outcome maps to route
- unauthorized maps to loginRequired
- item tap maps to detail route
- route uses Domain ID, not DTO
```

---

## 11. Rule

```text
Clean Architecture keeps navigation outside business and data rules.
```
