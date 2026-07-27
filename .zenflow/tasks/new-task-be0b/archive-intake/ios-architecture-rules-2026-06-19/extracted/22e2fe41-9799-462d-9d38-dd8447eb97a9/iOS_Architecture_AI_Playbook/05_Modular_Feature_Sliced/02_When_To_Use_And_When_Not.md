# 02_When_To_Use_And_When_Not — Modular / Feature-Sliced Architecture

## 1. Purpose

Этот документ объясняет, когда нужна модульная/feature-sliced структура, а когда она будет лишней.

---

## 2. Use Modular Architecture When

Используй, если:

```text
- приложение production-level
- много экранов
- несколько product features
- команда больше 1 разработчика
- ожидается рост проекта
- есть shared infrastructure
- есть design system
- важна изоляция фич
- нужны понятные ownership boundaries
```

---

## 3. Strong Fit Scenarios

```text
- social/news app
- finance app
- marketplace
- enterprise app
- app with auth + feed + profile + settings + payments
- app with offline/cache/database
```

---

## 4. Use Soft Modularity When

Для старта с 2–3 разработчиками лучше:

```text
folders first
dependency rules
internal boundaries
clear naming
```

Не обязательно сразу:

```text
SPM for every feature
binary frameworks
complex build graph
```

---

## 5. Use SPM Modules When

Выносить в SPM стоит, если:

```text
- boundary stable
- module reused
- compile-time benefits expected
- ownership clear
- public API can be controlled
- dependencies not cyclic
```

Хорошие кандидаты:

```text
DesignSystem
Networking
Persistence
Analytics
DomainPrimitives
FeatureFlags
```

---

## 6. Do Not Over-modularize When

Не нужно дробить, если:

```text
- feature маленькая
- API еще меняется каждый день
- границы нестабильны
- команда маленькая
- modules только усложнят сборку
```

---

## 7. Do Not Use Feature-Sliced as Excuse

Feature folder не означает, что внутри можно смешивать все:

```text
Feature/
  View
  APIClient
  DBModel
  DTO
  Cache
  Business
```

Feature still needs internal architecture.

---

## 8. Overengineering Signals

```text
- каждый экран как отдельный SPM module
- public API на все типы
- 20 маленьких packages без стабильных границ
- каждый change требует править Package.swift
- циклические dependencies борются через костыли
```

---

## 9. Underengineering Signals

```text
- один App target на 1000 файлов без структуры
- Views/ViewModels/Services folders с мешаниной
- Shared содержит все подряд
- features напрямую импортируют internals друг друга
- невозможно понять ownership
```

---

## 10. Decision Rule

```text
Start with feature folders and strict dependency rules.
Extract SPM modules only when boundaries are stable and useful.
```
