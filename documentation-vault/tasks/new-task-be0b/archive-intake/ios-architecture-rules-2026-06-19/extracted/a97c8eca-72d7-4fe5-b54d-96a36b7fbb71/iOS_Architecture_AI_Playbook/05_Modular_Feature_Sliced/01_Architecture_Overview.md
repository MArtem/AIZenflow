# 01_Architecture_Overview — Modular / Feature-Sliced Architecture

## 1. Purpose

Modular / Feature-Sliced Architecture описывает структуру всего iOS-приложения, а не одного экрана.

Она отвечает на вопросы:

```text
- как делить приложение на features
- что класть в Shared/Core
- когда выносить код в Swift Package
- как избежать циклических зависимостей
- как определить public API фичи
- как не превратить Shared в мусорку
```

---

## 2. Core Idea

Главная идея:

```text
Organize code around product features and stable boundaries, not just technical categories.
```

Плохо:

```text
Views/
ViewModels/
Models/
Services/
Repositories/
```

когда проект большой и все фичи перемешаны.

Лучше:

```text
Features/
  News/
  Profile/
  Settings/
  Auth/
Shared/
  DesignSystem/
  Networking/
  Persistence/
Core/
  AppFoundation/
```

---

## 3. What Modular Architecture Solves

Она помогает:

```text
- масштабировать проект
- уменьшать связанность
- ускорять навигацию по коду
- разделять ownership между разработчиками
- переиспользовать shared layers
- готовиться к SPM-модулям
- контролировать зависимости
- защищать feature internals
```

---

## 4. What It Does Not Solve

Modular Architecture не решает сама по себе:

```text
- state management
- business logic design
- API/cache/offline policy
- UI architecture
- navigation pattern
- DTO/Domain/UI mapping
```

Ее нужно комбинировать:

```text
Feature module + MVVM
Feature module + Clean Architecture
Feature module + TCA
Feature module + Coordinator
Feature module + Hexagonal
```

---

## 5. Horizontal vs Vertical Structure

### Horizontal technical structure

```text
Views/
ViewModels/
Repositories/
Services/
Models/
```

Минус: фичи размазаны по проекту.

### Vertical feature structure

```text
Features/
  News/
    Presentation/
    Domain/
    Data/
  Profile/
    Presentation/
    Domain/
    Data/
```

Плюс: feature находится в одном месте.

---

## 6. Recommended Top-level Structure

```text
App/
Features/
Shared/
Core/
Infrastructure/
DesignSystem/
Resources/
Tests/
```

---

## 7. App Layer

`App/` содержит:

```text
- App entry point
- root composition
- AppCoordinator
- dependency container
- environment setup
- app lifecycle
```

App может знать все модули для composition.

---

## 8. Features Layer

`Features/` содержит product features:

```text
Features/
  Auth/
  News/
  Profile/
  Search/
  Settings/
  Notifications/
```

Feature should own:

```text
- its screens
- its presentation state
- its domain use cases if feature-specific
- its data layer if feature-specific
- its navigation routes
- its assembly
```

---

## 9. Shared Layer

`Shared/` содержит reusable code with clear purpose:

```text
Shared/
  DesignSystem/
  UIComponents/
  NetworkingAbstractions/
  PersistenceAbstractions/
  AnalyticsAbstractions/
  Localization/
```

Shared не должен быть dumping ground.

---

## 10. Core Layer

`Core/` содержит stable app/domain foundations:

```text
Core/
  AppFoundation/
  DomainPrimitives/
  Concurrency/
  Errors/
  Logging/
  FeatureFlags/
```

Core должен быть маленьким и стабильным.

---

## 11. Infrastructure Layer

`Infrastructure/` содержит concrete adapters:

```text
Infrastructure/
  APIClient/
  Database/
  Keychain/
  Analytics/
  Push/
  RemoteConfig/
```

Infrastructure реализует shared/domain abstractions.

---

## 12. DesignSystem

DesignSystem должен быть отдельным:

```text
DesignSystem/
  Colors/
  Typography/
  Spacing/
  Components/
  Icons/
```

Feature-specific UI should not leak into DesignSystem unless it becomes truly reusable.

---

## 13. Swift Package Evolution

Для команды 2–3 developers не нужно сразу делать 30 SPM modules.

Рекомендуемый путь:

```text
Phase 1: folders with dependency rules
Phase 2: extract stable Shared/DesignSystem packages
Phase 3: extract Infrastructure packages
Phase 4: extract large stable Features if needed
```

---

## 14. Summary

Modular Architecture здорова, если:

```text
- features isolated
- Shared/Core small and meaningful
- dependencies flow in one direction
- public APIs explicit
- no cyclic dependencies
- feature internals protected
```

Нездорова, если:

```text
- Shared is a trash folder
- Core becomes God Module
- features import each other directly
- everything is public
- SPM split done too early
- dependency graph cyclic
```
