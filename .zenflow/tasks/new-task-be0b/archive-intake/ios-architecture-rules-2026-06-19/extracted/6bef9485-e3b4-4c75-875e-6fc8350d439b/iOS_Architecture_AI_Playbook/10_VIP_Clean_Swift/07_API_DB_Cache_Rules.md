# 07_API_DB_Cache_Rules — VIP / Clean Swift

## 1. Purpose

Этот документ описывает API/DB/cache boundaries in VIP/Clean Swift.

---

## 2. Main Rule

```text
Interactor may call Worker/UseCase. View and Presenter must not call API/DB/cache.
```

---

## 3. Worker Role

Worker handles external work:

```text
API
DB
cache
file storage
keychain
```

But in modern architecture Worker can delegate to Repository/UseCase.

---

## 4. Recommended Modern Flow

```text
Interactor
 → UseCase
 → Repository
 → DataSource
```

or:

```text
Interactor
 → Worker
 → Repository
 → DataSource
```

---

## 5. DTO/DBModel Rules

DTO/DBModel should not enter:

```text
View
Presenter
ViewModel
Request/Response if Response is intended as domain result
```

---

## 6. Cache Policy

Interactor may choose high-level policy:

```text
initial load
refresh
offline
```

Repository/Worker implements mechanics.

---

## 7. Offline/Stale

Worker/UseCase returns domain result + freshness.

Interactor includes in Response.

Presenter formats into banner/ViewModel.

---

## 8. Error Mapping

```text
Infrastructure error
 → Worker/Repository error
 → AppError/DomainError
 → Response
 → Presenter ErrorViewModel
```

---

## 9. Rule

```text
Worker is an adapter boundary, not a dumping ground for all business logic.
```
