# 15_Anti_Patterns — MVC / Massive ViewController / Migration

## 1. Purpose

Anti-patterns for MVC and migration.

---

## 2. Massive ViewController

Symptoms:

```text
UI + API + DB + business + navigation + formatting in one class.
```

Fix:

```text
extract boundaries incrementally.
```

---

## 3. Massive ViewModel Replacement

Bad:

```text
Move all ViewController code into ViewModel unchanged.
```

Fix:

```text
split UseCase/Repository/Coordinator/Mapper.
```

---

## 4. Helper Dumping Ground

Bad:

```text
FeatureHelper does validation, API, formatting, navigation.
```

Fix:

```text
name responsibilities explicitly.
```

---

## 5. Refactor + Redesign Together

Bad:

```text
change UI behavior while extracting architecture.
```

Fix:

```text
separate refactor from feature change.
```

---

## 6. DTO in Cell

Bad:

```text
Cell receives ArticleDTO.
```

Fix:

```text
Cell receives ArticleCellViewState.
```

---

## 7. API in ViewController

Bad:

```text
URLSession in ViewController.
```

Fix:

```text
Repository/DataSource/UseCase.
```

---

## 8. Coordinator Calls API

Bad migration:

```text
move navigation + data loading into Coordinator.
```

Fix:

```text
Coordinator navigates; feature loads data.
```

---

## 9. Over-architect Static Screen

Bad:

```text
Static info screen with Clean+VIPER+Coordinator.
```

Fix:

```text
simple MVC/SwiftUI Native State.
```

---

## 10. No Tests During Risky Refactor

Bad:

```text
rewrite massive class without behavior protection.
```

Fix:

```text
characterization tests/snapshot tests first where possible.
```

---

## 11. Final Rule

```text
The goal is not to remove MVC everywhere. The goal is to stop one object from becoming the whole application.
```
