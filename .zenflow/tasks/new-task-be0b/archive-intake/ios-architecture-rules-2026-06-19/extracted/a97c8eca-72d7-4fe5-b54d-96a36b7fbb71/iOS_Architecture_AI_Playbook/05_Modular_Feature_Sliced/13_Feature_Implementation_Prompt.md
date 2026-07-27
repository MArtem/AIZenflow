# 13_Feature_Implementation_Prompt — Modular / Feature-Sliced Architecture

## 1. Purpose

Prompt for implementing a new feature in modular/feature-sliced project.

---

## 2. Full Prompt

```text
Ты Staff iOS Architect.

Нужно добавить новую feature в modular/feature-sliced iOS project.

Сначала не пиши код. Определи:

1. Feature owner:
   - new feature
   - existing feature
   - shared module
   - infrastructure
   - core
   - design system

2. Folder structure:
   - Presentation
   - Domain
   - Data
   - Navigation
   - Assembly
   - Tests

3. Dependencies:
   - what feature imports
   - what imports this feature
   - public API needed
   - forbidden imports

4. Public contract:
   - Assembly
   - Route
   - Output
   - Protocols if needed

5. Cross-feature communication:
   - route
   - output
   - app coordinator
   - shared primitive

6. Shared/Core decision:
   - what can stay feature-local
   - what is truly shared

7. Testing:
   - feature tests
   - boundary tests
   - integration tests if needed

Rules:
- no random Shared code
- no sibling feature internals
- no everything public
- no SPM unless justified
- feature-specific DTO/DBModel stay in feature
- App/Coordinator composes features
```
