---
id: IOS-12-12
type: skill
title: Security review
domain: Security & Privacy
priority: production
baseline: Swift 6 / modern iOS
---

# Security review

## Назначение
Threat-driven audit auth/storage/network/webviews/deeplinks/logging/privacy/permissions.

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
2. Зафиксируй инварианты и failure modes именно для задачи: **threat-driven audit auth/storage/network/webviews/deeplinks/logging/privacy/permissions**.
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
Ты работаешь как Staff iOS engineer. Примени skill IOS-12-12: «Security review».

Контекст проекта: <вставь PROJECT_CONTEXT>.
Задача: <что должно наблюдаемо измениться>.
Ограничения: <deployment target, public API, dependencies, migration, performance>.

Перед кодом изучи существующую реализацию и аналоги в репозитории. Назови source of truth/lifetime/dependency boundaries и ключевые инварианты.
Особый фокус: threat-driven audit auth/storage/network/webviews/deeplinks/logging/privacy/permissions.
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

Глубокая operational-версия этого skill: `31_DEEP_PLAYBOOKS/OP-IOS-12-12.md`. Она задаёт обязательные факты, инварианты, режимы исполнения, failure modes и verification ladder.

## Review-ready depth — threat-driven security/privacy review

**Scenario.** A feature adds authentication, credential storage, network calls, deep links, analytics, or a third-party SDK and is described as "secure" because it uses HTTPS or Keychain somewhere in the implementation.

**Common wrong approach.** Review security as an API checklist instead of tracing assets, trust boundaries, attacker-controlled inputs, retention/logging, authorization decisions, and failure/recovery paths. A secure storage API does not fix over-broad access, secret logging, server-side authorization gaps, or unsafe deep-link routing.

**Preferred approach.** Start from assets and abuse cases. Trace secret/PII creation, transit, persistence, logging, deletion, and backup/synchronization behavior. Separate authentication from authorization, minimize credential lifetime and access, use platform security primitives with explicit access-control requirements, validate untrusted routing/input at the boundary, and review privacy-manifest/required-reason implications for app and SDK code.

**Traps / edge cases.** Tokens in URLs/headers/logs/crash metadata; refresh races; revoked credentials retained in caches; permissive Keychain accessibility; test/debug logging enabled in release; redirect/deep-link confusion; third-party SDK data collection; certificate-challenge code that weakens default trust evaluation; secrets copied into generated diagnostics or AI/task context.

**Verification.** Use synthetic credentials and abuse-case tests. Inspect release logging/telemetry, credential lifecycle and logout/revocation behavior, Keychain attributes/entitlements, network trust handling, deep-link rejection cases, dependency privacy manifests, and current App Store privacy requirements. Record what was inspected versus what was runtime-tested.

**Compatibility.** Keychain access groups, AuthenticationServices capabilities, privacy requirements, and required-reason APIs vary with target/platform/policy. Re-check the shipping SDK and current submission requirements rather than treating this document as a permanent policy snapshot.

Primary sources checked 2026-09-11: https://developer.apple.com/documentation/security/keychain-services, https://developer.apple.com/documentation/security/restricting-keychain-item-accessibility, https://developer.apple.com/documentation/authenticationservices, and https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk. Platform pages do not replace current App Store policy review or project-specific threat evidence; re-check both for each release.
