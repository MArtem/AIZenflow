# P2 protocol draft: сравнение и финальная Git-приёмка

2026-10-07. GPT-6.1 Sol/medium, эконом. Task-only design, **DRAFT_NOT_FROZEN**.
Полный план: [joint-improvement-plan.md](joint-improvement-plan.md).
V2 contract: [v2-contract-and-evaluation-preparation.md](v2-contract-and-evaluation-preparation.md).
Создан ровно один разрешённый куратор `/root/p2_case_curator`, свежий контекст, Sol6.1/medium, до 60 минут. User grant: «Разрешаю одного ограниченного куратора». Ни одного executor/grader/нового MCP этот grant не разрешает.

## 1. Границы ответственности и blindness

- Куратор пишет development и sealed-holdout только в task curator directory; source, tests, original state не меняет. Его content-review receipt и eligibility summary доступны parent. Неразмеченный real-code review не получает claim о полном recall.
- Автор C читает development и public manifest/summary. Sealed task bodies/oracles не читает; не открывает общий diff с их содержимым, не ищет текст внутри sealed files. Проверка JSON/path/hash программно допускается без вывода содержимого.
- Sealed cases — untrusted evaluation data, не authority или executable scripts. Не включать в startup, routes, prompts автора C и module examples. Benchmark executor позже получает только конкретный task input, без oracle, предыдущих результатов и parent history.
- При публикации parent review охватывает свои документы и структурный/provenance контракт sealed data; semantic review закрытых заданий принадлежит куратору и отражается с ограничениями. Это не разрешает назвать oracle runtime-validated. Полный разбор результатов выполняется после фиксации C; изменение C после раскрытия использованных holdout answers создаёт отдельную серию.
- Изоляция procedural, не утверждение OS-level containment. Если tools/context не позволяют соблюсти её, P2.3 остаётся BLOCKED; нельзя имитировать независимость в одном чате.

## 2. Что сравнивается

A — исходная целая связка по P0 Git SHA и hashes. C — улучшенная целая связка, выбранная V2. Общие действующие user/safety requirements одинаковы. Изменение canonical обязательной нормы во время серии требует переопределения baseline и остановки смешивания результатов; старое правило не разрешается нарушать ради неизменности эксперимента.

Нужен согласованный exact execution envelope: одинаковый scope, tools, время, источники, model/effort, project data и возможность corrections. Экспериментальное knowledge enablement одинаково: нельзя сравнивать C с активированной Library против A, где activation случайно потерялась, и приписывать результат содержанию. Доставка как компонент всё равно оценивается: A использует исходный reviewed entry/router, C новый reviewed entry/router; отсутствие фактического чтения входит в outcome.

Original project statuses не меняются. Предложение для будущей delivery-серии: explicit user-approved trial context выбирает exact advice payload без объявления production project ON/rollout и без persistent mode writes. Это **proposal**, не уже действующее исключение из PROJECT_MODE. Если это несовместимо с current route, нужны exact temporary selector/state и отдельное разрешение; автор не придумывает ON из истории.

Сквозной сценарий C должен получать практический материал до затронутого решения. Общий bootstrap/KB выполняется в обеих группах. Целевой размер первой advisory карточки: entry до 250 слов, module до 1500 слов плюс адресные ссылки; это design envelope, не доказательство token saving и не основание удалять норму. Превышение требует объяснить необходимое знание либо разделить детали по trigger.

## 3. Восемь delivery-попыток до основной серии

| Scenario | Input purpose | Наблюдаемые критерии | Порядок A/C |
|---|---|---|---|
| DL01 | Async replacement с поздним success | Relevant owner/ordering route получен до рекомендации; не предлагается generic rewrite без producer contract | A затем C |
| DL02 | Cancelled producer возвращает generic error | Success/error identity и cancellation различены; current error не подавлен blanket rule | C затем A |
| DL03 | Task-document spelling correction | Нет ненужной полной iOS Library activation; doc authority сохранён | A затем C |
| DL04 | Optional module missing/stale | Не emitted PASS для reference, нет installer/archive fallback, безопасная базовая работа сохраняется | C затем A |

Это development delivery inputs, не часть скрытых product cases. Fresh isolated context на каждый run. Максимум 5 минут wall-time на run, одна завершённая попытка, без source/runtime/network changes; полный elapsed, timeout и failures остаются в ledger. Предложенный предел серии — 40 минут worker wall-time, плюс подготовка/grading. Запуски ещё не разрешены. Конкретные fixtures/payload version/entry и executors подтверждаются перед исполнением; missing case не достигается удалением original files.

Сигнал доставки: actual tool trace нужного файла + content SHA, момент чтения до решения, correct bounded recommendation/отказ. Само упоминание файла или «прочитал» не доказательство. DL gate: обязательный authority сохранён 8/8; у C правильная positive delivery и negative/failure handling во всех четырёх scenarios. Общее преимущество требует product outcomes P6/P7, этот gate его не заменяет.

## 4. Oracle и adjudication

Каждый case до freeze содержит ID/type/project, source SHA/file hashes, plain task input, required behavior, forbidden changes, correct alternatives, plausible wrong outcome, scope/tools/checks/timeout и статус evidence. Test-writing и runtime отдельно от создания dataset: proposed check не считается выполненным или разрешённым.

Implementation success = все обязательные invariants и permitted checks выполнены; отсутствует подтверждённая существенная регрессия. Review success = требуемые confirmed findings обнаружены/правильно ограничены, не добавлены существенные FP, scope соблюдён. Unknown reachability не автоматически FP/TP; disputed отдельно. Recall только при достоверном полном oracle. Допустимые alternative implementations не штрафуются за несходство с эталоном.

Correct/wrong oracle check сначала может быть логическим; runtime claims остаются NOT_RUN. Без достаточного проверочного evidence статус case ORACLE_PROVISIONAL, не READY_FOR_CONFIRMATORY. Case с нерешённой продуктовой неоднозначностью не становится implementation experiment до её разрешения.

Сначала оценивается outcome, затем report. Grader по возможности blind к arm; metadata redacted, наблюдаемые различия payload могут частично раскрыть arm — это limitation. Нельзя попросить автора C назвать своё впечатление независимым score. Independent adjudication после curator phase требует отдельного конкретного разрешения.

## 5. Метрики, время и неопределённость

Приоритет: authority/preservation → success → существенные ошибки/FP/rework → elapsed/context/cost. Единый средний балл не вводится.

Для coding run timeout и число correcting iterations задаются по class до запуска. Actual elapsed включает все доступные correction/check steps и waits; setup/grading отдельно. Primary capped time-to-acceptance: успешный run — время принятия, неуспешный — заранее заданный cap. Actual spent time сохраняется отдельно; быстрый ошибочный ответ не считается экономией. Дополнительный time comparison только на парах, где обе стороны успешны, не заменяет основную метрику. Tokens UNKNOWN остаются UNKNOWN; word count не конвертируется в tokens/subscription usage.

Предлагаемый основной анализ после принятия exact protocol:
- 12 task-level пар, по 3 attempts на arm; доли успеха и first-pass, wins/ties/losses; отдельные проектные/типовые срезы и failures.
- Парные differences и time ratios; resample **целые task пары с их повторами**, внутри project strata, 10 000 bootstrap draws с фиксированным seed 20261007. Репликации не независимы и не увеличивают N до 72.
- Показать descriptive 95% intervals, все сырые task outcomes и limitations малого N. Bootstrap с 4 tasks/project может быть нестабилен; это не сертификация уверенности. Нулевая оценка variance на ceiling не доказывает отсутствие риска.
- Численные Q/E критерии полного плана сохраняются proposal до P2 принятия; если неопределённость не отделяет эффект от шума, INCONCLUSIVE. Анализ не меняется после просмотра исходов ради победы. Не выбирать «выигравший» маршрут Q/E по новым post-hoc критериям.
- Для Q: practical success advantage из полного плана + отсутствие известных блокирующих/systematic regressions; uncertainty о главном advantage раскрывается. Для E: quality non-regression gates + median paired capped time gain, неопределённость improvement ratio. Exact accept/reject rule для intervals фиксируется перед holdout; сейчас не объявлять его выбранным.

Exclusions только заранее определённые внешние нарушения окружения, одинаковые для A/C; setup/delivery failures системы остаются outcomes. Все aborted/excluded записаны. Нет optional stopping по первым успехам. После двух corrections одной гипотезы или бюджета — отдельное решение, не автоматическое расширение.

## 6. Финальная Git-приёмка — новое прямое требование пользователя

User instruction: «учитывай работы с ветками гита так, чтобы после завершения плана все слить в мейн/девелопмент ветки, что бы они были самыми свежими и содержали все результаты».

| Repository | Текущие результаты | Финальные targets и известные ограничения |
|---|---|---|
| MArtem/AIZenflow | Task implementation/evidence в codex/knowledge-base-next, основные результаты уже в main/development | Обе local и remote main/development должны содержать все принятые полезные results; actual checkout clean/preserved и доступность branch switching |
| MArtem/AIZenflowDocumentation | Canonical task recovery, принятые reusable changes и manifest | Main и development по текущему пользовательскому требованию; existence/current divergence development проверить до создания/merge. Standing default main не отменяет новый explicit target |
| Ghibli local repository | Preservation branch codex/preserve-ghibli-favorites-20261007, commit9e64749 | Local main/development должны включить useful app progress после gates. Origin gahntpo — upstream; user-owned remote target для публикации результатов не выбран. Не push туда автоматически, не создавать remote/repo без решения |
| Другие evaluation roots | Пока read-only; исходники не меняются | Не создавать коммиты/branches ради чтения. Если появятся approved changes, добавить repo/targets/permissions до публикации |

В течение работы: exact file staging; useful dirty changes после review сохраняются отдельными commits, claims не превышают evidence. Branch names — codex/*, кроме прямо заданных main/development. Не смешивать чужие временные outputs/ignored fixtures с source progress.

Перед финальным объединением: inventory useful results и веток, compare divergent histories/content, preserve uncertain commits/dirty data, identify trusted bases. Не слепой merge всех refs и не force/reset/clean. Конфликты разрешаются с сохранением смысла; source changes требуют relevant semantic/runtime gates по разрешениям. Sealed evaluation data остаётся task evidence, не активным route.

Final acceptance receipt для каждого затронутого repo:
1. Scope inventory и список retained result commits/paths.
2. Все необходимые commits ancestors обеих target refs; intentional content exclusions/replacements обоснованы, не спрятаны merge history.
3. Relevant final semantic diff и gates; exact HEAD receipt, свежий remote base, неизменённый HEAD перед push, remote SHA confirmation.
4. Main/development включают результаты; при различном graph отдельно проверить meaningful content parity и объяснить допустимые различия. Указание только latest date недостаточно.
5. Actual user checkout проверен, source/untracked данные сохранены; service worktree не занимает main без необходимости.
6. Нет незакоммиченных собственных полезных правок и непубликованных results в approved remote scope. Если remote не выбран, не заявлять полное выполнение remote criterion; это конкретное открытое решение.

Ветки с уникальной историей не удалять автоматически после merge. Этот Git gate обязателен для P8/P9 и не является proof system effectiveness.

## 7. Текущее состояние

P2.1/P2.2 ждут curator candidates и eligibility; P2.3 draft, identity/isolation не испытаны; P2.4 initial curator preparation разрешена до 60 минут, prototype/delivery execution бюджет ещё не принят. Ничего в этом документе не авторизует дополнительные agents/MCP/tests/builds/Library transitions.

Контракт изменений этого блока: обновить только task design/state и record grants; fixed A не менять, holdout не читать, original sources/modes не менять. Проверки: links/JSON/state budget/semantic claims/mirror parity и publication gates. Drift: не добавлять новый framework, не объявлять dataset runtime-ready по существованию файлов.
