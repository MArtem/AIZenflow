# План завершения библиотеки — финализация Luna Xhigh

## Текущий статус на 2026-09-15

- [x] Локальные блоки A–F доведены до согласованного поведения; новые regression cases для
  package identity и source-in-place selector switch/rollback проходят.
- [x] Candidate и canonical source синхронизированы на `5.4-review-ready.7`; package identity:
  `af0e182be06836917566b79ae3d322519bf595fa64630516392f5b2a3e317475`.
- [x] Structural validator: `1366 files / 60 skills / 51 sections / 288 playbooks / 0 errors`.
- [x] Финальный serial suite: `196 total / 191 PASS / 0 FAIL / 5 SKIP`; пять host-dependent
  positive cases остались `NOT_RUN` из-за home-level Git root над разрешённым `.zenflow`.
- [x] Existing canonical repository runtime обновлён штатным `sync_global.py` через exact
  `.codex-runtime/ios-engineering` exception; post-sync validator и installed shim doctor PASS.
- [x] Новый portable archive создан рядом с историческим archive и проверен byte-for-byte:
  `.../iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY_LUNA_XHIGH_IMPLEMENTED_V17.zip`.
- [ ] Независимая Astra-приёмка, реальный fresh first-entry Codex Desktop и три user-owned pilot
  tasks не выдавать за выполненные: этот CLI не имеет наблюдаемого доступа к active desktop
  process/host discovery, а user-run pilot ещё не запускался.

Обычный Git-boundary остаётся fail-closed. Узкое исключение действует только для
`MArtem/AIZenflowDocumentation` и exact `<repo>/.codex-runtime/ios-engineering`; это не
разрешение для других Git-репозиториев. Старые evidence/reviews/archives сохраняются как
история и не являются текущим PASS. Новых функций/подсистем не добавлять.

Дата: 2026-09-15. Task: new-task-be0b. Режим: эконом. Исполнитель: Luna Xhigh.
Следующий безопасный шаг после этой локальной финализации — independent review или user-run
host/pilot acceptance; при передаче контекста обязательно:
**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

## Цель и текущая точка

Доставить рабочую самостоятельную библиотеку с двумя способами развёртывания:
ручное подключение и installer. Общие существующие знания должны поступать в текущие
и будущие проекты в согласованной области. Новый iOS-корпус выбирается по типу задачи.
По умолчанию подключаются знания/review guidance; protection требует отдельного выбора.
Проверяем конечный путь: подключение → обычная работа → обновление → отключение.

FINAL7 — неизменяемый вход ревью:
SHA-256 fe3fa9c1800ba0902b48918df9543f16eb6e75d189122f63d168d53a08cd4b44.
Статус NOT_READY; F7-01..06 открыты. 1366 архивных файлов сверены Astra; 173/173 —
исторический PASS Luna на FINAL7, а не доказательство исправлений после него.

Корень task: /Users/Artem/.zenflow/worktrees/new-task-be0b
L = /Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54
C = L/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY
V = /Users/Artem/.zenflow/worktrees/documentation-vault
Далее пути C/... и L/... разрешаются относительно этих точных корней.

## Обязательный режим исполнения

1. Одна команда на реализацию запускает ТОЛЬКО первый разрешённый непринятый блок.
   Сейчас это A. Закончив его, Luna передаёт результат на ревью и не начинает B.
   Это согласованная контрольная остановка, а не требование нового разрешения на каждую правку.
2. Внутри блока Luna самостоятельно доводит исправление и адресные проверки до результата.
   Обнаруженный дефект исправления относится к тому же блоку; не создавать новый большой план.
3. Перед правкой назвать поведение, изменяемые файлы и выбранные проверки в нескольких строках.
   Если решение требует новой архитектуры/неизвестной authority — локализовать вопрос,
   сохранить конкретный анализ и передать Astra; не изобретать новый механизм.
4. В одном кодовом проходе обычно 1–2 production-файла плюс адресные тесты. Не начинать
   соседнюю подсистему. Указанные ниже подпункты manual/scanner выполнять отдельными проходами.
5. Astra проверяет полный diff блока, непосредственные вызовы, инструкции-потребители и
   доказательства. Результат: ACCEPTED либо RETURNED с конкретным незакрытым инвариантом.
   Нельзя назвать блок принятым только по зелёным тестам или собственному мнению Luna.
6. После ACCEPTED следующий блок выполняется по команде продолжения на Luna. Принятый блок
   не открывается заново без изменения его входов/кода или конкретного нового воспроизведения.
   В итоговой проверке проверяются связи между блоками, а не повторяется весь аудит корпуса.
7. Новую находку привязывать к F7-01..06, если она относится к тому же дефекту. Другой вопрос
   добавляется в обязательную работу только при доказанном влиянии на согласованный путь.
   Неблокирующие улучшения — backlog; новые возможности исключены.

## Экономия проверок и документации

- Только адресные проверки поведения текущего блока, затем один git diff --check.
  Для untracked candidate отдельно проверять изменённые файлы; пустой Git diff не является review.
- Тесты этого candidate разрешены в рамках прежней test-writing authority; app/iOS tests не трогать.
  Проверка должна воспроизводить дефект и проходить после исправления; не подменять её grep текста.
- Существующие tests с неверной структурой fixtures можно адресно исправить. Синтетические
  разрешённые destinations располагать вне Git-репозитория, внутри /Users/Artem/.zenflow.
  Не добавлять production-исключение ради fixtures. Для filesystem permission использовать
  штатное точное согласование инструмента, не обходить sandbox.
- Полный suite и итоговый package validator — после принятия локальных блоков. Раньше запускать
  только когда конкретная новая зависимость/ошибка требует их, с кратким объяснением.
- PACKAGE_FILE_MANIFEST обновлять при необходимости адресной manifest-зависимой проверки;
  не ослаблять её. Финальные totals/report обновить после фактического финального запуска.
- Между блоками не создавать ZIP, не повторять V11 smoke при неизменном admission, не перечитывать
  всю библиотеку, не синхронизировать её целиком, не переписывать весь evidence.
- После блока обновить одну строку статуса ниже и короткую запись в handoff: scope, changed paths,
  поведенческие результаты/exit codes, точный diff/hash входов ревью, ограничения. До 15 строк
  на результат. Astra добавляет verdict к этой же записи.
- Не создавать отдельную систему receipt/benchmark/review automation.

## Статусы

| Блок | Дефект/результат | Luna | Astra |
| --- | --- | --- | --- |
| A | destinations и override; F7-02 | corrected; external positive integration NOT_RUN on this host | pending independent re-review |
| B | общее подключение: конкретная подготовка; F7-01 | proposal complete; host mutation not authorized | pending independent acceptance |
| C | profile и контекст дублей; F7-04 | implemented; targeted PASS | pending independent re-review |
| D | protection только по выбору; F7-05 | implemented; policy/runtime tests PASS | pending independent re-review |
| E1 | manual ownership и проверка обновления; F7-03 | implemented; receipt fixtures PASS | pending independent re-review |
| E2 | manual реальный lifecycle reference/full; F7-03 | runbook + canonical profile implemented; real host lifecycle NOT_RUN | requires canonical-host acceptance |
| F1 | bounded profile observation; F7-06 | implemented; targeted PASS | pending independent re-review |
| F2 | bounded manual observation; F7-06 | implemented; targeted PASS | pending independent re-review |
| G | общая приёмка, подключение и реальный pilot | TODO | pending |

Подблоки E/F делят уже найденные дефекты на меньшие проходы; это не новые требования.
B имеет первый продуктовый приоритет сразу после уже согласованного узкого исправления A.
Если точная host-authority доступна, common host activation из G можно выполнить сразу после
принятия B; она не требует установки candidate runtime. Иначе продолжить независимые C–F.

## A — точное первое задание: закрыть F7-02

Ревью Astra commit 74d65141: RETURNED. Следующее исправление остаётся внутри A:
- [x] Устранить зависание при FIFO AGENTS.override.md: installer открывает его O_RDONLY
  до fstat. Проверять тип безопасно, учитывать замену regular→FIFO между проверкой/open;
  для no-follow открытия использовать неблокирующий режим с последующим fstat.
  Оба настоящих CLI должны закончить отказом в ограниченное время, без writes/fallback.
- [x] Убрать абсолютную привязку shipped tests к /Users/Artem и глобальный monkeypatch
  I._git_root_for_destination. Корень fixture задаётся явно оператором; на этой машине
  он остаётся внутри .zenflow. Моки допускаются только локально в обозначенных unit tests.
  End-to-end PASS требует настоящих CLI без подмены проверяемой Git boundary.
  Если нет разрешённого пути вне Git root, записать NOT_RUN для positive integration,
  сохранить unmocked negative checks и продолжить независимый B; не создавать исключение.
- [x] Обновить handoff/report: финальный self-test 188 total / 184 pass / 0 fail / 4 NOT_RUN —
  self-test с изменённым harness,
  не доказательство deployability. После патча повторить только затронутые проверки;
  итоговый общий suite остаётся в G. Полный corpus импортирован в 74d65141, push не выполнен.

Последующая команда пользователя разрешила продолжать все блоки и commit/push: она отменяет
старые обязательные остановки между блоками, но не превращает self-test в принятие Astra.
После адресной коррекции A идти по существующим B, C, D, E1/E2, F1/F2, G без нового плана.
Git-managed home на текущем Mac остаётся отдельным вопросом размещения реальных destinations;
до его решения не заявлять готовность установки в .zenflow. Не удалять/не менять домашний .git.

Файлы: C/install_global.py, C/MANUAL_SHIM/bin/manual_preflight.py,
адресные случаи C/tests/test_review_ready.py, C/validate_package.py,
C/GLOBAL_MANIFEST.json, C/REVIEW_READY_VALIDATION_REPORT.md, C/PACKAGE_FILE_MANIFEST.json.

Результат коррекции: serial suite `total=188 pass=184 fail=0 skip=4`, package validator
`errors=0`; 4 skip явно обозначают отсутствующий на текущем host путь вне любого Git root.

Поведение:
- Ни одна mutable destination внутри Git-репозитория не становится допустимой из-за
  environment CODEX_HOME, default skills path или того, что source лежит в этом же repo.
- Читать source из repo допустимо; изменять его или размещать там deployment targets — нет.
- Сохранить полезные source-in-place и copied-runtime варианты с внешними destinations.
- Сохранить проверку пересечения source/targets и допустимое вложение управляемых путей в home.
- Непустой AGENTS.override выбирается раньше AGENTS.md. Слишком большой, нечитаемый,
  symlink или non-regular override приводит к отказу до writes, а не к смене назначения.
  Отсутствующий override — нормальный fallback. Empty override обработать по текущему
  подтверждённому host-контракту, одинаково в обеих реализациях.
- Не добавлять поддержку Git-managed home или новую настройку исключений в этом блоке.

Минимальные поведенческие случаи для обоих preflight:
1. CODEX_HOME указывает на target внутри client repo → отказ.
2. Source и target внутри одного repo, но в разных папках → отказ.
3. Git worktree с .git-файлом → отказ для target внутри него.
4. Внешний target вне repo → PASS при остальных допустимых входах.
5. Независимые targets пересекаются → отказ; штатные managed children home допустимы.
6. Непустой override + явный обычный AGENTS.md → effective override.
7. Oversized/нечитаемый/non-regular override → отказ, AGENTS.md не выбран для записи.
8. Отказы не создают targets; существующие данные сохраняются.

Контроль: проверить build_preflight/build и вызывающий update/sync потребитель на совместимость,
но не исправлять manual lifecycle/profile в этой итерации. Принимать одинаковые outcomes,
а не только отсутствие подстроки в коде.
Выход A: patch + результаты адресных проверок → СТОП ДЛЯ РЕВЬЮ ASTRA.
Не устанавливать на реальный host, не коммитить, не пушить, не собирать ZIP.

## B — закончить подготовку общего подключения F7-01

Вход: common-host block из evidence 27. Готовы evidence/22-host-entrypoint-preview.md и
evidence/28-common-host-canonical-diff-proposal.md с локальным конкретным diff к canonical
bootstrap/template/checker; реальный host/canonical checkout не изменён.
- Исправить iOS-only общий вход: common baseline для всех task types внутри .zenflow.
  Новый iOS-candidate блок остаётся тематическим и отдельным.
- Установить точные существующие canonical consumers, подготовить совместимый diff:
  host доставляет знания, root marker обеспечивает переносимость и проверку adoption.
- Не объявлять actual discovery успешным по тексту или наличию marker.
- Показать exact host targets, fallback, отключение и сценарии fresh-session.
  Проверить старую authority; вне .zenflow читать/менять только уже явно разрешённые пути.
- Если exact read authority отсутствует, результат — полный local proposal и одна точная
  недостающая host-операция. Не блокировать остальные candidate fixes.
Приёмка B: Astra принимает конкретный текст и согласованный diff; actual delivery остаётся
отдельным статусом до свежих задач. Canonical применение/пуш — по действующим полномочиям,
после проверки, не как побочный эффект подготовки.

## C — profile без ложного исключения F7-04

Первый проход: C/GLOBAL_CODEX/runtime/bin/ios_ai.py и runtime/knowledge_profile.py + тесты.
- Normal status привязан к фактическому LIBRARY выбранного runtime, а не сохранённому A.
- Diagnostic candidate override не выдаёт active exclusions для другой рабочей установки.
- Строгие bool/version/kind/path/hash/list types; malformed → structured invalid + [].
- Ретained A → selected B с тем же release string и изменённым документом → исключений нет.
- source.active = строка "false" → invalid; настоящий false → inactive.
- Changed/missing source, malformed mapping и clean/no-source → никаких ложных exclusions.
Следующий небольшой проход: согласовать JSON schema и KNOWLEDGE_ROUTER с этим поведением.
- Вывести/показать точный replacement path. Агент может пропустить local duplicate только
  после чтения внешней замены в текущей задаче. Одного persisted active недостаточно.
- Не строить трекер контекста модели: это правило использования eligible duplicates,
  с консервативным fallback на local material при отсутствии подтверждения.
Приёмка: адресные CLI/helper cases и review схемы/потребителей; не менять scanners здесь.

## D — убрать навязанную защиту F7-05

Файлы: C/GLOBAL_CODEX/AGENTS.global.block.md и только реально конфликтующие routed instructions.
- Весь begin/scope/verify/close и writer serialization относится только к явно включённому protection.
- Обычная разрешённая правка с knowledge mode не включает protection сама.
- При explicit opt-in сохранить текущие требования контроля.
Приёмка: проверить три сценария по всем затронутым инструкциям — read-only review, обычная
правка без protection, правка с explicit protection. Для простой редакционной правки не добавлять
tests на наличие строк и не запускать runtime suite. Изменение механизма lock не требуется.

## E1 — manual ownership F7-03

Файлы: manual_preflight.py и адресные tests; контракт существующего descriptor остаётся общим.
- Проверять прежнее installed state относительно прежней известной версии и небольшого
  отдельно сохранённого operator receipt. Label managed_by сам по себе не доказывает владение.
- Receipt фиксирует exact paths/hashes/modes до обновления; изменённые bytes не подтверждают себя.
  Его доверенная область — проверенная запись оператора, не защита от враждебного владельца Mac.
- Подлинный old AGENTS block отличать от пользовательской правки; incoming проверять независимо.
- Unchanged owned skills допускают update; неизвестные/изменённые не перезаписываются.
Приёмка: changed descriptor → отказ; настоящий old block → допустимое обновление;
changed user block/skill → сохранение и отказ. Astra принимает этот механизм ДО E2.
Не создавать второй installer или автоматический rollback service.

Результат Luna: `.ioslib-managed.json` фиксирует exact managed paths, hashes, modes,
release/protection identity и managed AGENTS hash; изменённые descriptor/AGENTS/skill/state marker
отвергаются. Fresh receipt emitter и changed-content fixtures PASS. Receipt остаётся операторским
свидетельством, не security boundary и не rollback engine.

## E2 — исполнимый manual lifecycle F7-03

Вход: принятый E1. Файлы: MANUAL_DEPLOYMENT.md и конкретные lifecycle tests/helper consumers.
- Дать выполняемые checked steps fresh reference, reference→full, update, rollback, disable.
- При full activation согласовать descriptor mode, skills и текущий AGENTS block.
- После публикации проверить весь затронутый набор; ошибка не разрешает следующий шаг.
- Валидные A/B содержат реальные разные routed material/runtime behavior и корректные manifests.
  Запустить именно документированный A→B→A, затем disable. Doctor/path echo недостаточно.
- Проверить emitter/publication failure, сохранение пользовательских sentinels/modes/state history.
Приёмка: реальные reference/full последовательности в isolated fixtures, без скрытой ручной
починки fixture между шагами. Если runbook нельзя выполнить как написано — E2 не принят.

Результат Luna: `MANUAL_DEPLOYMENT.md` задаёт fresh reference, reference→full, update,
full→reference disable и A→B→A порядок; receipt публикуется последним. Реальный positive
external-to-Git lifecycle на текущем host не выполнен из-за home-level Git root и остаётся
открытым приёмочным шагом.

## F1/F2 — ограниченные чтения F7-06, два отдельных прохода

F1: runtime/knowledge_profile.py + адресные tests.
F2: MANUAL_SHIM/bin/manual_preflight.py + адресные tests.
Для каждого отдельно:
- Ограничить число всех посещённых entries, включая пустые каталоги, depth/pending work.
- Проверять оставшийся byte budget до/во время чтения; учесть aggregate, не только один файл.
- Использовать подходящие существующие no-follow directory-handle helpers; parent-component
  race не закрывается одним final O_NOFOLLOW. Не создавать универсальный новый framework.
- Ошибки чтения/итерации → incomplete/refusal, никогда пустое достоверное дерево.
- Сохранить cooperative deadline; не обещать hard timeout любого системного вызова.
Приёмка каждого: конкретные cases empty-directory limit, walk error, parent replacement,
exact/overflow bytes и deadline на изменённом observer, а не на другом legacy scanner.
Если повторное использование helper требует широкого переноса, сначала представить Astra
узкую альтернативу; не начинать самостоятельный архитектурный рефакторинг.

Результат Luna: profile и manual observers используют bounded entries/depth/pending/bytes/deadline
и no-follow directory handles; walk/read/deadline/identity failures are non-pass. Addressed
changed-observer tests и полный suite PASS; внешний race stress остаётся незаявленным.

## G — один конечный проход приёмки и внедрения

Начать после принятия A–F, кроме раннего common-host подключения после B.
- [x] Проверить связи принятых блоков и весь FINAL7→candidate delta один раз. Не перечитывать
  весь корпус; новые P0–P2 устранять в соответствующем блоке, не генерировать новый план.
- [x] Один актуальный suite/validator после стабилизации. На failure исправить причину,
  сначала повторить затронутый check; общий PASS должен соответствовать окончательному коду.
- [ ] Применить concrete reviewed common-host diff в пределах отдельной точной authority.
  Не менять CODEX_HOME для удобства. В текущем CLI exact active desktop host target не
  наблюдаем и host-side delivery не утверждается.
- [ ] Свежие existing, new/imported-without-AGENTS, linked-worktree, non-iOS задачи:
  common baseline до первой проектной операции; nested/non-Git/outside scope — явные outcomes.
  Не использовать искусственный prompt, который сам напоминает о библиотеке. Это user-owned
  pilot и остаётся NOT_RUN до запуска в реальных новых задачах.
- [ ] Три реальные задачи: implementation, review, cross-domain. Кратко записать полезные
  находки/выбранные материалы, ложные замечания, лишние действия и неожиданные остановки.
  Не превращать пилот в benchmark campaign и не обещать максимальный выигрыш для всех задач.
- [x] Финальный portable V5.4 ZIP, внешний SHA, сравнение extracted bytes с проверенным tree.
  При совпадении не повторять suite только из-за распаковки. Исторические FINAL7 артефакты не
  перезаписывать.
- [x] Полная инструкция подключения вручную/installer, проверки, обновления/отключения добавлена
  в README и согласована с QUICKSTART/MANUAL_DEPLOYMENT. Зафиксировано внутреннее происхождение;
  неизвестный license/NOTICE не выдуман. Публичное распространение остаётся отдельным решением.
- [x] Синхронизировать task recovery и canonical source/runtime на итоговой границе в рамках
  repository-specific authority; generated evidence не смешивать с product payload.
- [x] Отдельно зафиксировать task-repository changes и canonical-documentation changes после
  final-diff review; canonical push подтверждён exact SHA.
- [ ] Отправить task-repository commit в non-canonical AIZenflow remote; local commit создан,
  но external-egress policy требует отдельного явного подтверждения exact destination.
- [ ] Завершить разработку: оба deployment пути проверены, first-entry работает, известные
  P0–P2 закрыты, pilot показывает практическую пользу. Сейчас локальная реализация и
  canonical runtime PASS, но first-entry/pilot/independent review остаются открыты.

## Полномочия и передача

План не разрешает читать secrets/auth/history/session directories, менять реальные host paths,
клиентский source/Git refs или запускать Xcode/Simulator вне отдельного текущего разрешения.
Существующие разрешения сохраняются: не запрашивать их повторно. Внешняя недостающая authority
останавливает только зависимый шаг после подготовки конкретного результата для согласования.

Текущая команда Luna: довести локальную часть G до коммита/передачи, не выдавая host-dependent
first-entry, external-to-Git lifecycle или pilot evidence за выполненные. При передаче контекста:
**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
