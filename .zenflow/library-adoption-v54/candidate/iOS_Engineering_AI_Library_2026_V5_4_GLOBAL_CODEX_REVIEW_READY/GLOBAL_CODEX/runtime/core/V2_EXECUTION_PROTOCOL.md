# V2 Execution Protocol — iOS Coding Agent

Этот протокол превращает skill из справочного текста в воспроизводимый инженерный процесс. Он обязателен для V2 playbooks и рекомендуется для любого skill из V1.

## 0. Выбери режим
Перед началом явно выбери один основной режим:

- `IMPLEMENTATION` — добавить или изменить поведение.
- `REVIEW` — найти реальные дефекты/риски в diff и surrounding code без style-noise.
- `DIAGNOSTIC` — локализовать причину crash/race/hang/leak/data loss/performance regression.
- `MIGRATION` — изменить технологию/языковой режим/API с контролем совместимости и rollback.

Дополнительный режим допускается только если он естественно следует из основного, например `DIAGNOSTIC → IMPLEMENTATION` после доказанной root cause.

## 1. Fact pass — до решений
Не проектируй по предположениям, если репозиторий доступен. Собери минимум:

1. Xcode/SDK и Swift language mode.
2. Minimum deployment targets всех затронутых targets.
3. Workspace/project, schemes, build configurations.
4. UI stack: SwiftUI/UIKit/bridge.
5. State ownership и actor isolation.
6. Архитектурный паттерн и локальные conventions.
7. Dependency graph и SPM/CocoaPods/binary SDKs.
8. Test stack и команды CI.
9. Persistence/network/auth boundaries.
10. Feature flags, analytics, observability, release constraints.

### Правило доказательства
Факт должен быть одним из:
- найден в коде/настройках;
- подтверждён build/test/tool output;
- дан пользователем;
- помечен как предположение.

Не превращай предположение в факт в следующих шагах.

## 2. Change-risk classification
Классифицируй изменение:

- **R0 — local mechanical:** rename/local formatting/non-behavioral cleanup.
- **R1 — isolated behavior:** локальная бизнес-логика, небольшой UI state.
- **R2 — boundary:** networking, persistence, auth, navigation, public API, concurrency boundary.
- **R3 — systemic:** migration, shared architecture, data model, security, release pipeline, large concurrency change.
- **R4 — irreversible/high-impact:** destructive migration, payment/auth/security model, public SDK ABI/API, user-data loss risk.

Чем выше риск, тем больше evidence и rollback обязан предоставить агент.

## 3. Invariant sheet
До кода зафиксируй 3–10 инвариантов. Примеры:
- один refresh token request одновременно;
- UI state меняется на MainActor;
- cancellation не превращается в user-visible error;
- persisted schema остаётся читаемой предыдущей версией, если нужен downgrade;
- navigation path содержит только стабильные route values;
- секреты не попадают в logs.

Если невозможно назвать инварианты, задача ещё недостаточно понята.

## 4. Blast-radius pass
До изменения boundary/public contract найди:
- call sites;
- mocks/test doubles;
- serialization contracts;
- deep links/routes;
- persistence schema;
- feature flags;
- analytics/event names;
- availability shims;
- extension/app clip/widget/watch targets.

Не считай отсутствие compile errors доказательством отсутствия semantic blast radius.

## 5. Design pass
Для R2+ сравни минимум два варианта по:
- correctness;
- complexity;
- migration cost;
- testability;
- concurrency/ownership;
- performance;
- security/privacy;
- rollback/operability.

Выбирай минимально сложный вариант, который защищает инварианты.

## 6. Implementation pass
- Делай маленькие логические изменения.
- Не смешивай unrelated refactor.
- Не расширяй public API без причины.
- Не вводи protocol/repository/manager только ради абстракции.
- Не подавляй compiler warning как substitute for design fix.
- Для async кода проектируй cancellation и task lifetime до написания `Task {}`.
- Для persisted data сначала migration story, затем model change.

## 7. Verification ladder
Минимум проверок определяется риском:

### R0
- compile relevant target или local static validation.

### R1
- targeted unit tests;
- build relevant target;
- happy + key edge path.

### R2
- targeted + integration tests;
- strict concurrency/build warnings;
- failure/cancellation path;
- boundary compatibility;
- relevant privacy/security/perf checks.

### R3/R4
- regression suite;
- migration/rollback test;
- representative device/config matrix;
- observability/feature flag/staged rollout plan;
- explicit unchecked-risk list.

## 8. Evidence ledger
Финальный ответ обязан разделять:

### Verified
То, что реально подтверждено build/test/log/tool output.

### Reasoned
То, что следует из inspection/design, но не было исполнено.

### Unknown
То, чего агент не смог проверить.

Запрещены формулировки «готово», «безопасно», «race-free», «не течёт», если это не подтверждено достаточным evidence.

## 9. Stop conditions
Остановись и не делай destructive step, если:
- непонятно, какой store/schema является production source of truth;
- migration необратима и нет backup/rollback;
- auth/payment/security контракт не подтверждён;
- public API/ABI impact неизвестен;
- предлагается отключить ATS/cert validation/privacy checks;
- единственное решение требует `@unchecked Sendable` без доказуемого invariant;
- production defect не воспроизводится, а fix основан только на догадке.

Вместо blind change создай diagnostic instrumentation или narrow experiment.

## 10. Output contract
Всегда возвращай:
1. `Mode / risk class`.
2. `Facts and assumptions`.
3. `Invariants`.
4. `Decision and alternatives`.
5. `Changed files / exact scope`.
6. `Verification evidence`.
7. `Concurrency / memory / security / privacy / performance impact`.
8. `Rollback or containment`, если R2+.
9. `Unknowns / follow-ups`.
