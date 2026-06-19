# 02_When_To_Use_And_When_Not — MVP / Passive View

## 1. Purpose

Этот документ объясняет, когда использовать MVP/Passive View, а когда лучше MVVM, VIPER, VIP, TCA или SwiftUI Native State.

---

## 2. Use MVP When

Используй MVP, если:

```text
- UIKit screen has presentation logic
- ViewController should become passive
- Presenter tests are important
- screen is not complex enough for VIPER/VIP
- imperative display methods are convenient
- legacy MVC needs incremental refactor
```

---

## 3. Strong Fit Scenarios

```text
- login form
- settings screen with validation
- detail screen with formatting
- UIKit form
- simple checkout step
- legacy ViewController refactor
```

---

## 4. Use Passive View When

Passive View хорош, если:

```text
- View should be very dumb
- Presenter should prepare all display state
- you want easy mocks/spies for View
- team wants explicit display methods
```

---

## 5. Use MVVM Instead When

MVVM лучше, если:

```text
- SwiftUI-first screen
- binding/observable state is natural
- View observes state instead of receiving display commands
- screen state is mostly declarative
```

---

## 6. Use VIPER/VIP Instead When

VIPER/VIP лучше, если:

```text
- scene has complex business flow
- separate Interactor role is important
- Router/Worker/Entity boundaries are needed
- enterprise scene ceremony is justified
```

---

## 7. Use TCA/UDF Instead When

TCA/UDF лучше, если:

```text
- state machine complex
- many actions/effects
- action logging/testing/replay desired
- child feature composition important
```

---

## 8. Do Not Use MVP When

Не использовать MVP для:

```text
- tiny component
- static screen
- local visual state only
- SwiftUI view where @State/@Binding is enough
- feature needing reducer-style state machine
```

---

## 9. Overengineering Signals

```text
- Presenter for every small row
- View protocol with many trivial setters
- Presenter only forwards calls
- no logic worth testing
```

---

## 10. Underengineering Signals

MVP может быть нужен, если:

```text
- ViewController validates business rules
- ViewController formats domain data heavily
- ViewController calls API
- UI events and decisions are mixed
- no testable presentation layer
```

---

## 11. Decision Rule

```text
Use MVP when the View should be passive and the Presenter can meaningfully own presentation decisions.
```
