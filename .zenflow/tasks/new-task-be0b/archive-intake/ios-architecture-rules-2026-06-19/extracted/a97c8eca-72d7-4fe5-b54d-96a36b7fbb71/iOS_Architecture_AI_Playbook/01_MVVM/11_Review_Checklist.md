# 11_Review_Checklist — MVVM

## 1. Purpose

Этот чеклист используется для ревью MVVM-кода, созданного человеком или ИИ.

---

## 2. Architecture Boundary Checklist

Проверить:

```text
[ ] View не знает Repository
[ ] View не знает APIClient
[ ] View не знает DTO
[ ] View не знает DBModel
[ ] ViewModel не знает API endpoint
[ ] ViewModel не декодирует raw JSON
[ ] ViewModel не содержит DB query logic
[ ] Repository не возвращает ViewState
[ ] UseCase не возвращает DTO
[ ] Domain не импортирует SwiftUI
```

---

## 3. View Checklist

```text
[ ] View отображает state
[ ] View отправляет user events
[ ] View не содержит business logic
[ ] View body дешевый
[ ] Нет тяжелого mapping/sorting/filtering в body
[ ] .task вызывает ViewModel/Store, а не Repository
[ ] Reusable components получают ViewState/callbacks
```

---

## 4. ViewModel Checklist

```text
[ ] Dependencies через init
[ ] Dependencies private
[ ] State private(set)
[ ] Есть explicit ViewState
[ ] Есть loading/error/empty states
[ ] Async операции обрабатывают ошибки
[ ] Cancellation учтена для search/long tasks
[ ] Нет direct API/DB implementation
[ ] Нет создания destination views
[ ] Нет God Object behavior
```

---

## 5. State Checklist

```text
[ ] Local UI state остался во View
[ ] Screen state во ViewModel
[ ] App-wide state не спрятан во ViewModel
[ ] Per-card state моделируется явно
[ ] Loading не представлен одним isLoading для всего сложного экрана
[ ] Error state типизирован или представлен ErrorViewState
[ ] Empty state отличается от error/loading
```

---

## 6. Data Flow Checklist

```text
[ ] DTO → Domain mapping не во View
[ ] Domain → ViewState mapping не в Repository
[ ] Local JSON mock не привязан к UI
[ ] Repository скрывает источник данных
[ ] Cache policy не размазана по ViewModel
[ ] Offline/stale metadata правильно маппится в UI
```

---

## 7. Navigation Checklist

```text
[ ] Route model exists for non-trivial navigation
[ ] ViewModel emits route intent
[ ] Coordinator/Router performs navigation
[ ] ViewModel не создает destination View
[ ] routeHandled очищает одноразовый route
[ ] Deep link parsing не внутри screen ViewModel
```

---

## 8. Async Checklist

```text
[ ] UI state updates on MainActor
[ ] Heavy work outside MainActor
[ ] No uncontrolled Task.detached
[ ] Search cancels previous request
[ ] Pagination prevents duplicate loads
[ ] Errors are not swallowed with try?
```

---

## 9. Testing Checklist

```text
[ ] ViewModel tests cover success
[ ] ViewModel tests cover failure
[ ] ViewModel tests cover empty
[ ] ViewModel tests cover retry
[ ] Optimistic update tested if exists
[ ] Rollback tested if exists
[ ] Route intent tested
[ ] Mappers tested
[ ] Repository cache policy tested
```

---

## 10. Overengineering Checklist

```text
[ ] Нет protocol без причины
[ ] Нет UseCase на trivial UI-only action
[ ] Нет отдельной ViewModel для маленького dumb component
[ ] Нет 30 файлов для простой фичи
[ ] Нет BaseViewModel hierarchy без нужды
```

---

## 11. Underengineering Checklist

```text
[ ] ViewModel не больше разумного размера
[ ] Business logic не во View
[ ] Data access не во ViewModel
[ ] Navigation не через random closures everywhere
[ ] Error/loading не ad-hoc booleans
```

---

## 12. Red Flags

Код требует пересмотра, если есть:

```text
- ViewModel > 800 lines
- APIClient.shared inside ViewModel
- DTO rendered in SwiftUI
- SwiftData/CoreData model rendered in UI
- ViewModel creates other screens
- one isLoading controls everything
- try? await for important request
- no tests for non-trivial logic
```
