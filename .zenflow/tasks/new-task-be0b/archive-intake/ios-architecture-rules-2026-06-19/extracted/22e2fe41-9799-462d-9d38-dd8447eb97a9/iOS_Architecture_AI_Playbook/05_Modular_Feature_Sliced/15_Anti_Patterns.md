# 15_Anti_Patterns — Modular / Feature-Sliced Architecture

## 1. Purpose

Anti-patterns for modular/feature-sliced architecture.

---

## 2. Shared Dumping Ground

Bad:

```text
Shared/
  Helpers/
  Managers/
  Utils/
  Common/
```

Fix:

```text
Shared/Formatting
Shared/Localization
Shared/UIComponents
Shared/NetworkingAbstractions
```

---

## 3. Core God Module

Bad:

```text
Core imports everything and everyone imports Core.
```

Fix:

```text
Core contains stable primitives only.
```

---

## 4. Feature Imports Sibling Internals

Bad:

```text
News imports ProfileViewModel
```

Fix:

```text
News emits route/output, AppCoordinator opens Profile.
```

---

## 5. Everything Public

Bad:

```swift
public final class EveryInternalViewModel
```

Fix:

```text
minimal public API
internal by default
```

---

## 6. Premature SPM Split

Bad:

```text
one package per screen from day one
```

Fix:

```text
folders first, packages later
```

---

## 7. Cyclic Dependencies

Bad:

```text
News → Profile → News
```

Fix:

```text
move shared primitives up or communicate through app coordinator/output
```

---

## 8. Technical Folders Only

Bad:

```text
Views/
ViewModels/
Models/
Services/
```

in large app.

Fix:

```text
Features/News/...
Features/Profile/...
```

---

## 9. DTOs in Shared

Bad:

```text
AllDTOs shared because many features need data
```

Fix:

```text
feature owns DTO; shared only stable primitives/contracts
```

---

## 10. Infrastructure Leaks

Bad:

```text
Feature UI imports Firebase/Database SDK directly
```

Fix:

```text
Infrastructure adapter + feature boundary
```

---

## 11. Final Rule

```text
Modularity is about ownership and dependency control, not just folders or packages.
```
