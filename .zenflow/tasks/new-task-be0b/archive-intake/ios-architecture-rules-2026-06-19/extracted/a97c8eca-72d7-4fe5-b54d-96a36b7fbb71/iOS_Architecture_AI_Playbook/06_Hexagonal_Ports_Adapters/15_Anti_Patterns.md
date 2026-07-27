# 15_Anti_Patterns — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

Anti-patterns for Hexagonal Architecture.

---

## 2. Protocol Explosion

Bad:

```text
Protocol for every class
```

Fix:

```text
Port only for real boundary.
```

---

## 3. ManagerProtocol

Bad:

```swift
protocol ArticleManagerProtocol
```

Fix:

```swift
protocol ArticleFeedPort
protocol ArticleLikePort
```

Name capabilities, not vague managers.

---

## 4. Domain Imports SDK

Bad:

```swift
import Firebase
import SwiftData
```

inside Domain.

Fix:

```text
SDK in adapter only.
```

---

## 5. Port Returns DTO

Bad:

```swift
func fetch() async throws -> [ArticleDTO]
```

Fix:

```swift
func fetch() async throws -> [Article]
```

---

## 6. Adapter Returns ViewState

Bad:

```swift
func fetch() async throws -> [ArticleCardViewState]
```

Fix:

```text
Adapter returns Domain. Presentation maps to ViewState.
```

---

## 7. Business Logic in Adapter

Bad:

```text
API adapter decides if user can buy product
```

Fix:

```text
Domain/UseCase decides business rule.
```

---

## 8. Technology-named Domain Port

Usually bad:

```swift
protocol URLSessionPort
```

Better:

```swift
protocol ArticleFeedPort
```

unless building infrastructure abstraction.

---

## 9. ViewModel Uses SDK Directly

Bad:

```swift
FirebaseAnalytics.logEvent(...)
```

from ViewModel everywhere.

Fix:

```text
AnalyticsPort / AnalyticsAdapter
```

---

## 10. Local JSON Hardcoded in UI

Bad:

```text
View decodes local JSON
```

Fix:

```text
LocalJSONAdapter implements same port as API adapter.
```

---

## 11. Final Rule

```text
Hexagonal Architecture is not about more protocols.
It is about protecting the core from external details.
```
