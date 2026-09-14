# Repository Inspection Protocol

Цель — заставить coding agent понять реальный проект до генерации кода.

## Шаг 1. Карта репозитория
Найди:
- `.xcworkspace`, `.xcodeproj`, `Package.swift`;
- app/framework/extension/test targets;
- schemes и CI entry points;
- `project.yml`, `Tuist`, `Package.swift`, CocoaPods/Cartfile при наличии;
- lint/format/build scripts;
- `AGENTS.md`, contributing docs, architecture ADRs.

## Шаг 2. Toolchain и platform contract
Определи:
- Swift language version;
- Xcode/SDK pinning;
- iOS/iPadOS/watchOS/visionOS/macOS deployment targets;
- strict concurrency settings/upcoming features;
- warnings-as-errors, sanitizers, test plans.

## Шаг 3. Найди «локальный пример»
Для любой новой сущности сначала ищи 1–3 существующих аналога:
- screen/view model/feature;
- endpoint/auth flow;
- persistence model/migration;
- background task;
- dependency injection;
- test fixture.

Локальная consistency предпочтительнее абстрактного «best practice», пока она не нарушает correctness/security.

## Шаг 4. Source-of-truth map
Для затронутой feature нарисуй текстовую цепочку:
`Input/Event → Owner of mutable state → Transformation/effect → Persistence/network → UI/output`.

Отметь:
- кто мутирует state;
- actor/thread boundary;
- lifetime;
- cancellation owner;
- error mapping;
- caching/invalidation.

## Шаг 5. Dependency map
Найди прямые и обратные зависимости изменяемого типа/API. Для public/shared API обязательно ищи:
- all call sites;
- conformances;
- mocks/fakes;
- Objective-C exposure;
- extensions/widgets/watch/App Clip;
- serialization/storage coupling.

## Шаг 6. Test map
Определи:
- ближайшие unit/integration/UI tests;
- test doubles;
- fixtures;
- clocks/random/UUID abstractions;
- CI test plan;
- flaky/quarantined tests.

## Шаг 7. Operational map
Проверь:
- logs/signposts/metrics;
- crash SDK;
- analytics/feature flags;
- rollout/kill switch;
- migration telemetry.

## Anti-patterns
- начать писать новый `Service` до поиска существующего;
- считать имя папки архитектурным контрактом;
- рефакторить соседний код «заодно»;
- копировать паттерн из другого проекта, игнорируя текущий deployment target;
- ориентироваться только на один файл, не читая consumer/producer boundary.
