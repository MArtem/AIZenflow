# 11_Review_Checklist — Modular / Feature-Sliced Architecture

## 1. Purpose

Review checklist for modular architecture.

---

## 2. Ownership Checklist

```text
[ ] Code belongs to correct feature/module
[ ] Shared code is truly shared
[ ] Core code is stable and generic
[ ] Infrastructure code is technical adapter
[ ] DesignSystem contains reusable UI only
```

---

## 3. Dependency Checklist

```text
[ ] No cyclic dependencies
[ ] Feature does not import sibling internals
[ ] App composes features
[ ] Shared does not depend on Features
[ ] Core does not depend on Features
[ ] Infrastructure does not leak into Domain/UI
```

---

## 4. Public API Checklist

```text
[ ] Only necessary types public
[ ] Feature exposes assembly/route/output
[ ] Internals remain internal/private
[ ] No public everything
```

---

## 5. Shared/Core Checklist

```text
[ ] No Utils dumping ground
[ ] No Common mega-folder
[ ] Shared folder has clear subdomains
[ ] Core is not God Module
```

---

## 6. SPM Checklist

```text
[ ] Boundary stable
[ ] Module useful
[ ] Package dependencies simple
[ ] No premature extraction
[ ] Build benefits or ownership benefits exist
```

---

## 7. Red Flags

```text
- Shared/Managers
- Core/AppEverything
- Feature imports another feature's ViewModel
- DTOs all in Shared
- everything public
- cyclic package dependencies
- App target with 3000 unstructured files
```
