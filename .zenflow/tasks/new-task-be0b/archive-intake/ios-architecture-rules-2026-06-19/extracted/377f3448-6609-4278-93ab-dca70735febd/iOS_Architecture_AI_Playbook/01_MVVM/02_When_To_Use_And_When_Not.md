# 02_When_To_Use_And_When_Not — MVVM

## 1. Purpose

Этот документ объясняет, когда MVVM подходит для iOS-продукта, когда не подходит, и когда plain MVVM нужно усилить Clean Architecture, Coordinator, UDF/TCA или модульной структурой.

---

## 2. Use MVVM When

MVVM хорошо подходит, если экран:

```text
- data-driven
- имеет умеренную бизнес-логику
- имеет loading/error/empty/content state
- загружает данные из API/DB/cache
- содержит форму или список
- требует тестируемой presentation logic
- должен быть понятен небольшой команде
```

Примеры:

```text
- Profile screen
- Settings screen
- Article details
- Simple feed
- Search screen medium complexity
- Form screen
- Favorites list
```

---

## 3. Use MVVM Light When

MVVM Light подходит, если:

```text
- экран простой
- state небольшой
- нет сложных side effects
- нет pagination
- нет optimistic updates
- navigation простая
- бизнес-логики мало
```

Пример:

```text
View
ViewModel
ViewState
Repository or UseCase
```

---

## 4. Use MVVM + Clean When

Нужно усиливать MVVM Clean Architecture, если есть:

```text
- API + cache + DB
- offline-first
- domain business rules
- несколько источников данных
- local JSON mock now, real API later
- сложный mapping DTO → Domain → UI
- долгосрочная поддержка
```

Пример:

```text
View
ViewModel
UseCase
Repository Protocol
Repository Implementation
RemoteDataSource
LocalDataSource
DTO
DBModel
Domain Model
ViewState
```

---

## 5. Use MVVM + Coordinator When

Добавляй Coordinator/Router, если есть:

```text
- onboarding flow
- auth flow
- deep links
- tab navigation
- modal flow
- conditional navigation
- navigation after async operation
```

ViewModel не должна сама создавать следующий экран.

Правильно:

```text
ViewModel emits route intent
Coordinator performs navigation
```

---

## 6. Use MVVM + Reducer-like State When

Plain MVVM начинает слабеть, если есть:

```text
- много user actions
- complex screen state
- per-card state
- optimistic updates
- pagination
- search with cancellation
- multiple loading states
- child feature states
```

Тогда внутри ViewModel можно использовать reducer-like подход:

```text
Action
State
Mutation
Effect
```

или перейти на TCA/UDF.

---

## 7. Do Not Use Plain MVVM When

Plain MVVM плохо подходит, если:

```text
- экран имеет очень сложный state graph
- действия должны строго тестироваться как Action → State → Effect
- много child feature composition
- нужны reducer tests
- нужна time-travel/debug log архитектура
- нужно строгое unidirectional flow
```

В таких случаях лучше:

```text
TCA
Redux/UDF
Reactor-style
```

---

## 8. Do Not Use MVVM as App Architecture

MVVM — это в первую очередь presentation pattern.

Нельзя говорить:

```text
Our entire app architecture is MVVM
```

и считать, что этим решены:

```text
- modularization
- data boundaries
- domain logic
- persistence
- navigation
- sync
- offline
- app state
```

Правильнее:

```text
App Architecture: Modular / Feature-Sliced
Feature Presentation: MVVM
Data/Domain: Clean / Hexagonal
Navigation: Coordinator
```

---

## 9. Team Size Fit

Для команды 2–3 iOS developers MVVM хорош, потому что:

```text
- легко объяснить
- мало ceremony
- быстро писать фичи
- хорошо работает со SwiftUI
- можно усложнять постепенно
```

Но нужно защищаться от:

```text
- Massive ViewModel
- inconsistent folder structure
- mixed DTO/UI models
- navigation chaos
- duplicated loading/error handling
```

---

## 10. Product Complexity Fit

MVVM подходит для production-продукта, если он не используется один.

Рекомендуемый стек:

```text
MVVM + ViewState
MVVM + UseCases
MVVM + Repository
MVVM + Coordinator
MVVM + Feature folders/modules
```

---

## 11. Overengineering Signals

MVVM становится overengineering, если:

```text
- для простого компонента создается отдельная ViewModel
- ViewModel только прокидывает одно значение
- создается protocol для каждой ViewModel без тестовой причины
- каждый tap превращается в отдельный UseCase
- простая View имеет 10 файлов
```

---

## 12. Underengineering Signals

MVVM становится underengineering, если:

```text
- ViewModel > 800 строк
- ViewModel делает API + DB + formatting + navigation
- ViewModel содержит DTO
- ViewModel содержит DBModel
- View напрямую вызывает service
- loading/error/empty states размазаны по View
- невозможно протестировать логику без UI
```

---

## 13. Decision Rule

Используй MVVM, если:

```text
The screen has enough state or logic to justify a ViewModel,
but not enough complexity to require a full reducer architecture.
```

Используй TCA/UDF, если:

```text
The screen behavior is better described as Action → State → Effect.
```

Используй SwiftUI Native State, если:

```text
The state is purely local and visual.
```
