# 02_When_To_Use_And_When_Not — Clean Architecture / Layered Architecture

## 1. Purpose

Этот документ помогает понять, когда использовать Clean Architecture в iOS-проекте, а когда она будет лишней.

---

## 2. Use Clean Architecture When

Используй Clean Architecture, если есть:

```text
- API integration
- local JSON mock now, real API later
- database/cache/offline requirement
- business rules
- multiple data sources
- долгосрочная поддержка
- тестируемые use cases
- feature ownership by multiple developers
- need to replace infrastructure later
```

---

## 3. Strong Fit Scenarios

Clean Architecture особенно подходит для:

```text
- news/feed with pagination/cache
- auth/session
- profile/user data
- payments/subscriptions
- offline-first content
- sync-heavy features
- complex forms with validation
- enterprise/business logic
- domain-rich features
```

---

## 4. Use Clean Architecture Light When

Для большинства production SwiftUI features можно использовать Clean light:

```text
Presentation/
Domain/
Data/
```

Минимально:

```text
View
ViewModel
ViewState
UseCase
RepositoryProtocol
Repository
DTO
Mapper
```

Не обязательно сразу создавать:

```text
- отдельный Infrastructure folder
- отдельный protocol на каждый datasource
- отдельный module
- десятки use cases
```

---

## 5. Use Full Clean Architecture When

Full Clean уместна, если:

```text
- feature большая
- data flow сложный
- есть remote + local + cache
- business rules важны
- нужна сильная тестируемость
- feature будет жить долго
- есть несколько реализаций data source
- есть domain language/value objects
```

---

## 6. Do Not Use Full Clean When

Не нужно делать full Clean, если:

```text
- экран статический
- UI-only компонент
- нет data/business logic
- feature temporary/prototype
- простое меню настроек без API/DB
- простая кнопка/карточка
```

Там достаточно:

```text
SwiftUI Native State
MVVM light
```

---

## 7. Warning: Clean Architecture Is Not Boilerplate License

Нельзя создавать:

```text
- UseCase для каждого trivial getter
- Repository для одного local constant
- DTO/Domain/UI модели, если нет реального boundary
- Protocol для каждого класса
- Mapper для каждого one-line conversion
```

---

## 8. Team Fit

Для команды 2–3 iOS developers:

Рекомендуется:

```text
- Clean light as default
- full Clean only for complex features
- clear folder structure
- strict DTO/DB/UI separation
- minimal protocol usage
```

Не рекомендуется:

```text
- dogmatic Clean everywhere
- overmodularization from day one
- use-case explosion
- protocol explosion
```

---

## 9. Product Fit

Clean Architecture нужна, если продукт будет расти.

Особенно если сейчас:

```text
- API еще не готов
- используется local JSON
- позже будет БД/cache
- нужно не переписать UI при смене источника данных
```

---

## 10. Overengineering Signals

Clean стала слишком тяжелой, если:

```text
- простая фича занимает 20 файлов
- большинство use cases просто вызывают один repository method
- все interfaces имеют одну implementation и не являются boundary
- разработчики тратят больше времени на ceremony, чем на behavior
- нельзя быстро понять flow
```

---

## 11. Underengineering Signals

Clean недостаточно применена, если:

```text
- ViewModel вызывает APIClient
- DTO используется в UI
- DBModel используется в UI
- business rules в SwiftUI View
- cache policy в ViewModel
- нет мапперов
- невозможно протестировать business logic без UI
```

---

## 12. Decision Rule

Используй Clean Architecture, если:

```text
A feature has data/business complexity that should survive changes in UI, API, DB, cache, or infrastructure.
```

Не используй full Clean, если:

```text
The feature is simple enough that architecture ceremony is larger than the behavior.
```
