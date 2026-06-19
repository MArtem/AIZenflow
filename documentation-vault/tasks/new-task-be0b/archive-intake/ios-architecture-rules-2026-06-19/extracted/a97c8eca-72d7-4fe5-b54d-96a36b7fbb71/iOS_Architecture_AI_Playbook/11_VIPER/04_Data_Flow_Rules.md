# 04_Data_Flow_Rules — VIPER

## 1. Purpose

Этот документ описывает data flow в VIPER.

---

## 2. Main Flow

```text
View
 → Presenter
 → Interactor
 → UseCase/Repository/Service
 → Interactor
 → Presenter
 → View
```

Navigation:

```text
Presenter
 → Router
 → destination module
```

---

## 3. Load Flow

```text
View notifies presenter: viewDidLoad
 → Presenter asks Interactor to load
 → Interactor calls UseCase/Repository
 → Interactor returns result to Presenter
 → Presenter formats view model
 → View displays
```

---

## 4. User Action Flow

```text
View sends event to Presenter
 → Presenter decides screen-level intent
 → Interactor performs business operation
 → Presenter formats result
 → Router navigates if needed
```

---

## 5. API/Data Flow

```text
Interactor
 → UseCase/Repository
 → DataSource/API/DB/cache
 → Domain Entity
 → Presenter
 → ViewState/ViewModel
 → View
```

---

## 6. Mapping Rules

```text
DTO → Domain: Data layer
Domain → ViewModel/ViewState: Presenter
ViewModel → UI: View
```

---

## 7. Entity Rules

Entity should represent domain/business data.

Avoid:

```text
Presenter receives DTO
View receives Entity directly if formatting needed
```

---

## 8. Error Flow

```text
UseCase/Repository error
 → Interactor receives AppError/DomainError
 → Presenter formats ErrorViewModel
 → View displays
```

---

## 9. Navigation Data Flow

```text
Presenter asks Router.openDetails(id)
 → Router builds destination with ID
 → destination loads its data
```

Avoid passing DTO/DBModel.

---

## 10. Rule

```text
Presenter coordinates display and navigation; Interactor owns business data flow.
```
