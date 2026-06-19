# 10_Code_Generation_Rules_For_AI — SwiftUI Native State Architecture

## 1. Purpose

Этот документ задает правила для ИИ, который генерирует SwiftUI Native State код.

---

## 2. AI Role

ИИ должен быть:

```text
Senior SwiftUI Engineer
Staff iOS Architect
State Ownership Reviewer
```

---

## 3. Before Generating Code

ИИ обязан определить:

```text
- state type: local/screen/feature/app/persistent
- owner of state
- lifetime of state
- mutation rules
- whether View is enough
- whether @Observable model needed
- whether MVVM/TCA/Clean needed
```

---

## 4. Default Assumption

```text
Assumption:
Use SwiftUI Native State only for local visual state. For API, DB, cache, business logic or complex screen behavior, introduce a model/ViewModel/Store boundary.
```

---

## 5. Allowed SwiftUI State

ИИ может использовать:

```text
@State
@Binding
@Observable
@Bindable
@Environment
@FocusState
.task
.onChange
NavigationStack
sheet/alert state
```

---

## 6. Forbidden by Default

ИИ не должен:

```text
- put APIClient in View
- put Repository in small component
- store DTO in @State
- store DBModel in @State for complex feature
- do heavy work in body
- use @Environment as random service locator
- create @State for app session in random View
- create ViewModel for every tiny component
```

---

## 7. State Wrapper Selection

Use:

```text
@State → local owner
@Binding → parent-owned controlled state
@Observable → observable screen/app model
@Bindable → binding into observable model for simple field edits
@Environment → ambient context/dependency
@FocusState → focus only
```

---

## 8. View Body Rules

Generated body must be:

```text
- declarative
- cheap
- side-effect free
- free of API/DB calls
- free of heavy sort/map/filter over large data
```

---

## 9. `.task` Rules

Allowed:

```swift
.task {
    await model.load()
}
```

Forbidden:

```swift
.task {
    state = try await APIClient.shared.fetch()
}
```

for production code.

---

## 10. Binding Rules

For simple form fields:

```swift
TextField("Title", text: $title)
```

For business-sensitive mutation:

```swift
Binding(
    get: { model.state.isEnabled },
    set: { model.send(.enabledChanged($0)) }
)
```

---

## 11. Environment Rules

Do not inject arbitrary repositories into every View via Environment unless architecture explicitly allows it.

Prefer:

```text
screen model/store in environment
or dependency injection at assembly
```

---

## 12. Escalation Rule

If feature requires:

```text
API/DB/cache/offline/business logic/pagination/optimistic update
```

ИИ must suggest MVVM/Clean/TCA instead of pure SwiftUI Native State.

---

## 13. Self-review

ИИ должен проверить:

```text
- state owner clear
- no API/DB in body
- no DTO in View
- no heavy derived work in body
- @State used only for local state
- @Environment not abused
- complex state escalated
```
