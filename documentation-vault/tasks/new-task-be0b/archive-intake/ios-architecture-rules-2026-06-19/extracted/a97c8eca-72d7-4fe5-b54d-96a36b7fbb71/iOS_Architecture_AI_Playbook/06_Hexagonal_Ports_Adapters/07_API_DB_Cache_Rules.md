# 07_API_DB_Cache_Rules — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

This is the core adapter document for API, DB, cache, SDKs and local JSON.

---

## 2. Main Rule

```text
External technologies are adapters, not domain dependencies.
```

---

## 3. API Adapter

```swift
final class ArticleAPIAdapter: ArticleRemotePort {
    private let httpClient: HTTPClient

    func fetchArticles() async throws -> [Article] {
        let dto: [ArticleDTO] = try await httpClient.get(...)
        return try dto.map(ArticleDTOMapper.toDomain)
    }
}
```

---

## 4. DB Adapter

```swift
final class ArticlePersistenceAdapter: ArticlePersistencePort {
    private let database: DatabaseClient

    func cachedArticles() async throws -> [Article] {
        let models: [ArticleDBModel] = try await database.fetch(...)
        return models.map(ArticleDBMapper.toDomain)
    }
}
```

---

## 5. Cache Adapter

Cache adapter can implement:

```text
- memory cache
- disk cache
- stale metadata
- expiration
```

---

## 6. Composite Adapter

For policy orchestration:

```swift
final class ArticleFeedAdapter: ArticleFeedPort {
    private let remote: ArticleRemotePort
    private let persistence: ArticlePersistencePort

    func load(policy: FeedLoadPolicy) async throws -> ArticleFeed {
        // cache/network policy here
    }
}
```

---

## 7. Keychain Adapter

Session token access:

```swift
protocol TokenStoragePort {
    func readToken() async throws -> AuthToken?
    func saveToken(_ token: AuthToken) async throws
}
```

Adapter uses Keychain.

---

## 8. Analytics Adapter

```swift
protocol AnalyticsPort {
    func track(_ event: AnalyticsEvent)
}
```

Domain usually should not track UI events directly. Application/Presentation may call analytics port.

---

## 9. Local JSON Adapter

```swift
final class ArticleLocalJSONAdapter: ArticleRemotePort {
    func fetchArticles() async throws -> [Article] {
        // decode local DTO, map to Domain
    }
}
```

Can be swapped with API adapter.

---

## 10. Error Mapping

Adapters map:

```text
HTTPError/DatabaseError/SDKError → AppError/DomainError
```

---

## 11. Rule

```text
Adapters translate between technology language and domain language.
```
