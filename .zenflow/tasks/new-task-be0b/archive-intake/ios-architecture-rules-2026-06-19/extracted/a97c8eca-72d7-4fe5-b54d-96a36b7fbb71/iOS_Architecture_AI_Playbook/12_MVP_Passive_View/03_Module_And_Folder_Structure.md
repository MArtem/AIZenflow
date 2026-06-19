# 03_Module_And_Folder_Structure — MVP / Passive View

## 1. Purpose

Этот документ задает структуру файлов для MVP/Passive View feature.

---

## 2. Minimal Structure

```text
FeatureName/
├── FeatureNameViewController.swift
├── FeatureNamePresenter.swift
└── FeatureNamePresenterTests.swift
```

---

## 3. Production Structure

```text
FeatureName/
├── View/
│   ├── FeatureNameViewController.swift
│   ├── FeatureNameView.swift
│   └── FeatureNameViewProtocol.swift
│
├── Presenter/
│   ├── FeatureNamePresenter.swift
│   └── FeatureNamePresenterProtocol.swift
│
├── Models/
│   ├── FeatureNameViewState.swift
│   ├── FeatureNameInput.swift
│   └── FeatureNameOutput.swift
│
├── Navigation/
│   ├── FeatureNameRoute.swift
│   └── FeatureNameRouter.swift
│
├── Domain/
│   ├── Entities/
│   └── UseCases/
│
├── Data/
└── Tests/
    └── FeatureNamePresenterTests.swift
```

---

## 4. View Protocol

View protocol should be small:

```swift
protocol LoginView: AnyObject {
    func display(_ state: LoginViewState)
    func displayError(_ error: ErrorViewState)
}
```

Avoid:

```text
func setTitle(...)
func setSubtitle(...)
func setButtonEnabled(...)
func setSpinnerVisible(...)
func setErrorLabel(...)
```

when one ViewState would be cleaner.

---

## 5. Presenter File

Presenter contains:

```text
- user event methods
- presentation logic
- UseCase calls
- ViewState creation
- Router calls
```

---

## 6. Router File

Router/Coordinator contains:

```text
- navigation mechanics
- destination creation
- route parameters
```

---

## 7. Domain/Data

For API/DB/cache features, do not put everything into Presenter.

Use:

```text
UseCase
Repository
DTO
Mapper
DBModel
```

---

## 8. Tests

Presenter tests use:

```text
ViewSpy
RouterSpy
UseCaseMock
```

---

## 9. Rule

```text
MVP folder structure should keep View passive and Presenter testable without becoming VIPER-level ceremony.
```
