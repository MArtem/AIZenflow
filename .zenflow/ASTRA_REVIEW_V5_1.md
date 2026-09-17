# Независимое ревью iOS Engineering AI Library V5.1

Дата: 2026-09-11. Объект: предоставленный ZIP V5.1 GLOBAL_CODEX_REVIEW_READY.
SHA-256 архива: e7a2f732d7569342dbf7a53770bc3571f1efd0766279e5fce897886b3d752cde.

## Вердикт

**NOT_READY для глобальной установки runtime и обязательного protection gate.**
Это существенно улучшенная версия, а не косметическое переименование V5.
Однако несколько путей по-прежнему дают положительный результат без выполнения заявленного контракта.

Знания и исправленные примеры можно выборочно использовать как справочные материалы под действующими правилами проекта. Это не означает принятие всей библиотеки, установку skills или изменение глобального AGENTS.
Режим установки reference не равен пассивному чтению: он тоже устанавливает runtime и глобальный блок инструкций.

## Границы и доказательства

- Архив содержит 1356 файлов; проверены безопасные имена ZIP entries, отсутствие архивных symlink и дублей перед извлечением.
- Независимо выполнен validate_package.py: files=1356 skills=60 sections=51 playbooks=288 errors=0. Это структурная проверка, включая manifest/hash, а не поведенческая приёмка.
- Полностью прочитаны основные protection.py, ios_ai.py, adapt_project.py, install_global.py; прочитаны глобальный блок, отчёты автора, runner и выбранные тесты/документы. sync/uninstall и knowledge corpus проверены выборочно. Это не построчная проверка всех 1356 файлов.
- Выполнены безопасные вызовы классификатора и проверки protected(path), без исполнения классифицируемых команд.
- 92/92 из REVIEW_READY_VALIDATION_REPORT.md — результат автора на Linux/Python 3.13.5. Здесь этот набор не запускался. Не заявляю независимый PASS установочных, конкурентных или Git-mutation сценариев.
- Не запускались установка/sync/uninstall, сборки iOS, Simulator, Swift-тесты и Instruments. Исходники библиотеки и рабочие правила не менялись.
- Inspected/inferred ниже означает подтверждённую ветвь исходного кода и разобранный сценарий, но не выполненный end-to-end тест.
- Подход ios-evidence-gate использован для разделения наблюдений, выводов и отсутствующих доказательств.

## Исправления, которые действительно видны

Есть явный default REVIEW_UNSUPPORTED для неизвестных команд; runtime честно назван advisory/detection, а не sandbox.
Появились отдельные session_id, жизненный цикл, защита от обычного повторного begin, семантические Git-наблюдения, ограничения ресурсов и неполные статусы.
Установка переработана вокруг preflight, ownership manifest и rollback. Skills получили namespace ioslib-*.
Тестовый набор действительно существует и содержит поведенческие synthetic fixtures — это существенное улучшение относительно V5.
UNKNOWN вместо безусловного low-risk, русскоязычные маркеры, исправленный пример Task lifetime и более содержательные приоритетные knowledge-документы также полезны.

Эти улучшения следует сохранить. Следующий цикл должен исправлять узкие инварианты ниже, а не расширять объём библиотеки.

## V51-01 — P1: изменение уже staged файла обходится при разрешённом stage

Источник: [GLOBAL_CODEX/runtime/protection/protection.py:637](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v51-40IjMk/GLOBAL_CODEX/runtime/protection/protection.py:637).

При наличии transition stage проверяются только новые staged paths (cstaged - bstaged).
Сравнение semantic index entries находится целиком внутри ветви, где stage НЕ разрешён.

Сценарий:
1. До begin файл B.swift уже имеет staged и unstaged изменения: статус MM, index blob b1, рабочий файл b2.
2. Сессии разрешены только A.swift и transition stage.
3. Index blob B.swift заменён на b3; рабочий файл остаётся b2, статус остаётся MM.
4. Набор staged paths, dirty working-tree hashes, status, HEAD и refs остаются прежними.
5. Scope/allow_dirty для B отсутствует, но пропуск index comparison позволяет не обнаружить изменение.

Доказательство: inspected/inferred, без изменения Git-репозитория при ревью.
Существующий тест на pre-existing staged blob с commit transition не покрывает комбинацию со stage.

Исправление: всегда вычислять delta index entries по path/mode/oid/stage; stage разрешает тип операции, но не отменяет write/dirty/protected scope.
Проверка: неизменный MM + другой index blob вне scope должен дать NON_PASS/violation; внутри явно разрешённых областей — корректный результат. Добавить staged mode/removal и stage+commit варианты.

## V51-02 — P1: повторный ensure принимает partial context за fresh

Источники: [GLOBAL_CODEX/runtime/bin/ios_ai.py:132](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v51-40IjMk/GLOBAL_CODEX/runtime/bin/ios_ai.py:132), [GLOBAL_CODEX/runtime/bin/ios_ai.py:224](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v51-40IjMk/GLOBAL_CODEX/runtime/bin/ios_ai.py:224).

context_status вычисляет fresh только по fingerprint/options и отдельно возвращает partial.
Первый ensure неполного контекста сохраняет fresh=false и возвращает ненулевой код.
Повторный ensure при том же неполном наблюдении получает совпавший fingerprint, fresh=true, partial=true, пропускает регенерацию и возвращает 0.
Ветка --status проверяет partial, но финальная ветка ensure — нет.

Доказательство: inspected/inferred. Например, стабильный depth limit либо пропущенный symlink сохраняет одинаковый fingerprint неполного наблюдения.

Исправление: полнота старого и текущего наблюдения обязательна для fresh; все CLI-ветки согласованы по exit code. Не регенерировать бесконечно без изменения причин неполноты.
Проверка: два последовательных ensure при одинаковой partial-причине оба ненулевые; затем устранение причины восстанавливает complete/fresh.

## V51-03 — P1: защищённые имена файлов не защищены во вложенных каталогах

Источник: [GLOBAL_CODEX/runtime/protection/protection.py:543](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v51-40IjMk/GLOBAL_CODEX/runtime/protection/protection.py:543).

protected() сравнивает pattern с полным относительным путём. Именные patterns без каталогов перестают работать вне корня.

Независимо наблюдалось:
- Info.plist -> True; App/Info.plist -> False.
- Package.swift -> True; Modules/Core/Package.swift -> False.
- App/PrivacyInfo.xcprivacy -> False.

Последствие: для обычного вложенного iOS config/dependency/privacy файла достаточно allow, хотя контракт требует также allow_protected.

Исправление: разделить правила для basename и path patterns; не превращать все patterns в basename без разбора.
Проверка: root/nested/mixed separators, точные scope и отсутствие лишних совпадений.

## V51-04 — P2: доверие имени executable вместо его идентичности

Источник: [GLOBAL_CODEX/runtime/protection/protection.py:758](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v51-40IjMk/GLOBAL_CODEX/runtime/protection/protection.py:758).

Path(argv[0]).name превращает ./untrusted/git в git. Далее применяется allowlist настоящего Git.

Независимо наблюдалось: guard для './untrusted/git status' возвращает ALLOW_READ_ONLY и exit 0.
Сам файл не создавался и не запускался. Любая локальная программа с таким именем может иметь другую семантику.

Исправление: не давать положительную классификацию произвольным путям по basename. Либо проверять доверенную идентичность executable в конкретном окружении, либо возвращать REVIEW_UNSUPPORTED при невозможности проверки. Явно описать допущения для PATH/config/environment.
Проверка: custom relative/absolute git и pwd, подмена через PATH, доверенный системный инструмент.
Advisory-статус уменьшает область гарантии, но не оправдывает ложную зелёную классификацию.

## V51-05 — P2: command privacy нарушается через reason

Источники: [GLOBAL_CODEX/runtime/protection/protection.py:703](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v51-40IjMk/GLOBAL_CODEX/runtime/protection/protection.py:703), [GLOBAL_CODEX/runtime/protection/protection.py:707](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v51-40IjMk/GLOBAL_CODEX/runtime/protection/protection.py:707), [GLOBAL_CODEX/runtime/protection/protection.py:772](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v51-40IjMk/GLOBAL_CODEX/runtime/protection/protection.py:772).

Основные аргументы минимизированы, но неизвестные option/subcommand/executable вставляются в reason.
Независимо наблюдалось, что синтетические значения из:
- git --SYNTHETIC_OPTION_SECRET=demo status
- SYNTHETIC_EXECUTABLE_SECRET_DEMO

попадают в JSON reason без редактирования. Настоящие секреты не использовались.
Это остаточный путь раскрытия входной строки при сохранении/передаче diagnostic JSON.

Исправление: фиксированные reason codes и безопасный allowlisted текст, без неизвестных токенов во всех ветках.
Проверка: synthetic secret в option, subcommand, executable, ошибках парсинга и assignment; проверять весь сериализованный output, а не только поле executable.

## V51-06 — P2: parallel sessions не поддерживают независимые записи в одном worktree

Источник: [GLOBAL_CODEX/runtime/bin/ios_ai.py:96](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v51-40IjMk/GLOBAL_CODEX/runtime/bin/ios_ai.py:96).

UUID разделяет хранилище, но не владение изменениями.
Две сессии на одном исходном состоянии с disjoint scopes A и B при последующих легальных изменениях обеих сессий сравнивают весь repo и видят чужой scope как нарушение.
Кроме того, active-check/capture/save не сериализованы: два одновременных begin могут оба увидеть отсутствие активной сессии. Проверки пересечения scopes нет.

Доказательство: inspected/inferred. Тест создания двух session_id не доказывает корректное параллельное выполнение записей.

Предпочтительное минимальное исправление: один writer на worktree; параллелизм — отдельные worktrees. Если same-worktree writers остаются заявленной возможностью, нужны атомарная регистрация владения и правила согласованной verification.
Проверка: concurrent begin, overlapping/disjoint scopes, реальные изменения обоих участников, verify/close interleavings. Не расширять scopes автоматически для получения PASS.

## V51-07 — P2: общий deadline обходит очистку дочернего процесса

Источник: [GLOBAL_CODEX/runtime/protection/protection.py:102](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v51-40IjMk/GLOBAL_CODEX/runtime/protection/protection.py:102).

budget.check_deadline() внутри цикла может выбросить исключение до входа в try/finally с закрытием selector/pipes.
При срабатывании общего deadline после Popen отсутствует гарантированный kill/wait/close; subprocess timeout отдельно обработан и этого случая не заменяет.

Доказательство: inspected/inferred, долгие процессы при ревью не запускались.

Исправление: внешний try/finally вокруг всей жизни уже созданного процесса и его дескрипторов; гарантированная очистка при deadline, чтении, регистрации и отмене. Политику descendants задать явно.
Проверка: total deadline меньше subprocess timeout; после исключения нет живого owned child и утечки дескрипторов.

## V51-08 — P1: ошибки обхода каталогов могут выглядеть как полное наблюдение

Источники: [GLOBAL_CODEX/runtime/protection/protection.py:463](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v51-40IjMk/GLOBAL_CODEX/runtime/protection/protection.py:463), [GLOBAL_CODEX/runtime/protection/protection.py:781](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v51-40IjMk/GLOBAL_CODEX/runtime/protection/protection.py:781), [GLOBAL_CODEX/runtime/vendor/adapt_project.py:101](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v51-40IjMk/GLOBAL_CODEX/runtime/vendor/adapt_project.py:101).

os.walk вызван без onerror. Ошибка чтения содержимого каталога может быть молча пропущена. Проверка lstat каталога не гарантирует, что последующий scandir сможет прочитать его.
Так незамеченными могут остаться вложенная Git-граница, build surface либо вход контекста, а итог сохранит complete/fresh.

Доказательство: inspected/inferred; поведение по умолчанию подтверждается [официальной документацией Python](https://docs.python.org/3/library/os.html#os.walk). Permission fixture здесь не исполнялся.

Исправление: onerror, переводящий неожиданную ошибку в ObservationError либо явную limitation/partial; все потребители отвергают incomplete как PASS/fresh.
Проверка: injectable scandir error, каталог с отказом в доступе на поддерживаемой ОС, ошибка после успешного lstat; ожидаемые excludes отделить от неожиданных пропусков.

## Статус прежних F01–F14

«Исправлено по коду» ниже — узкий исходный дефект, не полная динамическая приёмка компонента.

| ID V5 | Независимый статус V5.1 |
|---|---|
| F01 default allow | Default исправлен; положительная ветка ещё неверна для basename spoof, V51-04. |
| F02 dangling symlink | Исходный путь переработан через no-follow/secure-write; динамическая приёмка всех платформ не выполнена. |
| F03 baseline/session | Обычное затирание baseline исправлено; concurrency/parallel contract остаётся V51-06. |
| F04 Git scope | Существенно усилен, но stage/index bypass остаётся V51-01; protected paths — V51-03. |
| F05 nested dirty | Вложенное состояние усилено; полнота discovery ограничена V51-08. |
| F06 fail-closed observations | Ошибки многих наблюдений теперь явные; V51-07/08 остаются. |
| F07 zero findings = safe | Исходное утверждение безопасности убрано; статический scanner не является разрешением build. |
| F08 raw commands | Основные строки минимизированы, но reason leak остаётся V51-05. |
| F09 stale context | Content fingerprint/options добавлены; partial/fresh bypass остаётся V51-02. |
| F10 installer | Существенно переработан; здесь нет независимого lifecycle/fault-injection PASS. |
| F11 tests absent | Отсутствие тестов исправлено; 92/92 — авторское evidence, сценарии выше требуют регрессий. |
| F12 Task lifetime | Исходный пример исправлен по коду: владелец не удерживается через await тем же способом; Swift lifetime fixture не запускался. |
| F13 RU/default risk | UNKNOWN + RU handling исправляют исходную узкую проблему; это эвристический router, не доказательство оценки риска. |
| F14 namespace/integration | Namespace исправлен; совместимость с нашей канонической политикой ещё не принята. |

## Внедрение рядом с нашими правилами

1. Сейчас — только выбранные справочные документы без установки глобального блока.
2. reference по текущему определению тоже активирует protection workflow; не считать его безопасным «ничего не меняющим» режимом.
3. effective-policy печатает декларативный список приоритетов, а не отчёт реально загруженных канонических правил. Назвать вывод declared-policy либо добавить фактическое provenance, если обещается effective resolution.
4. Наши ограничения на build/tests/Git, канонический documentation vault и sandbox должны сохраняться без дублирования источников истины.
5. Не нужен новый слой глобальных правил ради полезных примеров. Предпочтительнее библиотека знаний с выборочной маршрутизацией; runtime — отдельный opt-in после приёмки.
6. Объём knowledge corpus не равен его качеству. 12 углублённых документов — хороший прогресс, но не основание объявить все 288 playbooks экспертно проверенными.

## Что передать модели-автору

Исправить V51-01…08, сохранив полезные изменения V5.1.
Для каждого ID представить: инвариант, минимальный diff, regression fixture, результат, ограничения.
Не закрывать все исходные F-ID одним успешным общим запуском: mapping должен учитывать остаточные дефекты и уровень доказательства.

Порядок: index scope / partial freshness / protected paths / walk errors; затем classifier privacy/identity, cleanup и session concurrency.
Для parallel допустимо сознательно сузить контракт до one-writer-per-worktree вместо разработки сложного координатора.
После исправлений: manifest/structural validation + весь synthetic suite + целевые macOS lifecycle/permission/timeout checks. Сохранять выводы с платформой, версией Python, числом skips, exit code и идентичностью архива.
Отдельно показать минимальный проектный opt-in, который не изменяет глобальные инструкции и не требует запускать запрещённые текущим проектом команды.

Для передачи контекста: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.

## Итоговая граница готовности

- Полезный справочный материал: да, выборочно.
- Существенное улучшение V5: да.
- Все замечания независимо закрыты: нет.
- Глобальный обязательный runtime готов к внедрению: нет.
- Исправления внесены этим ревью: нет; только отчёт и изолированная копия для чтения.
