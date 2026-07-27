# 14_Refactoring_Prompt — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

Prompt for refactoring existing code toward Hexagonal Architecture.

---

## 2. Full Prompt

```text
Ты Staff iOS Architect.

Нужно отрефакторить код в Hexagonal Architecture / Ports & Adapters.

Сначала найди:

1. Technology leakage:
   - Domain imports API/DB/SDK
   - ViewModel uses SDK directly
   - DTO in Domain/UI
   - DBModel in Domain/UI

2. Missing ports:
   - use cases depend on concrete API/DB
   - tests require real infrastructure
   - local JSON replacement touches UI

3. Adapter problems:
   - business rules inside API adapter
   - adapter returns ViewState
   - adapter exposes SDK errors directly

4. Overengineering:
   - protocols without boundary
   - ManagerProtocol
   - too many tiny ports

Migration plan:

Step 1:
Identify domain core and technology dependencies.

Step 2:
Define meaningful outbound ports.

Step 3:
Move concrete API/DB/SDK code into adapters.

Step 4:
Map DTO/DBModel/SDK types to Domain at adapter boundary.

Step 5:
Make use cases depend on ports.

Step 6:
Replace infrastructure in tests with fake ports.

Step 7:
Introduce composite adapter for cache/offline if needed.

Step 8:
Remove unnecessary protocols.

Rules:
- no big bang rewrite
- keep behavior
- do not create protocols for every class
- move one boundary at a time
```
