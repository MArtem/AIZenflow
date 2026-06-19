# 07_API_DB_Cache_Rules — TCA

## 1. Purpose

Этот документ описывает API/DB/cache boundaries в TCA.

---

## 2. Main Rule

```text
Reducers use dependencies. Dependencies hide API/DB/cache mechanics.
```

---

## 3. Dependency Client

```swift
struct ArticleClient {
    var fetchFeed: @Sendable (CachePolicy) async throws -> ArticleFeedResult
    var like: @Sendable (ArticleID) async throws -> Void
}
```

---

## 4. Live Dependency

Live dependency can call:

```text
UseCase
Repository
API adapter
DB adapter
```

depending on architecture.

Reducer should not know details.

---

## 5. Test Dependency

Tests provide deterministic dependencies:

```text
fetchFeed returns fixture
like throws error
clock controls debounce
uuid/date controlled
```

---

## 6. DTO/DBModel

DTO/DBModel must not enter:

```text
Reducer State
View
Action payloads visible to UI
```

except very narrow data-layer tests.

---

## 7. Cache Policy

Reducer can choose policy based on action:

```text
onAppear → cacheFirstThenRefresh
refreshPulled → networkFirstFallbackToCache
```

Dependency/repository implements policy.

---

## 8. Offline/Stale

Dependency returns domain result:

```swift
struct ArticleFeedResult: Equatable {
    var articles: [Article]
    var freshness: DataFreshness
}
```

Reducer maps to state/banner.

---

## 9. Long-living Effects

For streams:

```text
network status
notifications
sync status
```

use cancellable effects and lifecycle actions.

---

## 10. Rule

```text
TCA reducers orchestrate effects; they do not implement infrastructure.
```
