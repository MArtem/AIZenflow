# 03_Module_And_Folder_Structure — Modular / Feature-Sliced Architecture

## 1. Purpose

Этот документ задает структуру папок для модульного iOS-проекта.

---

## 2. Recommended Root Structure

```text
iOSApp/
├── App/
├── Features/
├── Shared/
├── Core/
├── Infrastructure/
├── DesignSystem/
├── Resources/
└── Tests/
```

---

## 3. App

```text
App/
├── AppEntry.swift
├── AppCoordinator.swift
├── AppAssembly.swift
├── AppEnvironment.swift
├── DependencyContainer.swift
└── RootView.swift
```

App layer can compose everything.

---

## 4. Features

```text
Features/
├── Auth/
├── News/
├── Profile/
├── Search/
├── Settings/
└── Notifications/
```

Each feature:

```text
FeatureName/
├── Presentation/
├── Domain/
├── Data/
├── Navigation/
├── Assembly/
└── Tests/
```

---

## 5. Shared

```text
Shared/
├── UIComponents/
├── NetworkingAbstractions/
├── PersistenceAbstractions/
├── AnalyticsAbstractions/
├── Localization/
├── Formatting/
└── Utilities/
```

Every Shared subfolder must have a clear purpose.

---

## 6. Core

```text
Core/
├── DomainPrimitives/
├── AppErrors/
├── Concurrency/
├── Logging/
├── FeatureFlags/
└── FoundationExtensions/
```

Core should be stable and small.

---

## 7. Infrastructure

```text
Infrastructure/
├── Networking/
├── Persistence/
├── Keychain/
├── Analytics/
├── Push/
├── RemoteConfig/
└── FileStorage/
```

Infrastructure provides concrete implementations.

---

## 8. DesignSystem

```text
DesignSystem/
├── Tokens/
│   ├── Colors.swift
│   ├── Typography.swift
│   └── Spacing.swift
├── Components/
├── Icons/
├── Themes/
└── PreviewSupport/
```

---

## 9. Feature Internal Structure

Example:

```text
Features/News/
├── Presentation/
│   ├── Views/
│   ├── ViewModels/
│   ├── ViewStates/
│   ├── Components/
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
│   ├── NewsRoute.swift
│   └── NewsCoordinator.swift
└── Assembly/
    └── NewsAssembly.swift
```

---

## 10. Public API Folder

For SPM modules:

```text
FeatureName/
├── Public/
│   ├── FeatureNameAssembly.swift
│   ├── FeatureNameRoute.swift
│   └── FeatureNameOutput.swift
└── Internal/
```

In normal app target, use access control to simulate this.

---

## 11. Tests Structure

```text
Tests/
├── Features/
│   ├── NewsTests/
│   └── ProfileTests/
├── SharedTests/
├── CoreTests/
└── InfrastructureTests/
```

---

## 12. Forbidden Structure

Avoid:

```text
Shared/
├── Helpers/
├── Managers/
├── Common/
├── Utils/
└── Stuff/
```

Avoid:

```text
Features/
├── Views/
├── ViewModels/
├── Models/
└── Services/
```

because feature ownership disappears.

---

## 13. Rule

```text
Folder structure should make dependencies and ownership obvious.
```
