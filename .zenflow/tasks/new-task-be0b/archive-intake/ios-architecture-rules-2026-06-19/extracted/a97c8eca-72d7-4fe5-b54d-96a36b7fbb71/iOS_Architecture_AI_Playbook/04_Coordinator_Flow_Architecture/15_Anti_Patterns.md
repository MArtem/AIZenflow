# 15_Anti_Patterns — Coordinator / Flow Architecture

## 1. Purpose

Anti-patterns for Coordinator / Flow Architecture.

---

## 2. Coordinator as God Object

Symptoms:

```text
- handles every screen in app
- 1000+ lines
- owns business/data state
- knows all features deeply
- hard to test
```

Fix:

```text
split AppCoordinator, Flow Coordinators, Feature Coordinators
```

---

## 3. API in Coordinator

Bad:

```swift
let article = try await api.fetchArticle(id)
showDetails(article)
```

Fix:

```text
pass ID, destination feature loads data
```

---

## 4. DTO in Route

Bad:

```swift
case details(ArticleDTO)
```

Fix:

```swift
case details(ArticleID)
```

---

## 5. ViewModel Creates View

Bad:

```swift
func makeDetailsView() -> ArticleDetailsView
```

Fix:

```text
ViewModel emits route, Coordinator creates destination
```

---

## 6. Coordinator Contains Business Logic

Bad:

```text
Coordinator validates payment rules
Coordinator calculates permissions
Coordinator decides domain status
```

Fix:

```text
UseCase/Domain/RouteGuard returns business outcome
Coordinator routes based on outcome
```

---

## 7. Deep Links Everywhere

Bad:

```text
Each screen parses URLs independently
```

Fix:

```text
Central DeepLinkParser and AppCoordinator
```

---

## 8. Child Coordinator Leak

Bad:

```text
child coordinator retained forever after flow finished
```

Fix:

```text
onFinish removes child
```

---

## 9. Over-coordination

Bad:

```text
Coordinator for every tiny button/component
```

Fix:

```text
Use local navigation for local simple cases
```

---

## 10. Router Knows Business

Bad:

```text
Router decides if user can open premium screen
```

Fix:

```text
Coordinator/RouteGuard handles decision; Router executes mechanics
```

---

## 11. Navigation Closure Chaos

Bad:

```text
onTap
onOpen
onDetails
onLogin
onDismiss
random closures through 8 levels
```

Fix:

```text
Route enum + Coordinator boundary
```

---

## 12. Final Rule

```text
Coordinator is for flow orchestration, not for replacing ViewModel, UseCase, Repository, or AppState.
```
