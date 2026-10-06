# P0–P1: исходные ограничения и выбор подхода

2026-10-07. GPT-6.1 Sol/medium, эконом. Task-only evidence; не новая reusable policy.
Полномочие старта: «Приступай к реализации плана созданного астра».
Источники и 34 точных payload hash: [baseline-permissions.json](baseline-permissions.json).
Статус: P0 принят в статической области; P1.1 выполнен как ограниченный аудит; P1.2 ACCEPTED_BY_USER: V2. Контракты P1.3 и подготовка P2: [следующий блок](v2-contract-and-evaluation-preparation.md).

## 1. Подтверждённые проблемы и гипотезы

| ID | Ожидание → наблюдение | Что подтверждено | Возможная причина и следствие для решения |
|---|---|---|---|
| D1 | ON должен добавить reference pass → Firefox routes NOT_READ | `pair-adjudication.json`: активное содержимое не прочитано | Разрыв доставки/исполнения. Нельзя сначала наращивать содержание, не проверив путь получения |
| D2 | Review укладывается в limit → ON 2 766 356 ms против limit 1 200 000 ms; OFF 454 443 ms | Превышен прежний time gate; tokens UNKNOWN | Причинная доля overhead Library неизвестна, ведь reference не прочитан. Нужны ограничение времени, полный ledger и ранний delivery check |
| D3 | ON даёт новое подтверждённое инженерное знание → Tchop: 0 new defects, 0 actionable code delta, 2 refinements | `library-delta.json`: полезная калибровка evidence, без строгого causal результата | Уточнение обоснованности полезно, но повторные общие проверки могут не давать дополнительного outcome. Проверять качество решения, FP и rework |
| D4 | История объединена → пользователь видит 36 440 untracked после checkout | Git closeout и опубликованный ignore fix подтверждают пропущенный acceptance block | Ошибка consumer/result проверки, не доказанный недостаток справочных знаний. Проверять реальный пользовательский checkout, а не вводить общее новое правило по инциденту |
| D5 | Distribution соответствует canonical → 1 missing + 32 stale сейчас | Drift check: 148 exact, 29 overlays, 1 missing, 32 stale, 0 unexpected, 0 failures; совпадает с прежним перечнем | Maintenance/deployment риск. Canonical bootstrap защищает routed docs, но project skill mirrors могут давать старый trigger/контекст. Точечный разбор перед обновлением; не blanket sync |
| H1 | ON приносит дополнительное содержание | В исследованных core/concurrency/review документах есть пересечение с KB; это содержательная оценка, не доказательство вреда | Заменить повторное описание норм конкретными mechanisms/examples; измерять фактически прочитанный контекст |
| H2 | Подробности легче правильно применить | В выбранных активных маршрутах есть checks и нюансы, но нет исполняемых before/after-примеров этих механизмов | Практический модуль может помочь Sol/medium; это ещё непроверенная гипотеза |

Все пять D — реальные наблюдения, не пять независимых доказательств бесполезности Library. D1/D2 принадлежат одной прежней паре. Стоимость ошибок и частота будущих задач UNKNOWN. Новых дефектов приложений этот аудит не устанавливает.

## 2. Входы и границы baseline

- Общая цепочка: root AGENTS → canonical GLOBAL_RULES_BOOTSTRAP → baseline AGENTS/router → Level 0 → selected routes → triggered deep reference. Канонический commit `a521aa5a5dc036f6955cfb326ad290ad27ef264b`.
- Library: reviewed project entry → STARTUP_RULE → PROJECT_MODE → KNOWLEDGE_ROUTER → core + selected thematic route. Прочитаны canonical STARTUP/PROJECT_MODE и содержательно выбранные concurrency/review/data/performance/safety routes. Handler не выполнялся, состояние проектов не менялось.
- Два существующих project payload (BattleshipGame, TchopApp): все 34 файла побайтно соответствуют нынешнему canonical payload. Это identity evidence, не новый pilot или принятие этих проектов. Вариант A восстанавливается из опубликованного Git SHA и перечисленных hashes, не из будущих live canonical files.
- Shared KB и Library имеют разную authority. KB хранит обязательную норму; Library советует её применение, не авторизует действие. Project memory хранит факты selector/root/SHA, не общую policy.
- Архивные исходные playbooks вне allowlist не подключены. Существующие source-family архивы не прочитаны как активная policy. Увеличение allowlist требует provenance, neutralization и проверки ссылок.

## 3. Ограниченный аудит содержания и действий

| Материал | Наблюдение | Действие-кандидат и владелец | Потребители и проверка перед изменением |
|---|---|---|---|
| Library QUALITY_STANDARD / core | Повторяет contract, authority, permissions, evidence и whole-diff review, уже заданные baseline | Оставить краткую ссылку на KB; уникальные применимые нюансы сохранить. Norm owner — KB, practical owner — Library | STARTUP_RULE, KNOWLEDGE_ROUTER, REVIEW_GUIDE, quickstart и project entrypoints; поиск всех входящих ссылок при patch |
| Library concurrency route | Полезные нюансы weak→strong across await, success/error identity и continuation ordering, пересечение с KB deep reference | Уточнить роль; добавить bounded practical module с контрпримером; не удалять нынешний route до parity | Router, выбранные project copies, relevant module; positive/negative scenarios |
| Library review route | Evidence calibration подтверждена TC-MP01; много general review text | Сохранить calibration; вынести прикладной алгоритм «доказать caller/input/reachability» с примером ложного замечания | REVIEW_GUIDE/router; проверить trace и oracle false positives |
| Library data route | Есть interrupted/retry/rollback considerations сверх короткого KB стандарта | Сохранить unique nuance; практический рецепт cancellation/rollback после выбора первого механизма | Router, storage consumers выбранной задачи; не обещать schema compatibility по тексту |
| Library performance route | Сильное различение static suspicion/measured effect; нет конкретного bounded recipe выбранного media case | Сохранить evidence distinctions; практический модуль — после подтверждения workload | Router; representative scenario, resource envelope, negative case |
| Project mode/startup | Явные safety границы, но ещё одна цепочка и обязательный local-first/reference pass | Сохранить identity и полномочия; рассмотреть адресную доставку без повторного полного core | Existing entrypoints/handler/state schema; изменение mode identity не требуется для первого модуля |
| Missing/stale project mirrors | Точный перечень известен; current canonical authority применяется прямо | Разобрать только consumer, нужный выбранному блоку; overlays сохранить | Skill triggers, bootstrap checker, baseline policy; обновление отдельным согласованным patch |

Никаких удалений/переносов сейчас не сделано. Таблица не даёт разрешения удалить уникальный материал. Полный consumer search и migration gate выполняются при конкретном patch. Наличие части unique Library nuance не доказывает её дополнительную пользу на исходах.

## 4. Двенадцать предварительных диагностических запросов

Это **статическая проверка discoverability и правил выбора**, не 12 независимых запусков Sol и не продуктовый benchmark. Вопросы и ожидаемые направления ниже проверены против нынешних router/core и выбранных текстов; P2.1 фиксирует итоговый набор и oracle до эксперимента. Подробные темы, не выбранные для содержательного аудита, не считаются полностью проверенными.

| ID | Вопрос | Статически найденный путь / правильное ограничение |
|---|---|---|
| Q01 | Старый async результат перезаписывает новый state: где искать решение? | KB concurrency → deep reference; Library concurrency. Доступны нормы ordering/identity, практический before/after отсутствует в выбранном маршруте |
| Q02 | Отмена попадает в catch и показывается как ошибка: что проверить? | Те же маршруты: cancellation и error semantics; выяснить current product contract, не предполагать cancel как success |
| Q03 | Миграция прерывается после частичной записи: можно ли reset? | KB migration + Library data. Reset требует data authority; old/partial/retry/reopen evidence, не только clean install |
| Q04 | Лента использует тяжёлые изображения: какой cache budget нужен? | KB memory + Library performance. Численный бюджет нельзя получить без decoded workload/resource envelope |
| Q05 | Review нашёл потенциальный stale overwrite: можно ли ставить P1? | Engineering contract + Library review; trace caller/range/reachability, static gap не доказывает current impact |
| Q06 | После merge пользователь видит untracked: достаточно ли ancestry PASS? | Git scope + repository-safety guidance; нужен actual checkout/status, сохранность локальных файлов, ignore consumers |
| Q07 | В одном repo два Xcode проекта: наследует ли второй ON? | PROJECT_MODE/STARTUP: точная selector identity; не наследует |
| Q08 | Нужный документ отсутствует: читать старый installer как fallback? | KNOWLEDGE_ROUTER: нет; missing reference не PASS; canonical/bootstrap fallback только по действующему контракту |
| Q09 | Исправление одной опечатки в task-документе требует всей iOS Library? | Нет соответствующего инженерного trigger; doc/task governance, без новой project activation |
| Q10 | Просят iPad/реальный VoiceOver для завершения текущего task | CURRENT_USER_OVERRIDES: OMITTED_BY_USER, не PASS, не required follow-up |
| Q11 | Root/SHA изменился, память содержит старый PASS: можно ли использовать? | Bootstrap/current task + freshness; revalidate dependency; старый результат не восстанавливает grant |
| Q12 | Запрос «ускорь всё приложение» без сценария | Performance guidance: сначала определить symptom/workload; не broad optimization, не произвольный cache/actor rewrite |

Q09–Q12 — negative/ambiguous/stale controls. Пути обнаружимы статически; своевременность чтения и правильное применение моделью пока NOT_MEASURED. Это существенная граница: документация явно предлагает второй проход после local stage, и прежний Firefox ON не дошёл до активных маршрутов.

## 5. Три конкретных варианта P1.2

Обозначения V1–V3 относятся к архитектуре; experimental A/C — текущая/улучшенная система, а B — diagnostic ablation. Эти буквы не смешивать.

| Вариант | Изменение | Польза-кандидат | Стоимость/риски | Обратимость |
|---|---|---|---|---|
| V1 — точечное улучшение | Сохраняем second-pass структуру; добавляем 1–2 подробных рецепта и исправляем выбранный drift | Самый малый patch; уточнение advice | Повторное core чтение и поздняя доставка остаются; может снова не дать outcome | Высокая, мало consumers |
| V2 — адресная практическая связка **(рекомендовано)** | KB остаётся нормой; Library entry выдаёт короткий relevant module до инженерного решения; уникальные nuance сохраняются, дублирующее core заменяется ссылками после проверки | Больше полезной конкретики и меньше повторов; можно отдельно проверить delivery/content/application | Потребуется изменить selected router/core consumers и проверить equivalence норм; medium complexity. Начать одним модулем, не массовой миграцией | Высокая при versioned payload, старый A сохранён |
| V3 — индекс/поиск и дополнительные checks | Добавить более сложный поиск или малый read-only checker, если простой маршрут объективно не справляется | Может закрыть measured discoverability/recurring deterministic failure | Highest maintenance и новая executable surface; полномочия tools/MCP отдельно. Сейчас нет evidence, что indexed search решает D1/D2 лучше V2 | Средняя; больше новых consumers/outputs |

Оценка токенов и недельного расхода UNKNOWN; V1 требует меньше изменений, V2 — больше semantic/consumer проверки, V3 — ещё implementation и runtime/tool evidence. Нельзя из этого обещать экономию подписки. Для V2 предлагается сначала ограниченный design/module block, затем P2 выбирает бюджет дорогой серии; 110 attempts автоматически не запускаются.

### Два прохода сценариев для выбора

**S1 — async stale/error.** V1: исполнитель сначала делает KB pass, затем читает core + concurrency и новый recipe; локальное решение может уже быть сформировано. V2: после authority/task setup получает короткий module, устанавливает owner/cancellation/identity success+error до patch, подробности по ссылке; итоговый review проверяет тот же контракт. V3: поиск должен найти такой же module, но добавляет индекс/verification boundary. Для каждого рецепт должен отвергать ложный вывод из одного `await`, если lifetime producer исключает stale state. Сценарий пока walkthrough, не измеренный run.

**S2 — сохранность Git результата.** V1: safety second-pass напоминает inspect status, но history completeness может снова быть ошибочно выдана за consumer result. V2: короткая task-specific decision card различает reachable history, active file content и actual checkout/ignored data; предотвращает ложный clean claim на конкретном boundary. Не вводится новое глобальное правило по одному инциденту. V3: checker может автоматически сравнить exact pending/ignore/refs, но оправдан только повторным объективным failure и измеренной ценностью. Существующие Git команды уже позволяют проверить контракт без нового инструмента.

## 6. Предлагаемый первый блок после выбора

Контракты слоёв: KB — authority/invariants; Library — mechanisms/examples/diagnostic recipe; project memory — current facts; delivery — relevance/version; evaluation — outcomes. Изменение experimental payload не изменяет grants.

Предлагаемый первый модуль: **cancellation + stale-result publication**, затем conditional-error calibration. Основание: подтверждённая TC-MP01 calibration и существующая applicability в concurrency/data; independent new cases ещё нужно выбрать. Media/resource limits и migration/rollback — следующие кандидаты, после реального case inspection. Git preservation оставить boundary scenario, не создавать новый framework.

Пользователь выбрал V2. До P3/P4 P2 определяет задачи/oracle и бюджет разработки. Нельзя подготовить holdout-ответы здесь: этот чат автор improvements. Конкретное предложение независимого куратора и границы блока сохранены в следующем документе; агенты/MCP не созданы.

## 7. Приёмка и drift-check этого блока

- P0.1: scope/authority/clean identities установлены; последующие doc/static actions покрыты.
- P0.2: canonical revision, 34 payload hashes, оба exact copy сравнения и текущий drift сохранены; запусков Library/режимов нет. Execution envelope freeze ещё P2.
- P0.3: пять confirmed observations и две явно обозначенные гипотезы со ссылками на source evidence.
- P1.1: ограниченный content/authority audit и 12 static diagnostic questions; рекомендации migrations остаются proposal, effect NOT_MEASURED.
- P1.2: comparison и два walkthrough готовы; пользователь принял V2.
- P1.3: contracts/backlog сохранены в следующем документе; эффект ещё не измерен.
- Drift: не добавлены постоянные rules, installers, sources, новый search/agent platform; архив и holdout не превращены в активный input. Польза всей системы ещё не установлена.
