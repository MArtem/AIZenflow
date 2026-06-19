# 04_Data_Flow_Rules — SwiftUI Native State Architecture

## 1. Purpose

Этот документ описывает data flow при использовании SwiftUI Native State.

---

## 2. Main Rule

```text
SwiftUI Native State can own UI state.
It should not own raw data access flow for production features.
```

---

## 3. UI-only Data Flow

For local component:

```text
User taps
 → @State changes
 → body recomputes
 → UI updates
```

Example:

```swift
Button("Expand") {
    isExpanded.toggle()
}
```

---

## 4. Controlled Component Flow

```text
Parent owns @State
 → passes @Binding to child
 → child mutates binding
 → parent state updates
 → views re-render
```

Example:

```swift
@State private var query = ""

SearchField(text: $query)
```

---

## 5. Observable Model Flow

```text
View observes @Observable model
 → user action calls model method
 → model mutates observable property
 → View updates
```

Example:

```swift
@Observable
final class CounterModel {
    var count = 0

    func increment() {
        count += 1
    }
}
```

---

## 6. Production Data Flow

For API/DB/cache features:

```text
View
 → ViewModel/Store/Model method
 → UseCase/Repository
 → DataSource
 → DTO/DBModel
 → Domain
 → ViewState
 → View
```

SwiftUI state observes final ViewState, not raw DTO.

---

## 7. Local JSON Flow

Bad:

```text
View reads JSON file
 → decodes DTO
 → renders DTO
```

Good:

```text
View .task
 → viewModel.load()
 → LocalJSONDataSource
 → DTO
 → Domain
 → ViewState
 → View
```

---

## 8. `.task` Flow

Allowed:

```swift
.task {
    await model.load()
}
```

if `model.load()` hides data logic.

Avoid:

```swift
.task {
    let dto = try await api.fetch()
    self.dto = dto
}
```

---

## 9. `.onChange` Flow

Use `.onChange` for UI reaction to state changes.

Do not put heavy business/data logic directly in `.onChange`.

Better:

```swift
.onChange(of: query) { _, newValue in
    model.searchQueryChanged(newValue)
}
```

---

## 10. Binding Flow

Bindings should not become hidden business commands.

Bad:

```swift
Toggle("Premium", isOn: $model.user.isPremium)
```

if toggling premium has business/API implications.

Better:

```swift
Toggle(
    "Premium",
    isOn: Binding(
        get: { model.state.isPremiumEnabled },
        set: { model.send(.premiumToggleChanged($0)) }
    )
)
```

---

## 11. Derived Data Flow

Do not compute expensive derived data in body:

```swift
var body: some View {
    let sorted = items.sorted(...)
}
```

Better:

```text
prepare derived state in model/viewModel
or memoize when input changes
```

---

## 12. Per-card Data Flow

For simple local expansion:

```text
Card owns @State isExpanded
```

For server actions:

```text
Card sends action
 → parent/model handles action
 → parent updates card ViewState
```

---

## 13. Navigation Data Flow

Simple local route:

```swift
@State private var path: [Route] = []
```

Complex route:

```text
View sends action
 → model/ViewModel emits route
 → Coordinator/NavigationStack updates path
```

---

## 14. Rule

```text
SwiftUI state should receive prepared state, not perform raw data preparation.
```
