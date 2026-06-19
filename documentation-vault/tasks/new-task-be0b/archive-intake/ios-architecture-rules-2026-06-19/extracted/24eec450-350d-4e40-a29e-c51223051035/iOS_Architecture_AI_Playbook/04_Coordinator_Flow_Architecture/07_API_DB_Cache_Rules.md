# 07_API_DB_Cache_Rules — Coordinator / Flow Architecture

## 1. Purpose

Coordinator should integrate with data architecture without becoming data architecture.

---

## 2. Main Rule

```text
Coordinator does not fetch, cache, decode, persist, or sync feature data.
```

---

## 3. Forbidden Coordinator Behavior

Coordinator must not:

```text
- call APIClient.fetchArticle()
- decode DTO
- query database for screen content
- implement cache policy
- hold DBModel
- pass DTO to View
```

---

## 4. Allowed Coordinator Data Access

Coordinator may use lightweight app-level services for routing preconditions:

```text
SessionStore
FeatureFlagStore
RouteGuard
DeepLinkResolver
PermissionChecker
```

But it should not implement their business logic.

---

## 5. Route Guard

Example:

```swift
protocol RouteGuard {
    func canOpen(_ route: AppRoute) async -> RouteGuardResult
}
```

Coordinator can ask route guard, then route accordingly.

---

## 6. Destination Data Loading

Preferred:

```text
Coordinator passes ID
Destination feature loads data through its own use case/repository
```

---

## 7. Preloaded Data Exception

Passing preloaded Domain model may be acceptable if:

```text
- model is Domain/UI-safe
- data already exists in current state
- no DTO/DBModel leak
- destination still can refresh itself
```

Prefer ID for long-lived screens.

---

## 8. Offline Routes

Coordinator may route to offline fallback screen based on app-level network/session state.

But repository/data layer decides whether content is cached/stale.

---

## 9. Auth Unauthorized

Flow:

```text
Repository returns unauthorized
 → Feature maps to route .loginRequired
 → Coordinator opens login
```

Repository should not call Coordinator.

---

## 10. Rule

```text
Coordinator uses data only to decide flow, not to own content.
```
