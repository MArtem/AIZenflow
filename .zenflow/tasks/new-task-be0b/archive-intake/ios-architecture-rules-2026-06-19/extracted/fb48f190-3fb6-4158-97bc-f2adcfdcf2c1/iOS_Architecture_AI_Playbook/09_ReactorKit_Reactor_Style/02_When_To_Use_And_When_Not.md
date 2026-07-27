# 02_When_To_Use_And_When_Not — ReactorKit / Reactor-style Architecture

## 1. Purpose

Этот документ объясняет, когда использовать ReactorKit/Reactor-style, а когда лучше MVVM, TCA, SwiftUI Native State или UDF.

---

## 2. Use Reactor-style When

Используй, если:

```text
- проект уже RxSwift/RxCocoa based
- UI heavily reactive
- много bindings
- actions/events stream-based
- нужно разделить Action/Mutation/State
- нужно тестировать state transitions
- feature имеет async streams
```

---

## 3. Strong Fit Scenarios

```text
- RxSwift legacy project
- search with debounce
- reactive forms
- feed with pull-to-refresh and pagination
- screens with many observable inputs
- UIKit + RxCocoa screens
```

---

## 4. Use MVVM Instead When

MVVM проще, если:

```text
- проект SwiftUI + async/await
- RxSwift не используется
- state moderate
- reactive stream complexity отсутствует
```

---

## 5. Use TCA Instead When

TCA лучше, если:

```text
- SwiftUI-first project
- нужна сильная composition/testing/dependencies story
- команда готова к TCA
- нужно меньше Rx-specific complexity
```

---

## 6. Use SwiftUI Native State When

Если state purely local/visual:

```text
@State/@Binding
```

лучше, чем Reactor для каждого маленького компонента.

---

## 7. Do Not Use Reactor-style When

Не использовать, если:

```text
- команда не знает Rx
- проект не использует Rx
- feature trivial
- simple component
- Rx introduced only for architecture fashion
```

---

## 8. Overengineering Signals

```text
- Reactor for every tiny cell
- complex Rx chain for simple button
- Action/Mutation/State larger than behavior
- no real reactive need
```

---

## 9. Underengineering Signals

Reactor-style может быть нужен, если:

```text
- ViewController has many Rx bindings with logic
- subscriptions scattered
- loading/error state inconsistent
- API chains in View
- hard to test interaction streams
```

---

## 10. Decision Rule

```text
Use Reactor-style when Rx-based unidirectional event/state streams make the feature clearer and more testable.
```
