# 07_API_DB_Cache_Rules — MVVM

## 1. Purpose

Этот документ описывает, как MVVM должен взаимодействовать с API, DB, cache и local JSON.

Главная цель — не допустить data-access логики во View/ViewModel.

---

## 2. Main Rule

```text
ViewModel may call a UseCase or Repository boundary.
ViewModel must not implement API/DB/cache mechanics.
```

---

## 3. Recommended Dependency

Лучший вариант:

```swift
@MainActor
final class NewsFeedViewModel {
    private let fetchArticles: FetchArticlesUseCase
    private let likeArticle: LikeArticleUseCase

    init(
        fetchArticles: FetchArticlesUseCase,
        likeArticle: LikeArticleUseCase
    ) {
        self.fetchArticles = fetchArticles
        self.likeArticle = likeArticle
    }
}
```

Допустимый light вариант:

```swift
final class NewsFeedViewModel {
    private let repository: ArticleRepositoryProtocol
}
```

Для сложного продукта лучше UseCase.

---

## 4. Forbidden Dependencies in ViewModel

ViewModel не должна напрямую зависеть от:

```text
URLSession
APIClient concrete singleton
SwiftData ModelContext
CoreData NSManagedObjectContext
FileManager for feature data
raw JSON decoder
SQLite implementation
Firebase SDK
```

Исключение возможно только для очень маленького prototype, но не для production rules.

---

## 5. API Rules

API flow:

```text
RemoteDataSource
 → APIClient
 → DTO
 → Repository
 → Domain
 → UseCase
 → ViewModel
 → ViewState
```

ViewModel не должна знать endpoint path:

```swift
"/articles/feed"
```

---

## 6. Local JSON Rules

Для mock API:

```text
LocalJSONDataSource returns DTO
Repository consumes DTO same way as RemoteDataSource
```

Это позволяет заменить local JSON на real API без изменения ViewModel.

---

## 7. DB Rules

ViewModel не должна работать с DBModel напрямую.

Плохо:

```swift
var articles: [ArticleDBModel]
```

Лучше:

```swift
var state: NewsFeedViewState
```

и данные приходят как:

```swift
let articles: [Article] = try await fetchArticles.execute()
```

---

## 8. Cache Policy Rules

ViewModel может выбрать policy на уровне user intent:

```swift
try await fetchArticles.execute(policy: .cacheFirstThenRefresh)
```

Но не должна реализовывать сам cache algorithm.

Пример:

```text
Initial load:
.cacheFirstThenRefresh

Pull to refresh:
.networkFirstFallbackToCache

Offline mode:
.cacheOnly
```

---

## 9. Stale Data Rules

Repository/UseCase может вернуть metadata:

```swift
struct ArticleFeedResult {
    let articles: [Article]
    let freshness: DataFreshness
}

enum DataFreshness {
    case fresh
    case stale(lastUpdated: Date)
    case cached
}
```

ViewModel маппит это в UI:

```swift
state.offlineBanner = result.freshness.bannerViewState
```

---

## 10. Sync Rules

Если есть sync:

```text
ViewModel triggers sync intent
UseCase starts sync
Repository coordinates local/remote
ViewModel observes result/state
```

Не делать sync loop внутри View.

---

## 11. Optimistic Update Rules

ViewModel может делать optimistic UI state:

```swift
state.updateCard(id) {
    $0.isLiked = true
    $0.likeState = .loading
}
```

Но persistence/network confirmation идет через UseCase/Repository.

---

## 12. Error Mapping

Data errors должны быть преобразованы:

```text
NetworkError
DecodingError
DatabaseError
RepositoryError
DomainError
PresentationErrorViewState
```

ViewModel может использовать `ErrorViewStateMapper`.

---

## 13. Background Refresh

Background refresh не должен жить внутри конкретной screen ViewModel, если это app-level задача.

Использовать:

```text
BackgroundSyncService
AppRefreshCoordinator
Repository sync API
```

---

## 14. Analytics Boundary

ViewModel может отправить analytics event через abstraction:

```swift
analytics.track(.articleLikeTapped(articleID))
```

Но analytics не должна заменять business logic и не должна жить во View.

---

## 15. Rule

```text
MVVM Presentation controls user-facing state.
Data layer controls data-source mechanics.
```
