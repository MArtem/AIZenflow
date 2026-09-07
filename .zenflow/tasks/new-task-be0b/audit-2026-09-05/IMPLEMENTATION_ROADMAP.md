# План внедрения после аудита

Версия: 2026-09-07. Статус: план подготовки с четырьмя принятыми пользователем улучшениями. Этот документ не активирует новые правила, engine gates, тесты, CI, исключения или распространение на приложения.

Реального продуктового проекта пока нет. Текущие приложения — пробные consumers. Основной результат подготовки — применимая общая система для будущих проектов; продуктовые требования, архитектура и функции будущего приложения здесь не выдумываются. Проверка нового проекта использует нейтральный учебный репозиторий, а не заготовку продукта.

## Приоритет и модель работы

Цель — меньше реальных ошибок до релиза, более точные проверки, меньше повторного контекста и ручного разбора. Оптимизация стоимости допускается при сохранении критериев приёмки. Экономия за счёт пропуска нужного evidence не допускается.

**Новое обязательное ограничение пользователя:** каждый пункт этого плана, включая проектирование, реализацию, независимое ревью, калибровку и итоговый аудит, выполняется только на **GPT-5.6 Luna, reasoning xhigh**. Ранее предложенные Sol/Terra/Astra для внедрения отменены. Исходный аудит и его завершающее независимое ревью выполняются на Astra по отдельному уточнению пользователя. Это не меняет модель будущих этапов внедрения: Luna xhigh.

Качество сохраняется через размер блока, явные контракты, проверяемые результаты и отдельное ревью. Заранее гарантировать равенство результатов разных моделей нельзя. При неоднозначности Luna собирает evidence и формулирует конкретное решение пользователя; модель не переключается и требования не снижаются. Не повторять один неуспешный подход более двух раз без пересмотра гипотезы.

Обязательная инструкция исполнения: `LUNA_EXECUTION_GUIDE.md`. Она задаёт входные документы, микрошаги для всех 30 блоков, форму implementation packet, правила review и остановки. Все упоминания «reviewer» ниже означают отдельный проход на Luna xhigh; новая задача/субагент создаётся только если это разрешено текущими инструкциями среды и пользователем. При отсутствии независимого контекста выполнить отложенный self-review и честно обозначить его ограничение; обязательный independent gate этим не закрывается.

## Последовательность

| Этап | Содержание | Основная модель | Зависимости | Относительный объём |
| --- | --- | --- | --- | --- |
| 0 | Authority, current state, ранние измерения и сценарии | Luna xhigh | аудит | S/M |
| 1 | Единый словарь правил, severity, exceptions | Luna xhigh | 0 | M |
| 2 | Нормализация architecture/prompts/skills | Luna xhigh | 1 | L, несколькими блоками |
| 3 | Toolchain-aware iOS baseline | Luna xhigh | 1–2 | M |
| 4 | Доставка правил и нейтральный new-project сценарий | Luna xhigh | 4.1–4.2: 1; 4.3: 0.4, 2–3, 4.1–4.2 | M |
| 5 | Точность существующих QC adapters | Luna xhigh | 1, 3 | L, по одному контракту |
| 6 | Недостающие gates H | Luna xhigh | 5 | M |
| 7 | Canary и раздельная оценка генерации/обнаружения ошибок | Luna xhigh | 7.1: 5–6; 7.2: 0.3–0.4, 2–3, 7.1; разрешённые проверки | M |
| 8 | Два app pilots и отдельная готовность подготовки | Luna xhigh | 8.1–8.2: 4, 7; 8.3: 1–7, без обязательного завершения 8.1–8.2 | L |
| 9 | Версионированное распространение | Luna xhigh | 8 | M |
| 10 | Итоговая оптимизация по измерениям Luna с этапа 0 | Luna xhigh | 0.3, 2, 4, 7.2, доступные результаты 8 | S/M |
| 11 | Итоговая проверка и поддержка | Luna xhigh | 9–10 | S + периодическая работа |

S/M/L — размер относительно других блоков, не оценка токенов или часов. Проценты подписки заранее не обещаются. Пилоты дают фактическую стоимость.

## Этап 0. Одна актуальная точка продолжения

### 0.1 — Принять карту владельцев и границы внедрения

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** закрепить Documentation / QualityControl / apps / tasks как четыре разных владельца. Разделить распространение глобальных инженерных правил и подключение engine. Сохранить ручные CI/Codex Review, test permissions, zero-spend и отложенную branch protection. Явно отметить новый план как proposed до начала реализации.

**Файлы:** `tasks/new-task-be0b/universal-quality-control-plan.md`, task plan/handoff; ссылки на `UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md`, `DOCUMENT_BOUNDARY_STANDARD.md`, `SOURCE_OF_TRUTH_MAP.md`. Старый план архивировать целиком с SHA, не стирать историю и прежние ограничения.

**Приёмка:** один current status; прежние Stage 6/H/I/J не противоречат свежему checkout; app source blockers не выглядят свежим результатом. Любой следующий агент понимает, что разрешено сейчас.

**Откат:** вернуть прежний operational index; архив и результаты аудита не удалять.

### 0.2 — Установить проверяемый baseline evidence

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** перед первой реализацией сверить актуальные HEADs и dirty state с зафиксированными в аудите; читать только изменившиеся с тех пор правила. Сохранить baseline receipts/check results. Не использовать старый checkout QC как main.

**Приёмка:** точные base/head, engine/profile/policy revisions и права перечислены; user edits сохранены. Устаревший result помечен stale, не PASS.

**Откат:** не требуется для read-only фиксации.

### 0.3 — Ранний baseline работы Luna

**Модель:** GPT-5.6 Luna xhigh. **Входы:** 0.2, context-cost.json, первые разрешённые блоки 1–2. **Зависимость:** 0.2; сбор начинается до реализации 1.1 и продолжается по мере работы.

**Изменение:** одна компактная таблица в task evidence: task ID/class, source/policy revision, context packet, размер diff, исходный результат, пропуски P1/P2, reviewer corrections, лишние чтения, обращения к пользователю и причина, elapsed/usage при доступности. Unknown usage не ноль; words не billed tokens. Отличать полезное продуктовое уточнение от вопроса из-за неполной инструкции.

**Приёмка:** схема записи готова до первого patch; observations собираются без повторного решения завершённых задач. Повторяющаяся ошибка Luna приводит к уточнению конкретного packet/контракта до следующего сходного блока. Само измерение не задерживает работу ожиданием статистики.

**Откат:** убрать неиспользуемые поля, сохранив correctness evidence. Не строить telemetry platform. Итоговая оптимизация — 10.2.

### 0.4 — Контракты нейтральных сценариев

**Модель:** GPT-5.6 Luna xhigh. **Входы:** 0.1–0.3 и findings аудита. **Зависимость:** 0.3.

**Изменение:** описать пять общих сценариев: UI state, cancellation/lifetime, recoverable error, data preservation, API boundary. Для каждого — небольшой фиксированный input, инвариант, ожидаемое наблюдаемое поведение, корректный вариант и один намеренный дефект. Это specification, не тестовый код. Критерии фиксируются до просмотра решений Luna: correctness, простота, permissions, обнаружение дефекта и отсутствие false positive.

Часть вариантов отложить как holdout: их не использовать для настройки prompts/gates до 7.2. Answer key доступен только evaluator: ни generator, ни detector не получают truth label, место дефекта, ожидаемый finding или подсказку. Detector получает нейтрально обозначенный вариант и behavioral contract; его findings фиксируются до раскрытия key и scoring. Для слепого detection нужен отдельный разрешённый fresh контекст Luna. Если он уже видел key, результат unblinded и не independent holdout PASS. Та же модель не гарантирует независимость ошибок; self-review отмечается честно.

**Приёмка:** сценарии app-neutral, не требуют функций будущего продукта, имеют однозначный expected outcome. Generation quality и defect detection оцениваются отдельно. Создание/запуск tests и disposable project требуют соответствующей разрешённой фазы.

**Откат:** заменить неоднозначный пример до измерения, сохранив причину. Не подгонять expected outcome под ошибочное решение.

## Этап 1. Единая нормативная модель

### 1.1 — Устранить противоречие authority, severity и readiness

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Находки:** F02, F09, F10, F12. **Файлы:** `AI_iOS_MASTER_PROMPT.md` §0; `ENGINEERING_CHANGE_QUALITY_STANDARD.md`, `DEFINITION_OF_DONE.md`, `IOS_PRODUCTION_FRAMEWORK.md`, `IOS_PRODUCTION_AUDIT_MATRIX.md`, `PRODUCTION_CODE_REVIEW_CHECKLIST.md`, exception standards, `MODEL_ROUTING_RULE.md`.

**Изменение:** определить один словарь impact/confidence/applicability/evidence/decision; document hierarchy согласовать с system/developer. Указать разные verdicts для локальной готовности, merge и release. Таблица обязана объяснять skipped/denied/unavailable/accepted-risk без ложного normal PASS и без превращения ручного CI в обязательный.

Уточнить model routing: явный task override Luna xhigh действует на всё это внедрение и не должен блокироваться устаревшим списком reasoning levels. Не превращать его в глобальный запрет других моделей для несвязанных будущих задач.

**Приёмка:** несколько конкретных сценариев дают однозначный исход: исправление комментария; P2 crash без разрешённого runtime; пользователь не запускал advisory CI; истёкшее exception; локальный scope уже проверен, release ещё нет. Это desk review документов, не запуск тестов.

**Откат:** предшествующая версия нормативного набора; новая версия не распространяется, пока связанные consumers не согласованы.

### 1.2 — Ввести Rule ID и единый exception contract без нового огромного реестра

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** добавить минимальные metadata к активным нормам: ID, owner, scope, MUST/SHOULD, trigger, enforcement/limitations, exception policy, evidence, source date/revisit. Начать с 10–15 реально применяемых правил; не размечать всю историю.

Exception связывает rule version, конкретный app/scope, причину, owner, approver, дату, expiry/revisit, компенсацию и rollback. Draft exception никогда не становится approved по факту записи. Предложить resolution несовместимости universal concurrency ban и generic exception flow, сохранив текущий строгий default до решения пользователя.

**Приёмка:** каждая из выбранных норм имеет один authority; checklist/prompt ссылается на ID, а не создаёт вторую норму. Одобрение локального исключения не меняет новый проект.

**Откат:** удалить ещё не активированный metadata слой, сохранив mapping; не переиспользовать старые IDs с другим смыслом.

## Этап 2. Нормализация разработки и знаний

### 2.1 — Отделить invariant от архитектурного вкуса

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Находки:** F03, F07. **Файлы:** architecture router, UI state standard, MVVM intent standard, bootstrap template, package standards, UI workflow. AI Fieldbook ADR-010 остаётся app-local.

**Изменение:** ownership/state/IO/availability обязательны; ViewModel, Renderer, Coordinator, repository protocol, source-only integration выбираются по profile/current need. Убрать обязательный стек infrastructure для малого приложения. Сохранить explicit intent MVVM; approved reducer architecture не объявлять нарушением.

**Приёмка:** три desk examples проходят без искусственных слоёв: небольшой native SwiftUI screen, существующий MVVM app, сложная multi-target app. Принятые app ADR не ослаблены. Каждый перенесённый product fragment получает известного владельца.

**Откат:** прежняя версия generic standards; app ADR не меняются этим этапом.

### 2.2 — Переписать активные prompts и specialist routes

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Находки:** F08, F11, F14. **Изменение:** нормализовать сами тела, убрать contradictory defaults и обязательные длинные output forms; вместо импорта полного master — точный router. AI master разбить на тематические references со стабильными anchors/IDs, сохранив полный исходник в archive. Исправить его конец с full-read bootstrap и unconditional mock requirement. Figma permissions подчинить текущему разрешённому verification scope.

Skills получают узкие triggers по действию/риску, а не любому упоминанию «API», «file», «review». Пересекающиеся network/API/sync и testing routes выбирают один основной owner + точечные дополнения. Version/provenance глобальных Swift skills фиксируется; upstream text не считается local authority.

**Приёмка:** маленькое исправление не загружает все production/AI domains. Прямое чтение одного prompt не предлагает запрещённые тесты или Action enum. Swift Testing/XCTest выбираются по задаче. Старые exports сохранены как non-authoritative history.

**Откат:** предыдущая active prompt version и routing map; не удалять provenance.

### 2.3 — Нормализовать package/SDK и app snapshots

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** catalog описывает reusable capabilities и версию пакета; active-in-app/adoption/rollback history переносится к реальному app owner. SDK status 5 packages/50 iterations сверить с каталогом 40 roots; не продолжать старую numbered roadmap автоматически. Удалить тестовые квоты и признание URL path заведомо sanitized. Документировать outputs/cache root в verify templates; permission-sensitive команды не исполнять при одном чтении инструкции.

**Приёмка:** нет «source-app» как скрытого владельца продуктовой политики; source-only и SwiftPM paths различимы; package complete/readiness claims привязаны к revision/evidence. Примеры DocC и scripts соответствуют реальной структуре.

**Откат:** reversible moves с mapping; product docs нельзя потерять или сделать глобальными.

## Этап 3. Современная iOS-база

### 3.1 — Toolchain/isolation/availability contract

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** project profile хранит compiler, language mode, SDK, deployment target, targets/extensions, default isolation, upcoming features. Современные нормы привязать к применимости: Swift 6.2 default isolation/@concurrent, Swift 6.3 Testing semantics, Observation, UIKit bridging, iPad adaptability. Не повышать deployment target автоматически и не вводить beta API в stable baseline.

**Приёмка:** async wait и CPU-bound work различены; @MainActor не считается нарушением сам по себе; sync worker API не объявлен UI freeze без контекста; optional strict memory safety не применяется ко всему коду механически. Primary links/date присутствуют.

**Откат:** возврат policy version без изменения app build settings этим doc-only шагом.

### 3.2 — Release/privacy/performance matrices

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** обновить SDK upload floor и distinction deployment target; privacy manifest ↔ actual API/SDK/data use; permission/retention/delete/logout boundaries; measurable launch/interaction/frame/memory budgets. iPad/VoiceOver/Dynamic Type/RTL/keyboard/window matrix из app profile. Core AI и новые Foundation Models capabilities — отдельная experimental availability track.

**Приёмка:** structural manifest PASS не называется App Store compliance; screenshot не считается accessibility/performance proof; 250 ms hang threshold не выдаётся за responsiveness target. Нет автоматически добавленной cloud обработки или инфраструктуры.

**Откат:** policy revision; app capabilities только после отдельной реализации.

## Этап 4. Доставка правил текущим и будущим проектам

### 4.1 — Глобальный bootstrap и effective instruction inventory

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** подготовить минимальный global AGENTS entry для фактической среды Codex, repository bootstrap и portable fallback. Проверить CODEX_HOME, alternate host, repository root vs parent directory, nested AGENTS.override и отсутствующий canonical checkout. Root не должен молча менять unrelated non-iOS projects: общая инженерная база плюс routing по типу проекта.

**Приёмка:** read-only effective-route report для найденных 15 worktrees; отсутствующие entries явно видны. Новый disposable consumer получает правила без напоминания пользователя; offline fallback сообщает revision/stale state. Один marker не считается доказательством всех downstream rules.

**Откат:** сохранить прежний global file; reversible consumer patch; не перезаписывать user overlay.

### 4.2 — Manifest, ссылочная целостность, динамические app boundaries

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** раздельно валидировать canonical source, generated bundle и installed consumer; определить root ссылок. Обнаруживать apps по registry/структуре, а не четырём строкам. Различать exact mirror, intentional overlay, local-only и stale. Generated manifests обновлять единственным generator, не руками.

**Приёмка:** существующие stale/missing/index findings объяснены и исправлены без стирания overlays. Новый app с новым именем попадает в проверки. Known product-semantic leak требует review, даже когда token scan PASS.

**Откат:** старый distribution pin + mapping; canonical source не удалять.

### 4.3 — Сквозной сценарий нового проекта

**Модель:** GPT-5.6 Luna xhigh. **Входы/зависимость:** 0.4, результаты 2–3, 4.1–4.2; позднее 7.2 дополняет оценку качества кода.

**Изменение:** после разрешения на disposable consumer пройти чистый Git root → effective bootstrap → минимальный profile → архитектура по учебному заданию → небольшое изменение → разрешённая проверка → handoff → продолжение в другом разрешённом контексте Luna. Использовать только открытый сценарий 0.4 (не holdout), без backend, платежей, аккаунтов и продуктового backlog. Учебная архитектура не становится default будущего продукта.

**Приёмка:** правила применяются без напоминаний; app-local правила пробных проектов не утекают; следующий исполнитель восстанавливает задачу по routed docs. Missing tool/evidence/permission отражён честно. Static-only проход частичный; compiled/runtime claims требуют разрешённых доказательств. Учебный consumer не заменяет два app pilots для stable QC release.

**Откат:** точный manifest созданных файлов, без затрагивания user paths. Не создавать новый генератор проектов ради одного сценария.

## Этап 5. Исправить точность существующих QC gates

### 5.1 — Scope и source membership

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Находки:** F15. **Файлы:** QC adapter, profile/schema, membership receipt, check catalog, adapter README.

**Изменение:** отличить explicit source list от compiler membership; tracked Swift ≠ shipped Swift. Generated sources, extensions, packages и необычные paths учитываются в контракте. Пустой/unavailable scope получает честный status. Не писать универсальный pbxproj parser без текущей нужды: использовать уже доступный authenticated build graph boundary.

**Приёмка будущей разрешённой test-фазы:** compiled file в папке `Tests` не скрывается; неиспользуемый vault file не считается shipped; symlink/path/oversized/unknown membership не дают normal PASS; target/configuration указаны.

**Откат:** прежний engine pin; проблемный новый gate остаётся advisory/blocked с явной причиной, существующие checks не отключаются.

### 5.2 — Swift patterns и disabled tests

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Находки:** F16–F17. **Изменение:** правильно обработать comments/strings/raw/multiline/interpolation; выделить contextual hot paths и policy bans. Disabled tests различают unconditional/conditional/known-issue/OS applicability; selected/executed/skipped counts — отдельный runtime evidence contract, не regex догадка.

**Приёмка:** минимальные положительные и отрицательные случаи из F17; безопасный off-main worker не получает бессмысленный remediation, комментарий не блокирует build; скрытое отключение нужных тестов не становится PASS. Проверки запускаются только в открытой test/runtime фазе.

**Откат:** отдельный versioned adapter/policy pin; сохранённые findings не переписываются.

### 5.3 — Каталог зрелости и честное mode coverage

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Находки:** F18–F19. **Изменение:** implemented/verified/wired/pilot-enabled раздельно. Каждому ID реальные fixture references и narrow claim. `swift-format` / SwiftFormat / SwiftLint различить без молчаливой смены ID. Если mode не запустил adapter, receipt это показывает.

**Приёмка:** нет implemented gate с placeholder negative evidence; direct invocation не выдаётся за full mode coverage; отключённое пользователем действие не исполняется косвенным tool command.

**Откат:** schema compatibility mapping и прежний pin.

## Этап 6. Закончить действительно недостающую часть H

### 6.1 — SwiftLint с фиксированным tool/config contract

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** pinned executable/version/config digest, bounded invocation, выбранный source scope, no autofix, structured findings. Rule suppression — по единой policy; не открывать concurrency escape через inline disable. Не загружать mutable latest binary на каждый запуск.

**Приёмка:** tool missing/version mismatch/config drift/timeout/output overflow не PASS; benign fixture зелёный, deliberate violation красный; local/GitHub semantics одинаковы.

**Откат:** прежний pin; gate не становится required до canary/pilot.

### 6.2 — First-party warnings и concurrency diagnostics

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** использовать существующий authenticated build-report boundary. Определить first-party vs dependency/generated, baseline vs new warning, target/config/toolchain. Не парсить последние строки текстового лога как доказательство clean build; failure/partial log/truncation видимы.

**Приёмка:** warning выбранного target обнаруживается; warning другого input не приписывается текущей ревизии; compilation failure и zero-applicable-source не green; доказательство связано с exact source/toolchain.

**Откат:** предыдущая compatible policy/engine version; не удалять warning baseline автоматически.

## Этап 7. Проверить проверяющий механизм

### 7.1 — Ограниченная test-writing и canary acceptance фаза

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Требуемое разрешение перед исполнением:** отдельная конкретная фаза создания/изменения и запуска engine tests; пользовательские manual CI/Codex Review остаются ручными. Сам аудит её не запускал.

**Изменение:** добавить только tests для новых/исправленных invariants, не переписывать весь suite. Матрица: positive control; deliberate failure; stale source; empty scope; malformed config; unknown fields; denied action; conditional skip; timeout; output cap; tool drift; paths with spaces/newlines; interrupted process; retained evidence. Принимаемые cases привязать к findings этого аудита.

**Приёмка:** broken case ни разу не выдаёт normal PASS в разрешённом наборе; позитивный контроль не заблокирован. Старые неизменные PASS receipts переиспользуются с указанием границ; новые изменения получают новое evidence.

**Откат:** прежний pin. Новые tests не удаляются ради зелёного результата; дефект исправляется или gate остаётся неактивным.

### 7.2 — Оценка генерации и обнаружения ошибок отдельно

**Модель:** GPT-5.6 Luna xhigh для всех ролей. **Входы/зависимость:** 0.3–0.4, актуальные prompts 2–3, проверенные механизмы 7.1.

**Изменение:** в отдельно разрешённой фазе выполнять по одному сценарию за блок. Luna получает только задание и правила и создаёт решение; исходный diff фиксируется до исправлений. Затем решение оценивается по заранее заданному поведению. Отдельный detector получает варианты с нейтральными IDs без correct/defective меток, bug hints или key. Его findings фиксируются до раскрытия evaluator ключа; затем записываются detection/miss/false positive. Контекст, уже видевший key, не даёт слепой detection verdict. LLM verdict не заменяет разрешённое объективное evidence.

**Приёмка:** отдельные результаты initial code quality и detection quality, без объединения в один score. Невыполненный runtime остаётся unverified. После настройки на открытых примерах выполнить holdout без подсказанного ответа; при провале исправить правило и выбрать новый непоказанный вариант вместо повторения известного. Активация blockers требует positive/negative controls. Расширять набор только из-за конкретной непокрытой ошибки.

**Откат:** предыдущая prompt/policy version и receipt. Не создавать новый benchmark runner или массовые mutation suites. Расход и вмешательства пользователя включить в 0.3/10.2.

## Этап 8. Два различных app pilots

**Общая обязательная матрица каждого pilot** сохраняет контракт старого плана (`before-plan.md`, Phase J). Для каждого из двух consumers нужны:

| Evidence | Условие завершения pilot |
| --- | --- |
| Identity и static | Exact source SHA, engine/profile/policy/toolchain revisions, применимые static checks |
| Runtime | Как минимум один явно разрешённый runtime mode с сохранённым результатом и scope |
| Controls | Успешный positive control и обнаруженный deliberate failure |
| Integration | Dry-run safety, apply, повторное применение/idempotence и rollback |
| Local/GitHub parity | Сопоставимые exact inputs и подтверждённое соответствие результатов двух путей |
| Review | Действующий pre-PR receipt по полному trusted-base range и exact HEAD |

`denied`, `unavailable`, `not run` для обязательного evidence означают **partial pilot**, а не completed. Неполный pilot не допускает обычный stable promotion в 9.1. Матрица не разрешает запуск runtime/CI: они остаются ручными или отдельно разрешёнными. Более узкий static-only release требует отдельного явного решения пользователя о scope, изменённых критериях и claims; текущий план такого решения не содержит. Дополнительные app-specific runtime gaps нельзя скрыть за одним выполненным mode.

### 8.1 — Простой consumer

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Кандидат:** MVVMExample как простой existing consumer; AI Fieldbook — прежний утверждённый кандидат, если его активная работа закрыта. Выбор на старте по текущим permissions/readiness; не переключать старый pilot order молча.

**Изменение:** thin launcher + pinned engine + app-owned profile; сначала static. 5–10 разных реальных изменений, а не 10 повторов одного fixture. Записать duration, false-positive/negative examples, extra context, reviewer corrections и пользу.

**Приёмка:** общая матрица этапа 8 заполнена для этого consumer; никаких app names в engine; app local infrastructure и test permissions сохранены; dry-run/apply/repeat/rollback проверены в разрешённом scope; known deliberate failure красный. Runtime evidence требует соответствующего user-run/authorization.

**Откат:** удалить только добавленную integration по manifest или вернуть pin; не затронуть user files.

### 8.2 — Сложный multi-target consumer

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Кандидат:** Tchop как legacy/multi-target consumer, после подтверждения актуального branch/PR state.

**Изменение:** profile учитывает app/share/widget, source-only packages, resources, entitlements, migration/lifecycle. Исторические 19 Swift source blockers заново проверить в контексте executor/target; source remediation — отдельные app patches, не часть глобального engine hardening.

**Приёмка:** общая матрица этапа 8 заполнена для этого consumer; gates не подменяют extension runtime и VoiceOver/launch checks; два потребителя не требуют двух forks verifier; local/GitHub результаты соответствуют одинаковым inputs. Data-loss и lifecycle claims имеют подходящее evidence.

**Откат:** consumer-specific pin/launcher rollback; app behavior меняется только в отдельных явно разрешённых patches.

### 8.3 — Готовность подготовки к будущему продуктовому проекту

**Модель:** GPT-5.6 Luna xhigh. **Входы/зависимость:** результаты 1–7, включая 4.3/7.2, известные findings. Завершение миграций всех пробных consumers и 8.1–8.2 не требуется для этого отдельного verdict.

**Изменение:** readiness receipt подготовки: непротиворечивые authority/permissions, проверенный new-project bootstrap/handoff, пригодный процесс Luna, evidence generation/detection, достоверные применимые gates, pinned versions и ограничения. Наличие docs не равно приёмке. Известные P0–P2, влияющие на этот scope, блокируют положительный verdict; недостающие обязательные строки означают partial.

**Приёмка:** отдельно указать (1) что подготовлено для начала требований/проектирования/разрешённой разработки нового проекта, (2) что ещё нужно для stable QC release по 8.1–8.2/9.1, (3) какие продуктовые решения и app-specific проверки невозможно принять без настоящего проекта. Этот verdict не подключает engine автоматически, не ослабляет release/security/data/test permissions и не заявляет production readiness.

**Откат:** receipt становится stale при изменении обязательных правил/toolchain или выявленном пропуске ошибки; повторная проверка относится к изменённому контракту. Массовая миграция пробных apps и история идут отдельно, если не блокируют общую систему в заявленном scope.

## Этап 9. Версионированный rollout

### 9.1 — Promotion и release contract

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** после двух pilots подготовить compatibility notes, schema/profile migrations, checksums, signed tag согласно действующей release policy. Утверждение пользователем перед promotion/release/новыми consumers; этот план не является выполненным approval.

**Приёмка:** два completed pilot receipts по всей матрице этапа 8, documented support matrix, известные ограничения, exact artifact/version, rollback rehearsal. Проверить каждую строку обоих receipts, а не только их наличие. Partial pilot блокирует обычный stable promotion; более узкий release требует отдельного явного решения пользователя с ограниченными claims. «Stable» не ставится по одному успешному canary или двум static-only наблюдениям.

**Откат:** предыдущий release + совместимые schemas; evidence прошлой версии не переименовывается.

### 9.2 — Existing/future project adoption

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** inventory → conflict report → конкретный plan → apply → post-check → rollback. Работать по canonical Git identity и отдельным worktrees, не считать каждую папку независимым app. Existing overlays сохраняются; stale snapshots обновляются из versioned distribution.

**Приёмка:** повторный apply idempotent, partial failure не оставляет consumer с заявленным success; новый Git-root получает global rules, engine adoption соответствует действующему opt-in решению. Outside-host/remote cases явно поддержаны либо отмечены unsupported.

**Откат:** precise generated-file manifest + backup hashes, без широкого `rsync --delete` по пользовательскому дереву.

## Этап 10. Сократить расходы без снижения приёмки

### 10.1 — Context budget и повторное использование evidence

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** measured transitive route budget; compact Level 0; hashes/read-once внутри task; reread только после изменения source/route/context. Сократить repeated header только после отдельного изменения действующего response contract. Plan+handoff ≤3500 words; history по ссылке. Не удалять нужные правила ради формального лимита.

**Цель пилота:** сократить типичный routinely loaded context примерно на 30–50% относительно измеренного comparable route; это проверяемая цель, не обещание. Если coverage/quality ухудшается, оптимизация не принимается.

**Приёмка:** одинаковые sentinel tasks получают правильный route, authority и permissions; нет потери release/data/concurrency рисков. Semantic evidence reuse возможно только при сохранении всех relevant inputs и новой identity binding.

**Откат:** предыдущий router/budget; восстановить конкретное недостающее чтение, не весь архив.

### 10.2 — Калибровка процесса Luna xhigh на ваших типовых задачах

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** использовать observations с 0.3, результаты 4.3/7.2 и доступные pilot receipts; этот этап завершает оптимизацию, а не начинает измерения. Взять завершённые representative tasks без private payload: docs rename, bounded UI fix, DTO mapping, concurrency lifetime, migration, permission/evidence contract. Использовать только Luna xhigh. Сравнить варианты размера context packet, размера patch и способа review по correctness, missed P1/P2, reviewer corrections, actual usage и elapsed time. Не запускать другие модели ради сравнения.

**Приёмка:** процесс выбран по наблюдаемым результатам Luna. Uncertainty/security/data-loss уменьшают размер блока и повышают глубину проверки, но не меняют модель. Нет обещаний точного weekly percentage из prompt size и нет снижения gate при нехватке ресурсов.

**Откат:** вернуть более консервативный размер блока и обязательную проверку проблемного класса; модель остаётся Luna xhigh.

## Этап 11. Закрытие и дальнейшая поддержка

### 11.1 — Итоговый semantic audit

**Модель:** GPT-5.6 Luna xhigh. **Изменение:** итоговая сверка authority chain, изменённых контрактов, потребителей и evidence двух пилотов.

**Приёмка:** F01–F24 закрыты исправлением либо явным принятым решением с evidence; исключения approved/scoped; нет двух источников одной нормы; все activated blockers имеют reliable positive/negative controls; exact released revision совпадает у consumers; runtime limitations честно перечислены.

**Откат:** release/policy pins и app-specific rollback из предыдущих этапов. При P1/P2 false-success дефекте не объявлять систему готовой.

### 11.2 — Лёгкая поддержка

**Модель:** GPT-5.6 Luna xhigh. **Проверка:** отдельный проход Luna xhigh по контракту блока; для критичных изменений — полный итоговый diff и затронутые consumers.

**Изменение:** review triggers на major Swift/Xcode/SDK/провайдер релиз, новые типы приложения, missed defect, repeated false positive, изменение permissions. Периодический compact review по существующему плану; автоматизацию создавать лишь по отдельному запросу пользователя.

**Приёмка:** знания обновляются там, где изменился контракт; архив не растёт в Level 0; стоимость и реальные escaped defects доступны для решения о следующем улучшении.

## Что сейчас не включать

- Полную замену QualityControl runner из ZIP.
- Автоматический exhaustive review каждой мелочи, фиксированные тестовые квоты, mandatory SwiftPM/source-only для всех apps.
- Hostile-runner attestation, криптографическую инфраструктуру сверх принятой угрозы, hooks/telemetry platform без конкретного дефекта.
- Автоматическое включение CI, branch protection, платных runners/API, cloud AI, новых tests или массовых app migrations.
- Обещание отсутствия ошибок или уменьшение ручного review только на основании названия модели.

## Рекомендуемый первый implementation block

Начать с 0.1 → 0.2 → 0.3 → 0.4, затем отдельным блоком 1.1: актуальный operational plan, исправленная authority hierarchy и единый readiness/severity contract. Все действия и отдельная проверка — **GPT-5.6 Luna xhigh**. Это ограниченный docs/control-policy блок; engine/app edits и runtime не нужны. После него следующий исполнитель получает конкретные непротиворечивые правила вместо необходимости заново разбирать всю систему.

Передача контекста: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**. Это означает актуальный routed набор и изменившиеся источники, а не весь исторический vault.
