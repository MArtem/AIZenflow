# 04_Data_Flow_Rules — MVC / Massive ViewController / Migration

## 1. Purpose

Этот документ описывает data flow в legacy MVC и целевую миграцию.

---

## 2. Bad Massive VC Flow

```text
ViewController
 → APIClient
 → JSONDecoder
 → DTO
 → formatting
 → UI
 → DB/cache
 → navigation
```

Проблема: один файл отвечает за все.

---

## 3. First Improved Flow

```text
ViewController
 → Service/Repository
 → Domain/DTO result
 → Mapper
 → ViewState
 → UI
```

---

## 4. Better MVVM Flow

```text
ViewController
 → ViewModel
 → UseCase/Repository
 → Domain
 → ViewState
 → ViewController renders
```

---

## 5. Clean Flow

```text
ViewController
 → ViewModel
 → UseCase
 → Repository Protocol
 → Repository Implementation
 → DataSource/API/DB/cache
 → DTO/DBModel
 → Domain
 → ViewState
```

---

## 6. Extraction Order

Recommended:

```text
1. Extract DTO decoding
2. Extract mapping
3. Extract API client call
4. Extract business validation
5. Extract ViewState
6. Extract navigation
7. Extract state owner
```

---

## 7. Request Flow

User action:

```text
Button tap
 → ViewController forwards event
 → ViewModel/Presenter/Interactor
 → UseCase/Repository
 → result
 → ViewState
 → ViewController renders
```

---

## 8. Navigation Flow

Bad:

```text
ViewController decides business + creates destination + injects dependencies
```

Better:

```text
ViewController forwards event
 → ViewModel/Presenter emits route
 → Coordinator/Router creates destination
```

---

## 9. DTO Rules

DTO should not be the screen state.

During migration, if DTO is still used in UI, mark it as temporary technical debt.

---

## 10. Rule

```text
Every migration step should move one responsibility out of ViewController.
```
