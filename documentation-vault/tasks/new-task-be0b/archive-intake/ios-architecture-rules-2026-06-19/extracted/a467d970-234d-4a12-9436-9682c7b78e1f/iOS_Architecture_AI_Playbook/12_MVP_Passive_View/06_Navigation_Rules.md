# 06_Navigation_Rules — MVP / Passive View

## 1. Purpose

Этот документ описывает navigation in MVP.

---

## 2. Main Rule

```text
Presenter decides navigation intent.
Router/Coordinator executes navigation.
```

---

## 3. Presenter Navigation

Presenter can call:

```swift
router.openDetails(id)
router.close()
router.openLogin()
```

---

## 4. Router Role

Router owns:

```text
- push/present/dismiss
- SwiftUI path/sheet integration
- destination construction
- route parameters
```

---

## 5. Presenter Must Not

Presenter must not:

```text
- create UIViewController directly
- access UINavigationController directly
- build SwiftUI destination View directly
```

unless the project intentionally uses a very small MVP without Router.

---

## 6. Route Payload

Use IDs/value objects.

Avoid:

```text
DTO
DBModel
Repository
ViewModel
```

---

## 7. Auth/Protected Navigation

Presenter may ask UseCase/Session service:

```text
is user logged in?
```

Then route:

```text
open login
or open protected screen
```

Business truth should live outside Presenter.

---

## 8. Deep Links

Deep links should be handled at App/Coordinator layer, then call Presenter/Router or open module.

---

## 9. Rule

```text
Navigation is not View responsibility in MVP.
```
