# 02_When_To_Use_And_When_Not — TCA

## 1. Purpose

Этот документ объясняет, когда использовать TCA, когда TCA будет overengineering, и когда лучше MVVM/SwiftUI Native State.

---

## 2. Use TCA When

Используй TCA, если feature имеет:

```text
- сложный state
- много actions
- async effects
- cancellation/debounce
- pagination
- optimistic updates
- per-item/per-card state
- navigation as state
- child feature composition
- strict testability requirement
```

---

## 3. Strong Fit Scenarios

```text
- complex feed
- checkout/payment flow
- onboarding with many steps
- search with debounce/cancellation
- offline-first feature
- form wizard
- editor with drafts
- feature with nested child states
```

---

## 4. Use TCA Lightly When

Для medium feature можно использовать:

```text
one feature reducer
explicit State/Action
few dependencies
small child reducers only if needed
```

Не нужно сразу строить большое tree из reducers.

---

## 5. Do Not Use TCA When

Не использовать TCA для:

```text
- simple static screen
- simple reusable component
- local visual state only
- screen with one value and one button
- prototype where architecture cost bigger than behavior
```

Для этого лучше:

```text
SwiftUI Native State
MVVM light
```

---

## 6. Use MVVM Instead When

MVVM лучше, если:

```text
- state moderate
- actions few
- effect logic simple
- team unfamiliar with TCA
- boilerplate not justified
```

---

## 7. Use Clean + MVVM Instead When

Если проблема только в API/DB/cache separation, а state простой:

```text
Clean Architecture + MVVM
```

может быть проще, чем TCA.

---

## 8. Overengineering Signals

TCA overengineering, если:

```text
- simple row has full reducer
- every tiny button has Action/State/Reducer
- feature behavior is trivial
- tests mostly assert pass-through actions
- boilerplate hides intent
```

---

## 9. Underengineering Signals

TCA нужна, если сейчас:

```text
- ViewModel has many unrelated booleans
- async tasks race
- search has no cancellation
- pagination duplicates requests
- optimistic update logic scattered
- per-card loading inconsistent
- impossible to test user action flow
```

---

## 10. Decision Rule

```text
Use TCA when the feature behavior is naturally described as Action → State → Effect and that explicitness improves maintainability and testing.
```
