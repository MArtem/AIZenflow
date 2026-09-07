# Аудит системы iOS-разработки и QualityControl

Дата обследования: 5–6 сентября 2026. Автор: GPT-6 Astra. Статус: рекомендации для внедрения; действующие правила не заменены этим отчётом.

## Решение

Сохранить существующий QualityControl как исполнительную основу. Взять из нового архива компактную организацию политик, нормативные MUST/SHOULD/MAY, описание проекта, классификацию изменений и подход к постепенной модернизации. Переработать и объединить человеческие правила. Shell runner из архива не устанавливать: он существенно слабее существующей системы в выборе проверяемой ревизии, исполнении политики, сохранении доказательств и ограничении ресурсов.

Главная проблема системы — уже не нехватка чек-листов. Это противоречия между источниками, смешение общих правил с предпочтениями отдельных приложений, неодинаковая точность автоматических проверок и большой повторяющийся контекст. Добавление ещё одного полного комплекта правил усилит эти проблемы.

Максимальное качество здесь означает: ясный контракт изменения, правильные границы владения, применимые проверки, отсутствие ложного успеха, проверяемое покрытие и своевременную проверку на реальном потребителе. Ни число документов, ни число тестов, ни самая дорогая модель сами по себе этого не обеспечивают.

**Изменение ограничений после аудита:** пользователь потребовал реализовать весь план только на GPT-5.6 Luna xhigh, включая review будущей реализации. Текущий аудит и его независимое ревью пользователь отдельно оставил на Astra. Это отменяет первоначальные рекомендации по распределению этапов между моделями. Фактические выводы аудита остаются; обязательный маршрут исполнения описан в LUNA_EXECUTION_GUIDE.md.

Практический план находится в `IMPLEMENTATION_ROADMAP.md`, решение по каждому из 67 файлов архива — в `ARCHIVE_DECISIONS.md`, границы обследования — в `COVERAGE.md`.

## Зафиксированное состояние

| Источник | Проверенная ревизия / результат |
| --- | --- |
| AIZenflowDocumentation | `28d11bb79457d62d7fd26cec2ccf5ab1edaccbc6`; совпадает с remote main на момент проверки |
| QualityControl main-active | `f60d5da6c2dca4c2d12c72ed3096a133402ae408`; совпадает с remote main; рабочее дерево чистое |
| Старый checkout QualityControl | `9ac4cca4647cbd229a99250a4b60cd5ce27cca8c`; другая ветка, пользовательский изменённый AGENTS.md оставлен нетронутым |
| Текущий app/task checkout | `7e51b0f450ef37bd04deab617940574bdac5ae02` до изменений материалов аудита |
| Vault inventory | 3633 файла, 1921 уникальный SHA-256; это включает зеркала, исходники примеров и историю, а не 3633 независимых активных правила |
| Новый ZIP | 67 файлов; все 66 записей MANIFEST.sha256 совпали; manifest не хеширует себя |
| Каталог QualityControl | 20 записей: 16 implemented, 3 staged, 1 review-candidate; implemented не означает доказанную production readiness |
| Найденные Git worktrees | 15; у 14 есть bootstrap marker; у 7 есть portable snapshot |

Архив не исполнялся. Сборки, тесты, Simulator, Instruments, workflow dispatch, внешнее Codex Review и app source edits не выполнялись. Исторические PASS из старых планов не превращены в результаты текущего аудита.

## Что следует сохранить

- Разделение владельцев: Documentation — смысл правил; QualityControl — исполняемый механизм; приложение — факты, разрешения, продуктовые решения и исключения; task recovery — ход работы и план.
- Раздельные разрешения на создание/изменение/запуск тестов, UI, Simulator, profiling, CI. Отказ пользователя от запуска не является PASS.
- Проверку точной ревизии, закрытые схемы, bounded input/output/process, fail-closed поведение и явные статусы отсутствующего доказательства.
- Различие между компиляцией, статической проверкой, поведенческими тестами, Simulator, устройством и release evidence.
- Архитектурный router, explicit MVVM intent methods, отсутствие спекулятивных слоёв и добавление пакета только под реальную потребность.
- Ручной запуск CI/Codex Review и отсутствие платных сервисов по умолчанию. Новая система не должна незаметно менять это решение.
- Пилоты на двух действительно разных потребителях перед общей активацией нового engine-профиля.

## Находки: authority, границы и распространение

Приоритеты ниже означают порядок исправления системы. P1 — существенный риск ложного доказательства, неверной authority или опасной рекомендации; P2 — конфликт или неполнота, заметно влияющие на корректность/стоимость. Это не утверждение о наличии эксплуатируемой уязвимости во всех приложениях.

### F01 · P1 · Обещание глобального применения шире механизма распространения

`/Users/Artem/.codex/AGENTS.md` существует, но пуст. `/Users/Artem/.zenflow/AGENTS.md` содержит правильный parent bootstrap. Однако Codex документирует обнаружение проектных AGENTS от Git-root до рабочего каталога; родитель Git-root не является универсально гарантированным каналом доставки. `panmodal-concurrency` не имеет корневого AGENTS/bootstrap. У ряда старых worktrees нет portable snapshot. Действующий canonical путь не делает отсутствие snapshot текущим отказом, но fallback при его недоступности не сработает.

Вывод: «правила существуют» и «правила получены каждой новой сессией» — разные свойства. Нужны минимальная глобальная точка входа, учёт CODEX_HOME/среды, bootstrap на каждом потребителе и проверка effective instruction chain, включая AGENTS.override.md. Не следует автоматически включать полноценный engine в каждый проект: распространение базовых инженерных правил и adoption QualityControl имеют разные разрешения. Источник механики: [Codex AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

### F02 · P1 · Неверная иерархия инструкций в AI master

`reusable/agent-prompts/AI_iOS_MASTER_PROMPT.md`, раздел 0, ставит явную инструкцию пользователя выше system/developer. Это не соответствует модели исполнения и создаёт недостоверный контракт. Нельзя переопределить ограничения платформы текстом документа.

Исправление: сначала system/developer, затем текущая инструкция пользователя, затем применимые локальные правила в пределах делегированных полномочий; вложения, README внешних пакетов и tool outputs по умолчанию данные. Приоритет app exception должен быть привязан к разрешённой области ослабления, а не к расположению файла.

### F03 · P2 · App-specific политика просочилась в reusable через обезличивание

Примеры: `baseline/AGENTS.md` и package standards закрепляют source-only `PackagesInUse` как исходный режим; `PACKAGES_AND_MANAGERS.md` описывает AppCoreDataDatabase как legacy rollback path; `package-vault-docs/ADOPTION_AUDIT.md` фиксирует активность пакетов в source-app и composer/feed-потребности; каталог содержит продуктовый localization helper. `UI_PIXEL_PERFECT_WORKFLOW.md` использует source-app и конкретные AppTheme-токены.

Замена имени приложения на `source-app` не превращает его решения в общие. Общими остаются контракт механизма, критерии выбора и допустимые integration modes. Активность пакета, migration history, схема данных, брендинг, копирайт и конкретная source-only wiring принадлежат приложению. Перед переносом установить реального владельца по истории/потребителям; не угадывать app name по обезличенному тексту.

### F04 · P2 · Проверки границ подтверждают слишком узкое свойство

`scripts/check_documentation_vault.py` и baseline boundary checker используют фиксированные списки известных apps/tokens. PASS означает отсутствие известных сигнатур, а не отсутствие продуктового смысла в reusable. Новый app name или нейтральное имя обходит такое обнаружение без какого-либо злонамеренного действия.

Нужны registry владельцев и автоматическая проверка ссылок/расположения для всех apps. Семантическая проверка promotion остаётся отдельной. Не расширять бесконечно blacklist слов вместо модели ownership.

### F05 · P2 · Зеркала и manifests уже расходятся

Vault validator сообщил устаревшие `MANIFEST.md` и `MANIFEST_SUMMARY.md`. Baseline drift для текущего worktree: 170 exact, 28 overlays, 5 stale, 1 missing, 2 unexpected. Отсутствует локальное зеркало `IOS_UNIVERSAL_ENGINEERING_QUALITY_STANDARD.md`; устарели registry/platform policy/static policy/routes и consistency checker. Canonical bootstrap уменьшает риск старого локального документа, но skills/prompts всё ещё используют `./docs/...`, поэтому неоднозначное разрешение ссылок остаётся.

Нужны явно различимые canonical URI, project-relative paths и generated mirrors, а также точная версия distribution. Не обновлять app overlays копированием всей baseline. JSON-отчёты сохранены рядом с аудитом.

### F06 · P2 · Неполная переносимость ссылок и ложная уверенность index checks

Запуск canonical `check_docs_index.py` в baseline не находит `TESTING_INSTRUCTIONS.md` и три `scripts/...` ссылки: distribution хранит некоторые скрипты в `root-scripts`. Это доказывает отсутствие корректного canonical-root режима у данной проверки, но само по себе не доказывает поломку установленного проекта. Аналогично `./documentation-vault/...` внутри уже открытого vault и `./docs/...` внутри skill требуют явного base directory.

Проверять отдельно source bundle и собранный consumer. Registry должен задавать root каждой ссылки; не принимать виртуальную структуру за реальный каталог.

## Находки: качество правил и стоимость применения

### F07 · P2 · Архитектурные правила противоречат друг другу

`IOS_ARCHITECTURE_STYLE_ROUTER.md` разрешает SwiftUI Native State и выбирает подход по существующему проекту. `IOS_UI_STATE_RENDERING_STANDARD.md` формулирует обязательную Screen → ViewModel → ViewState/Renderer структуру для stateful screens. Bootstrap навязывает Coordinator при навигации. Старые feature/refactor/design prompts требуют ViewState, Repository protocol, Action enum и конкретные design tokens; общий README позднее отменяет часть этих требований.

Сделать обязательными ownership, предсказуемые состояния, cancellation и границы IO. MVVM, Coordinator, ViewStateBuilder, Renderer, repository protocol — применять по архитектурному профилю и сложности. У AI Fieldbook screen-oriented MVVM — отдельное принятое ADR; его следует сохранить локально. Общая библиотека не должна переписывать это приложение на Native State и не должна навязывать его структуру другим.

### F08 · P2 · Старые prompt presets формально оговорены, но внутренне не нормализованы

`feature-specific-quick.md` требует Action enum и unit tests; `refactoring-quick.md` требует тесты; test master ориентирован только на XCTest; дизайн master почти не покрывает iPad. `figma-mcp-swiftui-implementation.md`, разделы 23–24, требует запуск доступных build/test команд, тогда как router оставляет runtime пользователю. Наличие README с приоритетами предотвращает формальную отмену новых правил, но не убирает расходы и ошибки выбора.

Переписать активные тела prompts, а старые exact imports сохранить как provenance. Удалить обязательные 20–28-секционные ответы для простой задачи. Quick prompt должен быть действительно короткой операционной формой, а не иной версией архитектурной политики.

### F09 · P2 · Severity, gating и «готово» имеют несколько несовместимых определений

`ENGINEERING_CHANGE_QUALITY_STANDARD.md` блокирует commit/push при P0–P2. `DEFINITION_OF_DONE.md` оперирует P0/P1 с defer. Production framework допускает формулировку с записанным remaining risk, а release gates требуют evidence. В разных матрицах P2 может означать существенный UX-дефект либо naming/maintenance.

Один словарь: impact/severity, confidence, applicability, evidence status и decision — отдельные оси. `PASS` относится к конкретному выполненному gate. `READY_WITH_ACCEPTED_RISK` не является normal PASS. «Можно продолжить локальную работу», «можно merge» и «можно release» должны иметь отдельные условия. Отсутствие ручного CI запуска по действующему решению пользователя не превращать в обязательный merge blocker; при этом не выдавать отсутствие запуска за verification.

### F10 · P2 · Исключения не образуют единого проверяемого контракта

Local ADR, production exception policy, static allowlists и запрет всех concurrency escapes описывают разные варианты разрешений. Не везде обязательны approved-by, точный scope, версия правила, срок, компенсирующая проверка и revalidation trigger.

Единый exception record: ID, app/repository, rule ID/version, affected scope, причина, impact, evidence, owner, approver, approved-at, expiry/revisit, rollback, статус. Запись агентом предложения не означает одобрение. Высокие риски и ослабление universal floors остаются решением пользователя. Предлагаемая модель не открывает новые исключения автоматически.

### F11 · P2 · Обязательная загрузка контекста слишком широка

Измерение действующим reporter: Level 0 — 2746 слов; bootstrap + AGENTS + Level 0 — 4943 слова / 40209 bytes. Типичные маршруты с envelope: implementation 8738 слов, review 8138, universal engineering 11395, QualityControl 12003. У измеренных routes `max_words: null`. Это подсчёт текста, не точный расход токенов/подписки и не доказательство превышения автоматического AGENTS cap: manually-read references — другой канал.

Расход дополнительно повышают повторные headers, широкое production review по слову «review», перечитывание README и старые длинные handoffs. Сначала убрать дубликаты и конфликтующие маршруты; затем измерить input/reasoning/output и повторные чтения на реальных задачах. Целевое сокращение контекста — инженерная цель для пилота, а не обещанная экономия.

### F12 · P2 · Модельный router устарел и не проверен на ваших задачах

В правилах перечислены только Sol/Terra/Luna и используются разные написания Terra/tera. Astra уже доступна. Стоп при неизвестном route может блокировать работу на более сильной явно разрешённой модели. Проценты недельного бюджета нельзя надёжно вычислять из длины запроса.

Нужен router, который признаёт актуальное явное ограничение пользователя. Для данного внедрения единственный маршрут — Luna xhigh. Более сложные изменения требуют более узкого scope, явного контракта и проверки, а не автоматического переключения модели. Достаточность процесса необходимо подтвердить pilot outcomes; одинаковое качество заранее не гарантировано. [Официальные роли и ограничения оценки расхода](https://learn.chatgpt.com/docs/pricing#what-are-the-usage-limits-for-my-plan).

### F13 · P2 · Proof-oriented работа вытесняет проверку полезности

Старый план содержит многочисленные циклы hardening evidence и scope reset от 2026-08-11, который как раз запрещал дальнейшее speculative control-plane расширение. Текущий engine уже имеет сильные границы, но несколько практических adapters ещё staged; два app pilots не завершены.

Сохранить реализованные protections. Новую сложность допускать только под конкретный false-PASS, false-FAIL, permission violation или реальную потребность потребителя. Не строить hostile-runner attestation, автоматический risk scorer, hooks и метрики-платформу перед доказанной пользой основных gates. Повторный semantic review разрешать переиспользовать для неизменного content/tree при повторном подтверждении identity, policy и inputs; это будущая правка governance, не разрешение обходить текущий gate.

### F14 · P2 · Skills и SDK templates сохраняют отдельные несовместимые правила

29 canonical iOS skills в основном полезны как короткие specialist routes, но триггеры вида «whenever ... is mentioned» слишком широки и пересекаются. Три глобальных Swift skills живут отдельно от этой системы и не представлены единым version/provenance contract. В `swift-concurrency/SKILL.md` таблица говорит, что task group отменяет детей при выходе из scope: нормальный выход ждёт завершения, cancellation — отдельная семантика. Там же рекомендация переносить sleep off-main без измеримой тяжёлой работы излишне категорична. [Swift concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html).

SDK `TESTING_POLICY.md` задаёт квоты 5–8/10–20/25+ тестов вместо покрытия рисков. Verification templates используют fallback `mktemp` вне разрешённого root; SwiftUI skill показывает `/tmp` и Desktop. `PRIVACY_TELEMETRY_POLICY.md` считает URL path без query предпочтительно очищенным, хотя путь может содержать account ID или частный slug. Нужны configurable output root, permission guard и route templates/allowlisted metadata. Полезные upstream skills сохранять с pin + local adapter, не размножать их fork без владельца обновлений.

## Находки: точность текущего QualityControl

### F15 · P1 · «Shipped source» определяется именем каталога, а не target membership

`adapters/deterministic_checks.py`, `swift_hot_path_source_paths`, отбирает tracked `.swift` и исключает набор компонентов пути (`tests`, `fixtures`, `docs` и др.). Это не compiler source membership. Можно пропустить реально компилируемый файл в необычной папке или заблокировать неиспользуемый vault source. README честно ограничивает claims по runtime, но называет набор shipped-source.

Развести explicit-scoped source scan и authenticated build-membership scan. Указать источник scope в receipt; пустой неожиданный scope не должен означать проверенный продукт. Для app gates предпочтителен project profile + доказанная membership. Каталог `QC.BUILD.MEMBERSHIP` с generic README вместо положительного/отрицательного fixture также требует точной связи с реальными contract cases.

### F16 · P2 · Hot-path gate фактически запрещает API во всём выбранном Swift

Patterns ищут `Data(contentsOf:)`, `UIImage(contentsOfFile:)`, `PDFDocument(url:)`, `copyCGImage` без анализа executor/call context. Совет «move work behind asynchronous boundary» не устранит совпадение, если синхронный API правильно выполняется внутри worker. Название high-confidence hot-path шире доказательства.

Сохранить жёсткий запрет блокирующего IO в UI hot paths. Для общего source scan либо честно назвать правило API ban как осознанную политику, либо делать contextual review candidate; только подтверждённый context — blocker. Не заменять sync API фиктивным async wrapper ради зелёного regex.

### F17 · P2 · Лексические проверки дают ложные находки и неполное покрытие синтаксиса

`mask_swift_comments` сохраняет строковые литералы, затем regex ищет patterns в результате: диагностическая строка с `Data(contentsOf:)` или `@unchecked Sendable` может стать нарушением. Автомат состояний не является полным Swift lexer для raw/multiline strings и interpolation. `findings_for_disabled_tests` ищет raw text без удаления comments/strings; шаблон `.disabled` не различает условное и безусловное отключение.

Нужны минимальные adversarial/positive controls: string, comment, interpolation, raw/multiline, условный skip, OS-gated test, известная проблема, нулевой selected/executed test count. Для семантических claims выбрать parser/compiler evidence; regex оставить для доказуемо узких случаев. Эти сценарии в аудите не запускались — вывод основан на прочитанном алгоритме.

### F18 · P2 · Каталог не показывает полную цепочку зрелости

`implemented` смешивает наличие adapter, direct invocation, включение в mode orchestration и проверенность на реальном consumer. Formatter/configuration adapters пока требуют отдельных ручных invocations; режимы не должны выдавать их за выполненные. `QC.FORMAT.SWIFTFORMAT` использует Apple's `swift-format`, что стоит отличать от SwiftFormat Nick Lockwood и точно именовать в docs/config.

Ввести maturity/coverage fields: documented → implemented → contract-verified → wired → pilot-verified → enabled; отдельные limits и negative controls. Стабильный ID не менять незаметно: при rename сохранить alias/migration.

### F19 · P2 · Важные gates имеют узкие, полезные, но недостаточные claims

Privacy manifest adapter проверяет структуру и допустимые значения; отсутствие manifest может дать PASS в рамках этого узкого правила. Это не сверка реально используемых required-reason APIs/SDKs с декларациями. Resources gate видит literal references; legacy localization `.strings`/`.stringsdict` в `.lproj` использует технический fallback Base/en/лексический порядок. Для `.xcstrings` adapter уже учитывает `sourceLanguage` и проверяет source fallback; это не доказывает лингвистическую, format/plural полноту. Signing gate сравнивает явно перечисленные файлы, не доказывает корректную подпись. TODO owner syntax не проверяет реальный owner/ticket/expiry по календарю. Dependency lock check не доказывает безопасность/совместимость dependency.

Не объявлять эти adapters бесполезными и не превращать их в огромный универсальный scanner. Сузить labels и дополнить наиболее рискованные gaps profile-driven review gates: privacy runtime reconciliation, product source locale для legacy localization и format/plural variants без повторной реализации существующего `.xcstrings sourceLanguage`, effective configuration, dependency provenance. Нужные проверки определяются конкретным изменением.

## Находки: новый архив

### F20 · P1 · Неверная база diff пропускает committed PR и untracked files

`ios-quality/scripts/lib/common.sh`: `q_diff_base` возвращает HEAD; changed-files/added-lines сравниваются с HEAD. На чистой ветке после commit PR changes исчезают из сканирования. Untracked не включаются обычным git diff. Для unborn repository fallback не покрывает staged initial content. Часть ошибок Git подавляется `|| true`.

Это блокер adoption runner. Нужны отдельные точные режимы working tree/index/commit range, проверенный base, NUL-safe paths и явное поведение вне Git/unborn/shallow/deleted/renamed cases. Существующий QualityControl exact-HEAD контракт существенно сильнее.

### F21 · P1 · Декларированная policy не управляет исполнением

`quality_gate.sh` не исполняет `gates.yaml`, `risk-policy.yaml` или PROJECT_PROFILE как единый контракт. Risk/triggers приходят из environment; нет автоматического обязательного повышения по затронутым границам. `QUALITY_TREAT_NEW_WARNINGS_AS_FAILURE` не образует исполняемого warnings gate. Mode только выводится; phase частично влияет на исполнение: `prepr` при risk ≥ R3 включает full tests (`quality_gate.sh:47–48`). Это не заменяет отсутствующий общий policy/profile dispatcher. Набор R4 gates в YAML не полностью совпадает с обязательными G18/G19/G20/G26 в human matrix.

Переносить смысл в существующие schemas/catalog, а не ещё один независимый engine. Не считать YAML evidence того, что gate был выбран или выполнен.

### F22 · P1 · Secret scan может одновременно пропустить ключ и раскрыть совпадение

`secrets_check.sh` передаёт pattern, начинающийся с `-----BEGIN`, в grep без `-e`/`--`, а ошибка подавляется. Значение может интерпретироваться как option вместо pattern. Вывод совпавшей строки печатается целиком. Решение: не переносить реализацию; сохранить detection intent и использовать bounded redacted structured finding существующего adapter. Наличие секретов в пользовательском репозитории этим аудитом не устанавливалось.

### F23 · P2 · Runner нарушает ваши resource/evidence boundaries

Build/test scripts используют `mktemp`; tests не задают все sandbox-local Xcode paths; cleanup удаляет result bundle. Custom commands через shell config/`bash -lc` не связаны с granular permissions; executable PATH/version и timeout/output/resource ceilings не фиксированы. Config считается доверенным executable input, но это не описано как отдельный trust boundary.

Не запускать такой runner после простого копирования INSTALL. Полезные UX/command идеи переносить только в уже существующий executor с permissions и retained evidence.

### F24 · P2 · Новый комплект полезен как policy source, но не как готовая система

Положительные стороны: 27 тематических политик, короткие маршруты, нормативная сила правил, отличение findings от review triggers, profile с toolchain/isolation/targets, поэтапный legacy adoption, явные проверки поведения и ownership. Исправить: обязательную широкую загрузку для каждого изменения, повторный risk taxonomy R0–R5, неоднозначный SKIPPED, отсутствие исполняемой parity и неподтверждённые readiness claims.

Решение по каждому файлу приведено отдельно. Ничего из архива не получает authority автоматически.

## Современная iOS-база: что изменить по существу

1. **Версии раздельно.** Compiler, Swift language mode, SDK, deployment target, default isolation и upcoming features — разные поля. Xcode 26.6 содержит Swift 6.3; нельзя называть всякий Swift 6 проект одинаковым execution model. [Xcode 26.6 release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-26_6-release-notes).
2. **Concurrency.** Для Swift 6.2+ учитывать default MainActor и NonisolatedNonsendingByDefault; использовать @concurrent при реальной необходимости executor hop. Сам `await` network/sleep не блокирует main thread как синхронное IO. Дедупликация, reentrancy, stale result, cancellation и lifetime остаются обязательными. [Swift 6.2](https://www.swift.org/blog/swift-6.2-released/).
3. **Строгая политика ≠ запрет языка.** Swift допускает вручную доказанную Sendable/concurrency совместимость. Ваша система может запрещать escape hatches как более строгий baseline, но должна честно обозначать выбор и одинаково трактовать его во всех sources. Не добавлять исключения без отдельного решения. [Swift migration common problems](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/commonproblems/).
4. **Testing.** Swift Testing для подходящих новых unit/integration cases; XCTest сохраняется для UI/performance/legacy needs. Проверять отсутствие выполненных тестов, ожидаемые failures, warnings и cancellation; Swift 6.3 добавляет warning issues и Test.cancel. Квоты тестов заменить рисками и доказательствами. [Swift 6.3](https://www.swift.org/blog/swift-6.3-released/).
5. **SwiftUI.** Native controls, adaptive iPad/window layout, Observation по профилю, корректная identity и narrow invalidation. Liquid Glass применять осмысленно к controls/navigation; не добавлять glass на каждую карточку и не заменять проверку accessibility визуальной модой. [Apple adoption guide](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass).
6. **Performance.** Разделить hang detection и responsiveness budget: 250 ms не является достаточным бюджетом отзывчивости. Apple ориентирует на <100 ms для дискретного взаимодействия и значительно меньшую работу приложения внутри кадра; утверждения smooth/optimized требуют сценария и измерения. [Improving app responsiveness](https://developer.apple.com/documentation/xcode/improving-app-responsiveness).
7. **Release.** С 28 апреля 2026 для загрузки iOS/iPadOS apps требуется SDK 26 или новее. Это требование к SDK, а не принудительный deployment target iOS 26. [Apple SDK requirements](https://developer.apple.com/news/?id=ueeok6yw). Privacy declarations проверяются вместе с actual usage, third-party SDKs и product disclosures.
8. **Stable / experimental.** Core AI существует; это не выдуманный API. Но новые WWDC26/Core AI/Foundation Models возможности требуют отдельной таблицы availability и статуса SDK, а не автоматического включения в базу каждого приложения. [Core AI](https://developer.apple.com/core-ai/), [Apple ML resources](https://developer.apple.com/machine-learning/resources/). AI Fieldbook уже хранит iOS 27 track отдельно — это правильную границу следует сохранить.
9. **AI prompts.** Убрать обратный совет читать весь AI master из его последних строк: authoritative intake остаётся AI router. Исправить рекомендацию «не отправлять static prompt при caching»: cache не заменяет передачу обязательных инструкций текущему запросу. Конкретная cache/session semantics проверяется по API провайдера перед реализацией. [OpenAI prompt caching](https://developers.openai.com/api/docs/guides/prompt-caching).

## Пересборка старого плана QualityControl

Старый `universal-quality-control-plan.md` содержит и утверждённые ограничения, и историю, и уже устаревшие next steps. Например, «Stage 6 incomplete» остался рядом с более поздним completion. Сохраняется архивная копия; новый operational plan должен иметь одну текущую строку статуса на этап.

| Старый блок | Решение на основании текущего состояния |
| --- | --- |
| Foundation / permissions / fail-closed / canary | Сохранить; не реализовывать заново |
| Evidence / mode orchestration | Сохранить действующее; исправлять только конкретные gaps; не возвращать speculative attestation |
| H deterministic adapters | Format/privacy/signing/disabled-test уже в main; новые Swift source gates также существуют. Следующий шаг — точность, fixture mapping и mode coverage |
| Остаток H: SwiftLint, warnings, concurrency diagnostics | Действительно staged; внедрять после исправления scope/claims и pin/tool contract |
| I PR recommendation / release governance | Сохранить ручную модель; убрать иллюзию статистической вероятности из процентов, пока нет калибровки |
| J / Stages 12–15 pilots and rollout | Не считать завершённым по наличию canary; два разных consumer pilots и rollback остаются |
| Source blockers app (исторические 19 случаев) | Отдельный app backlog; заново подтвердить на текущем app HEAD/context. Не переносить число в свежий gate result |
| Hooks / automatic scoring / branch protection / advanced telemetry | Отложено; вновь открывается только под доказанную потребность и соответствующее разрешение |
| Снижение ручного чтения | Только после репрезентативного pilot evidence, не по числу PASS или модели |

## Целевая структура и критерий успеха

У каждой нормы один authority owner и stable ID. Policy указывает scope, MUST/SHOULD, применимость, причину, enforcement, допустимые exceptions, evidence и review trigger. Check implementation ссылается на rule ID, но не копирует текст нормы. Prompt/skill выбирает маршрут и формат работы. Project profile хранит реальные target/toolchain/permission/app facts. Distribution содержит pin и generated mirror manifest. История хранит provenance, но не подмешивается в обычный startup.

Система улучшилась, если одинаковые рискованные изменения получают одинаковые требования; известные bad cases не становятся PASS; benign cases не блокируются из-за текста в комментариях; повторные чтения и reviewer corrections уменьшаются; приложение не наследует чужие продуктовые решения. Метрики собирать компактно по завершённым изменениям, без source/секретов/полных логов и без отдельной telemetry-платформы.

## Ограничения выводов

Это аудит документационной системы, её доставки и соответствия выбранным исполнительным контрактам. Это не полный security/code audit всех Swift package/app sources и не новая runtime-сертификация QualityControl. История и зеркала инвентаризированы и структурно сопоставлены; глубокое чтение сосредоточено на активной authority, prompts, skills, quality contracts и всех файлах нового архива. Точная градация приведена в COVERAGE.md. Live saved-prompts UI/DB, удалённые настройки CI и среда будущих компьютеров не проверялись; вывод о глобальности ограничен обнаруженными roots и стандартной механикой Codex.

План намеренно содержит разрешаемую позднее test-writing/runtime фазу для engine: статический аудит не может честно заменить её. Реализация рекомендаций не объявляется выполненной этим отчётом.
