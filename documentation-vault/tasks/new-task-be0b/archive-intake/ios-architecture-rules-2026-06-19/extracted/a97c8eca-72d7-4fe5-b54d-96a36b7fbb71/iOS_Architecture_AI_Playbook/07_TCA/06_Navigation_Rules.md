# 06_Navigation_Rules — TCA

## 1. Purpose

Этот документ описывает navigation в TCA.

---

## 2. Main Rule

```text
Navigation should be state-driven.
```

---

## 3. Destination State

Use destination state for sheets/alerts/details:

```swift
@Presents var destination: Destination.State?
```

or path state for stacks depending on project style.

---

## 4. Destination Action

```swift
enum Action {
    case destination(PresentationAction<Destination.Action>)
    case articleTapped(ArticleID)
}
```

---

## 5. Reducer Sets Navigation State

```swift
case .articleTapped(let id):
    state.destination = .articleDetails(ArticleDetailsFeature.State(id: id))
    return .none
```

---

## 6. View Renders Navigation State

View observes store and connects navigation APIs to state.

---

## 7. Route with IDs

Navigation state should use IDs/value objects.

Avoid DTO/DBModel.

---

## 8. Auth Gate

```text
protected action
 → reducer/use case/dependency checks session
 → set destination login or target
```

App-level auth flows can still use Coordinator/AppFeature.

---

## 9. Coordinator with TCA

Coordinator can be used at app/flow boundary.

Rule:

```text
TCA feature owns feature navigation state.
App Coordinator/AppFeature owns app-level flow.
```

---

## 10. Rule

```text
No hidden navigation side effects. Navigation is data.
```
