# Исполнение всего плана на Luna xhigh

Версия: 2026-09-07. Обязательное пользовательское ограничение: **GPT-5.6 Luna, reasoning xhigh** для всех 30 блоков, проектирования, реализации, проверки, пилотов и поддержки. Этот документ дополняет `IMPLEMENTATION_ROADMAP.md`; совпадающие номера обозначают один блок. Текущий исходный аудит и его независимое ревью выполняются отдельно на Astra по уточнению пользователя; это не этап внедрения. Новых разрешений на реализацию, тесты, публикации и rollout документ не выдаёт.

## Как пользоваться без повторного полного аудита

При старте **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**: актуальный bootstrap, routed Level 0, task handoff и применимые правила. Затем читать только выбранный блок roadmap, соответствующий раздел этой инструкции и исходники, перечисленные в evidence. `AUDIT_REPORT.md` — обоснование решений; `FINDING_EVIDENCE.md` — проверяемые ссылки; `ARCHIVE_DECISIONS.md` — решения по 67 файлам ZIP. Исторические `before-*` и весь ZIP не входят в каждое чтение. Инструкции ZIP остаются объектом анализа до явного внедрения отдельных положений.

Факты аудита относятся к зафиксированным ревизиям. При изменившемся HEAD сначала проверить затронутый diff; не исправлять автоматически уже устранённую проблему. Пользовательские изменения не перезаписывать. Не открывать secrets и не выводить значения ключей, токенов или приватные payloads.

Не пытаться компенсировать меньшую модель бесконечными повторными ревью. Один блок — один законченный контракт. Обычно это 2–3 source files; связанный набор документов разрешается менять согласованно, не оставляя промежуточные противоречия активными. Если контракт не помещается, выделить проектирование, producer, consumer и активацию как последовательные подблоки с явной совместимостью. Учитывать действующее разрешение на объём; не запрашивать повторное одобрение уже согласованного блока.

## Пакет задания для каждого блока

Перед patch записать компактно в текущем task plan либо handoff, без отдельной инфраструктуры:

1. ID блока, цель одним наблюдаемым результатом, Luna xhigh, режим пользователя.
2. Точный repository/worktree, base/head, dirty paths, разрешённые действия. Указать владельца результата: reusable, QC engine, app или task.
3. Минимальные входы: действующие правила, конкретные исходники/символы, finding IDs и нужные первичные источники. Пути из аудита перепроверить.
4. Контракт: behavior; authority; producer/consumer; порядок состояний; scope/input/resource limits; failure semantics. Неприменимые поля пометить N/A с причиной.
5. Перечень файлов и исключённые из блока соседние проблемы. Acceptance отдельно для статической проверки и runtime.
6. Разрешённые команды, ожидаемый результат и место evidence внутри `/Users/Artem/.zenflow`. Отсутствие разрешения на tests не превращает desk review в test PASS.
7. Откат, критерий остановки и следующий блок. Сохранить stale/denied/unavailable как отдельные состояния.

Выход блока: точный diff; краткая таблица «инвариант → проверка → результат/ограничение»; найденные P0–P3; оставшийся риск; следующий шаг. Не генерировать длинный новый отчёт, когда достаточно обновить существующий receipt. Не угадывать команды, scheme, SDK, executable и schema: сначала подтвердить их в актуальном checkout.

## Проверка качества и остановка

Для authority, permissions, false PASS, concurrency, migration и release сначала закончить контракт, затем patch, затем разрешённые проверки, затем отдельный semantic review на Luna xhigh. Reviewer получает base/head, полный diff, затронутые callers/claims, контракт и evidence; отдельно ищет false success, потерю данных, несовместимость и утечку app rules. Передавать только вывод автора недостаточно. Другая задача или агент создаётся только при соответствующей авторизации; self-review нельзя называть независимым. Если обязательное независимое review недоступно, фиксировать незавершённый gate, не заменять его тайно self-review.

P0–P2 блокируют commit/push по действующему quality standard; допустимое исключение требует действительной более высокой авторизации. P3 исправить или явно сообщить. После исправлений один полный final-diff review. Неизменное пригодное evidence повторно не запускать; новая source/toolchain/profile identity требует проверить применимость старого evidence.

После двух неуспешных попыток одной гипотезы остановить этот подход: записать наблюдение, уменьшить задачу и выбрать проверяемую следующую гипотезу. Если требуется продуктовое решение, разрешение или недоступный runtime — запросить конкретное недостающее действие. Ни смена модели, ни ослабление gate не являются запасным выходом. Это не лимит двух попыток на всю задачу и не повод бросать самостоятельную полезную работу.

## Микрошаги по всем блокам

### 0.1 — Точка продолжения и владельцы

**Входы:** текущие plan/handoff, universal plan, раздел старого плана в AUDIT_REPORT, boundary/source-of-truth/governance.

1. Сопоставить старые H/I/J с фактическим QC checkout: completed, remaining, stale claim, superseded recommendation.
2. Зафиксировать четыре владельца и действующие запреты/разрешения; отдельно global rules и opt-in engine adoption.
3. Сделать один operational index, сохранив старый план с hash. Не повторять 930 строк в новом Level 0.
4. Проверить, что все будущие роли имеют Luna xhigh, а история Astra явно историческая.

**Выход/приёмка:** один актуальный индекс; старая история доступна; реализация ещё не объявлена разрешённой. **Стоп:** спор о владельце или конфликт текущих пользовательских решений — конкретное решение пользователя.

### 0.2 — Свежая исходная ревизия

**Входы:** inventory/adoption/baseline JSON, выбранные Documentation и QC main-active, доступные Git metadata.

1. Сверить repository identity, branch, HEAD и dirty paths. Не считать старый QC checkout актуальным main.
2. Проверить изменения исходников после аудита; обновить только относящиеся к блоку findings.
3. Зафиксировать profile/policy/toolchain identity и имеющиеся receipts; stale отделить от fresh.
4. Отметить пользовательские правки и разрешённые write roots до любых изменений.

**Выход/приёмка:** компактный baseline для следующего блока с точными SHA. **Стоп:** неоднозначная identity или пересечение с чужим незавершённым patch.

### 0.3 — Измерять Luna с первого блока

**Входы:** baseline 0.2, существующий context-cost, текущий task plan. **Модель:** Luna xhigh.

1. Создать одну таблицу observations в task evidence; не писать сборщик telemetry. Поля — из roadmap 0.3.
2. До каждого разрешённого patch записать class, identities и размер входного пакета. После — результат и correction count; отсутствующие usage/time пометить unknown.
3. Разделить missed defect, false positive, лишнее чтение и необходимый вопрос о продукте. Не оптимизировать число вопросов ценой догадок.
4. Первую проверку процесса выполнить после 1.1, следующую после первой группы prompts 2.2. Повторяющаяся причина ошибки требует поправить соответствующий packet до следующего сходного задания.

**Выход:** компактный baseline и наблюдения, не обещание статистической надёжности. **Стоп:** измерение превращается в отдельную платформу или требует недоступных данных. Продолжить полезную работу с unknown fields; итог анализа — 10.2.

### 0.4 — Задать пять нейтральных сценариев

**Входы:** roadmap 0.4, действующие constraints, F15–F19 как примеры ошибок проверок. **Модель:** Luna xhigh.

1. Зафиксировать пять карточек: UI state, cancellation/lifetime, recoverable error, data preservation, API boundary. Данные синтетические; продуктовые требования не нужны.
2. В каждой карточке: input, observed outcome, invariant, applicable rules, permitted evidence, корректный вариант и один дефект. Например, поздний ответ не перезаписывает новое состояние; cancel не показывается как пользовательская ошибка; failed save не теряет старые данные.
3. Задать два независимых критерия: качество первоначального решения и обнаружение дефекта. Лишние слои оценивать относительно необходимости, не по числу строк.
4. Разделить открытые и отложенные варианты до настройки. Generator packet содержит только задачу, правила и критерии поведения; answer key/намеренный дефект туда не включать. Key хранится отдельно и доступен только evaluator, вне routed input generator и detector. Detector packet содержит вариант с нейтральным ID и behavioral contract без truth label, места дефекта, ожидаемого finding и bug hint. Findings фиксируются до раскрытия ключа и scoring.
5. Описать разрешения на будущие code/tests/runtime actions; в этом блоке только текстовые контракты. Если generator или detector уже видел key, результат unblinded: нужен отдельный разрешённый fresh контекст соответствующей роли Luna. Иначе independent holdout PASS запрещён; ограничение фиксируется честно.

**Выход:** пять однозначных карточек и заранее записанный rubric. **Стоп:** неоднозначный outcome, продуктовая догадка или изменение rubric ради принятия плохого решения. Не строить скрытый benchmark сервис.

### 1.1 — Authority и вердикты

**Входы:** F02/F09/F10/F12 и указанные в roadmap нормативные документы.

1. Выписать конфликтующие строки и consumers; построить одну таблицу приоритета с system/developer выше project documents.
2. Определить отдельно impact, confidence, applicability, evidence status и decision. Не считать низкую confidence низким impact.
3. Сопоставить локальную готовность, commit/merge и release; определить skipped/denied/unavailable/accepted-risk.
4. Согласованно исправить нормативные документы, затем ссылки prompts. Ручной advisory CI сохранить ручным.
5. Согласовать MODEL_ROUTING_RULE с явным task override и поддержкой xhigh; не навязывать Luna несвязанным задачам.
6. Провести desk review пяти сценариев roadmap плюс противоречивое указание из ZIP.

**Выход/приёмка:** одна таблица решений без ложного PASS; полный diff review. **Стоп:** новое ослабление обязательного запрета без одобрения.

### 1.2 — Rule ID и исключения

**Входы:** результат 1.1, действующие exception templates, 10–15 активных норм.

1. Выбрать нормы с реальными конфликтами/consumers, назначить стабильные IDs и владельцев.
2. Добавить scope, trigger, enforcement limitation, evidence, source date и revisit; не размечать архив.
3. Свести поля exception в один контракт: rule version, app/scope, rationale, approval, expiry/revisit, compensation, rollback.
4. Проверить draft, approved, expired и wrong-app примеры; продление не считать автоматическим.
5. Перевести дубликаты в ссылки, сохраняя строгий concurrency default до отдельного решения.

**Выход/приёмка:** минимальный реестр и однозначные исключения. **Стоп:** ID изменяет смысл или локальное исключение становится глобальным.

### 2.1 — Архитектура и app ownership

**Входы:** F03/F07, architecture router, UI/MVVM/package standards, затронутые app ADR.

1. Разделить требования ownership/state/IO и предпочтения VM/Renderer/Coordinator/source-only.
2. Для каждого product fragment найти реального владельца; неизвестный не переносить наугад.
3. Согласовать generic router и шаблоны, оставив действующие app ADR в их приложениях.
4. Проверить native SwiftUI, MVVM и multi-target сценарии без обязательных лишних слоёв.

**Выход/приёмка:** карта переносов и непротиворечивый выбор архитектуры; app правила сохранены. **Стоп:** изменение поведения приложения или ADR без соответствующего scope.

### 2.2 — Prompts и skills

**Входы:** F08/F11/F14, prompt router, активные тела prompts, registry и provenance skills.

1. Взять одну связанную группу: feature/refactor, review, AI routing либо specialist overlap; не редактировать всё одновременно.
2. Устранить противоречия внутри тела, а не только README: test permissions, Action enum, full-master reading, output verbosity.
3. В AI master выделять references по существующим разделам, сохранять anchors и проверять всех consumers каждого переноса.
4. Исправить конкретные ошибочные concurrency/testing утверждения по primary sources; provenance upstream сохранять.
5. Desk scenarios: маленькая правка, async lifecycle, API mapping, AI feature. Проверить достаточность и отсутствие лишних маршрутов.

**Выход/приёмка:** одна согласованная группа prompts и routing diff; no broken links. **Стоп:** новая policy или API semantics не подтверждены источником/контрактом.

### 2.3 — Пакеты и snapshots

**Входы:** F03/F14, package catalog, SDK roadmap, фактические package roots, app adoption records.

1. Сверить заявленные packages/iterations с реальными roots; retired не считать active.
2. Отделить reusable API contract от app adoption/runtime owner и истории миграции.
3. Исправить test quotas, URL sanitization claims, output/cache paths в документах и templates.
4. Проверить ссылки после каждого согласованного переноса и applicability source-only/SwiftPM.

**Выход/приёмка:** каталог с revisions/evidence и владельцами; история не потеряна. **Стоп:** неясная app принадлежность или необходимость менять runtime packages.

### 3.1 — Toolchain и concurrency

**Входы:** F14, modern iOS раздел отчёта, actual build settings/profile, Swift/Apple primary docs.

1. Разнести compiler version, Swift language mode, SDK и deployment target; перечислить targets/extensions.
2. Зафиксировать default isolation/upcoming features и применимость @concurrent/nonisolated semantics.
3. Перепроверить task-group cancellation, suspension vs CPU work и executor assumptions на выбранной версии.
4. Обновить нормы и примеры без изменения build settings; beta capabilities выделить отдельно.
5. Проверить desk examples для main actor UI, worker IO, cancellation и cross-module boundary.

**Выход/приёмка:** version-aware policy с датами/ссылками. **Стоп:** неизвестный executor или toolchain — получить данные, не гадать.

### 3.2 — Release, privacy, performance

**Входы:** профиль приложения, primary Apple sources, F19 и modern iOS раздел.

1. Перепроверить актуальные upload требования на день внедрения; deployment floor учитывать отдельно.
2. Связать privacy claims с API/SDK/data flow; отсутствие manifest не объявлять compliance PASS.
3. Определить измеримые budgets и необходимые методы evidence для launch, interaction, memory, frames.
4. Вывести accessibility/iPad/localization матрицу из реального profile; experimental AI не активировать автоматически.

**Выход/приёмка:** применимая матрица с явно недостающим runtime evidence. **Стоп:** security/data handling продуктовый выбор или неподтверждённый API.

### 4.1 — Bootstrap для всех проектов

**Входы:** F01, adoption inventory, effective Codex discovery docs и фактические AGENTS/overrides.

1. Составить effective-route table по 15 найденным roots с отдельной Git identity; проверить новые roots на день исполнения.
2. Спроектировать минимальный global entry, repo bootstrap и versioned fallback; non-iOS routing учитывать явно.
3. Подготовить точечные patches, сохранив пользовательские overlays. Изменение global home требует соответствующего write permission.
4. В разрешённой фазе проверить новый disposable consumer, missing canonical, stale fallback, nested override и alternate host.

**Выход/приёмка:** доказанная effective route, а не один marker. **Стоп:** неразрешённый путь либо перезапись user overlay; сформировать конкретный patch для разрешения.

### 4.2 — Distribution и boundaries

**Входы:** F04–F06, generator/validators, current registry, drift inventory.

1. Разделить contracts canonical source, generated bundle и installed consumer; определить base каждого относительного пути.
2. Классифицировать exact/overlay/stale/missing/local-only, сохранить overlay mapping.
3. Убрать фиксированный список четырёх app names в пользу существующего registry/структуры; не обещать semantic detection по одному token scan.
4. Исправить missing/stale links и запускать штатный manifest generator; не править generated inventory вручную.
5. Проверить новый app name и distinct source/install roots в разрешённой проверке validator.

**Выход/приёмка:** manifests и links согласованы, overlays сохранены. **Стоп:** checker PASS скрывает известную semantic leak; требуется review конкретной нормы.

### 4.3 — Новый нейтральный consumer от старта до handoff

**Входы:** 0.4, 2–3, 4.1–4.2, new-project contract; только открытый учебный сценарий 0.4, не holdout. **Модель:** Luna xhigh.

1. Сначала подготовить точный путь, file manifest, минимальный profile и список действий. Создание проекта и runtime выполнить только в согласованной фазе; не создавать настоящий продукт.
2. В чистом Git root проверить effective instruction chain. Зафиксировать, какие правила загрузились автоматически; отсутствие явного напоминания не заменяет evidence маршрута.
3. По учебным требованиям выбрать минимальную архитектуру с одним кратким обоснованием; не переносить стек пробного приложения.
4. Выполнить одно ограниченное изменение и только разрешённые проверки. Сохранить diff/checks и ограничения; при runtime gap оставить результат partial.
5. Подготовить компактный handoff, затем в отдельном разрешённом контексте Luna восстановить identity, правила и следующий шаг без подсказок автора. Если такого контекста нет, recovery verification остаётся pending.
6. Записать ошибки маршрута/генерации/проверки в 0.3. Реальный общий дефект предложить исправить у владельца правила; учебные параметры оставить local. Точный disposable rollback — по manifest.

**Выход:** end-to-end receipt нового consumer, без app-specific leakage. **Стоп:** неизвестная authority, missing обязательное evidence или неразрешённый путь. Этот consumer не заменяет ни один из двух обязательных app pilots.

### 5.1 — Что реально входит в source scope

**Входы:** F15, QC adapter/profile/schema/catalog и существующий build-report boundary.

1. Описать explicit list, tracked files и compiled membership как разные виды evidence.
2. Выбрать минимальный доступный источник target/config membership; не создавать универсальный parser без нужды.
3. Определить unknown/empty/generated/package/extension/path-boundary states и соответствующие verdicts.
4. Последовательно согласовать producer, consumer и receipt; до их совместимости gate не активировать.
5. Составить acceptance cases из roadmap для test-фазы 7.1.

**Выход/приёмка:** scope нельзя выдать за shipped membership без доказательства. **Стоп:** missing graph evidence; честный unavailable вместо normal PASS.

### 5.2 — Swift patterns и disabled tests

**Входы:** F16/F17, конкретные regex/lexical helpers, действующая ban policy.

1. Разделить lexical detection, contextual hot-path evidence и explicit policy ban; не угадывать executor по имени файла.
2. Сначала описать comments, escaped/raw/multiline strings и interpolation; сохранить code внутри interpolation как применимый случай.
3. Выбрать ограниченный parser/lexer подход по доступным зависимостям; unsupported syntax показывать явно.
4. Разделить unconditional/conditional/known-issue skips и runtime selected/executed counts.
5. Подготовить positive/negative cases, включая literal внутри строки и безопасный worker; запускать только с разрешением.

**Выход/приёмка:** narrow claims и корректный remediation; unknown не маскируется. **Стоп:** требование доказать runtime/static isolation одной regex — пересмотреть контракт.

### 5.3 — Каталог и режимы

**Входы:** F18/F19, все 20 catalog entries, mode dispatcher, реальные fixture refs.

1. Для каждого gate записать implemented, verified, wired и pilot-enabled отдельно.
2. Сопоставить actual executable и ID: Apple swift-format, SwiftFormat и SwiftLint не смешивать.
3. Заменить placeholder evidence точными доступными ссылками либо честным pending.
4. Проследить mode → permission → adapter → receipt; direct invocation не означает mode coverage.

**Выход/приёмка:** каждый claim ограничен реальным охватом; 20 записей сверены. **Стоп:** скрытое исполнение denied action или несовместимая schema migration.

### 6.1 — SwiftLint

**Входы:** staged gate, tool policy, результаты 5.1/5.3, suppression contract.

1. Зафиксировать executable/version/config digest и источник установки; не брать mutable latest.
2. Использовать согласованный scope; определить timeout/output/resource limits и no-autofix.
3. Согласовать structured findings и missing/version mismatch/config drift verdicts.
4. Подготовить benign/violation/error cases для 7.1; inline disable не обходится без политики.

**Выход/приёмка:** gate реализован с честной maturity, до evidence не required. **Стоп:** установка/запуск вне разрешения или новая dependency без обоснования.

### 6.2 — Warnings и concurrency diagnostics

**Входы:** authenticated build-report contract, staged catalog, toolchain/profile.

1. Определить first-party/dependency/generated принадлежность и target/config identity.
2. Разделить baseline/new warnings, build failure, partial/truncated report и zero applicable scope.
3. Реализовать consumer существующего report boundary; не принимать произвольный tail лога как trusted clean build.
4. Подготовить cases для wrong revision, wrong target, warning, failure и clean positive control.

**Выход/приёмка:** отсутствие diagnostics имеет значение только при полном применимом report. **Стоп:** нет producer evidence или источник не связан с ревизией.

### 7.1 — Test-writing и canary

**Входы:** acceptance cases 5–6, текущий suite, точный scope разрешения на создание/запуск tests.

1. Если фаза ещё не разрешена, показать конкретный список тестовых файлов, команд и output paths; не запускать заранее.
2. Сопоставить каждый изменённый инвариант с минимальным positive и deliberate-failure контролем; reused evidence отметить.
3. Добавить cases empty/stale/malformed/denied/timeout/output cap/path/interruption только где затронут контракт.
4. Запустить разрешённый набор, сохранить evidence identity и failure details без secrets.
5. Провести отдельный Luna review trust/permission boundaries, исправить findings, повторить нужные checks и final diff review.

**Выход/приёмка:** все выбранные broken cases не normal PASS, controls проходят; ограничения перечислены. **Стоп:** false PASS, необъяснимый flaky outcome либо отсутствие обязательного review.

### 7.2 — Раздельная оценка генератора и проверяющего

**Входы:** карточки/рубрика 0.4, данные 0.3, prompts 2–3, evidence 7.1; точный test/code/runtime scope. **Модель всех ролей:** Luna xhigh.

1. Открыть один сценарий. Передать generator packet без answer key; не запускать параллельно все примеры.
2. Зафиксировать исходный diff до исправлений. Оценить initial correctness, простоту и permissions по rubric; сохранить пропущенные ошибки отдельно от исправленного результата.
3. В отдельном разрешённом fresh detector контексте предъявить варианты с нейтральными IDs и behavioral contract, без correct/defective меток, bug hints и answer key. Сначала зафиксировать findings. Только затем evaluator раскрывает key, проверяет detection/false positive и сопоставляет конкретный check/claim. Если detector видел key заранее, отметить unblinded и не выдавать independent holdout PASS.
4. Использовать разрешённый deterministic/runtime evidence там, где нужен behavioral verdict. Одного согласия двух LLM недостаточно. Denied/unavailable — unverified, не PASS.
5. После открытых примеров зафиксировать версию prompts/gates и проверить отложенные варианты без answer leakage. Провалившийся вариант становится известным; после исправления нужен новый непоказанный вариант для следующего holdout verdict.
6. Записать две группы результатов и затраты в 0.3. Реальный общий дефект исправлять отдельным bounded block на Luna, затем проверить затронутую приёмку. Увеличивать набор только при доказанном пробеле.

**Выход:** сравнимые generation/detection receipts с identities и ограничениями. **Стоп:** false PASS, раскрытый answer key, изменённая после результата rubric или отсутствие обязательного evidence. Сохранять прошлые результаты; не превращать процесс в бесконечный подбор зелёных примеров.

### 8.1 — Первый app pilot

**Входы:** 7.1 evidence, прежний approved pilot order, свежие app branch/permissions/profile.

1. Сохранить прежний AI Fieldbook порядок, если условия соблюдены; MVVMExample — предложение альтернативы, требующее решения при смене порядка.
2. Подготовить thin launcher/pin/app-owned profile без engine fork и app name внутри generic кода.
3. Начать с разрешённых static действий; dry-run/apply/repeat/rollback выполнять только в согласованной области.
4. Собрать 5–10 разных реальных изменений по мере работы; не создавать искусственные app changes ради количества.
5. Зафиксировать misses/false positives, corrections, duration/context/usage где доступны; ручное runtime evidence не подменять.

6. Заполнить каждую строку общей pilot acceptance matrix этапа 8 roadmap: exact-SHA static, один разрешённый runtime mode, positive/failure controls, integration/rollback, local/GitHub parity и pre-PR receipt.

**Выход/приёмка:** completed только при заполненной матрице; иначе partial pilot с конкретным missing evidence. **Стоп:** конфликт активной app работы, permissions, missing required evidence или reproducible false PASS. Частичный результат не открывает promotion.

### 8.2 — Multi-target pilot

**Входы:** актуальный Tchop state, profiles app/share/widget, 7.1 и первый pilot.

1. Подтвердить ветку/PR и владельцев targets, source-only packages, data migration и entitlements.
2. Применить общий engine через app profile; historical 19 blockers заново оценить по актуальному коду.
3. App remediation выносить в отдельные разрешённые patches, по одному lifecycle/data контракту.
4. Проверить одинаковые inputs локального/GitHub пути только при соответствующем разрешении; CI остаётся ручным.
5. Сохранить отдельные runtime gaps для extensions, VoiceOver, launch и migration.

6. Заполнить для второго consumer всю общую pilot acceptance matrix этапа 8 roadmap; evidence первого consumer не заменяет второй pilot.

**Выход/приёмка:** второй completed pilot без fork verifier только при заполненной матрице; иначе partial с missing evidence. **Стоп:** data-loss/permission finding, missing required evidence или попытка выдать static gate за runtime proof.

### 8.3 — Проверить готовность подготовки

**Входы:** 1–7, receipts 4.3/7.2, актуальный список findings, pins и ограничения. **Модель:** Luna xhigh.

1. Сформулировать scope: подготовка общей системы для будущего проекта; самого проекта и его продуктовой архитектуры пока нет.
2. Сопоставить readiness rows roadmap 8.3 с конкретным evidence. Наличие документов, число PASS или дешевизна модели не доказывают готовность.
3. Отделить blockers в этой области от миграций остальных пробных apps. P0–P2 с влиянием на scope блокируют положительный verdict; missing required evidence означает partial.
4. Выпустить три отдельных статуса: подготовка к старту; stable release QC по прежней полной pilot matrix; будущая app/release readiness пока не оценивается.
5. Перечислить решения, которые потребуются после появления реального проекта: требования, deployment/capabilities, архитектура по потребности, data/privacy и соответствующая верификация. Не выбирать их заранее.
6. Записать invalidation triggers и следующий разрешённый шаг. Подключение engine и релиз остаются отдельными действиями; 8.3 не обходит 8.1–8.2/9.1.

**Выход:** scope-bound readiness receipt, не разрешение на запуск продукта. **Стоп:** подмена stable promotion подготовительным verdict или попытка скрыть релевантный blocker за backlog.

### 9.1 — Promotion

**Входы:** два pilot receipts, current release policy, compatible schemas и pins.

1. Подготовить compatibility notes, exact artifact hashes, migrations, support matrix и rollback.
2. Проверить каждую строку матрицы этапа 8 в обоих receipts: в том числе разрешённый runtime mode, local/GitHub parity и pre-PR receipt. Required gates имеют достаточное positive/negative evidence; открытых blocker findings нет.
3. Собрать конкретный release candidate и запросить предусмотренное governance approval, если его ещё нет.
4. Выполнять tag/sign/release только в разрешённой фазе с доступной инфраструктурой; не имитировать signature.

**Выход/приёмка:** exact approved version и проверяемая связь с двумя completed pilots. **Стоп:** partial/missing pilot, несовместимость или missing approval. Denied/unavailable runtime/CI не разрешает запуск и не превращается в PASS. Static-only release возможен лишь после отдельного явного решения пользователя об ограниченном scope, изменённых критериях и claims; текущий план такого решения не содержит.

### 9.2 — Распространение

**Входы:** approved release, adoption inventory, consumer overlays и permissions.

1. Сгруппировать repos/worktrees по Git identity и составить migration/conflict report.
2. Для каждого consumer подготовить точный generated-file manifest и backups/hash mapping.
3. Применять ограниченными блоками: apply → post-check → repeat/idempotence → rollback evidence.
4. Проверить новый Git root и fallback; engine opt-in отдельно от universal rules.
5. Partial failure отражать по каждому consumer, не общим success.

**Выход/приёмка:** version pins совпадают, overlays сохранены, unsupported hosts названы. **Стоп:** неизвестный файл под перезапись либо неразрешённый consumer.

### 10.1 — Стоимость контекста

**Входы:** context-cost.json, текущий router, representative routed tasks и evidence bindings.

1. Измерить одинаковые transitive routes до/после; words/bytes не объявлять billed tokens.
2. Сократить duplicate text и обязательное чтение только после проверки authority/permission coverage.
3. Сохранить compact plan/handoff, stable references и read-once/re-read-on-change; историю не включать в Level 0.
4. Проверить sentinel cases маленькой правки, concurrency/data/release и exception.
5. Цель 30–50% оценивать по сопоставимому route; при потере coverage откатить конкретную оптимизацию.

**Выход/приёмка:** измеримое сокращение без пропущенных обязательств. **Стоп:** экономия достигается пропуском необходимого evidence или изменением response contract без разрешения.

### 10.2 — Калибровка Luna

**Входы:** observations с 0.3, результаты 4.3/7.2, завершённые разрешённые задачи разных классов, исправления reviewers, доступная usage telemetry. Это итоговая оптимизация уже наблюдаемого процесса.

1. Начать с уже полученных результатов, не заказывать повторные решения всех задач.
2. Для каждого класса записать размер пакета/patch, misses P1/P2, corrections, evidence sufficiency, usage и elapsed time при наличии.
3. При конкретной слабости сравнить не более двух вариантов процесса на сопоставимом разрешённом примере: меньший patch либо более точный context packet.
4. Выбрать минимальный достаточный процесс; для сложных классов сохранить отдельный review.
5. Не смешивать unknown usage с нулём и не объявлять относительную цену гарантией качества.

**Выход/приёмка:** практические инструкции для Luna, подтверждённые наблюдениями. **Стоп:** эксперимент дороже ожидаемой пользы или требует неразрешённого app/test scope; сохранить консервативный процесс.

### 11.1 — Итоговый аудит

**Входы:** closure map F01–F24, 67 archive decisions, final pins, policy changes и pilot receipts.

1. Для каждой finding указать fixed/accepted/deferred/not applicable и конкретное evidence; решение по файлу ZIP не равно внедрению.
2. Проследить global entry → router → rule → prompt/skill → engine/profile → verdict → release/consumer.
3. Проверить оставшиеся противоречия, исключения, false PASS и реальные pins всех активированных consumers.
4. Провести отдельный Luna review критичных final contracts; reuse неизменного evidence обозначить.
5. Выпустить итоговый статус с runtime gaps и backlog; P0–P2 не закрывать словом deferred без действительного исключения.

**Выход/приёмка:** честная готовность в явно проверенных границах, traceability по всем findings. **Стоп:** missing required evidence, blocker или неподтверждённый independent review.

### 11.2 — Поддержка

**Входы:** release/source dates, missed defects, повторные false positives, изменения Swift/Xcode/SDK/provider contracts.

1. Открывать работу по конкретному trigger, затрагивающему активный контракт.
2. Проверять primary source и affected consumers; обновлять одну норму с version/revisit.
3. Сохранять краткий cost/quality record и evidence, архивировать старую версию вне Level 0.
4. Автоматизацию создавать только по отдельному запросу; не превращать поддержку в постоянный полный аудит.

**Выход/приёмка:** актуальная норма и согласованные consumers на Luna xhigh. **Стоп:** улучшение спекулятивно, повторяет закрытую проблему или не имеет наблюдаемой пользы.

## Шаблон следующего запроса

> Выполни блок <ID> из IMPLEMENTATION_ROADMAP.md и соответствующие микрошаги LUNA_EXECUTION_GUIDE.md на GPT-5.6 Luna xhigh. Перечитай весь актуальный набор документации и правил для этого worktree и task-контекста. Сначала сверь HEAD/dirty state, разрешения и inputs блока; зафиксируй контракт и границы. Реализуй законченный блок, выполни только разрешённые проверки, проверь итоговый diff и обнови существующий handoff. Не меняй модель, не снижай критерии приёмки и не расширяй app/test/release scope без соответствующего разрешения. При реальном блокере дай конкретное evidence и необходимое решение.

Начальная последовательность: **0.1 → 0.2 → 0.3 → 0.4 → 1.1**. Остальные зависимости остаются в roadmap. Установка Luna xhigh в интерфейсе сама по себе не означает одобрение всех будущих тестов, публикаций и app migrations.
