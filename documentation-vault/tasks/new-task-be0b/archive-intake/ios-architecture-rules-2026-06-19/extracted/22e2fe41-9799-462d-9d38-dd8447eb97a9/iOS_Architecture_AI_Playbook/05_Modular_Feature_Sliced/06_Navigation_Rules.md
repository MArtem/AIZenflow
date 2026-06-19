# 06_Navigation_Rules — Modular / Feature-Sliced Architecture

## 1. Purpose

Navigation in modular architecture must not break feature boundaries.

---

## 2. Main Rule

```text
Feature internals should not be required to navigate to another feature.
Use public routes and app/flow coordinator.
```

---

## 3. Feature Route

Feature exposes route contract:

```swift
public enum NewsRoute {
    case articleDetails(ArticleID)
}
```

---

## 4. Cross-feature Navigation

Bad:

```text
News imports Profile internals and creates ProfileViewModel
```

Good:

```text
News emits .openAuthorProfile(UserID)
AppCoordinator/ProfileCoordinator opens Profile feature
```

---

## 5. App Coordinator Role

AppCoordinator can know feature public assemblies:

```text
AuthAssembly
NewsAssembly
ProfileAssembly
SettingsAssembly
```

---

## 6. Deep Links

Deep link routing:

```text
URL → AppRoute → AppCoordinator → Feature public route
```

---

## 7. Feature Outputs

Feature output:

```swift
enum NewsOutput {
    case openProfile(UserID)
    case openLogin
}
```

Parent coordinator handles it.

---

## 8. Tab Navigation

Tabs are app/main-flow concern.

Feature should not switch global tabs directly.

---

## 9. Rule

```text
Features request navigation through outputs/routes; app/flow layer connects features.
```
