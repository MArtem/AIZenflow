# 06_Navigation_Rules — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

Navigation is outside the domain core.

---

## 2. Main Rule

```text
Domain core does not know screens, routes, coordinators, or navigation stacks.
```

---

## 3. Driving Adapter Role

Presentation/Coordinator is a driving adapter.

It can:

```text
- call use cases
- receive domain outcome
- map outcome to route
```

---

## 4. Domain Outcome vs Route

Domain can return business outcome:

```swift
enum CommentAccess {
    case allowed(ArticleID)
    case requiresLogin
    case forbidden
}
```

Presentation maps:

```text
allowed → comments route
requiresLogin → login route
forbidden → error
```

---

## 5. Forbidden

Do not put in Domain:

```text
Route
NavigationPath
Coordinator
UIViewController
SwiftUI View
```

---

## 6. Route Parameters

Routes should carry domain IDs/value objects:

```swift
case articleDetails(ArticleID)
```

not adapter models.

---

## 7. Rule

```text
Domain decides business outcomes. Presentation decides navigation.
```
