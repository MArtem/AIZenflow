---
id: IOS-12-03
type: skill
title: Authentication flow
domain: Security & Privacy
priority: production
baseline: Swift 6 / modern iOS
---

# Authentication flow

## Назначение
OAuth/OIDC/PKCE/passkeys/system web auth, token lifecycle, logout, account switching и session fixation risks.

## Когда применять
- При реализации новой функциональности в этой области.
- При code review/refactor/migration, если затронут соответствующий риск.
- При расследовании production-дефекта, связанного с этой областью.

## Обязательные входы
- Relevant project context из `00_META/PROJECT_CONTEXT_TEMPLATE.md`.
- Затронутые файлы/модули и соседние реализации.
- Minimum deployment target и фактический toolchain.
- Acceptance criteria и ограничения на public API/dependencies/migration.

## Алгоритм skill
1. Найди существующий паттерн в репозитории и определи владельца state/lifecycle.
2. Зафиксируй инварианты и failure modes именно для задачи: **OAuth/OIDC/PKCE/passkeys/system web auth, token lifecycle, logout, account switching и session fixation risks**.
3. Сравни минимально два варианта, если решение затрагивает architecture/public contract или добавляет dependency.
4. Реализуй минимальный diff, следуя `00_META/QUALITY_STANDARD.md`.
5. Проверь тематические quality gates: threat model, least privilege, secret handling, PII/logging, privacy manifest, abuse cases.
6. Добавь тесты/diagnostics пропорционально риску.
7. Запусти доступные build/test/lint проверки и отдели проверенное от предположений.

## Anti-patterns
- Подмена design-проблемы suppression, force unwrap, global mutable state или "временным" unchecked escape hatch.
- Создание нового слоя/manager/protocol без измеримой пользы для coupling/testability.
- Изменение unrelated кода и массовое форматирование в том же diff.
- Утверждение о корректности без build/tests/measurement, когда их можно выполнить.

## Готовый prompt
```text
Ты работаешь как Staff iOS engineer. Примени skill IOS-12-03: «Authentication flow».

Контекст проекта: <вставь PROJECT_CONTEXT>.
Задача: <что должно наблюдаемо измениться>.
Ограничения: <deployment target, public API, dependencies, migration, performance>.

Перед кодом изучи существующую реализацию и аналоги в репозитории. Назови source of truth/lifetime/dependency boundaries и ключевые инварианты.
Особый фокус: OAuth/OIDC/PKCE/passkeys/system web auth, token lifecycle, logout, account switching и session fixation risks.
Проверь: threat model, least privilege, secret handling, PII/logging, privacy manifest, abuse cases.
Следуй `QUALITY_STANDARD.md`, сохраняй минимальный diff и не вводи abstraction без причины.
Добавь/обнови релевантные тесты и выполни доступные build/test/lint проверки.

В ответе дай:
1) решение и почему оно минимально рискованное;
2) изменения по файлам;
3) tests/verification;
4) concurrency/memory/security/privacy/performance impact, если применимо;
5) риски и что осталось непроверенным.
```

## Definition of success
Решение сохраняет инварианты проекта, проходит релевантные проверки и не создаёт новый скрытый lifecycle/concurrency/security/performance долг.

## V2 operational binding
Перед выполнением этого skill прочитай `00_META/V2_EXECUTION_PROTOCOL.md` и выбери режим `IMPLEMENTATION`, `REVIEW`, `DIAGNOSTIC` или `MIGRATION`. Для задач риска R2+ также применяй `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`, `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md` и `00_META/CHANGE_RISK_MATRIX.md`.

Глубокая operational-версия этого skill: `31_DEEP_PLAYBOOKS/OP-IOS-12-03.md`. Она задаёт обязательные факты, инварианты, режимы исполнения, failure modes и verification ladder.

## Review-ready depth — authentication boundary

**Scenario.** Credentials/tokens are stored locally and used across login, refresh, logout, and server-challenge paths.

**Common wrong approach.** Treat encrypted-at-rest storage as the whole authentication design, or log bearer/refresh material for debugging.

**Preferred approach.** Minimize retained secrets, use platform credential storage appropriate to the threat model, separate identity/session state from transport challenge handling, invalidate credentials deterministically on logout/revocation, and keep telemetry free of secret-bearing payloads.

**Traps / edge cases.** Concurrent login/logout, refresh-token rotation, account switching, keychain accessibility class, device restore/migration behavior, server trust challenges, deep-link callback spoofing, and stale async completions.

**Verification.** Test credential lifecycle transitions, duplicate refresh suppression, logout races, storage/access-control behavior on representative devices, and log/analytics redaction with synthetic secrets.

Primary sources checked 2026-09-10: https://developer.apple.com/documentation/security/keychain-services and https://developer.apple.com/documentation/authenticationservices. These sources cover platform credential storage and authentication APIs; backend authorization, refresh rotation, logout semantics, and account isolation remain application-contract evidence.

**Compatibility.** Authentication changes must preserve the deployed platform range, entitlements, redirect/callback contract, credential storage accessibility, and backend protocol. Prefer platform APIs available to the target; availability-gate newer APIs rather than weakening the existing flow.
