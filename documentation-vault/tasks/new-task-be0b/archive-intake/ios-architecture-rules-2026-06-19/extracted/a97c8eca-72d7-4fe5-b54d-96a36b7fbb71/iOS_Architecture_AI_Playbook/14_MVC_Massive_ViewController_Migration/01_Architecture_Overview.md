# 01_Architecture_Overview — MVC / Massive ViewController / Migration

## 1. Purpose

Этот раздел не продвигает Massive ViewController как хорошую архитектуру.

Цель — дать правила для:

```text
- понимания MVC в iOS
- безопасной поддержки legacy UIKit/MVC экранов
- распознавания Massive ViewController
- постепенной миграции в MVVM / Clean / VIP / Coordinator
- отказа от переписывания всего приложения одним big bang
```

MVC в iOS часто начинается нормально, но со временем ViewController становится местом для всего:

```text
UI
business logic
API
DB
cache
navigation
formatting
validation
analytics
state
```

Это и есть Massive ViewController.

---

## 2. Classic MVC Idea

Идея MVC:

```text
Model
View
Controller
```

В iOS UIKit часто:

```text
UIViewController
 → controls View
 → talks to Model/Services
 → updates View
```

Проблема: `UIViewController` легко превращается в God Object.

---

## 3. Healthy MVC

MVC может быть приемлемым, если:

```text
- экран простой
- business logic минимальная
- нет сложного API/DB/cache
- ViewController маленький
- зависимости понятные
- navigation простая
- тесты не критичны или logic вынесена
```

---

## 4. Massive ViewController Symptoms

Признаки:

```text
- 500–1000+ строк
- API calls внутри ViewController
- JSON parsing внутри ViewController
- CoreData/SwiftData queries внутри ViewController
- business validation внутри ViewController
- date/currency formatting везде
- navigation mixed with business logic
- analytics scattered
- много boolean state flags
- невозможно протестировать без UI
```

---

## 5. Why Massive VC Happens

Обычно из-за:

```text
- "быстро добавим здесь"
- отсутствие boundaries
- storyboard/segue logic
- UIKit lifecycle complexity
- нет ViewModel/Interactor/UseCase
- нет Repository
- нет Coordinator/Router
- features растут постепенно
```

---

## 6. Migration Philosophy

Главное правило:

```text
Do not rewrite everything. Extract one responsibility at a time.
```

Миграция должна быть:

```text
- incremental
- behavior-preserving
- test-backed
- low-risk
- focused on boundaries
```

---

## 7. Extraction Targets

Из ViewController постепенно выносятся:

```text
API logic → Service/Repository/DataSource
DB/cache → Repository/Data layer
business rules → UseCase/Interactor
formatting → Presenter/ViewModel/Formatter
navigation → Coordinator/Router
state → ViewModel/Store/ScreenState
analytics → Analytics adapter/event mapper
validation → UseCase/Validator
```

---

## 8. Migration Destinations

В зависимости от feature:

```text
Simple screen → MVVM light
Complex data screen → MVVM + Clean
Complex UIKit scene → VIP / MVP / VIPER
State-heavy feature → TCA/UDF
Navigation-heavy flow → Coordinator
Large app structure → Modular Architecture
```

---

## 9. Safe Migration Flow

```text
1. Add characterization tests if possible
2. Identify responsibilities
3. Extract pure helpers/mappers
4. Extract API/DB to Repository/DataSource
5. Extract business logic to UseCase/Interactor
6. Extract presentation state to ViewModel/Presenter
7. Extract navigation to Router/Coordinator
8. Reduce ViewController to UI glue
```

---

## 10. Healthy End State

After migration, ViewController should mostly do:

```text
- setup UI
- bind/render state
- forward user events
- call ViewModel/Presenter/Interactor
- display route-independent UI
```

It should not:

```text
- call API directly
- decode DTO
- query DB directly
- implement cache policy
- contain business rules
- construct complex destination graph
```

---

## 11. Summary

MVC is not evil. Massive ViewController is the problem.

Rule:

```text
Keep MVC only for simple screens. For growing screens, extract responsibilities before the ViewController becomes the application.
```
