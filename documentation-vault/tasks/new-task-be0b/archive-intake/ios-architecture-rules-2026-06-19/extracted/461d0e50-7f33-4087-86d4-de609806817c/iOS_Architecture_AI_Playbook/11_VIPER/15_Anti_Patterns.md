# 15_Anti_Patterns — VIPER

## 1. Purpose

Anti-patterns for VIPER.

---

## 2. VIPER for Every Screen

Bad:

```text
Static About screen with View/Presenter/Interactor/Entity/Router/Builder/Protocols.
```

Fix:

```text
Use SwiftUI Native State or MVVM light.
```

---

## 3. Presenter God Object

Symptoms:

```text
- business logic
- API calls
- formatting
- navigation
- state
- analytics
```

Fix:

```text
move business to Interactor, navigation to Router, data to UseCase/Repository.
```

---

## 4. Interactor Imports UIKit

Bad:

```swift
import UIKit
```

inside Interactor for UI reasons.

Fix:

```text
Interactor domain/application only.
```

---

## 5. Entity is DTO

Bad:

```text
VIPER Entity == API DTO
```

Fix:

```text
DTO → Domain Entity mapping.
```

---

## 6. Router with Business Logic

Bad:

```text
Router validates if payment allowed.
```

Fix:

```text
Interactor/UseCase decides. Router navigates.
```

---

## 7. Protocol Explosion

Bad:

```text
protocol for every class without tests/boundary value.
```

Fix:

```text
protocols only when useful.
```

---

## 8. Builder Missing

Bad:

```text
View manually creates Presenter/Interactor/Router.
```

Fix:

```text
Builder/Assembly owns module graph.
```

---

## 9. View Calls Interactor Directly

Bad:

```text
View → Interactor
```

in VIPER.

Fix:

```text
View → Presenter → Interactor
```

---

## 10. Final Rule

```text
VIPER is powerful only when roles are real. Empty roles are architecture theater.
```
