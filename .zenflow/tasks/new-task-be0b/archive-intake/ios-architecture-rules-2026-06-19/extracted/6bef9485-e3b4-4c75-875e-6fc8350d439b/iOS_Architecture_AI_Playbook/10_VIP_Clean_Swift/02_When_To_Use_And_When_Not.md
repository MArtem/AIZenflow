# 02_When_To_Use_And_When_Not — VIP / Clean Swift

## 1. Purpose

Этот документ объясняет, когда использовать VIP/Clean Swift, а когда лучше MVVM, TCA, SwiftUI Native State или Clean Architecture без VIP.

---

## 2. Use VIP When

Используй VIP, если:

```text
- UIKit/ViewController screen complex
- Massive ViewController needs refactoring
- enterprise-style scene
- strong separation View/Business/Presentation needed
- team already uses Clean Swift
- screen has forms, validation, API, navigation
- presenter formatting should be isolated
```

---

## 3. Strong Fit Scenarios

```text
- complex UIKit form
- checkout/payment scene
- auth/login scene
- order details scene
- enterprise workflow
- legacy MVC migration
```

---

## 4. Use VIP Light When

Можно использовать light VIP:

```text
View
Interactor
Presenter
Router
```

без лишних Workers, если external operations already handled by UseCase/Repository.

---

## 5. Use MVVM Instead When

MVVM проще, если:

```text
- SwiftUI-first project
- screen moderate complexity
- team wants less ceremony
- no separate presenter needed
- ViewState mapping is simple
```

---

## 6. Use TCA/UDF Instead When

TCA/UDF лучше, если:

```text
- complex state graph
- many actions/effects
- child feature composition
- strict reducer tests desired
```

---

## 7. Use Clean Architecture Instead When

Если проблема в data/domain boundaries, а UI scene simple:

```text
Clean Architecture + MVVM
```

может быть лучше, чем full VIP.

---

## 8. Do Not Use VIP When

Не использовать VIP для:

```text
- tiny SwiftUI component
- static screen
- simple settings row
- local visual state
- feature with no business logic
```

---

## 9. Overengineering Signals

```text
- every trivial screen has Interactor/Presenter/Router/Worker/Models
- protocols duplicate every class with no test/module value
- Request/Response/ViewModel are empty pass-throughs
- ceremony hides behavior
```

---

## 10. Underengineering Signals

VIP может быть нужен, если:

```text
- ViewController > 1000 lines
- ViewController calls API
- ViewController formats all UI
- ViewController validates business rules
- navigation/data/presentation all mixed
```

---

## 11. Decision Rule

```text
Use VIP when the screen/scene has enough business, presentation, and navigation complexity to justify explicit scene roles.
```
