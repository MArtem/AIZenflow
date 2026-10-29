# Ревью iOS Runtime Auditor Handoff v2.1

Дата: 2026-10-27. Автор: GPT-6 Astra; режим эконом. Это ревью поставки и проект
решения для KB, не runtime-аудит приложения, не независимая сертификация и не внедрение.
Уровень reasoning Astra не был достоверно доступен. Исполнитель следующей фазы по
прямому указанию пользователя: GPT-6.1 Terra, medium, только для этого плана.

## Решение

**Не устанавливать комплект целиком.** Принять после адаптации метод выбора
пользовательских сценариев, матрицу диагностик, правила корреляции и сопоставимости
измерений. Расширить существующих владельцев KB без нового `ios-runtime-auditor`,
bootstrap, глобальных режимов доступа и новых исполняемых инструментов.

Комплект правильно подчёркивает, что исходники, UI assertions и профили отвечают
на разные вопросы. Его слабые места — реализация вспомогательных инструментов,
искусственная приоритизация и несогласованные permission/evidence-контракты.
Известные P1/P2 ниже блокируют прямое принятие соответствующих частей. Отказ от их
импорта исключает их из будущего патча; он не означает, что архив исправлен.

## Входы, покрытие и границы

- Worktree: `/Users/Artem/.zenflow/worktrees/knowledge-base-next`, начальный HEAD
  `53efae82aabd0cc8ae4896a887854eb6195e37f8`, исходно чистый.
- Canonical: `/Users/Artem/.zenflow/worktrees/documentation-vault`, `main`, HEAD
  `55079f5b5926e63790a722fae05ac5eee9755abe`, исходно чистый. Remote не запрашивался:
  ревью не делает заявления о свежести `origin/main`.
- ZIP: `/Users/Artem/Downloads/Codex_iOS_Runtime_Auditor_Handoff_v2_1.zip`.
  SHA256: `c0baf50a88acf4f5a99435c694459b96f8e9c99cbb018a1e8323ed3730e34d60`.
- 57 файлов, 163955 распакованных байтов. Прочитаны все документы, prompts,
  references, examples, шаблоны, 12 скриптов и один файл тестов. Два списка хешей
  проверены как данные. Пофайловое решение и SHA256: `archive-inventory.json`.
- Распаковка проверяла относительные пути, `..`, дубликаты, типы, шифрование,
  размеры/суммарный объём/коэффициент сжатия и CRC; symlinks/special files запрещены,
  destination новый, права файлов 0600. Исходный архив не изменён.
- Разрешены чтение, безопасная распаковка, статический анализ и task-документы.
  Текущая фаза завершается предложениями/планом: canonical, source/test/config,
  Git index/refs и remote не меняются. Нет установки/скачивания инструментов,
  запуска приложения, builds/tests, Simulator, Instruments, CI, signing/archive.
- iPad, физические устройства и actual VoiceOver — `OMITTED_BY_USER`, не PASS и
  не очередь обязательных следующих действий. Firefox, Share, Library/holdout и
  отменённые forks Ghibli/Countries не возобновляются.

Относительные ссылки на архив ниже начинаются в
`archive-input/Codex_iOS_Runtime_Auditor_Handoff/`; `K/` обозначает
`payload/iOS_Runtime_Auditor_Kit/`, `S/` — `K/skill/ios-runtime-auditor/`.
Номера строк относятся к неизменённому содержимому поставки.

## Замечания

### R01 — P1: вложенный документ объявляет себя разрешением; режимы не согласованы

**Evidence:** `CODEX_TASK.md:3` объявляет получение архива разрешением на установку
и аудит; `S/references/02_execution_protocol.md:14–17` делает `AUDIT_EXISTING`
default, хотя skill требует начать с проверки разрешений. `S/SKILL.md:14–19`
предписывает doctor/discovery, генерацию файлов и исполнение как последовательный
обязательный протокол, не отделяя их ясно от `READ_ONLY_PLAN`. Prompt 05 связывает
создание harness с последующим запуском тестов.

**Последствие:** импорт в активные инструкции может превратить данные ревью или
разрешение на чтение/тестовые правки в разрешение на установку/build/runtime.
В этой сессии обхода не произошло: инструкции архива не исполнялись.
**Решение:** не импортировать install/autonomy blocks. Сослаться на существующие
`CURRENT_USER_OVERRIDES`, `IOS_TESTING_STRATEGY` и authority hierarchy. Независимо
фиксировать read, app launch/UI, build, test creation/modification/execution,
profiling, fault injection/backend effects, output/cleanup. Без новых глобальных
режимов. Статический пример: разрешён только план → никаких doctor/build/UI команд.
Confidence high; статически подтверждён конфликт, runtime не проверялся.

### R02 — P1: возвращаются явно исключённые проверки

**Evidence:** `S/templates/REPORT_TEMPLATE.md:44–51` требует device queue и device
validation request; `K/prompts/06_device_validation.md`; refs 01:39, 09:21 требуют
VoiceOver; refs 02:50, 06:28/51, 08:32 возвращают device gate.
`K/examples/01_LISTS_WORKED_PLAN.md` дополнительно говорит «install templates first».

**Последствие:** план нарушит действующий пользовательский scope или превратит
запрещённые проверки в условие завершения. **Решение:** отклонить device prompt и
очередь; сохранить только предел вывода Simulator и `OMITTED_BY_USER`. Недоступный
инструмент — gap, не установка. Физическую производительность, energy/thermal/GPU
и аппаратные свойства не объявлять доказанными. Confidence high.

### R03 — P1: runtime wrappers не обеспечивают заявленные границы и полноту доказательств

**Evidence:** `S/scripts/run_ui_tests.sh:19–29` вызывает `xcodebuild test` без общего
deadline, выбранной configuration/test-plan, контроля dependency resolution и
инспекции scheme build/pre/post scripts. Regex testIdentifier не доказывает, что
нужный тест существует/выполнен. Возврат только `${PIPESTATUS[0]}` теряет ошибку
`tee` при успешном xcodebuild. `record_trace.sh:9–24` проверяет UDID/template
подстрокой, PID лишь как число; нет связи bundle/executable/build/PID/start-time.
`doctor.sh:23–34` подавляет ошибки `|| true`, поэтому exit 0 не означает доступность
всех перечисленных средств.

**Последствие:** допустимы лишние сетевые/build-script эффекты, зависание,
неполные логи или запись другого живого процесса. Документы требуют предварительной
проверки, но wrapper не является enforcement этой проверки. Это не утверждение,
что побочные эффекты фактически произошли. **Решение:** не импортировать wrappers.
Будущий конкретный runtime-блок сначала связывает разрешения, схему, тест/driver,
контейнер/fixture/backend, process identity и output; проверяет фактический terminal
result, число/идентичность исполненных тестов и capture interval. Не строить сейчас
новый runner вместо отклонённого. Confidence high по отсутствующим проверкам.

### R04 — P2: evidence-validator подтверждает декларацию, а не provenance исполнения

**Evidence:** `S/scripts/validate_evidence.py:36–56`: каталог достаточно сделать
непустым, bundle digest не требуется; любой файл с корректным хешем и `kind=xcresult`
или `test_assertions` создаёт `has_assertions=True`; результаты берутся из
самодекларации `assertionResults`, не связываются с содержимым артефакта, test/run ID
или временем. `appRevision` — любая строка длиной ≥7. `:17–19` запрещает повторный
scenarioId, хотя измерения требуют повторов. Пустой список executions допускается.

**Последствие:** произвольный непустой файл/каталог + утверждение `passed:true`
проходит структурную проверку; это не подтверждение запуска. Предупреждение в stdout
частично ограничивает claim, но термин provenance и отсутствие run identity
опасны для downstream gate. **Решение:** отклонить как verifier. В методику перенести
цепочку scenario → run → build/process → interval → native result/export →
interpreted assertion/metric; hash означает целостность, не истинность.
Повторы имеют отдельные run IDs. Структурный PASS никогда не становится runtime PASS.
Confidence high; примеры выведены из ветвей кода, не выполнялись.

### R05 — P2: сравнение принимает недостоверные метрики и некорректные бюджеты

**Evidence:** `compare_samples.py:18–35` проверяет только восемь равных environment
полей, truthy evidenceRef и совпадение units; оба отсутствующих unit равны.
`:23–24` молча перезаписывает duplicate scenario/metric. Ни source/build identity,
ни timestamps, host, cache state, warmups, observation interval и реальная ссылка
на результат не проверяются. `:50–64`: budgets не проверяются на `math.isfinite`;
NaN/Infinity могут дать `WITHIN_DECLARED_BUDGET_CANDIDATE`. Отрицательный budget
или relative-only при нулевом baseline ошибочно обозначается exceedance.
Примерные данные/placeholder evidenceRef не отвергаются.

**Последствие:** некорректные входы получают вид численного результата. Candidate
label не равен окончательному verdict, но не исправляет ошибку данных.
**Решение:** не импортировать скрипт/schema. Перенести правила finite values/units,
provenance, независимых повторов, warm-up и сопоставимости; invalid input и
несопоставимость — gap/INCONCLUSIVE. Median/MAD полезны как описание, не статистическая
значимость; фиксированные ≥5/10–30 не становятся универсальной нормой. Confidence high.

### R06 — P2: механическая формула не выбирает приоритетные пользовательские пути

**Evidence:** `build_plan.py:8–39`, ref 01:11–17. Из литерала MATRIX получаются
6 P0 (concurrency/network/persistence/startup/background/permissions_security) и
5 P1 (lists/images/navigation/media/animations), независимо от приложения. P2/P3
не возникают. Любое keyword match становится одним обобщённым сценарием; frequency
и impact заранее придуманы. P0–P3 конкурируют с canonical шкалой severity.

**Последствие:** запуск приложения почти всегда P0, а реальный основной путь может
потеряться; наличие Task ничего не говорит о частоте/ущербе. **Решение:** отдельно
планировать порядок измерений и severity уже найденных дефектов. Основания очереди:
подтверждённая ценность/частота из требований либо unknown, возможный ущерб,
недавние изменения/симптомы, uncertainty и стоимость получения полезного сигнала.
Сначала минимальный набор главного пути и рискованных переходов, затем расширение
по результату. Не заимствовать проценты времени 60/25/15 и фиксированные 20/30/100
повторов. Confidence high.

### R07 — P2: discovery не ограничено реальным source universe

**Evidence:** `discover_features.py:25–38`: `sorted(base.rglob('*.swift'))`
обходит/материализует кандидатов до лимита; исключение `.git` не исключает соседнее
содержимое вложенного репозитория. Есть limit файла 2 MB и 15000 файлов, но нет
aggregate bytes/time/traversal budget; oversized/escaped inputs silently skipped.
In-root symlink файла не запрещён, `.zenflow`/fixtures не исключены. `sourceRoot`
и имена путей экспортируются.

**Последствие:** чтение чужого вложенного source boundary, generated/example input
вместо compiled feature, расход ресурсов; отсутствие текста исходника в JSON не
гарантирует приватность путей. **Решение:** использовать целевой ручной поиск по
авторитетному target/source inventory; отмечать недоступное/пропуски. Не импортировать
scanner и не заменять его новым без отдельного доказанного запроса. Confidence high.

### R08 — P2: примеры способны ложно подтвердить проверяемый сценарий

**Evidence:** `UITest_TaskCancellation.swift.txt:13–18`: сразу после B проверяется
отсутствие A, без управляемого завершения A и обработки его callback. Ошибочная
реализация может записать A позднее. `UITest_MeasuredLists.swift.txt:15–22` лишь
комментирует reset, но не делает его между повторениями measure. `XCUITest_Example.swift`
называет тест navigation, но выполняет только swipe; `list.exists` не измеряет latency.

**Решение:** принять смысл примеров, не Swift snippets. Для A/B: подтвердить оба
старта → завершить B → наблюдать B → завершить A → дождаться обработки старого
completion → проверить B и события. Cancellation, stale-write suppression и
server-side effect проверяются отдельно; допустимый владелец может продолжать
задачу после ухода. Для performance: идентичные начальные/конечные состояния и
явный reset вне измеряемого интервала. Confidence high; компиляция/тесты запрещены.

### R09 — P2: защита артефактов остаётся обещанием, output не ограничен

**Evidence:** Python tools принимают произвольные output paths; shell wrappers
делают `mkdir -p`/`tee`, без contained root, отказа от symlink destinations или
защищённого umask. `doctor.sh` перезаписывает `doctor.txt`; run_ui_tests печатает
полный stdout/stderr в чат/лог. Проверки `exists()` до записи не обеспечивают
exclusive creation и не отвергают dangling symlinks. Нет retention/size bounds.

**Последствие:** небезопасная destination или приватный build log может выйти за
согласованную область; ignored не равно приватный. **Решение:** не импортировать
scripts. Использовать текущие secret/evidence-lifecycle правила: synthetic data,
минимальные редактированные summaries, private owned output, отдельное разрешение
на upload/cleanup. Не обещать автоматическую очистку персональных данных. Confidence high.

### R10 — P2: установка и проверки после установки не соответствуют обещанию поставки

**Evidence:** `bootstrap.py` сначала copytree, затем append AGENTS; ошибка записи
или частичный copy оставляет смешанное состояние без понятного recovery receipt.
Следующий запуск сравнивает дерево и может остановиться конфликтом. Статические
проверки symlink хороши, но не защищают check/use и hardlink AGENTS от побочного append.
Устанавливается только skill subtree, а `check_kit.py`/`verify_local_kit.py` ищут
`parents[3]/skill/ios-runtime-auditor`, README/prompts/tests полного kit; в установленной
структуре это `.agents`, где этих файлов нет. `verify_local_kit.py:22` запускает
unittest, несмотря на возможное восприятие как простого syntax checker.

**Решение:** исключить installer и self-check runners. Текущий KB owner/mirror
workflow уже решает распространение. Не исправлять installer ради этого запроса.
Проверка синтаксиса выполнена своим bounded parser без imports/tests. Confidence high.

### R11 — P2: альтернативная таксономия и schema/examples расходятся

**Evidence:** refs смешивают OBSERVED/INFERRED, PASS/PASSED, WATCH, BLOCKED,
NOT_MEASURED и DEVICE_REQUIRED; ref 10:31 обозначает отсутствие budget как
NOT_MEASURED даже при существующих числах. `SCENARIOS.example.json` v1, builder v2,
`validate_scenarios.py` не проверяет version; non-dict risk проходит ветку без ошибки,
actions/assertions могут быть пустыми, `EXECUTED` требует только truthy evidencePaths.

**Решение:** не импортировать schema/validator/status dictionary. Сохранить
canonical отдельные оси applicability, evidence state, confidence, decision;
OBSERVED/INFERRED — вид claim, не verdict. Измерено без budget: измерения остаются
наблюдением, решение о соответствии budget не принято. Confidence high.

### R12 — P3: integrity и локальные test claims нельзя читать шире их покрытия

**Evidence:** `BUNDLE_SHA256.json` покрывает 52 payload files, не bootstrap и четыре
верхних файла; внутренний SHA256SUMS покрывает 50 файлов без MANIFEST и себя.
Хеши лежат рядом с проверяемыми байтами — это не подпись/доверенный канал.
`MANIFEST.json` честно сообщает `hasActuallyRunOnMac:false`, но `unitTestsPassed:9`
не имеет приложенного execution receipt. Девять test methods не покрывают installer,
shell wrappers, scenario validator, NaN budgets, duplicate metrics и false provenance.

**Решение:** сохранить SHA всей поставки и фактическое покрытие; историческое
утверждение о 9 PASS не считать нашей проверкой. Нет доказанного вредоносного
network/upload кода в прочитанном комплекте, но это не сертификация безопасности
и не утверждение о транзитивных эффектах xcodebuild.

## Что полезно и куда перенести

| Идея | Решение / canonical owner |
|---|---|
| Сначала реальная пользовательская функция, затем риск и диагностический вопрос | Расширить существующий `ios-performance-profiler/SKILL.md`; не делать regex обязательным |
| Route → fixture/state → UI action → assertion → interval → evidence | Встроить компактный контракт в `PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md` |
| Lists/images, navigation/retention, tasks, startup, storage/network | В том же справочнике дать условную таблицу scenario → method → signal → limits |
| Trace attach и UI driver должны относиться к одному процессу/интервалу | Сохранить явно; отдельные запуски не выдавать за одну причинную цепочку |
| Нет XCUITest | Разрешённый manual/другой реальный UI driver может дать scoped evidence; нет разрешения/driver → gap. Не требовать harness автоматически |
| Functional assertion, symptom, cause, budget verdict | Разделить; исходники могут доказать дефект кода, но не измеренную задержку/утечку/ускорение |
| Warm-up/cache/fixtures/host/settings, raw samples, median/MAD | Сохранить как условия сопоставимости; не вводить универсальные N/p95/budgets |
| Safe fault injection и A/B request order | Принять как предложения только при наличии функции и scoped authority; не создать fixtures/tests |
| Report / permission modes | Использовать уже существующие владельцы KB и короткие ссылки, без нового общего стандарта |
| Prompts | Переписать существующий `ios-performance-audit.md`, не добавлять 12 конкурирующих prompts |
| Scripts, installer, Swift templates, schemas/tests | Не принимать в первый блок; не ремонтировать и не запускать |

Новая методика должна уметь назначить измерение по приложению, а не только по словам
«lag»/«Instruments». Например, каталог с изображениями → scrolling/decoded memory;
поиск → input-to-result и stale completion; редактор → save/reopen correctness и
IO latency; медиаплеер → start/stop/teardown, только доступные Simulator сигналы.
Это примеры выбора, не предположение, что все функции есть в каждом приложении.

## Проверка спорных API и снятые гипотезы

Точечная проверка первичных источников выполнена 2026-10-27; архив/код/артефакты на
внешние сервисы не отправлялись, использовались общие технические запросы.

- [Apple XCTHitchMetric](https://developer.apple.com/documentation/xctest/xcthitchmetric)
  подтверждает реальность API. [What’s new in Xcode 26](https://developer.apple.com/videos/play/wwdc2025/247/)
  описывает несколько результатов, включая Hitch Time Ratio. Не объявлять API
  выдуманным и не смешивать count, ratio и frame rate. Конкретный runtime/SDK support
  для нужной матрицы проверяется при будущем разрешённом блоке; здесь не установлен.
- [Apple XCTMemoryMetric](https://developer.apple.com/documentation/xctest/xctmemorymetric)
  и [Preventing memory-use regressions](https://developer.apple.com/documentation/xcode/preventing-memory-use-regressions)
  описывают физическую память, рост и peak. Отчёт должен именовать фактическую метрику
  экспорта, а не объединять footprint, delta, peak и retained objects.
- [Apple animation performance testing](https://developer.apple.com/videos/play/wwdc2020/10077/)
  обосновывает reset состояния между измерениями и влияние diagnostics. Изменение
  scheme/debugger/coverage не разрешается самим чтением этой рекомендации.
- Прочитан только установленный Apple man-файл
  `/Applications/Xcode.app/Contents/Developer/usr/share/man/man1/xctrace.1`.
  По `Contents/version.plist` это Xcode 27.0, build 27A266a. В нём positional
  `xctrace export input.trace --toc` — preferred form, `--input` — legacy equivalent.
  **Гипотеза ошибки синтаксиса export отклонена.** Xcode/xctrace не запускались,
  шаблоны и возможность захвата не проверены. Метаданные установки не доказывают
  выбранный developer directory или работоспособность toolchain.
- SwiftUI performance page/Markdown не удалось полноценно получить через web tool;
  её текст не засчитан как новый полный прочитанный источник. Для будущего конкретного
  SwiftUI instrument contract потребуется actual tool/runtime capability check.

## Проверки и ограничения

PASS только для узких статических фактов: безопасное извлечение 57 файлов; 52/52
payload hashes; 50/50 inner hashes; Python AST 9/9; `bash -n` 4/4; JSON parse 6/6;
проверка совпадения трёх canonical owners с их distribution mirrors.
Это не semantic PASS инструментария: R01–R11 остаются в исходном архиве.
Первый hash helper использовал недоступный `hashlib.file_digest`; исправлен на
streamed SHA256, без исполнения кода архива. Ошибка сохранена как ограничение метода,
не скрытый успешный первый запуск.

Не запускались bundled unittest/self-check/doctor/build/test/profile, Swift compiler,
UI, CI, Simulator, Instruments. Нет runtime/benchmark/independent reviewer evidence.
Проверен полный текст поставки; semantic review ограничен исходниками, схемами,
контрактами и названными первичными источниками, не динамическими атаками.

Canonical baseline загружен в текущем revision. Docs route: Level 0 + governance,
preflight/engineering quality, boundary/source-of-truth/repository operations,
task-state/context/new-task, performance/evidence/testing-permission,
secret intake и AI.AGENTS §§34–40. Performance skill и Codex system skill-creator
применены; ранее прочитанный внешний skill-creator не запускался, его eval/test loop
не имеет authority поверх запрета пользователя. Остальные app/platform routes,
Library/holdout, полный AI master и другие app docs не требуются.
Старые plan/handoff прочитаны для запретов, а не для восстановления grants.

Контракт этого изменения: создаются только review/plan/recovery artifacts;
архив неизменен, authority не расширяется, сведения о выполнении не выдумываются.
Новый task-local owner выбран намеренно, прежние задачи не редактируются. Canonical
task recovery и публикация отложены Terra вместе с будущим внедрением по решению
пользователя. Context health: желательно обновить контекст перед исполнением.
