# 07_API_DB_Cache_Rules — Redux / Elm / UDF

## 1. Purpose

Этот документ описывает API/DB/cache boundaries in UDF.

---

## 2. Main Rule

```text
Reducers do not perform API/DB/cache work.
Effects/Middleware do.
```

---

## 3. Dependency Client

```swift
struct NewsFeedClient {
    var fetchFeed: (CachePolicy) async throws -> ArticleFeedResult
    var likeArticle: (ArticleID) async throws -> Void
}
```

---

## 4. Reducer

Reducer can decide intent:

```text
refreshPulled → effect fetch(.networkFirstFallbackToCache)
```

But cannot implement policy.

---

## 5. Effects

Effects call:

```text
UseCase
Repository
Client
Adapter
```

depending on architecture.

---

## 6. DTO/DBModel

DTO/DBModel should not enter State.

Effects/dependencies should return Domain models/results.

---

## 7. Cache Policy

Policy is passed as value, implemented below.

---

## 8. Offline/Stale

Dependency returns:

```swift
struct FeedResult {
    let articles: [Article]
    let freshness: DataFreshness
}
```

Reducer updates offline/stale UI state.

---

## 9. Rule

```text
Reducer decides what should happen. Effects decide how external work happens.
```
