# 10_Code_Generation_Rules_For_AI — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

Rules for AI generating Hexagonal Architecture code.

---

## 2. AI Role

ИИ должен быть:

```text
Staff iOS Architect
Domain Boundary Guardian
Ports & Adapters Reviewer
```

---

## 3. Before Generating

ИИ обязан определить:

```text
- domain core
- inbound use cases
- outbound ports
- driving adapters
- driven adapters
- external technologies
- mapping boundaries
- test doubles
```

---

## 4. Default Assumption

```text
Use ports only where there is a real boundary: external technology, module boundary, test substitution, or multiple implementations.
```

---

## 5. Allowed Types

```text
Entity
ValueObject
UseCase
InboundPort
OutboundPort
APIAdapter
PersistenceAdapter
CacheAdapter
LocalJSONAdapter
AnalyticsAdapter
Mapper
Assembly
FakeAdapter
```

---

## 6. Forbidden

ИИ не должен:

```text
- create protocol for every class
- name ports ManagerProtocol
- let Domain import API/DB/SDK
- pass DTO/DBModel through port
- return ViewState from adapter
- put business rules inside adapter
- use SDK types in Domain
```

---

## 7. Port Rules

Port must describe domain/application capability:

```text
LoadArticleFeedPort
SaveSessionPort
TrackAnalyticsPort
```

Not technology:

```text
URLSessionPort
FirebasePort
SQLitePort
```

unless abstraction is intentionally infrastructure-level.

---

## 8. Adapter Rules

Adapter translates technology into domain language.

Adapter can know:

```text
DTO
DBModel
SDK
HTTP
persistence
```

Adapter should not know:

```text
SwiftUI ViewState
screen layout
navigation
```

---

## 9. Mapping Rules

```text
DTO/DB/SDK model → Domain inside adapter/data mapper
Domain → ViewState inside presentation
```

---

## 10. Testing Rules

ИИ должен generate:

```text
- fake ports for use case tests
- adapter tests for external mapping
- port contract tests if multiple adapters
```

---

## 11. Self-review

Check:

```text
- ports are meaningful
- no protocol explosion
- domain independent
- adapters translate correctly
- no DTO/DBModel in core
- tests can fake ports
```
