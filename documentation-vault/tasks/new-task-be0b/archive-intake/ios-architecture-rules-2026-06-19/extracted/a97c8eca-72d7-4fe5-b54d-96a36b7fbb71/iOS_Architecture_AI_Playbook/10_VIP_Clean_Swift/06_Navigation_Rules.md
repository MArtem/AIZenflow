# 06_Navigation_Rules — VIP / Clean Swift

## 1. Purpose

Этот документ описывает navigation in VIP/Clean Swift.

---

## 2. Main Rule

```text
Router owns navigation mechanics.
Interactor may decide business outcome.
Presenter does not navigate.
```

---

## 3. Router Responsibilities

Router:

```text
- creates destination
- performs navigation
- passes route parameters
- handles UIKit segues if legacy
- coordinates with assembly
```

---

## 4. Interactor and Navigation

Interactor can produce navigation intent via business result:

```text
login success
validation passed
item selected
auth required
```

But should not push/present.

---

## 5. View and Router

View calls router for UI navigation event, or receives route display instruction.

Example:

```text
View detects tap
 → Interactor validates/selects
 → Presenter tells View success
 → View asks Router to route
```

or:

```text
View sends selected item to Router directly if no business rule
```

Project should choose one consistent style.

---

## 6. Route Model

Use route enum:

```swift
enum FeatureRoute {
    case details(ItemID)
    case loginRequired
}
```

---

## 7. Route Payload

Use IDs/value objects.

Avoid DTO/DBModel.

---

## 8. Router Must Not

Router must not:

```text
- call API
- validate business rules
- format UI
- own domain state
```

---

## 9. Deep Links

Deep links should be app/flow level, then route into scene.

---

## 10. Rule

```text
VIP Router moves between scenes. It does not decide business truth.
```
