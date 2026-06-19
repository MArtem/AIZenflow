# 08_Error_Loading_Empty_State_Rules — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

This document explains error/loading/empty modeling around ports and adapters.

---

## 2. Main Rule

```text
Adapters expose domain-friendly results and errors.
Presentation owns user-facing loading/empty/error.
```

---

## 3. Adapter Errors

Adapter should hide raw SDK errors:

```text
URLError
DecodingError
SQLiteError
FirebaseError
```

and map to:

```text
AppError
DomainError
PortError
```

---

## 4. Empty Result

Empty list from API/DB is not adapter error.

Adapter returns empty domain collection.

Presentation decides empty UI.

---

## 5. Loading

Loading is not Domain/Adapter state unless operation progress is part of use case.

Presentation owns spinner/skeleton.

---

## 6. Progress Port

For long operations:

```swift
protocol ImportPort {
    func importFile(_ file: FileReference) -> AsyncThrowingStream<ImportProgress, Error>
}
```

Progress is domain/application concept. Spinner is presentation.

---

## 7. Offline

Adapter/repository can return:

```swift
struct FeedResult {
    let feed: ArticleFeed
    let freshness: DataFreshness
}
```

Presentation renders offline/stale state.

---

## 8. Retry

Retry can live:

```text
Adapter: low-level transient retry
UseCase: business retry
Presentation: user retry action
```

---

## 9. Rule

```text
Technical failure becomes domain/application failure before it reaches UI.
```
