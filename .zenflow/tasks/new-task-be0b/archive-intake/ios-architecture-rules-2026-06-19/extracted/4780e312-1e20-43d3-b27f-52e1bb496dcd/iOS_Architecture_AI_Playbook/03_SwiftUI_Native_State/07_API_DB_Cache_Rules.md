# 07_API_DB_Cache_Rules — SwiftUI Native State Architecture

## 1. Purpose

Этот документ объясняет границы SwiftUI Native State с API, DB, cache и local JSON.

---

## 2. Main Rule

```text
SwiftUI View should not be the owner of API/DB/cache mechanics.
```

---

## 3. API in View — Forbidden for Production

Bad:

```swift
.task {
    articles = try await APIClient.shared.fetchArticles()
}
```

Problems:

```text
- View owns data access
- hard to test
- DTO leaks likely
- no cache/offline boundary
- error mapping weak
```

---

## 4. Correct API Boundary

```swift
.task {
    await model.load()
}
```

Where `model.load()` calls:

```text
UseCase / Repository / Service boundary
```

---

## 5. Local JSON Rules

Bad:

```swift
let url = Bundle.main.url(forResource: "feed", withExtension: "json")
let dto = try JSONDecoder().decode(...)
```

inside View.

Good:

```text
LocalJSONDataSource → DTO → Domain → ViewState
```

---

## 6. DB Rules

SwiftUI can work directly with persistence frameworks for simple screens, but production architecture must decide if this is allowed.

Allowed for simple local persistence screen:

```text
@Query for simple CRUD/settings/local-only data
```

Avoid for complex features:

```text
API + DB + cache + domain rules + offline + sync
```

where DB should be hidden behind Repository/Data layer.

---

## 7. Cache Rules

View should not decide:

```text
if cache exists then show cache else fetch network
```

Cache policy belongs to Repository/Data.

View can render:

```text
cached/stale/offline ViewState
```

---

## 8. Offline Rules

View can show offline UI, but should not implement offline strategy.

Correct:

```text
Repository determines freshness
Model/ViewModel maps to ViewState
View renders banner
```

---

## 9. Sync Rules

Sync engine should not live in SwiftUI View.

Use:

```text
SyncService
Repository
BackgroundTask coordinator
App-level store
```

---

## 10. Error Mapping

Raw data errors should be mapped before reaching View:

```text
NetworkError → AppError → ErrorViewState
```

View renders user-facing error.

---

## 11. Stale Data

ViewState can include:

```swift
var offlineBanner: OfflineBannerViewState?
var freshnessText: String?
```

Do not expose raw cache internals.

---

## 12. Rule

```text
SwiftUI Native State can render data-source outcomes.
It should not implement data-source policy.
```
