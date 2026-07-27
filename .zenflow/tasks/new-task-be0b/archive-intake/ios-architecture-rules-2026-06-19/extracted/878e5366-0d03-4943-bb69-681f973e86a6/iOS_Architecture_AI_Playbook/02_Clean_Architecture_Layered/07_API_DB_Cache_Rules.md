# 07_API_DB_Cache_Rules — Clean Architecture / Layered Architecture

## 1. Purpose

Этот документ задает правила API, DB, cache, offline, repository и data sources в Clean Architecture.

---

## 2. Main Rule

```text
API, DB, and cache are implementation details hidden behind Data layer boundaries.
```

---

## 3. Repository Protocol

Repository protocol lives in Domain:

```swift
protocol ArticleRepositoryProtocol {
    func fetchFeed(policy: CachePolicy) async throws -> ArticleFeedResult
    func likeArticle(id: ArticleID) async throws
}
```

It returns Domain models/results, not DTO/ViewState.

---

## 4. Repository Implementation

Repository implementation lives in Data:

```swift
final class ArticleRepository: ArticleRepositoryProtocol {
    private let remote: ArticleRemoteDataSourceProtocol
    private let local: ArticleLocalDataSourceProtocol
    private let mapper: ArticleDataMapper

    func fetchFeed(policy: CachePolicy) async throws -> ArticleFeedResult {
        // choose source, map DTO/DBModel to Domain
    }
}
```

---

## 5. RemoteDataSource

RemoteDataSource:

```text
- knows API endpoint
- calls APIClient/HTTPClient
- decodes DTO
- returns DTO
```

Example:

```swift
protocol ArticleRemoteDataSourceProtocol {
    func fetchFeed() async throws -> ArticleFeedDTO
}
```

---

## 6. LocalDataSource

LocalDataSource:

```text
- knows DB/cache/local JSON
- returns DBModel or DTO depending on source
- does not return ViewState
```

For local JSON mock:

```swift
protocol ArticleLocalJSONDataSourceProtocol {
    func fetchFeed() async throws -> ArticleFeedDTO
}
```

For DB:

```swift
protocol ArticleLocalDataSourceProtocol {
    func fetchArticles() async throws -> [ArticleDBModel]
    func saveArticles(_ models: [ArticleDBModel]) async throws
}
```

---

## 7. DTO Rules

DTO represents external data contract.

```swift
struct ArticleDTO: Decodable {
    let id: String
    let title: String
    let summary: String?
    let publishedAt: String
}
```

DTO can be ugly because APIs are ugly. Domain should not inherit that ugliness.

---

## 8. DBModel Rules

DBModel represents persistence schema.

```swift
struct ArticleDBModel {
    let id: String
    let title: String
    let summary: String
    let publishedAtTimestamp: TimeInterval
    let lastUpdatedTimestamp: TimeInterval
}
```

DBModel can be optimized for storage, not UI.

---

## 9. Cache Policy

Cache policy should be explicit:

```swift
enum CachePolicy {
    case cacheOnly
    case networkOnly
    case cacheFirstThenRefresh
    case networkFirstFallbackToCache
    case staleWhileRevalidate
}
```

Repository implements policy.

UseCase chooses policy based on business scenario or receives it from Presentation.

---

## 10. Offline First

Offline-first flow:

```text
read local first
render cached/stale data
attempt remote refresh
save remote result
update domain result
handle sync queue
```

Repository should expose enough metadata:

```swift
struct ArticleFeedResult {
    let articles: [Article]
    let freshness: DataFreshness
    let syncStatus: SyncStatus?
}
```

---

## 11. Error Mapping

Remote error:

```text
HTTPError
 → RemoteDataSourceError
 → RepositoryError
 → Domain/AppError
 → Presentation ErrorViewState
```

DB error:

```text
DatabaseError
 → LocalDataSourceError
 → RepositoryError
 → AppError
```

---

## 12. Retry

Retry strategy belongs to:

```text
- Repository for low-level transient retry if generic
- UseCase for business-level retry
- Presentation for user-triggered retry
```

Do not hide endless retries inside ViewModel.

---

## 13. Sync

Sync should be separate from screen ViewModel for app-level sync:

```text
SyncService
SyncRepository
PendingOperationStore
BackgroundSyncCoordinator
```

Feature ViewModel can trigger user action, not own sync engine.

---

## 14. Local JSON Replacement Rule

Local JSON and Remote API should share DTO mapping where possible:

```text
LocalJSONDataSource → DTO
RemoteDataSource → DTO
Repository → Domain
```

This allows replacement without Presentation changes.

---

## 15. Rule

```text
Repository is the policy boundary between business needs and data source mechanics.
```
