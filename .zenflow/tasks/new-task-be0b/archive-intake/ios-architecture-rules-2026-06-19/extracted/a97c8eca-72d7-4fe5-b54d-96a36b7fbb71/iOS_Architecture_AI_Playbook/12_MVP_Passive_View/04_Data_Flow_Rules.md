# 04_Data_Flow_Rules — MVP / Passive View

## 1. Purpose

Этот документ описывает data flow in MVP/Passive View.

---

## 2. Main Flow

```text
View
 → Presenter
 → UseCase/Repository/Service
 → Presenter
 → View
```

---

## 3. Load Flow

```text
View.onViewDidLoad
 → Presenter.viewDidLoad()
 → Presenter tells View to show loading
 → Presenter calls UseCase
 → Presenter maps result to ViewState
 → View displays ViewState
```

---

## 4. User Action Flow

```text
Button tap
 → View calls presenter.buttonTapped()
 → Presenter validates/acts
 → Presenter updates View
 → Presenter routes if needed
```

---

## 5. API Flow

```text
Presenter
 → UseCase
 → Repository
 → API/DB/cache
 → Domain result
 → Presenter maps to ViewState
 → View displays
```

Presenter should not decode DTO or query DB directly.

---

## 6. Input Flow

View passes primitive/input model:

```swift
presenter.loginTapped(email: email, password: password)
```

or:

```swift
presenter.loginTapped(LoginInput(email: email, password: password))
```

---

## 7. Output Flow

Presenter outputs:

```text
ViewState
ErrorViewState
Route intent
```

not DTO/DBModel.

---

## 8. Mapping Rules

```text
DTO → Domain: Data layer
Domain → ViewState: Presenter or presentation mapper
ViewState → UI: View
```

---

## 9. Navigation Flow

```text
Presenter decides route intent
 → Router/Coordinator executes navigation
```

---

## 10. Rule

```text
View forwards events. Presenter owns presentation decisions. Data layer owns data mechanics.
```
