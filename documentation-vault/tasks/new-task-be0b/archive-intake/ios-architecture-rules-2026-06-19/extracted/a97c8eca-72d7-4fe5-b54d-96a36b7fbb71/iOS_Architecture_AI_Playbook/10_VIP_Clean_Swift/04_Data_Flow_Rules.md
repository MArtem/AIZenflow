# 04_Data_Flow_Rules — VIP / Clean Swift

## 1. Purpose

Этот документ описывает data flow в VIP/Clean Swift.

---

## 2. Main Flow

```text
View
 → Request
 → Interactor
 → Response
 → Presenter
 → ViewModel/ViewState
 → View
```

---

## 3. Load Flow

```text
View lifecycle event
 → View sends Load.Request
 → Interactor calls Worker/UseCase
 → Interactor creates Load.Response
 → Presenter formats Load.ViewModel
 → View displays ViewModel
```

---

## 4. User Action Flow

```text
Button tap
 → View sends Action.Request
 → Interactor validates/executes business
 → Presenter prepares result view model
 → View displays result
```

---

## 5. API Flow

```text
Interactor
 → Worker/UseCase/Repository
 → DTO/DBModel hidden in Data
 → Domain result
 → Response
 → Presenter
 → ViewModel
```

View and Presenter should not see DTO/DBModel.

---

## 6. Request Rules

Request contains input from View:

```text
text field values
selected ID
pagination cursor
filter choice
```

Request should not contain:

```text
SwiftUI View
UIViewController
DTO
DBModel
Repository
```

---

## 7. Response Rules

Response contains business/domain result:

```text
Domain models
operation result
validation result
error/app error
```

Response should not contain formatted UI strings unless they are domain strings.

---

## 8. ViewModel Rules

ViewModel is display-ready:

```text
formatted title
formatted date
button state
error text
empty state
```

---

## 9. Mapping Rules

```text
DTO → Domain: Worker/Data layer
Domain → Response: Interactor
Response → ViewModel: Presenter
```

---

## 10. Rule

```text
Interactor decides what happened. Presenter decides how to display it.
```
