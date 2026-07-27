# 03_Module_And_Folder_Structure — VIPER

## 1. Purpose

Этот документ задает структуру файлов для VIPER module.

---

## 2. Classic Structure

```text
FeatureName/
├── FeatureNameView.swift / FeatureNameViewController.swift
├── FeatureNamePresenter.swift
├── FeatureNameInteractor.swift
├── FeatureNameEntity.swift
├── FeatureNameRouter.swift
└── FeatureNameBuilder.swift
```

---

## 3. Production Structure

```text
FeatureName/
├── View/
│   ├── FeatureNameViewController.swift
│   └── FeatureNameView.swift
├── Presenter/
│   └── FeatureNamePresenter.swift
├── Interactor/
│   └── FeatureNameInteractor.swift
├── Entity/
│   ├── FeatureNameEntity.swift
│   └── FeatureNameModels.swift
├── Router/
│   └── FeatureNameRouter.swift
├── Builder/
│   └── FeatureNameBuilder.swift
└── Tests/
    ├── FeatureNamePresenterTests.swift
    ├── FeatureNameInteractorTests.swift
    └── FeatureNameRouterTests.swift
```

---

## 4. Clean/Domain Integration

For production:

```text
FeatureName/
├── VIPER/
│   ├── View/
│   ├── Presenter/
│   ├── Interactor/
│   ├── Router/
│   └── Builder/
├── Domain/
│   ├── Entities/
│   ├── UseCases/
│   └── Repositories/
├── Data/
│   ├── DTO/
│   ├── DBModels/
│   ├── Mappers/
│   └── Repositories/
└── Tests/
```

---

## 5. Protocol Files

Protocols can be in same files for small module:

```text
FeatureNamePresenter.swift
FeatureNameInteractor.swift
```

or separate:

```text
FeatureNameProtocols.swift
```

Only if it improves readability.

---

## 6. Builder / Assembly

Builder wires dependencies:

```text
View
Presenter
Interactor
Router
UseCases
Repositories
```

View should not build VIPER graph.

---

## 7. Entity Folder

Entity should contain:

```text
Domain entities
screen input/output models
value objects
```

Avoid using DTO as Entity.

---

## 8. Tests

Test most value:

```text
Presenter tests
Interactor tests
Router tests
```

---

## 9. Naming Rules

Good:

```text
ArticleDetailsPresenter
ArticleDetailsInteractor
ArticleDetailsRouter
ArticleDetailsBuilder
```

Avoid:

```text
ArticleDetailsManager
ArticleDetailsHelper
VIPERBaseThing
```

---

## 10. Rule

```text
VIPER folder structure should clarify role ownership, not just generate files.
```
