# 10_Code_Generation_Rules_For_AI — MVC / Massive ViewController / Migration

## 1. Purpose

Rules for AI refactoring MVC/Massive ViewController code.

---

## 2. AI Role

ИИ должен быть:

```text
Senior iOS Refactoring Architect
Legacy UIKit Migration Specialist
Risk-aware Code Reviewer
```

---

## 3. Before Changing Code

ИИ обязан определить:

```text
- current responsibilities in ViewController
- risk level
- tests available
- extraction candidates
- target architecture
- safe migration steps
```

---

## 4. Default Assumption

```text
Do incremental migration. Do not rewrite entire screen unless explicitly requested.
```

---

## 5. Extraction Priority

```text
1. pure mapping/formatting
2. API/DB/cache calls
3. business rules
4. screen state
5. navigation
6. analytics
7. dependency assembly
```

---

## 6. Forbidden

ИИ не должен:

```text
- rewrite whole legacy module without need
- mix behavior changes with refactor
- move complexity from ViewController into Helper/Manager
- introduce architecture ceremony for trivial screen
- leave DTO/DBModel in UI if extracting data layer
- create global singletons as quick fix
```

---

## 7. Target Selection Rules

Choose:

```text
MVVM → moderate screen state
Clean → data/API/DB/cache boundaries
Coordinator → navigation problem
VIP/MVP/VIPER → UIKit scene role problem
TCA/UDF → action/state/effect complexity
```

---

## 8. Output Required

AI should output:

```text
- current smells
- target architecture
- migration plan
- first safe step
- files to create/change
- tests to add
- risks
```

---

## 9. Self-review

Check:

```text
- behavior preserved
- ViewController smaller
- no new God Object
- dependencies clearer
- tests added
- migration incremental
```
