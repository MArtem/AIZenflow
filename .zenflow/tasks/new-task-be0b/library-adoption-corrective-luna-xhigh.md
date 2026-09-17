# Исправления и внедрение библиотеки — исполнимый план Luna Xhigh

Дата: 2026-09-13. Автор: Astra. Исполнитель: Luna Xhigh по явному выбору пользователя.
Режим: эконом. Статус: S0–S7 выполнены в разрешённой локальной области; S5 завершён с verdict
`NO_DEMONSTRATED_GAIN` по frozen overhead gate; S8 real adoption остаётся внешним/pending gate.
Область: task new-task-be0b; этот документ заменяет последовательность исполнения
`library-operational-luna-xhigh.md`. Старые документы сохраняют историю, но не текущие PASS.

## 1. Результат, к которому идём

Первый рабочий профиль: существующий canonical router автоматически выбирает небольшой
проверенный набор знаний для поддерживаемых iOS-задач. Пользователь не перечисляет документы
каждый раз. Отключение возвращает прежний процесс. Runtime CLI принимается отдельно и остаётся
explicit opt-in. Для этого профиля global installer и установка 60 skills не нужны.

Завершение имеет три независимых статуса:

- knowledge: фактически подключён, полезность проверена на коде, отключение проверено;
- runtime: конкретные команды и ограничения приняты либо явно остаются непринятыми;
- installer: отдельно проверен; его готовность не следует из готовности knowledge.

Не обещать нулевой риск, максимальное качество любого кода или поддержку всех проектов.
Не расширять принятую выборку на весь корпус. Не выдавать подготовленный patch за внедрение.

## 2. Исходные материалы и подтверждённые дефекты

Рабочий корень W: `/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54`.
Candidate C: `W/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY`.
W/C — сокращения только этого документа; перед командами разрешать их в абсолютные пути.

- Последний архив: `W/dist/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY_LUNA_XHIGH_HARDENED_CANDIDATE_V2.zip`.
- SHA-256: `42e35b0d324c6aa0d6ae39c60b040a2946d702d2d9b8a829a167acfd5a251c59`.
- Original V5.4 SHA-256: `7013500596533af138c857d4e98471f9108ffe3c6eaae4055400e439e3f522ce`.
- Предыдущий промежуточный dist SHA: `900329bae58e596ca8d7549bec0bf0be38fa87d30000f41611360cdc0169af4c`.
- Evidence `10`–`17` описывает прошлый этап; `140/140` не закрывает дефекты ниже.
- Canonical repo: `/Users/Artem/.zenflow/worktrees/documentation-vault`.

| ID | Приоритет | Подтверждение Astra 2026-09-13 | Требуемый результат |
|---|---|---|---|
| A54-R1 | P1 | В copied reference install ошибка удаления второго backup после удаления первого оставила `content_exists=False`, `shim_exists=True`, `registry_exists=True`; выброшен обычный OSError | Сбой cleanup не разрушает уже опубликованную согласованную установку |
| A54-R2 | P2 | Последняя `_validate_session_record` задержана; scanner вернул `[]` за 0.284 s при лимите 0.1 s | После превышения cooperative deadline нет успешного результата |
| A54-R3 | P2, verification | Тест замены файла PASS даже при отключённой expected_identity проверке; замена имеет 0644 при umask 022 | Тест ловит именно замену identity и падает при удалении этой защиты |
| A54-R4 | acceptance gap | L2: нет отдельных frozen inputs/hashes; holdout/key не закреплены; criterion дополнительной находки потерян | Воспроизводимый blind A/B с заранее фиксированным критерием |
| A54-R5 | integration gap | L5 содержит описание, но не применимый patch и не результат rehearsal; installed reference требует sessions | Конкретный optional knowledge route и отдельный opt-in runtime |

13 файлов из прошлого отчёта — diff относительно промежуточного candidate, а не автоматически
полный original V5.4 → final delta. Проверить обе границы; не ограничивать review числом 13.

## 3. Полномочия и организация

Текущий запрос — подготовить план. После команды пользователя исполнять этот план:

- самостоятельно выполнять ранее разрешённые candidate edits, Python tests, synthetic Git,
  installer fixtures и disposable consumer rehearsal внутри W; не запрашивать их повторно;
- изменять tests только в candidate/fixtures этого плана; не трогать app/package UI tests;
- готовить proposed canonical changeset в W, не активируя его в настоящем baseline;
- не менять реальные app consumers, global Codex home, signing, Simulator/Xcode, remote Git
  или публикуемые артефакты без действующей отдельной авторизации соответствующего действия;
- для независимых агентов проверить разрешения текущей среды. Смена основной модели сама по
  себе не создаёт blind context. При отсутствии разрешённого способа подготовить sealed packets,
  оставить evaluation pending и продолжить независимые локальные этапы;
- fixtures, временные файлы, caches, subprocess HOME/config/state и logs направлять внутрь W;
  реальные секреты и пользовательские global settings не читать;
- существующие пользовательские изменения сохранять. Не применять reset/clean/force-push;
- не создавать новый benchmark framework, policy engine, daemon, auto-update или Git hooks.

Luna Xhigh — task-specific override только на этот план. Риск не является причиной менять
выбранную модель посреди заранее определённого блока. Новая неоднозначная destructive-семантика
вне плана требует отдельного решения; независимые безопасные шаги продолжать.

Последовательность: S0 → S1/S2 → S3; затем S4/S5 → S6 → S7 → S8.
S4/S5 можно готовить, пока ожидается независимый review. Не завершать turn на обычной границе
этапа, если следующий шаг уже разрешён. Пауза — при реальном недостатке authority/input.

## S0. Привести статус и входы в соответствие фактам

- [x] Прочитать canonical bootstrap, Level 0, текущий plan/handoff и этот план.
- [x] Проверить наличие C, archive SHA, dirty state; зафиксировать identity исходного candidate.
- [x] Сохранить исходный ZIP и предыдущие dist без перезаписи. Для нового результата выбрать
  уникальный task-local revision, не называя его официальным upstream release.
- [x] Зафиксировать A54-R1–R5 в одном corrective receipt в W/evidence; убрать общие L3/L4 PASS
  и claim «остались только внешние gates» из актуальных summary/receipts либо явно пометить
  их superseded со ссылкой на новые findings. Старые наблюдения не уничтожать.
- [x] Различить лицензирование/происхождение, utility, runtime, installer и adoption.
  Не выдумывать source commit, LICENSE или разрешение на распространение.

Gate: известны входы и их хеши; текущие статусы не скрывают подтверждённые дефекты.

## S1. Исправить update/cleanup transaction — A54-R1

Основные файлы: `C/sync_global.py`, `C/tests/test_review_ready.py`.
`install_global.py` менять только при доказанной необходимости общего helper.

Контракт:

- до commit point любое исправимое исключение возвращает прежние trees и metadata;
- commit point наступает после публикации и проверки согласованных content/shim/skills,
  AGENTS, state marker и registry, но до удаления первого rollback backup;
- после commit point ошибки cleanup не запускают destructive rollback;
- текущая установка и registry остаются согласованными; остатки backup доступны для
  диагностируемого cleanup; unknown/modified user content сохраняется;
- успешное обновление и незавершённая очистка — разные поля результата. Выбрать и описать
  однозначные status/exit semantics; обновить все затронутые CLI consumers/claims;
- не называть exception-handling crash-atomicity и не добавлять обещание backup app-кода.

Работа:

- [x] Проследить publication, metadata, cleanup, except/finally и вызывающие CLI consumers.
- [x] Ввести минимальное разделение pre-commit rollback и post-commit cleanup; не удалять
  рабочий target в надежде на backup, который уже отсутствует.
- [x] Обработать исчезновение/изменение backup и частичную ошибку удаления. Повторный запуск
  не должен маскировать незавершённую операцию или удалять чужие изменения.
- [x] Проверить copied reference и full с несколькими managed targets; source-in-place
  покрыть отдельно. Исходный тест имел только один backup и не закрывал эту проблему.
- [x] Проверить сбой до публикации metadata, на первом backup, после первого успешного
  удаления, во время частичного удаления следующего backup, при изменении backup.
- [x] Сравнить before/after file set, content hashes, обещанные modes, AGENTS/registry/marker,
  session history и user-owned sentinels. Трёх файлов для whole-install claim недостаточно.
- [x] Штатное обновление, повтор после cleanup failure, uninstall и validator согласуются
  с выбранной семантикой. Нельзя получать PASS удалением всей synthetic home и reinstall.

Gate: A54-R1 воспроизводился на исходном коде и устранён на исправленном; не теряется рабочая
установка и не возникает ложный rollback-complete. Все leftovers и residual risks названы.

## S2. Исправить scanner и доказательность tests — A54-R2/R3

Файлы: `C/GLOBAL_CODEX/runtime/bin/ios_ai.py`, `C/GLOBAL_CODEX/runtime/protection/protection.py`,
`C/tests/test_review_ready.py`.

- [x] Проверить путь от начала наблюдения до каждого успешного выхода, включая пустой registry,
  последнюю валидацию, path/identity resolution и завершение итерации. Явно описать, какие
  подготовительные операции входят в общий deadline, а какие имеют отдельный бюджет.
- [x] Проверять deadline после дорогих операций и перед success. Сохранить cooperative
  контракт: произвольный зависший syscall такой checkpoint не прерывает.
- [x] Добавить тест последней медленной валидации, не только JSON-read. Предпочесть локальный
  управляемый clock/stub, чтобы не получать flaky PASS/FAIL от нагрузки машины.
- [x] Проверить per-file и aggregate bytes совместно. `max_bytes=remaining` не должен молча
  отменять прежний per-file предел 4 MiB; применять меньший из двух лимитов, если прежний
  контракт сохраняется. Проверить exact limit, +1, несколько файлов и рост/замену при чтении.
- [x] Исправить race fixture: корректный private mode, валидный JSON и одинаковые bytes/size,
  иной inode; отказ должен быть именно `state file changed before read`.
- [x] Выполнить одну bounded mutation-проверку: временно обойти expected_identity в памяти
  или disposable copy; regression должен упасть. Не оставлять bypass в candidate.
- [x] Проверить неизменённый файл как positive control. Проверку mutation во время чтения
  утверждать только для фактически проверенных механизмов и metadata; не обещать обнаружение
  произвольного изменения с восстановлением содержимого/времени.
- [x] Убедиться, что symlink/private-mode, malformed JSON и iteration failure проверяются
  отдельными сценариями и не подменяют identity/deadline evidence.

Gate: обе подтверждённые проблемы закрыты; tests чувствительны к удалению целевой защиты;
resource limits и error semantics согласованы с вызывающими сторонами.

## S3. Проверить исправленный candidate без бесконечной переупаковки

- [x] Просмотреть полный накопленный original V5.4 → candidate diff и отдельно изменения
  после V2. Найти affected call sites, зеркальные runtime copies и устаревшие claims.
- [x] Привязать required публичные сценарии прошлого L3 к конкретным тестам: MM+stage,
  stage+commit, protected basename, repeated incomplete, changed producer/options,
  executable spoof/unknown argv, nested repos, config/refs, linked writer/recovery.
  Недостающие разрешённые сценарии выполнить; unchanged PASS не повторять без причины.
- [x] После code freeze выполнить targeted checks, затем один full suite и validator.
  Сохранить полный log и реальный exit code; pipeline с `tail` не должен скрывать код runner.
- [x] Count/time/environment записывать из наблюдений, не подгонять тесты под число 140.
  Не утверждать independent review для self-test. Пересчитать manifest после metadata edits.
- [x] Получить bounded independent review control-plane diff после исправлений. Independent
  reviewer выявил P1 unmanaged-target race и P2 route-integrity/false-success gaps; они закрыты
  candidate fix + regression/rehearsal. TOCTOU handoff ограничен явным advisory consistency
  contract и повторной проверкой, а не заявлен как filesystem security boundary.

Gate: нет известных открытых P0–P2 в принятом runtime/installer scope; независимая приёмка
указывается отдельно. Финальный ZIP пока не нужен: сначала завершить связанные изменения.

## S4. Подготовить конкретный профиль knowledge и его diff — A54-R5

- [x] Выбрать минимальный subset из уже рассмотренных 12 документов. Сначала concurrency,
  auth/retry и SwiftUI по задачам пилота; остальные домены не получают automatic acceptance.
- [x] Найти точные canonical router/registry entrypoints. Подготовить применимый patch против
  записанного canonical commit внутри `W/proposed-integration/`, сохранив base identities.
- [x] В patch указать реальные целевые paths, whitelisted documents/hashes, task triggers,
  source attribution, version, supported profiles и одно место отключения. Не добавлять
  второй router и не помещать полный corpus в Level 0.
- [x] Proposed размещение reusable references выбрать под существующим
  `documentation-vault/reusable/knowledge-global/ios/`; точный новый подкаталог определить
  после collision check и записать до просьбы о promotion. Candidate C остаётся рабочей копией.
- [x] Настоящий pin — trusted hash в принимаемой конфигурации. Самопроверка файла по изменённому
  манифесту из того же недоверенного пакета не подтверждает pin.
- [x] Missing/altered reference выключает зависимый advice и оставляет baseline работоспособным;
  обязательная protection-проверка, если выбрана, не превращается из unknown в PASS.
- [x] Подготовить отдельный runtime packet с точными абсолютными CLI/repo/state paths,
  разрешёнными командами, write/dirty/protected scope и правилами завершения sessions.
- [x] Проверить расхождение с installed reference: его глобальный block требует sessions.
  В первом профиле не использовать этот block; не называть установленный reference пассивным.
- [x] Сопоставление 60 skills сохранить как triage; не устанавливать дубликаты. Если предлагается
  новый активный skill — отдельно прочитать и проверить весь его instruction contract.

Gate: reviewer получает конкретный patch, pin/config и disable-инструкцию; это ещё не
применение к canonical repo. Отсутствие реальной активации не заменяет подготовку patch.

## S5. Подготовить и провести честный A/B — A54-R4

- [x] Разделить `reviewer-inputs/` и `evaluator-only/` внутри W. Reviewer не получает ключ,
  предыдущие ответы или широкое разрешение читать task evidence. Если такой доступ нельзя
  исключить, отметить ограничение и не называть запуск blind.
- [x] A: замороженный relevant canonical baseline. B: те же code/prompt/baseline + pinned
  subset. Дополнительный input B ожидаем; одинаковыми должны быть общие входы и условия.
- [x] Для T1–T3 закрепить код, assumptions/backend contracts, expected findings, severity и
  корректные control samples. Не записывать неизвестный контракт как доказанный code bug.
- [x] Четвёртый holdout и его ключ закрепить до ответов; не использовать его при настройке
  subset. Достаточны локальные файлы + hashes; новая платформа evaluations не нужна.
- [x] До запуска закрепить model/effort, permissions, budget, порядок A/B, output schema,
  versions/hashes и scoring. Два свежих изолированных контекста на задачу, одинаковые условия.
- [x] Использовать доступный разрешённый способ независимого запуска; sealed T1/T2/T3/holdout
  A/B outputs сохранены в `evidence/l2-pilot-20260913/results/`.
  контекст с известным ключом за reviewer. Если нужен пользовательский запуск — подготовить
  copy-paste packets полностью, включая paths и запрет чтения evaluator-only.
- [x] Считать только подтверждённые code-anchored findings; outputs проверены по frozen keys.
  Записаны recall, controls, dangerous advice/authority conflicts, input overhead и доступные
  elapsed estimates; недоступные tokens отмечены `UNKNOWN`. Gate verdict: `NO_DEMONSTRATED_GAIN`.

Предварительно закреплённый gate:

- B находит минимум одну дополнительную подтверждённую существенную проблему на T1–T3;
- B не теряет существенные находки A, не добавляет опасные советы или нарушения полномочий;
- три корректных control samples не получают необоснованных замечаний;
- holdout не показывает нового существенного пропуска относительно A;
- input/time overhead целевой ≤50%; превышение требует сужения subset или явного решения,
  unknown measurements не становятся PASS;
- false positives не растут без объяснённого отдельного решения. Не менять пороги после ответов.

Если A уже находит всё или дополнительная польза не установлена, это `NO_DEMONSTRATED_GAIN`,
а не дефект модели и не основание бесконечно подбирать примеры. Сузить конфигурацию один раз
либо оставить материал manual reference. Четыре задачи не дают статистической гарантии.

Gate: реальные A/B outputs, заранее закреплённый key и итог оценки. Подготовка packets
закрывает только подготовку, не utility. Ожидание запусков не блокирует S6 rehearsal.

## S6. Disposable consumer rehearsal и отключение

- [x] Внутри W создать disposable consumer с representative Swift files и копией только нужного
  router context. Применить proposed patch здесь; production app и global home не затрагивать.
- [x] До запуска закрепить expected route/action/result для: new iOS, dirty iOS, non-iOS,
  unknown profile, review-only, runtime opt-in, соседняя задача без opt-in, linked worktrees,
  missing root, altered file/manifest/pin, malicious README, no test permission, disabled route,
  появление новой версии. Объединять в один компактный harness/receipt, не плодить сервисы.
- [x] Проверить настоящие existing entrypoints, а не функцию, которая заранее возвращает
  ожидаемую таблицу. Agent adherence и детерминированный resolver оценивать раздельно.
- [x] До/после сравнить owned file set, user dirty bytes, Git index/refs/config, state paths.
  Использовать synthetic markers. Проверять process/network attempts только доступным
  контролируемым механизмом; текстовый запрет не доказывает отсутствие side effects.
- [x] Отключить optional knowledge route одной документированной операцией, проверить baseline,
  затем вернуть тот же pin. Runtime отключается отдельно; active sessions остаются видимыми,
  их нельзя удалять для получения зелёной проверки.
- [x] Зафиксировать supported/unsupported случаи и измеренный context overhead. При недостатке
  observer coverage писать UNKNOWN, не whole-Mac-safe.

Gate: automatic route действительно работает в disposable consumer, disable/re-enable
воспроизводимы, нет новых неразрешённых действий в проверенном scope.

## S7. Финальный пакет для решения о подключении

- [x] Свести один receipt: A54 findings → fix/evidence; knowledge utility; runtime; installer;
  route compatibility; license/provenance; поддержка; residual risk; omitted checks.
- [x] До упаковки завершить content/metadata edits. Синхронизировать manifests, выполнить
  validator и final diff review. Если поменялся только Markdown, не повторять весь runtime suite
  без причины; привязать reused PASS к неизменившимся code/test inputs.
- [x] Создать один новый финальный archive, распаковать в новый owned path, проверить manifest,
  file set, hashes и CLI entrypoint. Связать source и dist; archive SHA хранить вне самого ZIP.
- [x] Подготовить owner decision packet: exact canonical diff/base, все целевые paths,
  выбранный knowledge профиль, proposed первый реальный проект, backup/restore/disable,
  что реально меняется в процессе, и какие действия требуют ещё отсутствующей авторизации.
- [x] Если canonical base изменился, актуализировать proposed patch и повторить affected checks.
- [x] Источник/лицензию не придумывать; до распространения запросить только реально недостающие
  сведения. Это не препятствует локальным исправлениям и синтетической проверке.

Gate: готов проверяемый результат для принятия. Нельзя ограничиться просьбой «разрешите
интеграцию», если exact diff/paths/rollback ещё не подготовлены.

## S8. Реальное внедрение после конкретного решения владельца

- [ ] Сверить действующую авторизацию canonical promotion и первого реального consumer.
  Если её нет, показать S7 packet и запросить только эти действия; не повторять synthetic grant.
- [ ] Применить approved knowledge route/pinned placement. Соблюсти canonical vault commit/push
  contract и remote-SHA verification. Публикацию candidate в другом repo не считать разрешённой.
- [ ] На одном approved проекте провести три реальные ограниченные задачи: review, обычная
  source-правка, правка с существующим dirty work/защищённой границей. Не вносить баги специально.
- [ ] Проверить automatic selection, отсутствие конфликтов/неожиданных commands, полезные findings,
  overhead и выключение с возвратом к прежнему процессу. Builds/UI только по их авторизации.
- [ ] Runtime подключать лишь если он отдельно принят и выбран; knowledge не ждёт global full.
- [ ] После принятия пилота расширять только на согласованные registered projects. Подтвердить
  bootstrap новых проектов в этом списке. Неподключённые проекты не включать в coverage claim.
- [ ] Зафиксировать владельца сопровождения, pin/version, критерии повторного review и ручное
  обновление. Обновления не происходят автоматически.

Финиш: named profile фактически используется и прошёл consumer/disable checks. Если S8 не
разрешён, итог: «кандидат и подключение подготовлены, реальное внедрение ожидает решения».
Если knowledge принят раньше CLI, сообщить оба статуса. Общий PASS не усредняет открытые gates.

## 4. Экономия, остановки и handoff

- Работать блоками 1–3 исходных файлов; test/metadata synchronization привязать к тому же
  смысловому изменению. Не повторять broad reads, full suite и ZIP ради каждой строки отчёта.
- Не ограничивать tests целью «сохранить 140». Качество определяется invariants и чувствительностью.
- После этапа обновлять checklist и один corrective receipt, не создавать новый итоговый отчёт
  после каждого инструмента. Старые successful checks сохранять с их настоящим scope.
- При новом unrelated P0–P2 назвать evidence, ограничить затронутую приёмку и подготовить
  bounded решение. Не скрывать finding и не превращать исправление в безграничную платформу.
- Readiness не требует механической смены модели. Независимый review должен иметь другую роль
  и достаточную изоляцию; availability/permissions сообщаются фактически.

Стартовый prompt:

> Luna Xhigh, выполняй library-adoption-corrective-luna-xhigh.md в task new-task-be0b.
> Перечитать весь актуальный набор документации и правил для этого worktree и task-контекста.
> Начни с S0, затем исправь A54-R1/R2/R3. Продолжай разрешённые локальные этапы без ненужных
> остановок. Подготовь применимый knowledge-route patch, frozen A/B packets и disposable rehearsal.
> Прежние 140/140 и L3/L4 PASS не закрывают findings Astra от 2026-09-13. Не устанавливай
> global reference/full и не меняй реальные consumers без соответствующего решения.
> До запроса promotion подготовь exact diff/paths/rollback. Отдельно отчитай utility, runtime,
> installer и фактическое внедрение; не выдавай документы с намерениями за выполненную интеграцию.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
