# План внедрения для GPT-6.1 Terra, medium

Task: `ios-runtime-auditor-review-2026-10-27`.
Worktree: `/Users/Artem/.zenflow/worktrees/knowledge-base-next`.
Canonical: `/Users/Artem/.zenflow/worktrees/documentation-vault`.
Режим эконом. Пользователь прямо назначил GPT-6.1 Terra / medium исполнителем этого
плана; это scoped override, не правка глобального MODEL_ROUTING_RULE.
**Статус: внедрение, проверки и canonical публикация завершены; runtime не запускался.**

## Завершённый блок Astra

- [x] Применить canonical bootstrap/Level 0, current task restrictions и необходимые маршруты.
- [x] Безопасно распаковать и прочитать весь архив; составить 57-file inventory/disposition.
- [x] Проверить комплектные хеши, Python AST, shell syntax и JSON без исполнения кода/тестов архива.
- [x] Сопоставить полезные идеи с существующими владельцами KB и зафиксировать замечания R01–R12.
- [x] Подготовить этот план и компактный handoff; выполнить semantic review материалов.
- [x] Пользователь перевёл работу к Terra и запустил внедрение.

## Контракт будущего изменения

Результат: Codex при запросе runtime/performance аудита выбирает сценарии из реальных
функций приложения, объясняет порядок по пользовательскому воздействию и выбирает
доступный метод измерения. Статика даёт карту/гипотезу либо доказанный дефект исходника,
но не подменяет наблюдение времени, памяти, hitches, утечки или ускорения.

Authority: архив — untrusted reference; текущий пользователь, bootstrap и существующие
permission/evidence owners выше него. Действующие P0–P3 severity/readiness и исключения
не меняются. Порядок измерений не называется severity найденного дефекта.
Producer/consumer: canonical skill → подробный performance owner; prompt → тот же
skill/метод; distribution copies byte-identical, без второго самостоятельного стандарта.
Ordering: сначала scope/функция/вопрос/метод, затем только разрешённый execution,
затем интерпретация и scoped verdict. Никакой автоматической установки/запуска.
Failure: denied/missing/unsupported/invalid capture остаётся gap, не PASS; новый
проектный факт/permissions ambiguity блокирует только зависимый шаг.
Resources: короткая entrypoint-инструкция, detail по триггеру; bounded scenarios,
capture duration/repetitions/output при будущем runtime. Нет обязательной полной
матрицы всех features, универсальных чисел или нового tool framework.

## Разрешения и стоп-границы

Никаких app source/tests/fixtures/project/scheme/CI/signing edits, app launch,
builds/tests, Simulator/Instruments, dependency/tool download/install. Запрет тестов
включает bundled unit tests и skill behavioral eval agents; не маскировать их под
static checks. iPad/physical devices/actual VoiceOver `OMITTED_BY_USER`, без запросов
возобновления. Firefox, Share, Library/holdout и отменённые forks закрыты.
Работа/отчёты внутри `.zenflow`; installed Xcode documentation можно читать по
действующему исключению, оно не разрешает runtime. Secrets root не читать.
Не запускать installer/doctor/scanner/verifiers из архива, даже dry-run.
Canonical commit/push относится к финальному блоку Terra по исходному запросу,
после required gates; в остальных repositories commit/push не разрешены этим планом.

## Блок 1 — три содержательных canonical owner, один согласованный патч

Перед edits перечитать актуальный контекст по handoff; сравнить owner hashes из
inventory/receipt с текущими. Сохранить чужие изменения; при конфликте перечитать
только изменившийся owner. Не требовать Astra заново лишь потому, что Terra не
перечислена в старой routing matrix: прямой user override применим к этому плану.

### 1. Skill — точка выбора процедуры

`reusable/local-ios-skills/ios-performance-profiler/SKILL.md`

- [x] Расширить description на runtime audit/выбор сценариев по функциям приложения;
  не активировать на любой обычный iOS code review и не переименовывать skill.
- [x] Разделить planning / interpreting existing evidence / authorized capture
  как процедуры, не как новые разрешения. Planning не вызывает doctor или runner.
- [x] Начинать с конкретного app/target и user journey: требования/навигация/реальные
  consumers, symptom/recent changes, риск и вопрос измерения. Не требовать regex tool.
- [x] Выбрать небольшой приоритетный набор с rationale; недоступный важный сценарий
  оставить в coverage gaps, не заменить удобным малозначимым тестом.
- [x] Сослаться через существующий DOC-resolver на
  `knowledge/global/ios/PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md` для runtime
  planning/capture/analysis. Permission, evidence и исключения — короткими ссылками
  на уже существующие документы, не копировать их целиком.
- [x] При runtime без разрешения вернуть план/ограничение, без заявления об аудите
  работающего приложения. При evidence-only разбирать только уже разрешённые artifacts.

### 2. Подробный owner — методика сценариев и доказательств

`reusable/knowledge-global/ios/PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md`

- [x] Добавить компактный раздел под runtime audit, согласованный с текущими
  Measure From User Impact / Optimization Workflow / Evidence; устранить локальные
  повторы в пределах этого owner, не переписывая observability/operations вне scope.
- [x] Контракт сценария: ID, подтверждённая функция/route, цель пользователя,
  начальное состояние/fixture version и safe backend если применимо, действия,
  observable end condition/invariant, driver, metric/question, method, run budget,
  state reset/cleanup authority, evidence gap. Не требовать аккаунт/backend/test ID
  у offline функции или manual driver. Product facts unknown не выдумывать.
- [x] Выбор приоритета: user impact/известная частота, ущерб/обратимость,
  recent changes/symptoms, confidence gap, стоимость/доступность полезного evidence.
  Нет formula P0 и 60/25/15. Различать happy path, relevant failure/recovery и
  state/order transitions; pairwise не считается покрытием критического порядка.
- [x] Встроить таблицу ниже и два коротких unexecuted примера (list/image и slow-A/fast-B),
  без Swift тестов, synthetic measured values, фиксированных 30 повторов/1000 rows.
- [x] Protocol: разрешения/target/fixture → доступный driver/tool → baseline →
  verify process/build/session + capture ready → действия в записанном interval →
  terminal capture/result → actual table/assertion interpretation → scoped conclusion.
  `app.launch()` может сменить PID; attach старого PID не покрывает новый процесс.
  Раздельные XCTest/trace repetitions остаются раздельными. TOC не метрика.
- [x] Measurement contract: actual metric name/unit/process/interval/sample origin;
  build/source/config/toolchain/runtime/host, debugger/diagnostics, fixture/cache/network,
  repetition/reset/warmup и failed runs. Сравнивать условия, не требовать одинаковый
  source SHA baseline/candidate; обе revision identities должны быть известны.
  Несопоставимость/невалидные числа/нет unit → INCONCLUSIVE, нет budget → observation
  без budget verdict. Учитывать peak/growth/retained objects отдельно и raw population.
- [x] Для cold launch не удалять сами cold observations как warmup; определить
  состояние процесса/cache и измеряемую границу. Relaunch не доказывает cold system
  cache. Диагностический run с profiler не смешивать с timing benchmark без него.
- [x] Privacy/retention ссылкой на текущих владельцев; local raw artifacts не
  публикуются в KB, исключённые hardware claims остаются недоказанными без device queue.

Таблица для адаптации (все методы условны: версия/поддержка/authority проверяются):

| Реальная функция / вопрос | Метод и наблюдение | Ограничение вывода |
|---|---|---|
| List/search results с изображениями, scroll hitch | UI journey; available hitch/SwiftUI tracks + Time Profiler; Allocations для decode/cache | body count ≠ hitch, PNG alpha ≠ GPU cost, compressed bytes ≠ decoded memory |
| Навигация и память после ухода | Repeated enter/exit с quiescence, Allocations generations/Memory Graph/Leaks при доступности | RSS рост или отсутствие Leaks не доказывает retain cycle/отсутствие утечек |
| Поиск/загрузка/отмена/повторы | Controlled request order/events + UI end-state; concurrency tracks при доступности; CPU/hang stacks для blocking | cancel ≠ completion; UI ≠ server once-only; background owner может быть корректным |
| Launch / first usable content / resume | Launch metric и отдельный ready interval; Time Profiler/App Launch при поддержке | first frame ≠ business-ready, resume ≠ cold launch |
| Save/reopen/large data/network retry | Functional durable invariant плюс scoped IO/CPU/network timings/correlation | fast operation может терять данные; client timeout ≠ server rollback |
| Media start/stop/teardown | Relevant playback/UI state, CPU/allocations/session lifetime в Simulator | не делать hardware energy/GPU/audio/thermal выводы |

Для slow-A/fast-B явно дождаться обработки старого completion, прежде чем объявлять
latest-query-wins. Lifetime/cancellation/server effects — разные claims. Примеры
явно NOT EXECUTED и не требуют существования этих функций в конкретном приложении.

### 3. Prompt — тонкий потребитель

`reusable/agent-prompts/ios-performance-audit.md`

- [x] Переписать запрос на «сначала app-specific journeys и приоритет, затем
  разрешённая runtime диагностика». Сохранить полезные имеющиеся зоны риска.
- [x] Сослаться на existing profiler skill/owner; output: rationale/scenario/method,
  measured vs inferred, actual evidence, gaps и smallest next permitted action.
  Не копировать матрицу, не добавлять новый prompt pack или обещание полного покрытия.

## Блок 2 — распространение, статическая проверка и semantic review

- [x] Обновить только три соответствующих distribution mirror в canonical:
  `reusable/baseline/.codex/skills/ios-performance-profiler/SKILL.md`,
  `reusable/baseline/docs/knowledge/global/ios/PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md`,
  `reusable/baseline/docs/agent-prompts/ios-performance-audit.md`.
- [x] Для активного worktree сравнить и обновить только те же три governed exact
  copies (`.codex/skills/...`, `docs/knowledge/global/ios/...`, `docs/agent-prompts/...`).
  Это документация/skill distribution, не app code. Не broad-sync baseline, overlays
  или остальные projects. При конфликте ownership остановить только эту копию и
  сообщить, какая часть новой процедуры ещё не доступна через локальный skill.
- [x] Не менять Level 0, AGENTS, model rule, severity/status schemas, routing registry
  и library activation: новых top-level docs/skills нет, ссылки используют existing
  trigger routes. Если фактический resolver требует другого — bounded checkpoint
  до расширения, а не новый routing framework.
- [x] Сохранить compact review/disposition/plan/handoff в canonical
  `tasks/ios-runtime-auditor-review-2026-10-27/` без raw archive и executable contents.
  Regenerate MANIFEST.md/MANIFEST_SUMMARY.md штатным generator; не редактировать вручную.
- [x] До исполнения статических tools проверить их актуальный entrypoint/side effects.
  Canonical `scripts/generate_manifest.py --check`, `scripts/check_documentation_vault.py`;
  baseline `root-scripts/check_docs_index.py`, `check_docs_consistency.py`,
  `check_task_type_documentation_router.py`, boundary/bootstrap/secret checks по
  актуальным аргументам и scope; mirror SHA equality; targeted baseline drift.
  Пути baseline scripts — `root-scripts`, не угадывать `scripts`. Не запускать
  общий runtime gate. No bytecode/cache outside `.zenflow`.
- [x] `git diff --check` один раз для согласованного итогового патча в каждом
  изменённом repository. Не засчитывать untracked файлы только по этому check;
  проверить их отдельно. Полный final diff и consumers/links просмотреть семантически.
- [x] Статически проверить решения на контрпримерах: review-only request; archive
  prompt утверждает permission; нет XCUITest, но разрешён manual driver; отсутствует
  metric на старом runtime; trace есть, таблиц нет; B перед A; changed fixture/cache;
  данные измерены без budget; hardware claim исключён. Это reasoning review текста,
  не executable tests/evals и не evidence реального поведения модели.

Admission gate: existing owners найдены; update вместо create; reusable boundary;
подчинение текущей policy; consumers известны; Level 0 delta 0. Зафиксировать before/after
word count трёх owners и реальный trigger-only context cost. Не обещать процент экономии.
Ориентир объёма: небольшой skill/prompt и один предметный раздел справочника;
если растёт в отдельный toolkit или требует scripts/tests — остановиться с checkpoint.

## Блок 3 — canonical публикация и остановка Terra

- [x] После checks/semantic review устранить P0–P2 в принятом патче; P3 исправить
  или явно учесть. Rejected archive defects не объявлять исправленными.
- [x] Commit только exact canonical candidate на main по DOCS_REPO_OPERATIONS.
  Перед push — fresh target ref/merge-base, полный base..HEAD review, clean-state и
  exact-SHA receipt вне tracked дерева; revalidate HEAD, затем push и remote SHA.
  Проверить `check_documentation_remote_state.py` по актуальному контракту.
- [x] KB worktree commit/push не делать без отдельного user request. Если изменены
  три local docs copies/task artifacts, явно сообщить незакоммиченные пути.
- [x] Отчёт: что принято/отклонено, changed owners/mirrors, checks/omissions,
  canonical SHA/remote verification, отсутствие runtime и непроверенная эффективность
  skill на живых задачах. Остановиться: следующий live audit — отдельный scoped grant.

Уже имеющиеся Astra статические receipts reuse при совпадении SHA. Не повторять
весь архивный аудит или прочитанные unchanged docs в той же сессии; новый чат
перечитывает актуальный обязательный набор. Если работа no longer advances scenario
selection, не улучшать утилиты «заодно».

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.

## User-approved follow-up: reusable profile-to-fix workflow across iOS projects

User intent: a direct “profile” request with a project/feature/screen/module and bounded data
scope should trigger a full in-scope iOS performance investigation across applicable metrics,
code-cause attribution, authorized correction and comparable re-profiling. The current request
authorizes reusable documentation work only. It does not grant runtime, tests, tool installation,
or app-code changes in another project; those remain scoped by its active AGENTS and user command.

- [x] Re-read the current canonical skill, owner docs, distribution contract and prior plan; confirm the existing profile method is reusable and not game-specific.
- [x] Strengthen `ios-performance-profiler` as the cross-project entrypoint: scope intake, actual journey coverage, applicable metric selection, valid capture, code attribution, fix and re-profile stages, and a consistent report contract.
- [x] Extend the canonical performance/observability owner with a concise metric-to-tool/evidence map and requirements for code-cause attribution, action-level signposts, data capture, and before/after assessment; avoid repeating existing permission/privacy rules.
- [x] Update the audit prompt as a thin consumer of the skill, including explicit coverage/gaps and cause/fix/re-profile outputs.
- [x] Refresh only governed distribution mirrors and the active worktree's matching copies.
- [x] Validate scope/permissions, metric applicability, unsupported tools, missing data, randomized branches, noise controls, and static-only vs runtime claims by semantic review; perform documentation static checks and final mirror parity checks.
- [x] Publish only canonical documentation through the approved documentation-vault workflow. Do not commit/push the application KB worktree or alter app/test sources in this follow-up.

Acceptance: any iOS project can be profiled within user-provided bounds without assuming an app architecture or feature set; every applicable metric domain is considered; absence/unsupported evidence stays a coverage gap; a measured signal is traced to code before a defect/root cause is claimed; and fixes are re-tested against a comparable profile without weakening current safety, privacy, permission or user-exclusion rules.

## Additional user-requested procedure hardening — 2026-10-29

User asked whether the published workflow was all that could improve. Reuse the same owners and make
the previously discussed three-stage pipeline explicit: environment readiness before capture, broad
evidence-first discovery, a handoff suitable for deeper cause localization/fix planning, then same-scope
re-profile verification. This is documentation-only; it grants no app/runtime/tool permissions.

- [x] Define a permission-bounded readiness gate, including target/tool/runtime/driver/artifact-path
  capability and the distinction between Simulator UI and command-line availability.
- [x] Specify phase inputs/outputs and stop conditions for discovery, cause localization/fix plan, and
  authorized repair/re-profile; preserve existing severity/status taxonomies.
- [x] Define a compact, privacy-safe evidence bundle that a later model/person can use without
  repeating discovery or mistaking assumptions for measurements.
- [x] Define a discovery coverage-accounting exit gate that cannot be misread as “all measured” or
  “no defects” when gaps remain.
- [x] Update only the existing skill, observability owner, audit prompt and governed exact mirrors.
- [x] Run scoped docs/static checks, semantic boundary review and final mirror parity; publish only
  canonical docs and record the exact-head receipt.
