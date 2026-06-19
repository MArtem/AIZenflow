# 05_Global_API_DB_Cache_Rules

## 1. Purpose

Этот документ задает правила для API, DTO, DB, cache, repository, local JSON mock и offline-first.

---

## 2. Main Rule

```text
UI must not depend on the physical source of data.
```

UI не должен знать:

```text
- REST это или GraphQL
- JSON mock это или real API
- SwiftData это или CoreData
- cache hit это или network hit
```

---

## 3. Data Layers

Рекомендуемый flow:

```text
Remote API / Local JSON
        ↓
DTO
        ↓
Domain Model
        ↓
UI Model / ViewState
```

С БД:

```text
Remote API
    ↓
DTO
    ↓
DBModel
    ↓
Domain Model
    ↓
UI Model / ViewState
```

---

## 4. DTO Rules

DTO:

```text
- отражает API/local JSON contract
- может иметь snake_case mapping
- может иметь optional поля из-за backend reality
- не должен содержать UI formatting
- не должен протекать во View
- не должен быть DB model
```

Пример:

```swift
struct ArticleDTO: Decodable {
    let id: String
    let title: String
    let summary: String?
    let publishedAt: String
    let author: AuthorDTO?
}
```

---

## 5. Domain Model Rules

Domain model:

```text
- отражает смысл продукта
- не зависит от API
- не зависит от DB framework
- не зависит от SwiftUI
- содержит нормализованные типы
```

Пример:

```swift
struct Article: Equatable, Identifiable {
    let id: ArticleID
    let title: String
    let summary: String
    let publishedAt: Date
    let author: Author?
}
```

---

## 6. DB Model Rules

DB model:

```text
- отражает persistence schema
- может содержать индексы
- может содержать relationship fields
- может отличаться от Domain
- не должен использоваться напрямую в UI
```

Если используется SwiftData, надо помнить: SwiftData тесно интегрирован со SwiftUI, но архитектура все равно должна решать, разрешено ли View напрямую работать с persistence.

---

## 7. UI Model / ViewState Rules

UI model:

```text
- готов для отображения
- содержит formatted strings
- содержит UI flags
- содержит button states
- содержит loading/error markers
- не должен быть DTO
- не должен быть DB model
```

Пример:

```swift
struct ArticleCardViewState: Identifiable, Equatable {
    let id: ArticleID
    let title: String
    let subtitle: String
    let authorName: String
    let publishedDateText: String
    let isLiked: Bool
    let likeButtonState: LoadingButtonState
}
```

---

## 8. Repository Rules

Repository отвечает за:

```text
- выбор источника данных
- cache policy
- sync policy
- объединение remote/local
- сохранение remote result в local storage
- отдачу domain models
```

Repository не должен:

```text
- форматировать UI text
- знать SwiftUI
- возвращать ViewState
- быть God Service для всего
```

---

## 9. DataSource Rules

RemoteDataSource:

```text
- знает API endpoint
- возвращает DTO
- не возвращает Domain напрямую, если есть DTO layer
```

LocalDataSource:

```text
- знает DB/local JSON/cache
- возвращает DBModel или DTO depending on source
- не знает SwiftUI
```

---

## 10. Local JSON Mock Rules

Local JSON mock должен быть архитектурно совместим с будущим API.

Правильно:

```text
LocalJSONDataSource returns DTO
RemoteArticleDataSource returns DTO
Repository consumes DTO from either source
```

Неправильно:

```text
Local JSON decoded directly into ArticleCardViewState
```

---

## 11. Cache Policy Rules

Каждый repository должен явно иметь cache policy.

Примеры:

```swift
enum CachePolicy {
    case cacheOnly
    case networkOnly
    case cacheFirstThenRefresh
    case networkFirstFallbackToCache
    case staleWhileRevalidate
}
```

Не должно быть скрытого поведения:

```swift
func fetchArticles() async throws -> [Article]
```

если непонятно, откуда данные и что происходит при offline.

Лучше:

```swift
func fetchArticles(policy: CachePolicy) async throws -> ArticleFeedResult
```

---

## 12. Offline State Rules

Offline — это не всегда error.

Возможные состояния:

```text
- loaded fresh data
- loaded stale data
- loaded cached data while refresh failed
- no cached data and offline
- sync pending
- optimistic update pending
- optimistic update failed
```
