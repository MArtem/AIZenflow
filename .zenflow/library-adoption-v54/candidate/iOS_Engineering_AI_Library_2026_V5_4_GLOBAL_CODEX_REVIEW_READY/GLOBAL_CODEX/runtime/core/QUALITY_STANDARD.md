# Единый стандарт качества iOS-кода

Этот документ обязателен для всех skills/prompts библиотеки. Если локальный skill не переопределяет правило явно, действует этот стандарт.

## 1. Correctness first
- Не выдумывать API, типы, атрибуты, availability или поведение SDK. Если есть сомнение — обозначить его и проверить по доступной документации/SDK.
- Код должен компилироваться в заявленной конфигурации проекта. Не оставлять псевдокод в production-решении без явной маркировки.
- Сохранять существующие инварианты, публичные контракты и пользовательское поведение, если задача не требует их изменения.
- Учитывать minimum deployment target и делать availability-gating для новых API.

## 2. Swift и типобезопасность
- Предпочитать value semantics, immutable state и узкие типы.
- Избегать `Any`, stringly-typed контрактов, force-cast/force-unwrap и неявных предположений. Допускать их только при доказанном инварианте и документировать причину.
- Использовать expressive enums, Result/throws, generics/protocols там, где они уменьшают количество недопустимых состояний, а не ради абстракции.
- Соблюдать Swift API Design Guidelines и единообразное именование.

## 3. Swift 6 concurrency safety
- По умолчанию проектировать код так, чтобы он проходил strict concurrency checking в Swift 6 language mode.
- Явно определять actor isolation и владельца mutable state. Не использовать `@unchecked Sendable` как способ скрыть проблему; каждое применение требует доказанного инварианта.
- Учитывать cancellation, structured concurrency, task lifetime, priority inheritance и reentrancy.
- Не создавать `Task.detached` без конкретной причины. Не использовать continuation там, где есть native async API; checked continuation должен resume ровно один раз.
- UI-state и UIKit/SwiftUI interaction — с корректной MainActor isolation.

## 4. Ownership, ARC, memory
- Проверять retain cycles: closures, delegates, timers, NotificationCenter, Combine/AsyncSequence, tasks, coordinators, cached objects.
- `weak`/`unowned` выбирать по реальному lifetime-инварианту. `unowned` — только когда lifetime гарантирован.
- Не держать тяжёлые объекты, изображения, декодированные буферы и сетевые payload дольше необходимого.

## 5. Архитектура
- Не навязывать MVVM/Clean/VIPER/TCA или иной паттерн без причин. Архитектура должна соответствовать размеру команды, сложности feature, тестируемости и существующему проекту.
- Dependency direction должен быть явным. Feature не должен знать лишнее о concrete infrastructure.
- Не создавать слой/протокол/репозиторий/фасад, если он не уменьшает связность, не даёт test seam и не защищает контракт.
- Feature boundaries должны быть понятны из структуры модулей и зависимостей.

## 6. SwiftUI/UIKit
- В SwiftUI источник истины должен быть единственным и владение состоянием — очевидным. Современная Observation-модель предпочтительна там, где доступна и подходит deployment target.
- Не лечить неправильную модель данных множеством `onChange`, `id`, manual refresh и глобальных observable singletons.
- UIKit: корректный lifecycle, containment, appearance forwarding, diffable data source/modern collection APIs, безопасная работа с Auto Layout.
- Любой bridge SwiftUI↔UIKit должен иметь ясный ownership и lifecycle.

## 7. Ошибки и UX
- Ошибки делить на recoverable/non-recoverable и user-facing/internal. Не терять первопричину.
- Не показывать пользователю технические тексты ошибок. Для retry/idempotency учитывать семантику операции.
- Loading/empty/error/success/offline состояния должны быть определены для асинхронных экранов.

## 8. Тестирование
- Новая бизнес-логика должна иметь unit tests; интеграционные границы — integration tests; критические пользовательские пути — UI tests.
- Предпочитать Swift Testing для новых unit/integration тестов, сохраняя XCTest/XCUI там, где он нужен или уже является стандартом проекта.
- Тесты должны быть deterministic, независимыми от порядка, часового пояса, локали, реальной сети и wall-clock без явного контроля.
- Проверять happy path, edge cases, cancellation, retries, serialization, race-prone paths и error mapping.

## 9. Performance
- Не оптимизировать вслепую. Сначала измерение: Instruments, signposts, MetricKit/production metrics, memory graph, allocations, Time Profiler.
- Учитывать launch time, scrolling hitching, main-thread stalls, image decoding, database fetch size, network payload, battery/thermal impact.
- Избегать N+1, repeated work в `body`, лишней invalidation и тяжёлых synchronous операций на main actor.

## 10. Security & privacy
- Секреты не хранить в source code/UserDefaults/plain files. Использовать Keychain/Secure Enclave подходяще задаче.
- Не логировать access tokens, refresh tokens, PII, платежные данные и чувствительные payload.
- Валидировать server trust/security решения осторожно; не отключать ATS/verification ради "починки".
- PrivacyInfo.xcprivacy, collected data, tracking, required-reason APIs и third-party SDK privacy должны рассматриваться как часть Definition of Done.
- Минимизировать данные и разрешения; permission запрашивать в момент ценности для пользователя.

## 11. Accessibility, localization, internationalization
- VoiceOver, Dynamic Type, contrast, Reduce Motion, accessibility labels/values/actions и focus order — не "полировка", а часть функциональности.
- UI не должен зависеть от фиксированной длины текста. Поддерживать pluralization, RTL, locale-aware dates/numbers/currency.

## 12. Observability
- Использовать структурированное логирование с subsystem/category и privacy modifiers.
- Для значимых интервалов — signposts. Для production quality — crash diagnostics, MetricKit/telemetry в рамках privacy policy.
- Логи должны помогать восстановить state transition, но не раскрывать чувствительные данные.

## 13. Dependencies & supply chain
- Новая dependency требует обоснования: maintenance, license, privacy manifest, binary size, transitive deps, concurrency readiness, platform support.
- Предпочитать системные SDK и Swift Package Manager, если это снижает риск и сложность.
- Версии зависимостей фиксировать предсказуемо; обновления проверять CI и regression tests.

## 14. Reviewability
- Делать минимальный осмысленный diff. Не смешивать feature, массовое форматирование и unrelated refactor.
- В ответе агента указывать: что изменено, почему, риски, как проверено, что осталось непроверенным.
- Не подавлять warnings, lints или tests без объяснения причины.

## 15. Definition of Done
Решение готово только если: корректно компилируется, проходит релевантные тесты, не ухудшает concurrency/memory/security/privacy/accessibility, учитывает availability, имеет наблюдаемость для критических путей и не добавляет неоправданную сложность.
