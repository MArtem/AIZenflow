# 07_API_DB_Cache_Rules — MVC / Massive ViewController / Migration

## 1. Purpose

Этот документ описывает extraction of API/DB/cache from Massive ViewController.

---

## 2. Bad Pattern

```swift
final class FeedViewController: UIViewController {
    func load() {
        URLSession.shared.dataTask(...)
        JSONDecoder().decode(...)
        database.save(...)
        tableView.reloadData()
    }
}
```

---

## 3. First Extraction

Create Service/Repository:

```swift
protocol FeedRepositoryProtocol {
    func loadFeed() async throws -> [Article]
}
```

ViewController calls repository through ViewModel/Presenter where possible.

---

## 4. DTO Extraction

Move DTO to Data layer:

```text
Data/DTO/ArticleDTO.swift
```

---

## 5. Mapping Extraction

```text
ArticleDTO → Article
Article → ArticleViewState
```

---

## 6. DB Extraction

Move DB operations to:

```text
LocalDataSource
Repository
PersistenceAdapter
```

---

## 7. Cache Policy Extraction

Cache policy should not stay in ViewController.

Move to Repository:

```text
cacheFirstThenRefresh
networkFirstFallbackToCache
staleWhileRevalidate
```

---

## 8. Local JSON Migration

If API is not ready:

```text
LocalJSONDataSource → DTO → Domain → ViewState
```

Then replace with API data source later.

---

## 9. Error Mapping

Move from raw error labels:

```text
URLError → AppError → ErrorViewState
```

---

## 10. Rule

```text
ViewController should request data, not know how data is fetched, decoded, cached, or persisted.
```
