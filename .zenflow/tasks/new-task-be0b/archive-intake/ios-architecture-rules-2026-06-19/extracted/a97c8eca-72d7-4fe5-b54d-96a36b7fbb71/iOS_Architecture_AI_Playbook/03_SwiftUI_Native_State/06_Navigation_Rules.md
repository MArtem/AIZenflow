# 06_Navigation_Rules — SwiftUI Native State Architecture

## 1. Purpose

Этот документ описывает навигацию при использовании нативного SwiftUI state.

---

## 2. Main Rule

```text
Navigation state is state too.
It needs ownership and boundaries.
```

---

## 3. Simple NavigationStack

For simple screen-local navigation:

```swift
enum Route: Hashable {
    case details(ItemID)
}

@State private var path: [Route] = []
```

---

## 4. Route Type Rules

Route should contain stable identifiers or small value objects:

```swift
case articleDetails(ArticleID)
```

Avoid:

```swift
case articleDetails(ArticleDTO)
case articleDetails(ArticleDBModel)
case articleDetails(ArticleViewModel)
```

---

## 5. NavigationLink Rules

For static/simple links:

```swift
NavigationLink("Details", value: Route.details(id))
```

For business-dependent navigation, prefer action:

```swift
Button("Comments") {
    model.send(.commentsTapped(articleID))
}
```

---

## 6. Sheet State

Simple UI-only sheet:

```swift
@State private var isFilterSheetPresented = false
```

Business-driven sheet:

```swift
enum ActiveSheet: Identifiable {
    case filters
    case share(ArticleID)
}
```

---

## 7. Alert State

Simple alert:

```swift
@State private var isAlertPresented = false
```

Non-trivial alert:

```swift
struct AlertState: Identifiable, Equatable {
    let id: String
    let title: String
    let message: String
    let action: AlertAction?
}
```

---

## 8. Programmatic Navigation

Avoid random navigation mutations from many child views.

Better:

```text
Child sends action
Parent/model updates route/path
```

---

## 9. Coordinator Escalation

Use Coordinator when:

```text
- deep links
- auth flow
- onboarding
- tab flows
- multi-step modal flows
- navigation depends on async preconditions
```

---

## 10. Deep Links

Deep links should be parsed outside random View body:

```text
URL → AppRoute → FeatureRoute → Navigation state/coordinator
```

---

## 11. Navigation and `.task`

Do not navigate from raw `.task` without clear state boundary.

Better:

```text
task loads session
model updates route intent
View/Coordinator applies route
```

---

## 12. Back Navigation

Simple:

```swift
@Environment(\.dismiss) private var dismiss
```

Use for local modal/pop.

Complex flow:

```text
send close action to coordinator/store
```

---

## 13. Navigation Tests

Test route decisions in model/ViewModel/store if logic exists.

No need to unit-test simple NavigationLink.

---

## 14. Rule

```text
Use SwiftUI navigation state for simple flows.
Escalate to Coordinator/Router when flow logic becomes non-local.
```
