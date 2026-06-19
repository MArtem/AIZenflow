# 08_Global_Architecture_Decision_Matrix

## 1. Purpose

Этот документ помогает выбрать архитектуру под конкретную задачу.

---

## 2. Decision Matrix

| Ситуация | Рекомендуемый подход |
|---|---|
| Простой статичный экран | SwiftUI Native State |
| Простой экран с загрузкой данных | MVVM light |
| Экран с API + cache + DB | Clean Architecture |
| Сложный feed с лайками, search, pagination | TCA / UDF / MVVM + reducer |
| Экран с per-card loading | TCA / UDF / screen-level state dictionary |
| Legacy UIKit экран | MVC migration / MVP / MVVM |
| Сложная форма | MVVM / VIP / TCA |
| Onboarding flow | Coordinator + MVVM/TCA |
| Deep links | Coordinator / Router |
| Большой app structure | Modular / Feature-Sliced |
| Сильная domain isolation | Hexagonal / Clean |
| Enterprise UIKit scene | VIP / Clean Swift |
| Очень большой app с feature tree | RIBs |
| RxSwift-heavy проект | ReactorKit |
| Нужно учить ИИ строгим boundaries | Clean / VIP / TCA |

---

## 3. Architecture Selection by Feature Type

### Simple UI Component

```text
Use:
SwiftUI Native State

Avoid:
VIPER, RIBs, full Clean stack
```

---

### Data-driven Screen

```text
Use:
MVVM + Repository
Clean light

Avoid:
Direct API in View
DTO in UI
```

---

### Complex Feed

```text
Use:
TCA
UDF
MVVM + reducer-like state
Clean + feature store

Required:
per-card state strategy
pagination strategy
refresh strategy
optimistic update strategy
```

---

### Offline-first Feature

```text
Use:
Clean Architecture
Hexagonal
Repository + LocalDataSource + RemoteDataSource

Required:
cache policy
stale data state
sync policy
error mapping
```

---

### Navigation-heavy Flow

```text
Use:
Coordinator / Flow Architecture

Can combine with:
MVVM
TCA
VIP
Clean
```

---

### Legacy UIKit Migration

```text
Use:
MVC/Massive VC Migration
MVP
MVVM
VIP

Avoid:
big bang rewrite
```

---

### Large Multi-team Product

```text
Use:
Modular / Feature-Sliced
Clean
Hexagonal
RIBs selectively

Avoid:
single giant app target
uncontrolled Shared folder
cyclic dependencies
```

---

## 4. Overengineering Signals

Архитектура слишком тяжелая, если:

```text
- простая кнопка требует 5 файлов
- экран без бизнес-логики имеет Interactor, Presenter, Router, Worker
- каждый тип имеет protocol без тестовой/модульной причины
- разработчики боятся менять код
- фича занимает больше времени из-за ceremony, а не из-за complexity
```

---

## 5. Underengineering Signals

Архитектура слишком слабая, если:

```text
- ViewModel > 800 строк
- View напрямую вызывает API
- DTO используется в SwiftUI
- DBModel используется в UI
- retry/cache/offline размазаны по экрану
- navigation живет в random closures
- невозможно протестировать бизнес-логику без UI
- любое изменение ломает несколько слоев
```
