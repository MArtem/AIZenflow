# 06_Navigation_Rules — MVC / Massive ViewController / Migration

## 1. Purpose

Этот документ описывает navigation migration from Massive ViewController.

---

## 2. Massive VC Navigation Smell

```text
ViewController:
- validates auth
- fetches data
- creates destination
- configures destination dependencies
- pushes/presents
```

Too much.

---

## 3. First Step

Extract route enum:

```swift
enum FeatureRoute {
    case details(ItemID)
    case loginRequired
}
```

---

## 4. Better Flow

```text
ViewController forwards user event
 → ViewModel/Presenter decides route intent
 → Coordinator/Router executes route
```

---

## 5. Coordinator Extraction

Create:

```text
FeatureCoordinator
FeatureRoute
FeatureAssembly
```

Coordinator handles:

```text
- destination creation
- dependency injection
- push/present
```

---

## 6. Route Payload

Use:

```text
IDs
Domain value objects
small input models
```

Avoid:

```text
DTO
DBModel
ViewController
ViewModel instance
```

---

## 7. Storyboard/Segue Migration

If storyboard segues exist:

```text
1. centralize segue identifiers
2. move prepare(for segue:) mapping to router adapter
3. gradually replace with coordinator assembly
```

---

## 8. Deep Links

Move from random ViewControllers to:

```text
DeepLinkParser
AppCoordinator
FeatureCoordinator
```

---

## 9. Rule

```text
ViewController can trigger navigation, but should not own navigation construction for complex flows.
```
