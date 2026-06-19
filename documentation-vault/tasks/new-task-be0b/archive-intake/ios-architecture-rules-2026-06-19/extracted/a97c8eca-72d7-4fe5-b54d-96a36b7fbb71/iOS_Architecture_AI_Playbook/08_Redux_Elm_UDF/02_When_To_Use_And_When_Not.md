# 02_When_To_Use_And_When_Not — Redux / Elm / UDF

## 1. Purpose

Этот документ объясняет, когда использовать Redux/Elm/UDF, а когда лучше MVVM, SwiftUI Native State или TCA.

---

## 2. Use UDF When

Используй UDF, если feature имеет:

```text
- complex state transitions
- many user actions
- async effects
- need for predictable state mutation
- need for action logging
- need for replay/debugging
- pagination/search/filtering
- optimistic updates
- multiple loading/error states
```

---

## 3. Strong Fit Scenarios

```text
- feed with likes/comments/pagination
- complex search screen
- form wizard
- checkout
- onboarding
- editor/draft screen
- offline sync state screen
```

---

## 4. Use Lightweight UDF When

Если TCA кажется слишком тяжелой, можно использовать custom UDF:

```text
State
Action
Reducer
Store
Effect handler
```

Но нужно явно задать rules.

---

## 5. Use TCA Instead When

TCA лучше, если нужны:

```text
- battle-tested dependency/effect model
- TestStore
- child feature composition
- state-driven navigation tooling
- strict conventions
- team ready to use TCA
```

---

## 6. Use MVVM Instead When

MVVM лучше, если:

```text
- state moderate
- few actions
- async simple
- team wants less ceremony
- no need for action log/replay
```

---

## 7. Use SwiftUI Native State Instead When

SwiftUI Native State лучше, если:

```text
- state local and visual
- simple component
- no domain/data complexity
- no testable action flow needed
```

---

## 8. Do Not Use UDF When

Не использовать UDF для:

```text
- static screen
- tiny reusable view
- simple local toggle
- feature with no meaningful state transitions
```

---

## 9. Overengineering Signals

```text
- every local bool becomes global action
- reducer for a divider/icon/title
- AppState too complex for feature
- boilerplate bigger than behavior
```

---

## 10. Underengineering Signals

UDF нужна, если:

```text
- ViewModel has too many methods
- async result races
- state mutation happens everywhere
- no one knows what changed state
- multiple loaders conflict
- optimistic update rollback scattered
```

---

## 11. Decision Rule

```text
Use UDF when state predictability, action traceability, and reducer tests justify the ceremony.
```
