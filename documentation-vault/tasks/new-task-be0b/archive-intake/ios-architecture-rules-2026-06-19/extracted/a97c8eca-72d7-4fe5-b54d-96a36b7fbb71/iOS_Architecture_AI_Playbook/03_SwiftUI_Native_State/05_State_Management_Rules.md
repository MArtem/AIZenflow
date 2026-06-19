# 05_State_Management_Rules — SwiftUI Native State Architecture

## 1. Purpose

Этот документ задает правила владения состоянием в SwiftUI.

---

## 2. Main Rule

```text
State must have one clear owner.
```

Перед выбором wrapper спроси:

```text
- Who owns this state?
- Who mutates it?
- How long does it live?
- Is it local, screen, feature, app, or persistent?
- Does it require business logic?
```

---

## 3. State Ownership Levels

```text
Level 1: Local visual state → @State
Level 2: Parent-owned child state → @Binding
Level 3: Screen model state → @Observable / ViewModel / Store
Level 4: App-wide state → @Environment injected observable model/store
Level 5: Persistent state → DB/cache/repository, not raw @State
```

---

## 4. `@State` Rules

Use for:

```text
- local UI flag
- local selected segment
- local expansion
- local animation
- local draft if it is not shared/business-critical
```

Do not use for:

```text
- API response DTO
- DBModel
- app session
- shared feature state
- cache
- sync status
```

---

## 5. `@Binding` Rules

Use when:

```text
- parent owns state
- child edits state
- state is simple enough
```

Avoid:

```text
- passing binding through 5 levels
- binding to deep business model directly
- binding to persistence model directly
```

---

## 6. `@Observable` Rules

Use for:

```text
- observable screen model
- lightweight ViewModel
- app settings
- session store
- shared UI model
```

Rules:

```text
- keep mutation methods explicit
- avoid public free mutation for business-critical state
- avoid God object
- avoid hiding dependencies inside object
```

---

## 7. `@Bindable` Rules

Use `@Bindable` when a View needs bindings to properties of an `@Observable` model.

Be careful:

```text
@Bindable makes mutation easy.
Easy mutation can bypass action/business rules.
```

Use direct bindings for simple form fields. Use actions for business-sensitive mutations.

---

## 8. `@Environment` Rules

Use for ambient context:

```text
- colorScheme
- locale
- theme
- modelContext if architecture allows
- app settings
- session store
```

Avoid:

```text
- random Repository in Environment
- APIClient in Environment for Views
- many hidden dependencies
```

---

## 9. `@FocusState`

Use for focus only:

```text
- focused field
- keyboard flow
- form focus transitions
```

Do not use focus state to drive business logic directly.

---

## 10. Navigation State

Simple:

```swift
@State private var path: [Route] = []
```

Complex:

```text
use route model/coordinator/store
```

Navigation path should not contain DTO/DBModel.

---

## 11. Form State

For simple local form:

```swift
@State private var title = ""
@State private var description = ""
```

For complex form:

```text
@Observable FormModel
ViewModel
validation use case
field-level ViewState
```

---

## 12. App State

App state should not be scattered:

```text
SessionStore
SettingsStore
FeatureFlagStore
NetworkStatusStore
```

Inject through environment or DI boundary.

---

## 13. Persistent State

Avoid:

```swift
@State private var savedArticles: [ArticleDBModel]
```

Use:

```text
Repository/Query/ViewModel depending on architecture
```

SwiftData `@Query` can be acceptable for simple persistence-driven screens, but for production complex features it should be evaluated against data boundary requirements.

---

## 14. State Mutation Rule

Prefer explicit mutations:

```swift
model.send(.saveTapped)
```

over random direct mutations for business actions.

---

## 15. Rule

```text
Use the smallest state owner that is still correct.
```
