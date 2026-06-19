# 11_Review_Checklist — SwiftUI Native State Architecture

## 1. Purpose

Чеклист для ревью SwiftUI Native State кода.

---

## 2. State Ownership Checklist

```text
[ ] У каждого state есть один владелец
[ ] @State используется только для local state
[ ] @Binding используется для parent-owned state
[ ] @Observable не стал God Object
[ ] @Environment не используется как хаотичный service locator
[ ] App-wide state не хранится в random View
```

---

## 3. View Body Checklist

```text
[ ] body дешевый
[ ] нет API calls в body
[ ] нет DB queries в body
[ ] нет heavy sorting/filtering/mapping в body
[ ] нет side effects в body
```

---

## 4. Data Boundary Checklist

```text
[ ] View не хранит DTO в @State
[ ] View не хранит DBModel для complex feature
[ ] View не вызывает APIClient напрямую
[ ] View не реализует cache policy
[ ] Local JSON parsing не во View
```

---

## 5. Async Checklist

```text
[ ] .task вызывает model/ViewModel/Store
[ ] .task не делает raw API/DB logic
[ ] .task(id:) используется осознанно
[ ] cancellation учтена для search/long tasks
[ ] async ошибки не проглатываются
```

---

## 6. Binding Checklist

```text
[ ] Binding не мутирует business-critical state без action boundary
[ ] Binding не протянут через много уровней без причины
[ ] Binding не связан напрямую с DTO/DBModel
```

---

## 7. Navigation Checklist

```text
[ ] Route содержит ID/value object, не DTO/DBModel
[ ] Simple navigation local
[ ] Complex navigation escalated to Coordinator/Router
[ ] Deep link parsing не во View body
```

---

## 8. Loading/Error/Empty Checklist

```text
[ ] Simple booleans используются только для simple cases
[ ] Complex screen has explicit state
[ ] Refresh не стирает existing content
[ ] Pagination state отдельный
[ ] Per-item server loading не локальный случайный @State внутри card
```

---

## 9. Escalation Checklist

Нужно перейти к MVVM/TCA/Clean, если:

```text
[ ] много @State переменных
[ ] API/DB/cache рядом с View
[ ] бизнес-логика во View
[ ] нужна тестируемая action logic
[ ] per-card server actions
[ ] pagination/search/offline
```

---

## 10. Red Flags

```text
- APIClient.shared in View
- @State var dto: ArticleDTO
- @Environment var repository in every component
- body contains sorted/filter/map over large data
- 15 @State vars in one screen
- View decides business navigation
- Task.detached in View
```
