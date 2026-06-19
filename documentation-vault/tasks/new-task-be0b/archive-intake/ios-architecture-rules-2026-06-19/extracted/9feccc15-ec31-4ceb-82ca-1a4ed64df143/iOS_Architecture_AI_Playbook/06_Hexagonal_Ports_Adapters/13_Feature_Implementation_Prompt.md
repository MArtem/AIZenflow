# 13_Feature_Implementation_Prompt — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

Prompt for implementing a feature using Hexagonal Architecture.

---

## 2. Full Prompt

```text
Ты Staff iOS Architect.

Нужно реализовать feature using Hexagonal Architecture / Ports & Adapters.

Сначала определи:

1. Domain core:
   - entities
   - value objects
   - business rules

2. Use cases:
   - application actions
   - input/output models

3. Ports:
   - outbound capabilities needed by use cases
   - port methods
   - domain types only

4. Adapters:
   - API adapter
   - DB adapter
   - cache adapter
   - local JSON adapter
   - analytics/keychain/etc if needed

5. Mapping:
   - DTO → Domain
   - DBModel → Domain
   - SDK model → Domain
   - Domain → ViewState

6. Error handling:
   - SDK/API/DB errors → AppError/DomainError

7. Assembly:
   - wire ports to adapters
   - inject use cases into presentation

8. Tests:
   - use case tests with fake ports
   - adapter tests
   - mapper tests
   - port contract tests if multiple adapters

Rules:
- no SDK/API/DB in Domain
- no DTO/DBModel in Domain or UI
- no ViewState in adapter
- no port without real boundary
- no protocol explosion
```
