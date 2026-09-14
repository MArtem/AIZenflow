# Skill Router — что подключать к задаче

Используй `MASTER_SYSTEM_PROMPT` + project context + **один основной skill**. Добавляй второй только для реального пересечения рисков.

## Маршрутизация
- **Новая feature** → Discovery/Product → Architecture/State → конкретная технология → Testing.
- **Crash** → Crash triage → тематический skill → regression test.
- **Race / Swift 6 errors** → Strict Concurrency Migration → Actor Isolation/Sendable/Task Lifetime.
- **Memory leak** → Leak Diagnosis → UIKit/SwiftUI/task ownership skill по месту.
- **Медленный UI** → Instruments Plan → Scrolling/SwiftUI list/image pipeline → Performance Gate.
- **API/network** → HTTP Client → Auth Refresh/Retry/Pagination/Cache по необходимости.
- **Offline/data loss** → Offline-first/Data Migrations/Persistence Concurrency.
- **Security** → Threat Model → конкретная граница (Auth/Keychain/WebView/Deep Link/Privacy Manifest).
- **SwiftUI** → State Ownership/Observation/View Identity; Navigation/Async UI по задаче.
- **UIKit** → Lifecycle/Containment/Layout/Concurrency/Memory.
- **Release** → CI/CD + Release Gate + Security/Privacy + Data Migration Gate при изменении store.
- **AI feature** → Foundation Models/Core AI → Evaluation → Privacy → Abuse/Tool Calling.
- **Hardware/media** → соответствующий Media/System skill + lifecycle/permission/performance checks.
- **Legacy migration** → Migration skill + compatibility tests + staged rollout/rollback.
- **PR review** → General Code Review + один тематический review (Concurrency/Security/SwiftUI/Performance).

## Не делай
Не подключай 10–20 skills одновременно: модель начинает выполнять конфликтующие локальные инструкции и хуже замечает реальные инварианты проекта.
