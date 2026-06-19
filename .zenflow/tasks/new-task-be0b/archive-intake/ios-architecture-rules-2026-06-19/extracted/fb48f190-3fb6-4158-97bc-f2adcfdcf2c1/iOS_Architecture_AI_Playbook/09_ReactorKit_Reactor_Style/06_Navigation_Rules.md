# 06_Navigation_Rules — ReactorKit / Reactor-style Architecture

## 1. Purpose

Этот документ описывает navigation in Reactor-style architecture.

---

## 2. Main Rule

```text
Navigation intent should be explicit and separated from View business logic.
```

---

## 3. Options

Navigation can be modeled as:

```text
State route
Pulse route/event
Output relay
Coordinator route
RxFlow Step
```

Choice depends on project.

---

## 4. Route in State

```swift
struct State {
    var route: Route?
}

enum Route {
    case details(ArticleID)
    case loginRequired
}
```

Clear after handling if one-shot.

---

## 5. Output Relay

```swift
let route = PublishRelay<Route>()
```

Can be used carefully, but avoid hidden untestable navigation.

---

## 6. Coordinator

Recommended for larger apps:

```text
Reactor emits route/output
Coordinator handles navigation
```

---

## 7. RxFlow

For RxFlow projects:

```text
Action/Mutation/State handles screen behavior
Stepper/Step handles navigation flow
```

Keep responsibilities clear.

---

## 8. Route Payload

Use IDs/value objects.

Avoid DTO/DBModel/ViewModel.

---

## 9. Rule

```text
Reactor may decide navigation intent. Coordinator/Flow executes navigation mechanics.
```
