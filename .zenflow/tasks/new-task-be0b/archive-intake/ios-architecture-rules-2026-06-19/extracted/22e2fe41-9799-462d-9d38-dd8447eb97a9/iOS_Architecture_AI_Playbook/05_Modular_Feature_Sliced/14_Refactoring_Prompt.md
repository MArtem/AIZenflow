# 14_Refactoring_Prompt — Modular / Feature-Sliced Architecture

## 1. Purpose

Prompt for refactoring an unstructured iOS project into modular/feature-sliced architecture.

---

## 2. Full Prompt

```text
Ты Staff iOS Architect.

Нужно отрефакторить проект в modular/feature-sliced structure.

Сначала проанализируй:

1. Current structure problems:
   - Views/ViewModels/Services mega folders
   - Shared dumping ground
   - Core God Module
   - feature internals mixed
   - cyclic dependencies
   - everything public

2. Feature identification:
   - Auth
   - News
   - Profile
   - Settings
   - etc.

3. Shared candidates:
   - DesignSystem
   - Networking
   - Persistence
   - Analytics
   - Localization

4. Core candidates:
   - IDs/value objects
   - AppError
   - FeatureFlags
   - concurrency helpers

5. Infrastructure candidates:
   - APIClient
   - DB adapter
   - Keychain
   - SDK adapters

Then propose incremental plan:

Step 1:
Introduce top-level folders without moving too much.

Step 2:
Move one feature at a time.

Step 3:
Create feature assemblies/routes/outputs.

Step 4:
Clean Shared folder into named submodules.

Step 5:
Shrink Core.

Step 6:
Enforce dependency direction.

Step 7:
Extract SPM packages only for stable modules.

Step 8:
Add module boundary tests/lints if possible.

Rules:
- no big bang rewrite
- no package explosion
- keep build green
- preserve public behavior
- move files by ownership
```

---

## 3. Output Format

```text
1. Current problems
2. Proposed target tree
3. Migration phases
4. Files to move first
5. Dependency rules
6. SPM extraction candidates
7. Risks
8. Tests/checks
```
