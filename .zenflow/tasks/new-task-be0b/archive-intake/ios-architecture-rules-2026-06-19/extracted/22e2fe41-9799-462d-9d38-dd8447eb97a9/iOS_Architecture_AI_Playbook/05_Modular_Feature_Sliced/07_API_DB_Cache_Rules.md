# 07_API_DB_Cache_Rules — Modular / Feature-Sliced Architecture

## 1. Purpose

Этот документ описывает, как размещать API/DB/cache в модульном проекте.

---

## 2. Main Rule

```text
Infrastructure provides mechanics.
Features own product-specific data policy.
```

---

## 3. Shared Infrastructure

Shared/infrastructure modules can provide:

```text
HTTPClient
DatabaseClient
KeychainClient
FileStorageClient
AnalyticsClient
```

---

## 4. Feature Data Layer

Feature owns:

```text
DTO
DBModel
Repository
DataSource
Mappers
Cache policy for that feature
```

unless data is truly shared domain.

---

## 5. Avoid Shared Repository Dump

Bad:

```text
Shared/Repositories/AppRepository.swift
Shared/Services/DataManager.swift
```

Good:

```text
Features/News/Data/NewsRepository.swift
Features/Profile/Data/ProfileRepository.swift
```

---

## 6. Shared API Client

Good:

```text
Infrastructure/Networking/HTTPClient
```

Feature RemoteDataSource uses it.

---

## 7. Shared Database

Good:

```text
Infrastructure/Persistence/DatabaseClient
```

Feature LocalDataSource uses it.

---

## 8. DTO Ownership

DTO belongs to the feature/data source that consumes API contract.

Do not put all DTOs in Shared by default.

---

## 9. DBModel Ownership

DBModel belongs to feature if schema is feature-specific.

Shared DB primitives are okay:

```text
StoredMetadata
SyncStatus
```

---

## 10. Rule

```text
Share infrastructure, not feature-specific data policy.
```
