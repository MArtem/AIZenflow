# 02_When_To_Use_And_When_Not — Coordinator / Flow Architecture

## 1. Purpose

Этот документ объясняет, когда использовать Coordinator / Flow Architecture, а когда достаточно простого SwiftUI navigation.

---

## 2. Use Coordinator When

Coordinator нужен, если есть:

```text
- несколько экранов в flow
- onboarding
- auth flow
- main tabs
- deep links
- modal/push combinations
- conditional navigation
- navigation after async preconditions
- reusable screens
- feature modules
- UIKit navigation
```

---

## 3. Strong Fit Scenarios

```text
AuthCoordinator
OnboardingCoordinator
MainTabCoordinator
NewsCoordinator
ProfileCoordinator
CheckoutCoordinator
SettingsCoordinator
DeepLinkCoordinator
```

---

## 4. Use Simple SwiftUI Navigation When

Coordinator может быть лишним, если:

```text
- один простой экран
- один простой NavigationLink
- нет conditional navigation
- нет deep links
- нет modal flow
- destination простая и локальная
```

Пример:

```swift
NavigationLink("Details", value: Route.details(id))
```

---

## 5. Use Route-only Approach When

Для средней сложности достаточно:

```text
Route enum
NavigationStack
sheet item
feature container view
```

без отдельного coordinator object.

---

## 6. Use Full Coordinator When

Full Coordinator уместен, если:

```text
- flow имеет жизненный цикл
- есть child coordinators
- нужно управлять root switch
- нужно cleanly finish flow
- есть UIKit
- есть deep link routing
- есть несколько presentation styles
```

---

## 7. Do Not Use Coordinator For

Не использовать Coordinator для:

```text
- бизнес-правил
- API calls
- data fetching
- formatting
- validation
- cache/offline policy
- state management вместо ViewModel/Store
```

---

## 8. Overengineering Signals

Coordinator слишком тяжелый, если:

```text
- простая кнопка требует отдельный Coordinator
- каждый экран имеет Coordinator без flow
- Coordinator просто вызывает один NavigationLink
- route hierarchy сложнее самого приложения
```

---

## 9. Underengineering Signals

Coordinator нужен, если сейчас:

```text
- View создает destination views
- ViewModel возвращает SwiftUI View
- deep links обработаны в random places
- auth redirects размазаны
- tab flow не централизован
- невозможно понять, кто управляет модальным flow
```

---

## 10. Decision Rule

```text
Use simple SwiftUI navigation for local navigation.
Use Coordinator when navigation becomes a flow.
```
