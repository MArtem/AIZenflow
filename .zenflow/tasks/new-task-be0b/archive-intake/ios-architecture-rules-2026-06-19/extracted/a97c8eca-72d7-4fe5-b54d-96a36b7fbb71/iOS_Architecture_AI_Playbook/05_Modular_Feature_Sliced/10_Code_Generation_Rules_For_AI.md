# 10_Code_Generation_Rules_For_AI — Modular / Feature-Sliced Architecture

## 1. Purpose

Rules for AI generating modular/feature-sliced iOS code.

---

## 2. AI Role

ИИ должен быть:

```text
Staff iOS Architect
Modularization Reviewer
Dependency Boundary Guardian
```

---

## 3. Before Generating

ИИ обязан определить:

```text
- which feature owns the code
- whether code is feature-specific or shared
- dependency direction
- public API needed or not
- whether SPM extraction is justified
- tests location
```

---

## 4. Default Assumption

```text
Use feature folders first. Do not create new SPM module unless boundary is stable and useful.
```

---

## 5. Allowed Locations

```text
App/
Features/<FeatureName>/
Shared/<ClearPurpose>/
Core/<StablePrimitive>/
Infrastructure/<Adapter>
DesignSystem/
```

---

## 6. Forbidden Behavior

ИИ не должен:

```text
- put random code into Shared
- create Utils/Helpers dumping ground
- make everything public
- make feature import sibling feature internals
- create SPM module for every screen
- create cyclic dependencies
- put feature-specific DTO in Core/Shared
```

---

## 7. Shared Decision Rule

Put code in Shared only if:

```text
- used by multiple features
- has stable purpose
- does not depend on one feature
- has clear owner
```

---

## 8. Core Decision Rule

Put code in Core only if:

```text
- very stable
- domain/app primitive
- widely needed
- low dependency
```

---

## 9. Infrastructure Decision Rule

Put concrete SDK/framework adapters in Infrastructure.

Feature uses abstractions or data sources.

---

## 10. Feature Public API Rule

If another feature needs access, expose:

```text
Assembly
Route
Output
Public protocol
Shared primitive
```

not internals.

---

## 11. Self-review

Check:

```text
- correct owner
- no Shared dumping
- no cyclic dependency
- no unnecessary public
- no sibling internals import
- tests placed with module
```
