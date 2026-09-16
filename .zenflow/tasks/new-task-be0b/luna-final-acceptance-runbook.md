# Исполнимый план Luna Xhigh: библиотека, подключение, три пилота

Дата: 2026-09-15. Task: new-task-be0b. Режим: эконом. Исполнитель: Luna Xhigh.
Этот документ задаёт следующий проход, когда пользователь поручит Луне его выполнить.
Сейчас Astra подготовила план; реализация, новые pilot tasks и host mutation не запускались.
План не отменяет явные запреты пользователя и не выдаёт себе новые разрешения на внешние пути.

## 0. Результат и исходные факты

Нужны два работающих способа подключения библиотеки (manual/installer), проверяемая доставка
общего baseline и выбранных знаний, а также три ограниченных пилота на настоящих исходниках.
Не создавать новый framework, новые глобальные правила или масштабный аудит всех приложений.

Обозначения — точные абсолютные корни:

- T = /Users/Artem/.zenflow/worktrees/new-task-be0b
- L = T/.zenflow/library-adoption-v54
- C = L/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY
- V = /Users/Artem/.zenflow/worktrees/documentation-vault
- S = V/reusable/ios-engineering-library/v5.4
- R = V/.codex-runtime/ios-engineering
- P = /Users/Artem/.zenflow/library-acceptance-projects
- E = L/evidence/final-acceptance

В shell раскрывай обозначения в проверенные абсолютные пути. Не переопределяй HOME или CODEX_HOME
ради удобства. Явный codex-home CLI target не доказывает, что Desktop использует его.

Последнее независимое ревью: L/evidence/31-astra-acceptance-and-pilot-intake.md.
Вердикт RETURNED: четыре открытых P2. Не сводить остаток к пользовательскому пилоту.
Текущий проверенный пакет .7; V17 ZIP SHA256:
746946651ed1d540377a33007d930ec30b60b18b57ff7e157f6ff0f0cff08a22.
Все 1366 файлов архива совпали с candidate, validator 0 ошибок. Это structural/byte PASS,
не deployment PASS. 196 total / 191 PASS / 5 SKIP — прежний результат автора, не новый запуск.
Последний implementation commit: 5a34f4dd616d4f9076800043a367b59974272450.
fc9ffd798a5bf14339d88911b75edf19646f45b5 — последующий receipt-only HEAD на момент ревью.
Проверь фактический HEAD и dirty state; новые правки Astra принадлежат текущему task.

## 1. Полномочия, экономика и порядок

1. Перечитай canonical bootstrap, Level 0 и только маршруты library control-plane, testing,
   documentation и выбранного пилота. Не загружай все 60 skills и весь корпус.
2. Сохрани выбранный пользователем Luna Xhigh; не переключай модель сам. Если возникает
   неразрешённый архитектурный выбор с риском данных, подготовь ограниченный вопрос для Astra.
3. Исправления библиотеки, её адресные tests, canonical synchronization и commit/push двух
   рабочих репозиториев уже разрешались. Не спрашивай это повторно. Используй sandbox escalation
   для записей в V и P, если инструмент требует его. Не обходи отказ другим инструментом.
4. Внешние /Users/Artem/.codex/AGENTS.md и AGENTS.override.md не входят в разрешённую .zenflow.
   Прежде чем читать/менять их, проверь, есть ли в новых сообщениях точное разрешение.
   Если нет, подготовь точную операцию и запроси только её. Не исследуй весь .codex.
5. Запрещены secrets/auth/history/session directories, домашний .git, глобальная смена launcher,
   незапрошенные настройки Desktop, отправка данных/PR/issues в upstream проектов.
6. Xcode, Simulator, dependency installation, app tests, signing и workflow не разрешены текущим
   блоком. Этот план не превращает требование «сама» в такое разрешение. Library Python tests
   разрешены прежним task scope. App test-файлы не менять без открытия соответствующей фазы.
7. На проектах допускается запланированный локальный implementation-пилот после команды
   пользователя выполнить план; сейчас они сохранены неизменными. Firefox/Countries — read-only.
   Новые project commits/push не подразумеваются прежним разрешением для T/V.
8. Файлы/кэши/логи/fixtures — только .zenflow. Рабочие fixtures держать в E, кроме сценариев,
   которым production boundary требует другой явно допустимый destination. Не объявлять E
   внешним к Git root: на этом Mac home-level Git root известен.
9. До/после каждого этапа оцени размер создаваемых каталогов. Не создавать DerivedData вообще.
   Новые generated data сверх 500 МиБ требуют пересмотра необходимости. Не копировать Firefox
   несколько раз и не загружать полную Git-историю. Нужные старые payload/backup сохранять.
10. Одна содержательная правка → адресная проверка → semantic review → следующий блок.
    Не повторять полный suite и упаковку между исправлениями. Не коммитить свой текущий SHA
    в попытке сделать receipt самоссылочным; SHA фиксируется снаружи коммита.

## 2. Приоритет P2: четыре исправления библиотеки

### R1. Самостоятельная manual установка и исполнимый harness

Область: C/MANUAL_DEPLOYMENT.md, C/tests/test_review_ready.py; только при доказанной
необходимости C/MANUAL_SHIM/bin/manual_preflight.py. R1 закрывает findings 1 и 4 из ревью.

- Раздели два явных профиля: clean-host без canonical repository и current-host с exact R.
- Для clean-host LIB_ROOT и ACTIVE_CODEX_HOME задаются отдельно; canonical flags отсутствуют.
  Все mutable destinations проходят существующие production ancestry/ownership проверки.
- Для current-host оставь ровно существующее исключение MArtem/AIZenflowDocumentation/R.
  Не вводи второе исключение ради тестов. Runtime внутри скачанных приложений запрещён.
- Не менять работающий Desktop и реальную установку ради rehearsal. Сначала fixtures.
- Сохрани текущие ownership receipts, original AGENTS bytes/modes, no-follow, отказ при collision,
  staging/порядок публикации, сохранность state и обработку неуспешного emitter.
- Harness должен выбирать нужный профиль и заменять реальные placeholders документа.
  До запуска shell проверяй, что все обязательные placeholders заменены ровно как ожидается;
  остался /ABSOLUTE/PATH или отсутствует нужный блок — явный FAIL harness, не SKIP.
- Выполняй документированные shell-блоки, а не переписанную в тесте «идеальную» установку.
- Host-independent проверки placeholder/profile выполнять до environment-dependent skip.
- Адресные cases: свежий reference/full, AGENTS absent/existing, отказ на чужом/изменённом файле,
  неправильном профиле и отсутствующем payload; update/disable — по реально выбранному пути.
- При отсутствии разрешённого внешнего-к-Git target выполнить negative checks и harness checks;
  positive end-to-end = BLOCKED_ENVIRONMENT с точной причиной. Не mock Git boundary в CLI тесте.

Готово: самостоятельные команды не требуют V; current-host commands не расширяют исключение;
test fixture действительно исполняет текст документа. Пропущенный positive сценарий остаётся
незакрытым доказательством, даже если исправление по исходникам принято.

### R2. Installer fresh-full отдельно от reference→full

Область: C/README.md, C/QUICKSTART.md, адресные library tests.

- Fresh full: install_global.py, matching full dry-run/preflight ID, пустая допустимая область.
- Existing reference: sync_global.py --codex-home <existing> --mode full --dry-run;
  затем тот же sync с --preflight-id <ID именно этого dry-run>.
- Existing full update также требует matching ID; проверь все связанные примеры обновления
  и отката, а не только README section 7. Не переносить ID installer в sync или между профилями.
- Не добавлять portable/canonical flags к sync, если parser их не принимает: существующий
  registry хранит профиль. Проверить реальные argparse и downstream consumers.
- Проверить сохранение состояния и пользовательских файлов, отказ устаревшего/неверного ID,
  конфликт существующего unmanaged skill. Fresh install поверх registration должен отказывать.

Готово: последовательность reference→full использует поддерживаемый producer/consumer flow;
разница fresh/migration очевидна во всех трёх документах установки.

### R3. Реальный возврат к .6, а не .7→копия .7→.7

Область: C/sync_global.py и только необходимые общие helpers, docs, адресный test.

- Старый .6 брать из сохранённого PORTABLE.zip с SHA
  57e34f454b5247a43864f89354cdb02a742e5a26d1e6a343d287c9b05bd76e27;
  проверить SHA до распаковки. Извлекать только безопасные уникальные entries без traversal.
- Сохранённый .6 payload не менять и не подменять его sync новым файлом.
- Сначала зафиксировать отказ старого .6 sync на чужом registered source: это baseline дефекта.
- Предпочтительное направление: существующий исправленный sync управляет выбором проверенного
  старого payload, если ownership/schema/runtime compatibility действительно допускают это.
  Не добавлять флаг, который лишь меняет путь без согласования version/descriptor/identity.
  Не создавать второй installer или rollback service. До production patch выписать контракт:
  кто исполняет update, откуда берётся incoming manifest/runtime, что остаётся прежним и что
  публикуется последним. Если этот путь требует новой небезопасной архитектуры — остановить R3
  с конкретным анализом, не заявлять неподдерживаемый downgrade как выполненный.
- Приемлемая альтернатива — существующая проверяемая recovery-процедура с backup/restore,
  которая возвращает .6 и то же состояние. Одного удаления обещания rollback недостаточно для
  полного принятия согласованного жизненного цикла; неподдерживаемый downgrade явно блокирует его.
- Фактическая цепочка: .6 → incoming fixed release → .6. На каждом шаге реальные CLI,
  version/knowledge_root/source_tree_sha256, descriptor, launch validation и изменённый материал.
- Сохранить sentinel пользовательского файла, режим AGENTS, байты исторического состояния,
  прежний payload и неизменные path boundaries. При несовместимом active state — отказ.
- Проверить ошибку во время публикации: нельзя сообщать успешный rollback при частичном состоянии.
- Unit test с mock разрешён как unit; он не заменяет end-to-end и не называется host PASS.

Готово: documented recovery исполним для реально выпущенной .6, либо отдельно зафиксирован
точный blocker. Не выбирать случайно только удобные одинаковые версии для зелёного отчёта.

### R4. Согласование и один финальный library suite

- После R1–R3 проверить полный изменённый diff, вызовы, README/QUICKSTART/manual/validation report.
- Для новых fixtures не создавать global Git bypass. Не выполнять повторную реальную установку.
- Обновить version/package manifest согласно существующей процедуре после стабилизации.
- Запустить один полный serial Python suite с явными temp/cache roots внутри .zenflow;
  сначала проверить runner и его поддержку fixture root. Не полагаться на системный /tmp.
- Для каждого SKIP записать test name, проверяемое поведение, конкретную средовую причину,
  влияние на acceptance. «Host-dependent» без объяснения недостаточно.
- До независимого re-review статус SELF_VERIFIED, не ASTRA_ACCEPTED. Ни subagent той же модели,
  ни собственный финальный ответ не являются новым независимым ревью Astra.
- После исправлений синхронизировать S/C, обновить существующий R только штатным sync и с backup
  в разрешённой области. Не перезаписывать unknown assets. Проверить выбранную identity.

## 3. Host delivery: диагностировать, а не переустанавливать

Различай три наблюдения: (a) наши common rules пришли; (b) выбран именно исправленный пакет;
(c) агент применил relevant route. Каждое имеет свой PASS/FAIL/UNKNOWN.

- Прочитать только разрешённый descriptor R/ios-engineering-shim/INSTALLATION.json и global
  instruction block в R. Проверить source/version/hash. Это факт дисковой установки, не Desktop.
- Установить доступные facts активного task/host через продуктовые инструменты и явно доступный
  контекст. Не выдавать env дочернего shell или unset CODEX_HOME за доказательство процесса Desktop.
- Если вход ведёт через project bootstrap — записать PROJECT_ENTRY. Это не доказательство
  независимой global delivery в imported project без AGENTS.
- Не угадывать active home по стандартному пути. Если доступных facts нет, UNKNOWN.
- За пределами .zenflow читать только после точного разрешения; потенциальный запрос ограничить
  двумя AGENTS-файлами. config.toml — только если необходим и отдельно разрешён; не печатать secrets.
- Если нужен host patch, подготовить byte-preserving diff exact managed block/precedence/fallback,
  сохранить остальной текст. Общие правила для .zenflow не должны активировать iOS route для
  non-iOS задач. Предложения evidence/22 и /28 — вход анализа, не автоматически принятый patch.
- Применять только с фактической authority. Смена CODEX_HOME/launcher не считается рутинной
  частью установки и не делается наугад. Если необходим restart Desktop, подготовить состояние,
  попросить только restart, затем продолжить проверки. Не закрывать работающее приложение самовольно.
- Пока host операция недоступна, закончить независимые библиотечные проверки/подготовку пилотов;
  не заставлять пользователя выполнять ваши shell-проверки и не объявлять весь task заблокированным.

## 4. Fresh-entry контроль до изменений проектов

Начальный prompt не должен упоминать библиотеку, правила, baseline, skills или имена ожидаемых
документов. Coordinator хранит матрицу evidence отдельно. Не отправлять этот runbook в проверочную
новую задачу: тогда она заранее знает, что должна «обнаружить».

Запуск fresh tasks — только после пользовательской команды выполнить этот план с пилотами.
При наличии create/list/read task tools использовать их после проверки схемы, выбирать Luna Xhigh
по доступной модели инструмента. Не менять модель существующей чужой задачи и не создавать
дубли бесконечно. Если проект отсутствует в доступных saved projects, не выдавать projectless
за project task: подготовить exact path для добавления пользователем. CLI/subagent probe явно
обозначать своим типом; он не доказывает Desktop fresh entry.

Исходные репозитории не переобновлять: pin из intake. До observation не добавлять наши AGENTS,
portable snapshot, engine launchers или workflows. Это согласованный deferred bootstrap для
тестового intake; не утверждать adoption до отдельной проверки. Upstream AGENTS сохранять.

Минимальная матрица:

| Case | Корень | Что проверяет |
| --- | --- | --- |
| Existing/project overlay | P/firefox-ios | native upstream AGENTS + общая доставка |
| Imported, no root AGENTS | P/GhibliSwiftUIApp | доставка без нашего project marker |
| Второй imported | P/clean-architecture-swiftui | повторяемость на иной архитектуре |
| Empty Git, no AGENTS | P/entry-empty-git | новый проект; disposable fixture, без app source |
| Non-Git + non-iOS | P/entry-non-ios | отсутствие ложного iOS route |
| Linked worktree | P/entry-linked, от disposable entry-empty-git | самостоятельный entry при .git-файле |

Последние три создать только как маленькие локальные fixtures при выполнении плана; не менять
refs upstream приложений. Empty Git можно снабдить единственным README и локальным seed commit
для создания linked worktree; это disposable test data, не продуктовый commit/push.
Non-iOS fixture: README с текстом «Проверка небольшой текстовой папки. Код приложения отсутствует».
Если нужны nested/outside-scope cases, nested расположить внутри disposable fixture; outside
.zenflow не создавать. Отсутствие внешнего разрешения → NOT_RUN для outside-scope.

Обычный read-only prompt для entry cases:

> Кратко опиши структуру текущего проекта и предложи один небольшой следующий шаг. Ничего
> не изменяй, не устанавливай зависимости, не запускай сборки и тесты.

Для non-iOS:

> Прочитай README и предложи более понятную формулировку его текста. Файлы не изменяй.

До повторных подсказок сохранить первый turn и доступные tool calls. После него можно спросить:

> Назови источники инструкций, которые были доступны до первого действия. Отдели уже
> предоставленные инструкции от файлов, прочитанных позже. Сейчас ничего дополнительно не читай.

Этот ответ — supplementary self-report, не единственное доказательство. Инструкции могут быть
внедрены в контекст без отдельного tool read; отсутствие такого вызова само по себе не FAIL.
Нужны доступная provenance и порядок действий; если инструмент не раскрывает их — UNKNOWN,
а не выдуманный PASS/FAIL. Не требовать показать скрытые system prompts или внутренние рассуждения.

Для каждого case: task ID, точный cwd, исходный SHA, original AGENTS inventory, prompt,
наблюдаемые первые действия, common route/package route, источник доказательства и ограничение.
Не читать файловые user sessions ради evidence: только доступные task tools/ответы.

## 5. Pilot A — Ghibli: ручной повтор загрузки списка

Корень: P/GhibliSwiftUIApp.
Pin: 524c434882dcc22d95b1c5781f295d8fbfe0ced6.
Прочитанный факт: FilmsScreen в .error показывает только Text; FilmsViewModel.fetch() уже
загружает список, меняет state и имеет guard против текущей загрузки. ContentView запускает
первую загрузку через .task. Продуктовую задачу не нужно придумывать заново.

Обычный prompt implementation-задачи:

> На экране Movies при ошибке загрузки сохрани сообщение об ошибке и добавь кнопку Retry.
> Нажатие должно повторять существующую загрузку списка; во время загрузки повторное действие
> недоступно. При успехе показывай список, при повторной ошибке снова сообщение и Retry.
> Не меняй поиск, избранное, сервис API и архитектуру приложения. Не запускай сборки, тесты,
> установку зависимостей, commit или push. Покажи diff и оставшиеся проверки.

Перед mutation: entry observation уже сохранён; coordinator проверил ограничения и локальные
overlays. При необходимости явного подключения библиотеки после неудачного auto-entry отметить
GUIDED_PILOT: это позволяет оценить пользу знаний, но не закрывает AUTO_ENTRY.

Порядок работы:
1. Проверить чистоту/pin и relevant nested instructions. Не fetch upstream.
2. Читать только FilmsScreen.swift, Networking/FilmsViewModel.swift, LoadingState.swift и
   ContentView.swift как прямой caller; подходящий service/mock — только если требуется понять API.
3. Выбрать минимальные library routes error handling + SwiftUI. Не делать concurrency migration.
4. Изменить преимущественно Views/FilmsScreen.swift. Второй production файл допустим лишь
   для конкретной необходимой lifecycle/intent корректировки, с объяснением.
5. Использовать существующий fetch, не добавлять retry framework, сетевые retries, новый service,
   ViewModel, routing enum или протокол. Асинхронное действие имеет понятный lifetime; не использовать
   Task.detached. Не создавать бесконечную автоматическую перезагрузку при появлении error UI.
6. Native Button с доступным названием Retry; сохранить сообщение и текущий layout насколько возможно.
7. Проследить error→loading→loaded/error, guard double-tap, повторное отображение экрана и cancellation.
8. Один git diff --check и полный semantic diff. Никаких app tests без разрешённой test-writing фазы.

Готово: маленький понятный diff, без соседних изменений; guard/visibility не допускают повторных
параллельных запросов из кнопки. Результат = STATIC_VERIFIED; работа UI/компиляция = NOT_RUN.
Для runtime acceptance нужен отдельный разрешённый запуск с controllable service error/success;
отключение сети само по себе не deterministic regression test. Не обещать runtime PASS.

Если при чтении выявлена проблема поиска SearchFilmsViewModel (например, stale responses),
не расширять этот пилот. Записать отдельно без исправления: поиск не входит в задачу.
Не включать сторонний исходник Ghibli в архив библиотеки; license availability не проверена.

## 6. Pilot B — Firefox: ограниченное read-only ревью поиска

Корень: P/firefox-ios.
Pin: 0ac7cc9e98b81ac7ec68b18cd38ea6ab8a0ed071.
Upstream root AGENTS.md сохранён. Не запускать fxios/bootstrap.sh/npm/brew и не ставить Rust.

Начальные файлы относительно корня:
- firefox-ios/Client/Frontend/Browser/Search/SearchViewModel.swift
- firefox-ios/Client/Frontend/Browser/Search/SearchViewController.swift
- firefox-ios/firefox-ios-tests/Tests/ClientTests/Search/SearchViewModelTests.swift
- firefox-ios/firefox-ios-tests/Tests/ClientTests/Search/SearchViewControllerTests.swift

Обычный prompt:

> Проведи read-only ревью цепочки поисковых подсказок Firefox: смена запроса, отмена/поздний
> ответ и ограничения приватного режима. Начни с SearchViewModel и SearchViewController в
> firefox-ios/Client/Frontend/Browser/Search и существующих SearchViewModelTests/SearchViewControllerTests.
> Проверяй конкретные дефекты поведения, не стилевые предпочтения. Не изменяй файлы, не запускай
> приложение, сборки, тесты или установки. Дай подтверждённые findings и границы уверенности.

Порядок:
1. Relevant review workflow + concurrency/network/privacy guidance по реально затронутому пути.
2. Trace query→provider→callback→state→UI; актуальность результата, отмена, empty query,
   смена engine, private mode и consent/preferences проверять по callers, не по именам переменных.
3. Разрешено открыть до трёх прямых зависимостей (найти точный SearchSuggestClient/provider path
   через rg), если без них утверждение не подтверждается. Не сканировать весь Firefox.
4. Для findings указать priority, path:line, trigger, consequence, why existing guard insufficient,
   подтверждение из callers/tests. Потенциальный вопрос с неизвестным invariant — не подтверждённый P2.
5. Ноль findings допустим. Не придумывать issue ради успешного пилота и не переписывать архитектуру.
6. Итог read-only, git status должен совпасть с before. Тесты лишь прочитаны, не выполнены.

Готово: воспроизводимое рассуждение по узкой цепочке, проверенные или отвергнутые гипотезы,
материалы библиотеки, которые реально повлияли на анализ. Ревью Luna не называть независимой
приёмкой библиотеки Astra и не публиковать upstream PR/comment.

## 7. Pilot C — Countries: сеть, persistence и UI error semantics

Корень: P/clean-architecture-swiftui.
Pin: 9eca97b8cfff96a14084b564b1fefd949c93d232.
Это cross-domain внутри iOS; non-iOS проверка отдельно в разделе 4.

Точные начальные файлы относительно корня:
- CountriesSwiftUI/Interactors/CountriesInteractor.swift
- CountriesSwiftUI/Repositories/WebAPI/CountriesWebRepository.swift
- CountriesSwiftUI/Repositories/Database/CountriesDBRepository.swift
- CountriesSwiftUI/UI/CountryDetails/CountryDetailsView.swift
Прямые supporting types: Utilities/Loadable.swift, WebAPI/WebRepository.swift,
Repositories/Database/ModelContainer.swift — читать только необходимое.

Обычный prompt:

> Проследи загрузку подробностей страны от CountryDetailsView через CountriesInteractor
> к сети и локальной базе. Объясни поведение при cache hit/miss, forceReload, ошибке сети,
> ошибке чтения или записи базы и отмене. Проверь, не выдаётся ли неуспешная операция за успех
> и сохраняются ли ранее доступные данные. Исходники не меняй, сборки/тесты не запускай.
> Дай таблицу сценариев, подтверждённые дефекты при наличии и ограниченный план их проверки.

Порядок:
1. Два основных specialist routes: network + persistence; UI error contract — прямой consumer.
2. На реальном коде проследить обычный cache hit, cache miss, forceReload=true, network failure,
   DB read failure, DB write failure, read-after-write miss, cancellation, retry из UI.
3. Разделить наблюдаемое поведение и желаемую политику продукта. Например, try? превращает
   ошибки чтения в nil, но это не автоматически defect: установить consequence и контракт caller.
4. Итоговая таблица: trigger → call sequence → resulting state/error → data preservation → evidence.
5. Обнаруженные проблемы описать без исправления. Существующие tests можно читать; не менять.

Готово: связная сквозная проверка минимум двух областей и честная граница статической уверенности.
Никаких незапрошенных миграций SwiftData, mock network framework или новых архитектурных слоёв.

## 8. Как оценивать пилоты без самообмана

Coordinator ведёт один компактный E/summary.md, а не десятки очередных receipts:

| Поле | Обязательное содержание |
| --- | --- |
| Identity | project SHA, library version/hash, task ID, Luna model/effort |
| Entry | AUTO / PROJECT / GUIDED / UNKNOWN и основание |
| Scope | точные файлы и исходная задача |
| Knowledge | что реально загружено и какое решение/проверку это изменило |
| Result | diff либо findings/таблица сценариев |
| Verification | выполнено/не выполнено; команды и exit codes |
| Friction | лишние чтения, неподходящие правила, необоснованные остановки |
| Verdict | PASS в названном scope / FAIL / NOT_RUN / UNKNOWN |

Не утверждать причинный выигрыш относительно «без библиотеки», если контрольного сравнения нет.
Достаточно конкретного использования guidance и корректного результата без лишней работы.
Для trial не обязательны найденные bugs; правильное отсутствие findings также полезный результат.
Если правило заставляет трогать весь учебный проект/запускать запрещённый build — это finding
на routing/scope, а не причина тихо отменить пользовательский запрет.

## 9. Финальная публикация и стоп-критерии

1. Закрыть R1–R3 либо честно перечислить оставшиеся P2; не публиковать accepted release с ними.
2. Собрать результаты библиотеки, host, fresh-entry, трёх пилотов и non-iOS control отдельно.
3. Сохранить полезные уникальные ревью/план: выборочный git add в T/V, без fixtures, чужих
   исходников, user state, секретов и распакованных дубликатов. Не git add .
4. Сверить S/C и установленную identity; один итоговый manifest/validator/suite после всех code
   changes. Если suite уже соответствует тем же bytes/input, повторять его только ради ZIP не надо.
5. Semantic review полного final diff и affected consumers; адресный fix/повтор проверки при дефекте.
6. Commit/push T и V по прежней authority после закрытия blockers; проверить remote SHA.
   Если авто-проверка отклонила конкретную операцию, сообщить именно отказ/причину, не выдумывать
   новое требование повторного разрешения для всего task. Пилотные upstream repos не пушить.
7. Новый архив из проверенного S с новым уникальным именем, старые ZIP сохранить. Проверить
   traversal/entries, исключить runtime/cache/.git, сверить все file bytes, записать SHA256.
   Не добавлять новые возможности или пересобирать архив после каждого документационного receipt.
8. В финале назвать отдельно: package integrity, manual/installer lifecycle, installed runtime,
   auto delivery, pilots, runtime verification и independent acceptance. Общий «готов» допустим
   только для действительно закрытого объёма. Остаток с недоступным host/runtime = NOT_RUN/UNKNOWN.
9. При отсутствии новых разрешений закончить весь разрешённый объём и вернуть один точный
   запрос на оставшуюся внешнюю операцию. Не требовать от пользователя делать диагностику самому.
10. Не менять model selector самостоятельно. Если независимая Astra-приёмка результата ещё нужна,
    подготовить exact diff/commands/results и сообщить один ограниченный остаток для неё.

## Чеклист выполнения

- [ ] Startup/pins/authority/dirty state проверены.
- [ ] R1 standalone manual и stale harness исправлены, адресные результаты сохранены.
- [ ] R2 fresh/migration/update commands согласованы и проверены.
- [ ] R3 настоящая .6 recovery проверена; state/payload сохранены.
- [ ] Structural/full-suite evidence соответствует финальным bytes; skips объяснены.
- [ ] Host common delivery и library selection определены отдельно.
- [ ] Fresh-entry observations сохранены до project mutation.
- [ ] Ghibli implementation-пилот завершён в согласованном объёме.
- [ ] Firefox read-only review завершён.
- [ ] Countries cross-domain analysis завершён.
- [ ] Non-iOS control выполнен или точно обозначен NOT_RUN.
- [ ] S/C/R согласованы; полный diff reviewed; release blockers отсутствуют.
- [ ] Разрешённые commit/push и archive verification завершены.
- [ ] Финальный отчёт различает PASS/NOT_RUN/UNKNOWN и independent review.

При передаче: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
