# 15_Anti_Patterns — VIP / Clean Swift

## 1. Purpose

Anti-patterns for VIP/Clean Swift.

---

## 2. Presenter with Business Logic

Bad:

```text
Presenter decides if payment is allowed.
```

Fix:

```text
Interactor/UseCase decides. Presenter formats.
```

---

## 3. Interactor with UI Formatting

Bad:

```text
Interactor formats "19 Jun 2026" display string.
```

Fix:

```text
Presenter formats display strings.
```

---

## 4. View Calls Worker

Bad:

```text
ViewController → Worker.fetch()
```

Fix:

```text
View → Interactor → Worker
```

---

## 5. Router Calls API

Bad:

```text
Router fetches object before navigation.
```

Fix:

```text
Router passes ID; destination loads data.
```

---

## 6. Worker God Service

Bad:

```text
Worker has API, DB, analytics, validation, formatting, navigation.
```

Fix:

```text
split Worker/UseCase/Repository/Mapper.
```

---

## 7. Empty Pass-through VIP

Bad:

```text
View → Interactor → Presenter → View
```

where every method only forwards same data with no logic.

Fix:

```text
Use MVVM/SwiftUI state for simple screen.
```

---

## 8. DTO in ViewModel

Bad:

```text
ViewModel contains ArticleDTO.
```

Fix:

```text
Presenter creates display-ready ViewModel.
```

---

## 9. Protocol Ceremony

Bad:

```text
protocol for every class with one implementation and no test/boundary value.
```

Fix:

```text
use protocols where test/assembly/module boundary needs them.
```

---

## 10. Final Rule

```text
VIP is valuable when each role has real work. If roles are empty pass-throughs, it is ceremony.
```
