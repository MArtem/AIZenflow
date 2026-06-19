# 04_Data_Flow_Rules — Modular / Feature-Sliced Architecture

## 1. Purpose

Этот документ описывает data flow между модулями/features.

---

## 2. Main Rule

```text
Features should communicate through explicit public contracts, not through internal implementation details.
```

---

## 3. Within Feature Data Flow

Inside feature, use selected architecture:

```text
View
 → ViewModel/Store/Presenter
 → UseCase
 → Repository
 → DataSource
```

---

## 4. Cross-feature Communication

Prefer:

```text
Feature Output
Route
Public Protocol
Shared Domain Event
App-level Coordinator
```

Avoid:

```text
Feature A imports Feature B internals
Feature A directly mutates Feature B ViewModel
Feature A reads Feature B database models
```

---

## 5. Public Contract

Example:

```swift
public enum ProfileRoute {
    case profile(UserID)
}

public protocol ProfileFeatureBuilding {
    func makeProfile(userID: UserID) -> ProfileView
}
```

---

## 6. Shared Models

Use shared models only when they are truly shared domain primitives:

```text
UserID
ArticleID
Money
DateRange
AppError
```

Do not put full feature entities in Shared just because two features need one field.

---

## 7. App Composition Flow

```text
AppCoordinator
 → AuthFeature public API
 → NewsFeature public API
 → ProfileFeature public API
```

App composes features.

Features should not compose the whole app.

---

## 8. Feature Output Flow

```swift
enum AuthOutput {
    case didLogin(UserID)
    case didCancel
}
```

Parent flow handles output.

---

## 9. Domain Events

For cross-cutting events:

```text
UserLoggedIn
UserLoggedOut
SettingsChanged
NetworkStatusChanged
```

Use app-level store/event bus carefully. Avoid global event soup.

---

## 10. Data Ownership

A feature should own its feature-specific data.

Shared infrastructure can own:

```text
database client
network client
keychain client
```

But feature repository owns feature-specific data policy.

---

## 11. Rule

```text
Data crosses module boundaries as IDs, public contracts, outputs, or shared primitives — not as internal DTO/DBModel/ViewModel.
```
