# 07_API_DB_Cache_Rules — ReactorKit / Reactor-style Architecture

## 1. Purpose

Этот документ описывает API/DB/cache boundaries in Reactor-style architecture.

---

## 2. Main Rule

```text
Reactor can call UseCase/Repository boundary, but should not implement API/DB/cache mechanics.
```

---

## 3. Dependencies

Inject:

```text
UseCase
Repository Protocol
Client abstraction
```

Avoid:

```text
URLSession
APIClient.shared
SwiftData/CoreData context directly
raw JSON decoder
```

inside Reactor.

---

## 4. mutate() Side Effects

`mutate(action:)` is where async side effects start.

But it should call boundaries:

```text
fetchFeedUseCase.execute()
likeArticleUseCase.execute()
```

not raw infrastructure.

---

## 5. DTO/DBModel

DTO/DBModel should not enter State or View.

Use:

```text
DTO → Domain in Data
Domain → State in Presentation mapper
```

---

## 6. Cache Policy

Reactor can choose policy based on Action:

```text
viewDidLoad → cacheFirstThenRefresh
refresh → networkFirstFallbackToCache
```

Repository implements policy.

---

## 7. Offline/Stale

UseCase can return:

```text
Domain result + freshness metadata
```

Reactor maps to state/banner.

---

## 8. Rule

```text
Reactor orchestrates feature side effects. Data layer owns data-source policy.
```
