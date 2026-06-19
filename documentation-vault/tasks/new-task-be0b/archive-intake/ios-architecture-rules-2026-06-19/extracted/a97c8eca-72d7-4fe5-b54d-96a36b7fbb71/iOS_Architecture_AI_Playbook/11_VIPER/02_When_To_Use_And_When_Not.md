# 02_When_To_Use_And_When_Not — VIPER

## 1. Purpose

Этот документ объясняет, когда использовать VIPER, а когда он будет лишним.

---

## 2. Use VIPER When

Используй VIPER, если:

```text
- UIKit screen is complex
- Massive ViewController needs refactoring
- navigation is non-trivial
- Presenter/Interactor tests are important
- team already uses VIPER
- enterprise-style feature
- screen has business logic + formatting + navigation
```

---

## 3. Strong Fit Scenarios

```text
- payment/checkout scene
- complex auth scene
- enterprise form
- order details scene
- complex legacy UIKit module
- screen with many user interactions
```

---

## 4. Use VIPER Light When

Можно использовать light VIPER:

```text
View
Presenter
Interactor
Router
Builder
```

без чрезмерного количества protocols/models, если границы понятны.

---

## 5. Use MVVM Instead When

MVVM лучше, если:

```text
- SwiftUI-first app
- screen moderate complexity
- team wants less ceremony
- state and presentation logic simple
```

---

## 6. Use TCA/UDF Instead When

TCA/UDF лучше, если:

```text
- feature has complex state machine
- many actions/effects
- reducer testing is desired
- SwiftUI composition is important
```

---

## 7. Use VIP/Clean Swift Instead When

VIP/Clean Swift может быть лучше, если:

```text
- scene flow naturally Request/Response/ViewModel
- team prefers Interactor → Presenter flow
- Presenter should only format output
```

---

## 8. Do Not Use VIPER When

Не использовать VIPER для:

```text
- static screen
- tiny SwiftUI component
- simple settings row
- local visual state
- feature with no real business/navigation complexity
```

---

## 9. Overengineering Signals

```text
- 7 files for a static text screen
- protocol for every class without testing/module reason
- Presenter only forwards calls
- Interactor only forwards calls
- Router exists but no navigation
```

---

## 10. Underengineering Signals

VIPER может быть нужен, если:

```text
- ViewController > 1000 lines
- ViewController calls API and navigates
- ViewController validates business rules
- navigation/data/presentation mixed
- Presenter-like logic exists informally
```

---

## 11. Decision Rule

```text
Use VIPER when strict scene role separation gives more value than boilerplate cost.
```
