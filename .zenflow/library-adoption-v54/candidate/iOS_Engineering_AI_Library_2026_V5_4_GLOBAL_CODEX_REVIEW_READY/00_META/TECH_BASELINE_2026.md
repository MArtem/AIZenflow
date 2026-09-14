# Технологический baseline библиотеки — сентябрь 2026

Библиотека ориентирована на современный production iOS и не привязана жёстко к одному minimum deployment target.

## Язык и toolchain
- Основная модель: Swift 6 language mode и strict concurrency checking.
- Актуальный стабильный release Swift на 2026-09-08 — Swift 6.3 (released 2026-03-24). Swift 6.4 является upcoming/development-snapshot линией; её возможности нельзя считать production baseline до фактического релиза/toolchain adoption проекта.
- Swift Package Manager и современный Swift Build workflow — базовый путь модульности и зависимостей, если проект не требует иного.

## UI и state
- SwiftUI — основной современный декларативный UI-инструмент, но UIKit остаётся полноценным production framework и часто нужен для legacy, сложных UIKit-компонентов, custom transitions, точечного контроля и постепенных миграций.
- SwiftUI архитектурно нейтрален: выбирай MVVM, unidirectional flow, feature model, Clean-like boundaries или локальную модель на основании сложности, а не догмы.
- Observation (`@Observable`, современный State/Environment data flow) предпочтительна там, где подходит platform availability и существующая архитектура.

## Concurrency
- Actors, Sendable, structured concurrency, cancellation, actor isolation и data-race freedom — часть дизайна API, а не только способ "убрать compiler errors".

## Tests
- Swift Testing — предпочтительный новый инструмент для unit/integration tests; XCTest сохраняется для существующих suites, отдельных performance scenarios и XCUIAutomation/UI testing.

## Persistence / networking
- SwiftData — современный declarative persistence вариант, но Core Data остаётся правильным выбором для зрелых кодовых баз и сценариев, где его возможности/миграции уже доказаны.
- URLSession async/await остаётся базовым networking foundation. Дополнительная библиотека должна оправдывать свой вес.

## Performance / production diagnostics
- Instruments, OSSignposter/signposts, MetricKit, structured OSLog и crash diagnostics являются частью performance/observability workflow.

## Privacy / security
- Privacy manifests и Required Reason APIs — обязательная часть поставки для затрагиваемых API/SDK.
- Permission minimization, Keychain, App Attest/DeviceCheck-класс механизмов, CryptoKit и безопасная аутентификация выбираются по threat model.

## Apple Intelligence / on-device AI
- App Intents используется для системной discoverability и интеграции с Siri/Shortcuts/Spotlight/Apple Intelligence.
- Foundation Models относится к современному стеку AI-функций; в iOS 27-era SDK Apple расширяет model abstraction, Private Cloud Compute, dynamic profiles, multimodal/tool workflows, Evaluations и Instruments. Эти APIs необходимо availability-gate и повторно сверять с final SDK.
- Core AI — новый WWDC26 framework для запуска собственных on-device моделей на Apple silicon с memory-safe Swift API, model specialization/caching, ahead-of-time compilation и CPU/GPU/Neural Engine execution. На 2026-09-08 Apple documentation помечает Core AI как **Beta**, поэтому библиотека запрещает считать его безусловным production baseline до final SDK.

## Главный принцип
Новый API не является автоматически лучшим. Лучший выбор — тот, который минимизирует риск и сложность при соблюдении correctness, maintainability, performance, privacy и пользовательского качества.
