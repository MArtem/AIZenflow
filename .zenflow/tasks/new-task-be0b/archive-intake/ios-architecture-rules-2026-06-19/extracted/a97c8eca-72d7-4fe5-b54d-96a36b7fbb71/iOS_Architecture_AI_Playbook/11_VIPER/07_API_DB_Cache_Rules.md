# 07_API_DB_Cache_Rules — VIPER

## 1. Purpose

Этот документ описывает API/DB/cache boundaries in VIPER.

---

## 2. Main Rule

```text
Interactor can call UseCase/Repository. Presenter/View/Router must not implement API/DB/cache.
```

---

## 3. Interactor Data Access

Interactor can depend on:

```text
UseCase
Repository Protocol
Domain Service
```

Avoid direct:

```text
URLSession
APIClient.shared
SwiftData/CoreData raw context
JSONDecoder
```

unless legacy/prototype.

---

## 4. Worker-like Dependency

VIPER sometimes uses Services/Managers.

Prefer:

```text
UseCase
Repository
DataSource
Adapter
```

over vague managers.

---

## 5. DTO/DBModel

DTO/DBModel should not enter:

```text
View
Presenter ViewModel
Router route payload
```

Interactor should receive Domain models from use cases.

---

## 6. Cache Policy

Interactor may choose high-level policy:

```text
initial load
refresh
offline load
```

Repository implements mechanics.

---

## 7. Offline/Stale

Repository returns:

```text
Domain result + freshness metadata
```

Interactor passes to Presenter.

Presenter formats offline/stale UI.

---

## 8. Error Mapping

```text
Infrastructure error
 → Repository/AppError
 → Interactor result
 → Presenter ErrorViewModel
 → View
```

---

## 9. Rule

```text
Interactor orchestrates data use. Data layer owns data mechanics.
```
