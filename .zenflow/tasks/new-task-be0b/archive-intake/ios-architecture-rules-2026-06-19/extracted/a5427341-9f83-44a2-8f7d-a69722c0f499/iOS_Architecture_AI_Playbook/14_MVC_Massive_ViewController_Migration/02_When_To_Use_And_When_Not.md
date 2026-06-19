# 02_When_To_Use_And_When_Not — MVC / Massive ViewController / Migration

## 1. Purpose

Этот документ объясняет, когда MVC приемлем, когда он опасен, и когда пора мигрировать.

---

## 2. MVC Is Acceptable When

MVC приемлем, если:

```text
- экран простой
- нет сложной business logic
- нет сложной async логики
- нет offline/cache
- navigation локальная
- ViewController короткий
- state минимальный
```

Примеры:

```text
- static legal/about screen
- simple settings screen
- local-only form
- tiny UIKit utility screen
```

---

## 3. MVC Becomes Risky When

MVC становится опасным, если:

```text
- появляется API
- появляется DB/cache
- появляется pagination
- появляется optimistic update
- появляется complex validation
- появляется multi-step navigation
- появляются multiple loading/error states
```

---

## 4. Migrate to MVVM When

```text
- нужно screen state
- нужно loading/error/empty/content
- ViewController содержит presentation logic
- SwiftUI/UIKit screen moderate complexity
```

---

## 5. Migrate to Clean Architecture When

```text
- DTO leaks into UI
- local JSON now, API later
- DB/cache/offline needed
- business rules need tests
- Repository boundary needed
```

---

## 6. Migrate to Coordinator When

```text
- ViewController creates many destinations
- navigation depends on business result
- deep links involved
- app/feature flow complicated
```

---

## 7. Migrate to VIP/MVP/VIPER When

For UIKit legacy:

```text
- ViewController massive
- team prefers scene roles
- Presenter/Interactor tests valuable
- enterprise flow
```

---

## 8. Migrate to TCA/UDF When

```text
- many actions
- many effects
- state machine complex
- cancellation/debounce important
- action flow should be testable
```

---

## 9. Do Not Over-migrate When

Не нужно мигрировать, если:

```text
- screen simple and stable
- no real pain
- refactor risk higher than benefit
- code will be deleted soon
```

---

## 10. Overengineering Signals

```text
- static screen converted to VIPER
- 5 layers added for one label
- tests assert only pass-through
- code became harder to understand
```

---

## 11. Underengineering Signals

```text
- ViewController > 1000 lines
- every bug fix touches same file
- adding tests impossible
- data/navigation/UI logic all mixed
- small change breaks unrelated behavior
```

---

## 12. Decision Rule

```text
Migrate MVC when the cost of changing/testing ViewController is higher than the cost of extracting boundaries.
```
