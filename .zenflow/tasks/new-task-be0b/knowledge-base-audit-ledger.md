# База знаний — реестр аудита

Дата начала: 2026-09-27. Это рабочие кандидаты, не закрытые дефекты и не
разрешение на массовые правки. Приоритет и потребители уточняются трассой
реальной загрузки. Источник истины для общих правил — canonical
`documentation-vault/reusable/`; проектные документы могут задавать только
явное локальное усиление или исключение.

## A0: зафиксированный первый срез

- Канонический `reusable/` содержит 4,197 файлов по `rg --files`; в
  обследованных семействах — 158 baseline docs, 53 agent prompts, 29
  `local-ios-skills/SKILL.md` и 256 файлов вместе в baseline docs/prompts/
  навыках/общем iOS knowledge. Это **инвентарь файлов**, не число активных
  маршрутов и не полнота аудита.
- В `AGENTS.md`, проектных `docs/`/`.codex/skills` и канонических bootstrap,
  baseline, prompt, skill и common-knowledge каталогах точечный поиск
  `ios-engineering-library/v5.4` и `.codex-runtime/ios-engineering` дал ноль
  совпадений. Это не доказывает отсутствие косвенной ссылки или иных ошибок.

## Кандидаты на проверку

| ID | Наблюдение и точное место | Возможный эффект | Следующая проверка |
| --- | --- | --- | --- |
| KB-001 | Проектный `AGENTS.md` ранее требовал повторно читать локальный router, который расходился с canonical в четырёх app-specific маршрутах. Те же документы уже объявлены в `docs/TASK_DOCUMENT_ROUTES.overlay.json`. | Двойное чтение тратило контекст и могло выбрать разные документы для одной задачи. | **Исправлено и опубликовано в `main`/`development`**: общий текст router синхронизирован с canonical; добавлен только короткий локальный индекс пяти optional-документов, который требует текстовый валидатор. `AGENTS.md` выбирает один canonical router; новый чат ещё не проверен. |
| KB-002 | При начале аудита проектный и общий `AGENTS.md` и `MODEL_ROUTING_RULE.md` перечисляли только GPT-5.6 Sol/Terra/Luna при фактическом GPT-6. | Буквальное применение могло ошибочно потребовать смены модели или дать неверный статус. | **Исправлено и опубликовано**: канонические правила/шаблоны `e14f398`, проектные правила в `main`/`development` `48e6bdeea`. Описаны GPT-6 Luna/Sol/Astra, selector-supported effort, риск и разница между per-token и полной стоимостью задачи. Проверены статические контракты и SHA; поведение новых чатов ещё не проверено. |
| KB-003 | `reusable/agent-prompts/ios-security-privacy-review.md` задавал только перечень API/областей без доказательства достижимости, контроля атакующего и уровня уверенности. | Поверхностные аудиты могли давать ложные находки, пропускать сквозные пути и завышать серьёзность; дублирующие длинные промпты повышали стоимость контекста. | **Канон `2744466` и проектные зеркала опубликованы**: сценарий требует read-only трассу и факты/предположения, secret-intake сохраняет приоритет; baseline-drift не показывает stale. Неактивный copy-only маршрут добавляет adversarial pass. Runtime-качество ещё нужно проверить сценариями A5/B5/C0. |
| KB-004 | `scripts/resolve_docs_route.py` при выборе широкого route добавляет все `optional_documents` из проектного overlay без дополнительного условия подзадачи. В четырёх маршрутах это пять локальных файлов суммарно 1,763 слова; `report_documentation_context_cost.py` учитывает их в route words без отдельной метки «верхняя граница». | Узкая задача по lifecycle/package/persistence/architecture может загрузить нерелевантный локальный контекст; машинный отчёт нельзя считать наблюдённой стоимостью фактического чтения. | **Открыто, P3 для стоимости контекста**: `AGENTS.md` и router уже требуют отбирать optional-файлы по подзадаче. В A-I5 измерить реальное поведение; затем решать, нужно ли разделять обязательные/условные пути в схеме и отчёте. |
| KB-005 | `ios-security-privacy/SKILL.md` имел catchall-триггер по любому упоминанию security/privacy/PII/permissions и предлагал P0/P1 по имени класса проблемы. | Лишняя загрузка навыка, дублирование prompt/gate и завышение severity без доказанного воздействия. | **Канон `3423925` и проектное зеркало опубликованы**: триггер привязан к реальному аудиту/изменению security boundary; навык ссылается на gate, а полный prompt читает лишь для аудита. Severity зависит от воздействия и экспозиции. Три копии побайтно равны; поведение нового чата ещё не проверено. |
| KB-006 | Навыки `ios-qa-localization`, `ios-configuration-environments`, `ios-memory-cache-media` и `ios-code-documentation` срабатывали по словам widgets/push/IAP, production/debug, image/file и callers соответственно, даже вне своей задачи. Некоторые тела требовали полный QA/media обход для узкой правки. | Лишняя загрузка навыков и вторичных документов, отвлечение от задачи и расход контекста. | **Канон `c2bd24d`/`8b42e9d` и проектные зеркала опубликованы**: условия привязаны к фактической работе; QA/config/media копии равны канону побайтно, `ios-code-documentation` сохраняет разрешённый проектный overlay. Реальное поведение выбора навыков ещё не измерено. |
| KB-007 | В историческом `docs/documentation-split/app-specific/AGENTS.md` оставались инструкции читать полный старый набор документов и использовать GPT-5.4/5.5. В то же время `docs/documentation-split/README.md` прямо запрещает использовать экспорт как активный bootstrap. | При работе внутри вложенного каталога реальный `AGENTS.md` мог навязать устаревшую модель и расход контекста вопреки текущему root/canonical маршруту. | **Локально исправлено, ещё не опубликовано**: вложенный `AGENTS.md` теперь только обозначает историческую область и направляет к корневым/canonical правилам. Старый текст остаётся в Git history. Проверить потребителей и сценарий открытия вложенного файла; не объявлять исправление действующим в `main`/`development` до отдельной публикации. |
| KB-008 | Поиск с `--hidden` нашёл ещё два вложенных `AGENTS.md`: архивный quality-system snapshot в `.zenflow/tasks/new-task-be0b/audit-2026-09-05/archive/`, присутствующий в `origin/main`, и установочный кандидат в `.zenflow/library-adoption-v54/candidate/`, отсутствующий в `origin/main`. Первый содержал самостоятельный обязательный запуск build/tests; второй — указания сохранять глобальную установку. | Работа внутри этих каталогов могла ошибочно принять исторический материал за действующее разрешение или восстановить отвергнутую установочную модель. | **Архивная точка входа локально нейтрализована, ещё не опубликована**: теперь она отсылает к root/canonical правилам, старый текст в Git history. Установочный кандидат сохранён как evidence только в старой ветке: не копировать, не активировать, не сливать. Проверить, нет ли иных скрытых инструкционных точек входа в новых проектах. |
| KB-009 | Канонический `reusable/baseline/templates/AGENTS.template.md` требовал читать `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md` до работы и снова после Level 0; `reusable/baseline/docs/NEW_PROJECT_START_CONTRACT.md` повторял локальный router в gate 6. Canonical bootstrap уже загружает общий router. | Новые проекты могли повторно читать зеркало вместо единого canonical маршрута; при расхождении возможны конфликт и лишний контекст. | **Канон исправлен и опубликован как `0f4a120`**: при доступном canonical используют один общий router и только релевантные overlay-кандидаты; при недоступном canonical явно сообщают fallback и читают tracked local router под portable snapshot. Текущий проектный `AGENTS.md` поправлен локально, но ещё не опубликован. Quality-engine adoption и инфраструктура Codex не менялись. |
| KB-010 | Канонические навыки `ios-lifecycle-background` и `ios-concurrency-runtime` использовали в frontmatter `Trigger whenever ... mentioned`; первый охватывал почти любое слово «widget/extension/notification», второй — «task/async/cancellation». Их тела требовали широкий lifecycle или concurrency обход. | Узкая задача, где термин только упомянут, может загрузить нерелевантный навык и документы, повысив стоимость и шум замечаний. | **Канон исправлен**: concurrency-навык опубликован как `8c741ed`, lifecycle-навык как `d780c89`; проектные зеркала синхронизированы локально, но ещё не опубликованы. Исторические снимки не меняли. Выбор навыков в новом чате не измерен; это текстовая коррекция, а не доказанная экономия токенов. |
| KB-011 | В проектном `.codex/skills/ios-content-cards/SKILL.md` Markdown-ссылки `[PROJECT_DOCUMENTATION.md](./PROJECT_DOCUMENTATION.md)` и `[handoff.md](./.zenflow/tasks/new-task-be0b/handoff.md)` разрешались относительно каталога навыка; там файлов нет. | Пользователь или агент, открыв ссылку буквально, не получит продуктовый контракт или handoff. | **Локально исправлено, P3 до публикации**: оба пути теперь разрешаются от каталога навыка к корню проекта; три ссылки навыка проверены `test -f`, `git diff --check` прошёл. App-specific навык не переносился в reusable. |
| KB-012 | `report_documentation_context_cost.py --task-id new-task-be0b` показывает Level 0 3105 слов и текущие plan/handoff 3380 слов при пределе 3500 для task-state. План сохраняет много уже выполненной истории V5.4. | Каждый новый чат расходует существенный контекст до выбора предметных маршрутов; история вытесняет актуальные факты. | **Открыто, P3 для стоимости контекста**: после текущего аудита сжать завершённые пункты `plan.md` в разрешённый task archive, оставить активные решения/риски/следующие шаги. Не удалять доказательства и не менять handoff без проверки размера и смысла. |
| KB-013 | Канонический `DOCUMENT_BOUNDARY_STANDARD.md`, Import Gate, ставил локальные handoff/plan перед этим стандартом и reusable baseline, хотя canonical bootstrap/router требуют сначала общий baseline и Level 0. | Новый проект мог трактовать task-state как более ранний или самостоятельный источник полномочий и загрузить документы в неверном порядке. | **Исправлено и опубликовано, P2 закрыт на уровне текста**: канон `17414e5` следует bootstrap → baseline/router/Level 0 (с task-state внутри) → тематические документы → app boundary. Проектное зеркало синхронизировано локально; общий drift checker не находит stale. Реальное поведение нового чата остаётся неизвестным до A-I5. |
| KB-014 | Глубокий `figma-mcp-swiftui-implementation.md`, §§23–24, 39–40, требовал запускать build/tests при доступности инструмента; компактный `FIGMA_TASK_ROUTER.md` и текущие user overrides оставляют это отдельным разрешением пользователя. | При Figma→iOS задаче агент мог принять установленный Xcode за разрешение на сборку/тесты и внешние кэши, либо объявить задачу неготовой только из-за запрета запуска. | **Канон и baseline опубликованы `c99e2c7`/`7f81077`, P2 закрыт на уровне текста**: выбор проверок отделён от полномочия, `not_run` и риск названы явно. Remote `main` указывает на `7f81077`; оба канонических файла и проектное зеркало побайтно равны. Проектное зеркало ещё не опубликовано. До A-I5 проверить сценарий запрета build, не заявляя runtime-доказательство. |
| KB-015 | Тот же глубокий Figma-промпт в главной цели, §§10, 21, 23 и критериях требовал Preview/mock data/reusable components даже при узком изменении существующего экрана, хотя компактный router запрещает раздувать архитектуру. | Лишние файлы, preview-зависимости и target membership ради формального чеклиста; рост diff и риск сломанной сборки без продуктовой пользы. | **Канон и baseline опубликованы `722d668`, P3 закрыт на уровне текста**: элементы условны по потребности/поддержке target. Remote main указывает на точный SHA, три копии побайтно равны; проектное зеркало пока локально. Фактический выбор агента остаётся A-I5. |
| KB-016 | `DEPENDENCY_POLICY.md`, Update Policy, безусловно предписывал `Run affected build/test/QA scope` при изменении зависимости; user overrides/governance требуют отдельного разрешения на каждое runtime-действие. | Агент мог запустить Xcode build/tests или QA только потому, что обновляет пакет, нарушив user-owned verification и sandbox caches. | **Исправлено и опубликовано `5d70c86`, P2 закрыт на уровне текста**: стандарт выбирает и рекомендует затронутый scope; запуск только по разрешению, иначе `not_run` и интеграционный риск. Проектное зеркало локально равно канону; runtime-поведение ещё не наблюдалось. |
| KB-017 | `IOS_MEMORY_CACHE_MEDIA_STANDARD.md` и `IOS_NETWORK_RESILIENCE_STANDARD.md` называли runtime traces/relaunch/manual-offline/tests «Required Verification» без локального указания, кто вправе это выполнять. Общий governance оставляет действия пользователю. | Узкий тематический маршрут мог прочитать требование как самостоятельное разрешение на Instruments, сетевой QA или тесты, а без них неверно выдать PASS. | **Уточнено и опубликовано `5d70c86`, P3 закрыт на уровне текста**: проверки выбираются по изменению, runtime/tests лишь при делегировании; иначе `not_run` и риск. Проектные зеркала локально равны канону, remote main подтверждён на точном SHA. |
| KB-018 | `IOS_SECURITY_PRIVACY_GATE.md` назначал `P0/P1 by default` всем перечисленным категориям без установления экспозиции/воздействия, вопреки общему severity-контракту. | Завышение или неверная приоритизация security findings; сильный ярлык мог заменить проверку фактов и затруднить принятие точного решения. | **Канон опубликован `26ca4c7`, P2 закрыт на уровне текста**: категории потенциально блокирующие, P0–P3 по реальному impact/exposure, confidence отдельно; unknown sensitive-data boundary не PASS. Проектный overlay синхронизирован локально; секреты не читались. |
| KB-019 | `IOS_PERFORMANCE_BUDGETS.md` требовал `Use Instruments` при жалобе на лаги или изменении feed/list, без локального указания на user-owned runtime permission. | Агент мог запустить профилирование/Simulator без разрешения либо выдать неподтверждённое «performance improved». | **Канон опубликован `26ca4c7`, P3 закрыт на уровне текста**: Instruments рекомендуется по риску, запуск только при делегировании; без измерения claim непроверен. Проектный overlay синхронизирован локально. |
| KB-020 | `IOS_UI_STATE_RENDERING_STANDARD.md`, Stop Rules, запрещал любой production screen без failure/empty и требовал MVVM/ViewState позже, хотя в том же документе допустимы native SwiftUI state и только применимые состояния. | Для статического экрана или локального UI-state агент мог создать фиктивные failure/empty ветви и лишний ViewModel, вопреки простой архитектуре. | **Канон опубликован `7cb5bbf`, P3 закрыт на уровне текста**: failure/empty нужны лишь когда достижимы; ownership/render-state контракт обязателен для stateful screen, стиль выбирается по проектной границе. Проектное зеркало локально равно канону; static gates и remote SHA подтверждены. |
| KB-021 | Между источником `reusable/agent-prompts/` и управляемым baseline `reusable/baseline/docs/agent-prompts/` было 16 несовпадающих Markdown-файлов. Baseline `test-generation-quick.md` требовал feature-based MVVM, baseline `code-review-master.md` — Action enum и AppTheme; AI master даже ставил user instruction выше system/developer. | Текущий проект повторял baseline и мог получить устаревшую архитектуру, неверный порядок полномочий и лишний контекст; прежний baseline-drift не проверял верхний source→baseline слой. | **Исправлено и опубликовано `d8dc684`, P2 закрыт на уровне файлов**: полезное baseline-only дополнение Rule ID/evidence перенесено в source, 15 устаревших копий синхронизированы пакетами по 3. Все общие source→baseline→project prompt-файлы побайтно равны; manifest/vault/router/index/drift/diff-check и exact-HEAD прошли, remote main подтвердил тот же SHA. Реальный выбор промпта остаётся A-I5. |
| KB-022 | Четыре навыка `ios-api-contracts`, `ios-network-resilience`, `ios-offline-sync`, `ios-test-strategy` сохранили слишком широкие `description`-триггеры в baseline и проекте по сравнению с `reusable/local-ios-skills/`; слова API/offline/widget/test активировали не тот домен без риска/действия. Ещё три source→project отличия — metadata или разрешённый project overlay. | Лишняя загрузка навыков, дублирование проверок и токенов; возможность принять общий термин за отдельный экспертный аудит. | **Канон/baseline опубликован `c805823`, P3 закрыт на уровне текста**: четыре описания синхронизированы, проектные копии локально равны baseline; `ios-code-documentation` overlay и metadata-only различия сохранены. Реальный auto-selection нового чата пока `unknown`. |
| KB-023 | `IOS_CODE_DOCUMENTATION_STANDARD.md` трактовал неуточнённое «добавь документацию в проект» как требование прокомментировать все значимые executable-файлы, не проговаривая лимит 2–3 source files/итерацию и отдельное решение для большого блока. | Агент мог принять широкую цель за разрешение на одномоментный дорогой sweep всего проекта и объявить частичную работу полной. | **Канон опубликован `2ceba46`, P3 закрыт на уровне текста**: whole-project остаётся inventory/completion target, но изменения идут разрешёнными порциями с честным остатком; проектное зеркало локально равно канону. |
| KB-024 | `PRODUCTION_QUALITY_GATES.md` держал отдельную severity-таблицу: P2 назывался только maintainability, P3 — polish, а crash/security автоматически тянулись к P0. Канонический `IOS_PRODUCTION_AUDIT_MATRIX.md` и QC governance задают иной единый impact/confidence/evidence контракт. | Один и тот же дефект получал разный приоритет в разных маршрутах; P2 correctness мог быть ошибочно понижен, а несущественный crash завышен без экспозиции. | **Канон опубликован `2ceba46`, P2 закрыт на уровне текста**: отдельная таблица удалена, единая шкала и правила P0–P2/P3 добавлены; проектное зеркало локально равно канону. |
| KB-025 | `IOS_UNIVERSAL_ENGINEERING_QUALITY_STANDARD.md`, Severity and exception policy, имел вторую независимую расшифровку P0–P3: любой correctness/concurrency относился к P1, performance к P2, независимо от воздействия. | Универсальный слой мог конфликтовать с audit matrix и по-разному блокировать финальный diff для однотипных findings. | **Канон опубликован `2ceba46`, P2 закрыт на уровне текста**: единая шкала impact и независимые confidence/applicability/evidence axes; доменное слово не назначает приоритет, P0 stop и P0–P2 gate сохранены. Remote main подтверждён на `c805823`; проектное зеркало локально равно канону. |

KB-001: четыре маршрута resolver возвращают все пять прежних локальных документов,
общая часть проектного router побайтно совпадает с canonical; `--all` не дал
missing/unclassified/failures. Проектный diff опубликован в `main`/`development`
как `0df17826f`; новый чат не проверен, а KB-004 ограничивает утверждение об
экономии контекста.
KB-002 не считать доказанным во всех новых чатах до отдельной runtime-проверки.

## A1: проверенная трасса типовых маршрутов (2026-09-28)

- Действующий вход: проектный `AGENTS.md` → canonical bootstrap → общий
  `AGENTS.md` → canonical router/Level 0 → подходящий маршрут; автоматической
  ссылки из этих проверенных точек в неактивную copy-only библиотеку нет.
- Для совмещённых маршрутов lifecycle, packages, persistence и architecture
  `resolve_docs_route.py --json` вернул 19 документов, включая все пять
  проектных optional-файлов; `missing=0`, `failures=0`. Код resolver добавляет
  optional в `documents` и печатает их под общим заголовком `Resolved route
  documents`, не отличая кандидатов от обязательных чтений. Это уточняет
  доказательство KB-004: риск лишней загрузки реально присутствует в машинном
  выводе, но фактическое поведение агента после новых текстовых указаний ещё
  не измерено. Не менять schema/resolver до сценарного сравнения или отдельного
  ограниченного согласования контракта вывода.
- Эта трасса не завершает A0/A1: другие entrypoints, вложенные overlays,
  триггеры навыков и поведение нового проекта ещё не проверены.
- Первичный поиск имён без `--hidden` пропустил `.zenflow`. Повтор с
  `--hidden` обнаружил четыре `AGENTS.md` в этом worktree: корневой,
  исторический documentation-split, архивный quality-system snapshot и старый
  V5.4 candidate. Их область действия вложенная, не весь проект; последние
  два дали KB-008. Поведение нового чата не проверено.

## A-I1: статический receipt authority/inventory (2026-09-28)

- Canonical документация `d780c8937f8e60a98142d2d0ac15d68a77aa69aa`;
  этот worktree — `codex/audit-remediation-luna` при `9f9421e68` с локальными
  изменениями. Это не публикационный SHA проекта.
- Действующая трасса старого проекта: родительский и root `AGENTS.md` →
  canonical bootstrap → общий baseline `AGENTS.md` и router → Level 0
  (три статических документа плюс текущие plan/handoff) → task route;
  проектный overlay добавляет только условные кандидаты. При отсутствии
  canonical — tracked portable snapshot и локальный router с явным
  `canonical-baseline-unavailable`. Шаблон нового проекта содержит тот же
  bootstrap marker и эту fallback-границу; это статическая трасса шаблона,
  не наблюдение свежего чата.
- Обследованный активный корпус: 158 baseline docs, 53 agent prompts,
  29 canonical iOS skills; проектная `.codex/skills` содержит 31 навык,
  включая два проектных (`ios-content-cards`, `ios-reusable-packages`).
  Машинный registry содержит 43 маршрута, проектный overlay — четыре
  добавления. `resolve_docs_route.py --all --task-id new-task-be0b`:
  106 route-документов, 111 с Level 0, `missing=0`, `unclassified=0`, `failures=0`;
  router check: 95 классифицированных документов, Level 0 — 3105/5000 слов.
- Архив/неактивное: historical documentation-split и task audit имеют
  отдельные вложенные `AGENTS.md`, локально обезвреженные; старый V5.4
  candidate остаётся лишь в ветке-предохранителе и не входит в активные
  маршруты. Copy-only библиотека не активирована. Обнаружение навыков,
  фактическое чтение optional-документов и поведение нового чата остаются
  неизвестными до A-I2/A-I5.

## A2: бумажные сценарии выбора навыка (не runtime-доказательство)

- «Уточнить план задачи; async-код не меняется»: concurrency-навык не нужен,
  несмотря на слова task/async в описании. Новый триггер это выражает.
- «Исправить отмену `Task` при смене экрана»: навык нужен; новый триггер
  сохраняет проверку владельца, отмены и времени жизни затронутой операции.
- «Изменить текст подписи в widget»: широкий lifecycle-обход сомнителен,
  а UI-only сценарий остаётся под локальными правилами UI/ресурсов. Новый
  lifecycle-триггер его исключает; если меняются исполнение расширения или
  shared data, навык по-прежнему требуется. Реальное auto-selection не проверено.
- После двух узких исправлений дальнейшее механическое сужение всех `Trigger
  whenever` остановлено: `ios-error-handling` и другие описания требуют
  сценарного подтверждения, иначе можно убрать полезный обязательный обзор.
  В `PRODUCTION_QUALITY_GATES.md` уже есть явные ограничения на тестовые правки
  и пользовательское разрешение для performance/runtime evidence; противоречия
  этому при точечном чтении не обнаружено. Это не полный A2-аудит.

## A-I2: статическая матрица маршрутов (2026-09-28)

- Все 43 машинных route проверены resolver `--all`: 106 route-файлов,
  111 вместе с пятью Level 0,
  `missing=0`, `unclassified=0`, `failures=0`. Отчёт стоимости: нет
  превышений настроенных route-бюджетов и недостижимых зарегистрированных
  документов; 180 точных project mirrors и 29 разрешённых overlays без
  `missing/stale/unexpected/failures`.
- Самые тяжёлые route-only верхние оценки по отчёту: quality-control
  governance 10063 слов (12 документов), universal iOS quality 7810 (7),
  new-app bootstrap 5892 (11). Их высокая стоимость сама по себе не ошибка:
  это широкие задачи. Level 0 3105 слов; текущие task plan/handoff 3380,
  обе части под своими пределами, но общий startup без иных инструкций уже
  около 6485 слов. KB-012 фиксирует возможность безопасного сжатия.
- Четыре проектных overlay-route добавляют пять optional-файлов. Resolver
  и cost report считают их в общем списке, а текстовые правила требуют
  читать только релевантные подзадаче; это KB-004, не PASS фактического
  auto-selection. Prompt/skill содержимое и сценарии остаются за A-I4/A-I5.
- При просмотре всех Markdown-ссылок вида `](./...)` в 31 проектном навыке
  две ссылки навыка content-cards не разрешаются из его каталога (KB-011);
  прочие обнаруженные относительные ссылки ведут в существующие references.

## A-I3: authority и риск-стандарты (2026-09-28)

- Семантически сопоставлены canonical bootstrap, router/Level 0, текущие
  user overrides, model routing, engineering change, QC governance,
  evidence/completion, secret intake, document boundary и source-of-truth map.
  Одна подтверждённая несогласованность порядка чтения — KB-013 — исправлена
  каноническим коммитом `17414e5`; remote `main` подтверждён на этом SHA.
- Разрешения на tests/build/runtime и Git не следуют из quality-гейтов:
  change standard прямо отделяет evidence от разрешения, governance хранит
  отдельные test permissions, user overrides оставляет runtime пользователю.
  Рекомендация хранить секрет в Keychain — правило для человека, не разрешение
  агенту менять Keychain; текущая задача не обращалась к секретному корню.
- `PASS` требует применимости и свежего terminal evidence; skipped/denied не
  превращаются в успех. Completion contract требует отдельные непроведённые
  проверки и остаточный риск. При выборке этих источников второго
  противоречия уровня P0–P2 не найдено; это не runtime-подтверждение.
- Проверки проекта: router 95 classified, bootstrap PASS, docs index 208,
  boundaries PASS. Канон: manifest PASS, vault 5136 файлов PASS, exact-HEAD
  diff review и clean tree после `17414e5`. Далее — предметные iOS-семейства
  и проектные навыки; KB-011/012 и KB-004 остаются P3.

## A-I4/A-I5: предметное покрытие и статические сценарии (2026-09-28)

- `validate_ios_knowledge_system.py`: 18 активных iOS-доменов, 5 отмечены
  complete, 4 платформы deferred; реестр ссылается на 31 уникальный
  operating document, 15 deep references и 23 навыка. Это проверка
  существования/регистрации, а не доказательство актуальности каждого тезиса.
- Статический resolver для этого worktree и task ID дал без missing/failures:
  review+PR 12 документов; fix+concurrency 11; feature+accessibility/localization
  14; architecture 11; persistence 9; build graph 9; Figma+accessibility 14;
  new-app routes 16. Последний кейс использует нынешний root как fixture,
  а не реально созданный новый проект. Optional-файлы учтены как верхняя
  граница; реальные чтения и выбор навыков в свежем чате не наблюдались.
- В Figma-глубоком промпте подтверждён KB-014: доступность `xcodebuild` не
  была достаточным разрешением на build/tests. Канон исправлен и опубликован
  `c99e2c7`, baseline-зеркало `7f81077`; remote указывает на `7f81077`,
  локальное зеркало равно обоим каноническим файлам.
  Проектный content-cards навык исправлен локально (KB-011), три ссылки
  разрешаются в существующие файлы. `skill-creator` использован для узкой
  правки существующего навыка; его дорогие runtime/eval циклы не запускались,
  потому что изменение касается только детерминированных путей.
- Сценарии no-build, conflict/exception, недостатка Figma assets и нового
  чата ещё требуют отдельной трассы решений; не помечать A-I4/A-I5 готовыми
  только по положительному resolver output.

### Негативные бумажные трассы (не исполнение нового чата)

- `Figma frame + нет разрешения на build/tests` → `ios-figma-design` +
  accessibility route → компактный Figma router (build user-owned), глубокий
  prompt лишь при сложном layout/assets → статический review и `not_run` для
  build/tests с рекомендацией пользователю. Это теперь одинаково во всех
  трёх копиях prompt; никакая команда сборки не запускалась.
- `Figma frame + отсутствуют assets/fonts` → router Fast Intake требует
  указать точные недостающие материалы и согласовать export/existing asset/
  deferred item; нельзя молча выдумать имя или продуктовый fallback.
- `Локальное исключение против reusable правила` → user overrides и
  DOCUMENT_BOUNDARY_STANDARD требуют явного одобренного app/task ADR;
  task-state сам по себе не переопределяет baseline. До решения существенного
  конфликта результат не объявляется готовым.
- `Новый Xcode-проект` → canonical template/bootstrap и выбранные new-app
  routes дают 16 документов в нынешнем worktree-fixture; фактическое
  получение этих инструкций новым чатом/проектом остаётся `unknown`.
- `Изменение target/extension` → build-binary + platform-capabilities routes
  дают 12 документов без missing; нужно статически проверить source/resource
  membership, owner, entitlements и affected consumers. Без разрешения build
  остаётся `not_run`, а сборочная готовность не объявляется PASS.
- `Введение/перенос пакета` → reusable-packages + build-binary routes дают
  14 документов без missing; выбирать package boundary только при текущей
  необходимости и учитывать источник/target integration, license/security и
  rollback. SwiftPM не становится дефолтом; tests/build отдельно разрешаются.
- `Figma→assets/localization` → design + accessibility/localization routes
  дают 14 документов без missing; сверить реальные export/asset names,
  локализованные строки, target membership и отсутствующие ресурсы. При
  неясных Figma facts задать один предметный вопрос, не выдумывать ассет;
  визуальная/runtime проверка остаётся пользователю.
- `Review с недостатком evidence` → review + security routes дают 16
  документов без missing; severity зависит от воздействия, confidence и
  applicability отдельно. `unknown/not_run` не становятся PASS, finding
  остаётся до фактов или явного risk decision.

## A-I4: gate активных iOS-семейств и prompt/skill mirrors

- Все 18 активных registry-доменов имеют существующий route/operating/deep
  набор; `validate_ios_knowledge_system.py` PASS. Семейства: universal quality;
  Swift/runtime/concurrency; SwiftUI/adaptive UI; AI/App Intents; architecture;
  API/network; identity/security; persistence/offline; testing/debugging;
  build/supply chain; capabilities/extensions; media; performance/operations;
  release/App Store; StoreKit; accessibility/localization. Deferred watchOS,
  visionOS, tvOS, macOS не выданы за завершённые iOS-домены.
- Содержательный проход был риск-ориентированным по operating rules и
  задействованным prompt/skill interfaces: ownership/state, authority,
  severity/evidence, build/test/Simulator, Figma→assets/Preview, migrations,
  networking, privacy, localization, release. Он дал KB-014–025. Не было
  повторного построчного чтения 15 deep references и всех 2758 строк AI
  master: они загружаются только по своим task routes; актуальность каждого
  внешнего Apple/API тезиса без разрешённой внешней проверки остаётся UNKNOWN.
- Источник→baseline→проект: все общие Markdown prompt presets побайтно
  равны после `d8dc684`; четыре исправленных навыка равны трём слоям после
  `c805823`. Два навыка отличаются только distribution metadata,
  `ios-code-documentation` и два project-only навыка сохраняют локальную
  область. `ios-content-cards` ссылки исправлены, но локально не опубликованы.
- Ни один static PASS не доказывает, что новый Codex chat выбирает нужный
  навык/optional-документ или что Xcode target реально собирается.

## A-I6: финальный локальный audit receipt (2026-09-28)

- Проверенный canonical docs SHA `c805823cece77dcb406f1a4aef055b759b5ef6a4`:
  remote `main` подтвердил его; canonical checkout чистый. Источник prompt
  presets → baseline → проектные общие prompt-копии побайтно равны.
  Управляемые baseline mirrors: `missing=0`, `stale=0`, `unexpected=0`,
  `failures=0`. Ровно 4 навыка были синхронизированы; project-only навыки
  сохранены локальными.
- Проектный кандидат на старой ветке `codex/audit-remediation-luna` **грязный**:
  40+ изменённых файлов, включая архивные nested `AGENTS.md`, но без файлов
  установщика, Codex host config, auth или Keychain. Git-публикация проекта
  не разрешается документационным standing permission; перенос только
  проверенных правок без installer history требует отдельного решения.
- PASS статически: docs consistency; index 208; bootstrap; router 95; границы;
  iOS registry 18 active/4 deferred; production framework 54 required files;
  resolver 43 routes, 106 route docs + 5 Level 0 = 111 combined без missing/
  unclassified/failures; context-cost policy без превышений; remote state;
  `git diff --check`. Build, tests, Simulator, Instruments не запускались.
- Не закрыты как runtime evidence: загрузка маршрутов и auto-selection навыков
  в свежем чате после этих SHA; реальный build/target membership; выбор
  optional-documents; актуальность внешних Apple/Swift сведений. Устаревший
  ранее предоставленный fresh-chat receipt не подтверждает новые тексты.
- Остаток P3: KB-004 (optional/верхняя стоимость 1763 слов), KB-012
  (startup task-state 3380/3500, полный instruction envelope 8219 слов),
  проектная публикация KB-011 и зеркал ещё не выполнена. Других известных
  **локально неустранённых P0–P2** по этому статическому аудиту нет.
- Вердикт: **локальный статический кандидат готов к дальнейшей проверке, но
  A6 / стабильная опубликованная база знаний ещё NOT_READY** до безопасного
  переноса проектных изменений и честной fresh-chat проверки. Не начинать B.

## A-I6: точечная проверка первичных источников (2026-09-29)

- С разрешения пользователя read-only сверены официальные Apple Releases и
  Swift.org. Реестр ошибочно называл Xcode 27 и iOS/iPadOS 27 RC: Apple уже
  опубликовала Xcode 27 (27A266a) 14 сентября и iOS/iPadOS 27.0.1 (24A446)
  28 сентября; Swift.org подтвердил выпуск Swift 6.4 15 сентября.
- Исправлены только `verification.toolchain_reference`, ссылки на релизы и
  формулировка правила о beta/RC в canonical baseline и проектном mirror.
  `last_primary_source_review` оставлена 2026-09-10: этот проход **не был**
  повторным аудитом каждого API-тезиса во всех доменах.
- Источники: https://developer.apple.com/news/releases/?id=09142026a и
  https://www.swift.org/blog/swift-6.4-released/. Установленный локально
  Xcode, совместимость конкретных проектов и фактическая загрузка правил
  в новом чате этой проверкой не установлены.
