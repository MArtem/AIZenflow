# 03_Module_And_Folder_Structure — MVC / Massive ViewController / Migration

## 1. Purpose

Этот документ задает структуру файлов для legacy MVC и целевой миграции.

---

## 2. Legacy MVC Structure

Typical old structure:

```text
Feature/
├── FeatureViewController.swift
├── FeatureCell.swift
├── FeatureModel.swift
└── FeatureService.swift
```

Проблема: почти все может оказаться в ViewController.

---

## 3. First Extraction Structure

Минимальный safe step:

```text
Feature/
├── FeatureViewController.swift
├── FeatureViewState.swift
├── FeatureMapper.swift
├── FeatureService.swift
└── FeatureTests.swift
```

---

## 4. MVVM Target Structure

```text
Feature/
├── View/
│   └── FeatureViewController.swift
├── ViewModel/
│   └── FeatureViewModel.swift
├── Models/
│   ├── FeatureViewState.swift
│   └── FeatureAction.swift
├── Navigation/
│   └── FeatureRoute.swift
└── Tests/
    └── FeatureViewModelTests.swift
```

---

## 5. Clean Target Structure

```text
Feature/
├── Presentation/
│   ├── FeatureViewController.swift
│   ├── FeatureViewModel.swift
│   ├── FeatureViewState.swift
│   └── Mappers/
├── Domain/
│   ├── Entities/
│   ├── UseCases/
│   └── Repositories/
├── Data/
│   ├── DTO/
│   ├── DBModels/
│   ├── DataSources/
│   ├── Repositories/
│   └── Mappers/
├── Navigation/
└── Assembly/
```

---

## 6. Coordinator Target Structure

```text
Feature/
├── View/
├── ViewModel/
├── Navigation/
│   ├── FeatureRoute.swift
│   └── FeatureCoordinator.swift
└── Assembly/
```

---

## 7. Legacy Support Folder

For transitional code:

```text
Legacy/
├── OldFeatureViewController.swift
├── OldFeatureAdapter.swift
└── MigrationNotes.md
```

Use `Legacy` intentionally, not as permanent dumping ground.

---

## 8. Tests Structure

```text
FeatureTests/
├── Characterization/
├── Mappers/
├── UseCases/
├── ViewModel/
└── Navigation/
```

---

## 9. Naming Rules

Good:

```text
FeatureViewState
FeatureViewModel
FeatureUseCase
FeatureRepository
FeatureCoordinator
```

Avoid:

```text
FeatureHelper
FeatureManager
CommonService
DataUtil
```

---

## 10. Rule

```text
Migration structure should make the next extraction obvious, not hide old complexity in new folders.
```
