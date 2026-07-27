# 04_Data_Flow_Rules — Coordinator / Flow Architecture

## 1. Purpose

Coordinator is not a data architecture, but navigation interacts with data through route parameters, async preconditions, and feature assemblies.

---

## 2. Main Rule

```text
Coordinator passes identifiers and route parameters.
It does not pass DTOs, DBModels, or raw data layer objects.
```

---

## 3. Correct Route Data

Good:

```swift
case articleDetails(ArticleID)
case userProfile(UserID)
case orderDetails(OrderID)
```

Bad:

```swift
case articleDetails(ArticleDTO)
case userProfile(UserDBModel)
case screen(UIViewController)
```

---

## 4. Screen Creation Flow

```text
Route received
 → Coordinator handles route
 → Assembly creates feature
 → Feature dependencies injected
 → Destination shown
```

---

## 5. Data Loading Flow

Coordinator should not fetch destination data directly.

Preferred:

```text
Coordinator passes ArticleID
 → ArticleDetails feature loads its own data
```

Avoid:

```text
Coordinator fetches ArticleDTO
 → passes DTO to destination View
```

---

## 6. Async Precondition Flow

Example protected action:

```text
User taps comments
 → ViewModel/Store checks auth via UseCase
 → emits route .loginRequired or .comments(articleID)
 → Coordinator handles route
```

Alternative for app-level preconditions:

```text
Coordinator receives route
 → asks SessionGate/RouteGuard
 → routes to login or destination
```

But business logic should stay in domain/use cases, not coordinator.

---

## 7. Deep Link Data Flow

```text
URL
 → DeepLinkParser
 → AppRoute
 → AppCoordinator
 → FeatureRoute
 → FeatureCoordinator
 → Assembly
```

Deep link should resolve identifiers, not fetch all data in parser.

---

## 8. Modal Result Flow

If modal returns result:

```text
Parent coordinator presents child flow
 → child coordinator emits result
 → parent handles result
 → updates parent feature or route
```

Do not make child directly mutate parent internals.

---

## 9. Feature Output Flow

Feature output:

```swift
enum NewsFeedOutput {
    case route(NewsFeedRoute)
    case didSelectArticle(ArticleID)
    case didFinish
}
```

Coordinator handles output.

---

## 10. Rule

```text
Coordinator moves the user through flows.
Features own their data loading and state.
```
