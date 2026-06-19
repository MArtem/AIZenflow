# 01_Project_Context

## 1. Purpose

Этот документ описывает базовый контекст проекта, который должен учитывать любой ИИ-агент, разработчик или ревьюер перед генерацией кода.

ИИ не должен генерировать код “в вакууме”. Каждый архитектурный выбор должен учитывать:

```text
- размер проекта
- тип продукта
- команду
- наличие API
- offline/cache/database требования
- SwiftUI/UIKit стек
- долгосрочную поддержку
- тестируемость
- скорость разработки
- риск overengineering
```

---

## 2. Project Type

Базовый тип проекта:

```text
Large production iOS application
```

Проект не является:

```text
- учебным todo app
- одноэкранным prototype
- demo app
- pet project без поддержки
- temporary throwaway app
```

Проект должен проектироваться так, чтобы выдерживать:

```text
- рост количества экранов
- рост бизнес-логики
- появление реального backend API
- offline/cache/database слой
- несколько разработчиков
- постепенную миграцию архитектуры
- рефакторинг без переписывания всего приложения
```

---

## 3. Platform

Основная платформа:

```text
iOS
```

Основной UI framework:

```text
SwiftUI
```

UIKit может использоваться:

```text
- для legacy экранов
- для интеграции UIKit-only компонентов
- для сложной кастомной навигации
- для системных контроллеров
- для постепенной миграции старого кода
```

Новый код по умолчанию должен проектироваться как:

```text
SwiftUI-first
```

---

## 4. Team Context

Предполагаемый размер команды:

```text
2–3 iOS developers
```

Это важно.

Для такой команды нельзя по умолчанию выбирать максимально тяжелую архитектуру. Архитектура должна давать порядок, но не превращать каждую фичу в 30 файлов без необходимости.

Правило:

```text
Choose the simplest architecture that preserves long-term maintainability.
```

Нельзя:

```text
- внедрять VIPER/RIBs/TCA everywhere без причины
- создавать протокол на каждый класс
- создавать UseCase на каждое простое действие
- выносить каждый helper в отдельный слой
- строить SPM-модули до появления стабильных границ
```

Можно:

```text
- начинать с soft modularity через папки
- усложнять архитектуру только в hot spots
- использовать разные архитектурные стили для разных типов фич
- держать общий data/domain слой стабильным
```

---

## 5. Backend/API Context

На ранней стадии API может быть не готов.

Поэтому проект должен поддерживать режим:

```text
Local JSON mock first → real API later
```

ИИ обязан проектировать data flow так, чтобы замена local JSON на real API не требовала переписывания UI.

Правильный подход:

```text
View
 → ViewModel / Store / Presenter / Interactor
 → UseCase
 → Repository Protocol
 → Repository Implementation
 → DataSource
 → LocalJSONDataSource or RemoteAPIDataSource
```

Неправильный подход:

```text
View directly reads local JSON
ViewModel directly parses JSON file
UI model is decoded directly from API response
DTO is used directly in SwiftUI View
```

---

## 6. Offline / Cache / Database Requirement

Проект должен быть готов к:

```text
- local cache
- persistent database
- offline mode
- stale data display
- background refresh
- retry
- sync
- optimistic updates
```

Даже если БД еще не внедрена, архитектура не должна блокировать ее добавление позже.

Правило:

```text
Do not couple UI to the current source of data.
```

UI не должен знать:

```text
- пришли данные из API
- пришли данные из local JSON
- пришли данные из database
- пришли данные из memory cache
- данные свежие или stale, если это не часть UI state
```

UI должен получать:

```text
- ViewState
- UI model
- loading state
- error state
- empty state
- offline/stale marker when needed
```

---

## 7. Core Architectural Principle

Главный принцип проекта:

```text
Separate UI, state, business logic, data access, persistence, and navigation.
```

Нельзя смешивать:

```text
- View и API
- View и Repository
- DTO и UI model
- DBModel и ViewState
- navigation и business logic
- cache policy и SwiftUI rendering
- formatting и persistence
```

---

## 8. Model Types

В проекте должны различаться следующие типы моделей:

```text
DTO
Domain Model / Entity
DB Model / Persistence Model
UI Model / ViewState
Input Model / Command
Route Model
Error Model
```

Минимальное правило:

```text
Never use one model for API, DB, Domain, and UI unless the feature is explicitly trivial and temporary.
```

Для production-кода предпочтительно:

```text
API DTO → Domain Model → UI Model
API DTO → DB Model → Domain Model → UI Model
```

---

## 9. State Complexity Levels

ИИ должен определять сложность состояния до выбора реализации.

### Level 1 — Local UI State

```text
- isExpanded
- selectedTab
- local text field focus
- local animation flag
```

Можно держать в:

```text
@State
@Binding
```

### Level 2 — Screen State

```text
- loading
- loaded data
- error
- empty
- search query
- filter
- sort
```

Можно держать в:

```text
ViewModel
Store
Presenter
Interactor output
Observable screen model
```

### Level 3 — Feature State

```text
- feed state
- pagination
- selected filters
- per-card loading
- optimistic likes
- cached content
- refresh state
```

Нужен более строгий state owner:

```text
ViewModel with clear rules
Reducer Store
TCA Store
Reactor
Interactor + Presenter
```

### Level 4 — App-wide State

```text
- auth session
- user profile
- app settings
- feature flags
- selected locale
- global network status
```

Нельзя разбрасывать по экранам.

Нужно:

```text
AppState
SessionStore
SettingsStore
Dependency container
Environment dependency
```

---

## 10. Architecture Selection Rule

ИИ не должен автоматически выбирать одну архитектуру для всего.

Правильная стратегия:

```text
Use architectural composition.
```

Пример:

```text
App structure:
Modular / Feature-Sliced

Data boundaries:
Clean Architecture + Hexagonal

SwiftUI state:
Native SwiftUI State for local state

Complex screens:
MVVM, TCA-like Store, or TCA

Navigation:
Coordinator / Router

Legacy migration:
MVC → MVVM/Clean/VIP step-by-step
```
