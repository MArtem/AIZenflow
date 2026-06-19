# 02_When_To_Use_And_When_Not — SwiftUI Native State Architecture

## 1. Purpose

Этот документ объясняет, когда использовать нативное состояние SwiftUI, когда оно достаточно, а когда нужно переходить к MVVM, TCA/UDF, Clean Architecture или Coordinator.

---

## 2. Use SwiftUI Native State When

Используй нативное состояние SwiftUI, если state:

```text
- локальный
- визуальный
- короткоживущий
- не требует бизнес-логики
- не должен шариться между многими экранами
- не требует сложных тестов
```

Примеры:

```text
- isExpanded
- isFocused
- selected local segment
- local draft text in simple control
- local animation flag
- local sheet toggle for UI-only sheet
```

---

## 3. Use for Simple Screens When

SwiftUI Native State может быть достаточным для простого экрана:

```text
- статичный экран
- настройки без сложной логики
- simple form без API
- simple preview/demo
- local-only UI
```

---

## 4. Use `@State` When

```text
- View owns the state
- state is local to this View
- parent does not need to control it
- state can reset with View lifecycle
```

Пример:

```swift
@State private var isExpanded = false
```

---

## 5. Use `@Binding` When

```text
- parent owns state
- child edits it
- component is controlled
- two-way UI interaction is desired
```

Пример:

```swift
struct SearchField: View {
    @Binding var text: String
}
```

---

## 6. Use `@Observable` When

```text
- state is reference-owned
- state has multiple mutable properties
- state is shared across a screen or feature boundary
- View needs to observe object changes
```

Но `@Observable` не означает, что объект может быть God Object.

---

## 7. Use `@Environment` When

```text
- dependency is ambient by nature
- many views need access
- explicit passing would create noise
- dependency is stable and app-level
```

Примеры:

```text
- theme
- locale
- color scheme
- app settings
- session state
```

Не использовать для random repositories без архитектурного решения.

---

## 8. Use `.task` When

```text
- async work is tied to View lifetime
- work should cancel when View disappears
- work should restart when id changes
```

Пример:

```swift
.task(id: selectedCategoryID) {
    await viewModel.reload(categoryID: selectedCategoryID)
}
```

---

## 9. Do Not Use SwiftUI Native State Alone When

```text
- screen has complex API/DB/cache
- feature has offline-first behavior
- there is domain logic
- there is pagination
- there are optimistic updates
- state must be tested as user action sequence
- state is shared across multiple screens
- navigation flow is complex
```

---

## 10. Move to MVVM When

```text
- screen has loading/error/empty/content
- screen loads data
- user actions trigger async operations
- presentation logic must be tested
- Domain → ViewState mapping appears
```

---

## 11. Move to TCA/UDF When

```text
- many actions
- many effects
- nested states
- per-item state
- complex reducer-like behavior
- need strict Action → State → Effect tests
```

---

## 12. Move to Clean Architecture When

```text
- API/DTO/DB/cache exist
- local JSON mock should be replaced by API later
- business rules exist
- data source must be hidden from UI
```

---

## 13. Move to Coordinator When

```text
- deep links
- onboarding/auth flow
- multi-screen flow
- modal/push/pop complexity
- navigation depends on async preconditions
```

---

## 14. Overengineering Signals

SwiftUI Native State was overcomplicated if:

```text
- every tiny visual state has ViewModel
- simple local expansion uses global store
- binding component has 5 architectural files
- no actual business/data complexity exists
```

---

## 15. Underengineering Signals

SwiftUI Native State is insufficient if:

```text
- View has APIClient
- View stores DTO
- View has many unrelated @State vars
- body contains business decisions
- .task does raw data access
- no testable presentation layer exists
```

---

## 16. Decision Rule

```text
Keep state in SwiftUI only while it is truly local, visual, and simple.
Escalate state ownership when the state becomes business, feature, shared, async-heavy, or persistent.
```
