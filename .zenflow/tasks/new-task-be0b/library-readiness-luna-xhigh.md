# План доведения iOS Engineering AI Library до готовности к внедрению

Дата: 2026-09-11. Статус: план подготовлен, реализация не начата.
Автор плана: Astra. Исполнитель всех implementation-блоков: **GPT-5.6 Luna, reasoning xhigh**.
Режим: эконом; приоритет — корректность и сохранность данных, затем экономия.
Это явный пользовательский выбор модели для данного плана, а не изменение глобального model routing.
Не заменять Luna другой моделью молча. При неоднозначности остановить только затронутый блок и запросить решение.

## 1. Цель, границы и критерий завершения

Подготовить конкретный, воспроизводимо проверенный кандидат библиотеки для нашего iOS workflow, с понятной областью применимости, доказательствами, способом включения/обновления/отключения и ответственностью за сопровождение.

Разделить три результата:

| Поверхность | Что означает готовность |
|---|---|
| Knowledge reference | Выбранные материалы технически проверены, не конфликтуют с canonical rules, дают измеримую пользу на ограниченных задачах. |
| Optional runtime | Защитные команды, session state, обновление и установщик прошли macOS-приёмку; ограничения и режим отказа известны. |
| Global activation | Выбран и одобрен пользователем глобальный контракт, проверены реальные целевые пути и rollback; требуется отдельное разрешение на применение. |

**Финиш обязательной части:** пакет кандидата и evidence готовы; knowledge/runtime имеют отдельные выводы; пользователь получает обоснованный выбор режима и точные инструкции. Реальная глобальная установка не является скрытым условием завершения подготовки.

Нельзя объявлять всю библиотеку проверенной по выборке документов, runtime безопасным по одному зелёному suite, а исходники iOS production-ready по работе Python guard.
Если runtime не принят, допустим knowledge-only результат, но весь план нельзя пометить выполненным как full-runtime readiness.

Не входит: переписывание нашего QualityControl, новый policy engine, новые 288 playbooks, массовое изменение приложений, автоматическая миграция глобальных инструкций, release/signing/App Store, UI/Simulator без отдельного разрешения.

## 2. Зафиксированная исходная точка

- ZIP: /Users/Artem/Downloads/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY.zip.
- SHA-256: 7013500596533af138c857d4e98471f9108ffe3c6eaae4055400e439e3f522ce.
- Проверенная копия: /Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v54-s40wNd/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY.
- Отчёт: /Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/ASTRA_REVIEW_V5_4.md.
- Структурный validator: 1357 files, 60 skills, 51 sections, 288 playbooks, errors=0.
- 134/134 Linux/Python 3.13.5 — author evidence, не независимое macOS evidence.
- A53-01 закрыто по исходникам; A52 исправления сохранены.
- Остались P3: недостижимое накопление legacy blockers; неизмеренный риск масштаба и области отказа глобального session registry.
- Знания проверялись выборочно; license/provenance и полезность всего corpus не приняты.
- Глобальная установка не выполнялась.

Предыдущая история QC/app remediation не является текущим планом этой библиотеки. Не возобновлять её по старому handoff.

## 3. Разрешения и безопасная рабочая область

Этот запрос разрешает создание плана, **не исполнение тестов или установку**.

| Действие | Условие выполнения |
|---|---|
| Чтение предоставленных материалов, статический осмотр | Разрешено в текущей области. |
| Правки library candidate и regression tests | Требуется явное разрешение на implementation и test-writing этого плана. |
| Python tests, synthetic Git commits/worktrees, subprocess fixtures | Требуется разрешение на disposable runtime-приёмку. |
| install/update/uninstall внутри synthetic Codex home | Требуется разрешение именно на эту тестовую установку. |
| Swift compilation/unit fixtures | Отдельное разрешение; не подразумевается Python-приёмкой. |
| Реальные app repositories, Simulator, UI, Instruments | Не разрешены планом; точный consumer/action согласовать отдельно. |
| Git commit/push/PR публикация кандидата | Отдельное разрешение с repository/remote/branch; synthetic fixture commits не равны публикации. |
| Настоящий global Codex home/AGENTS/skills | Только отдельное явное разрешение на конкретные пути и действия. |

Рекомендуемый единый пакет разрешений для этапов 0–8: изменения изолированного кандидата и его Python tests, выполнение Python suite и synthetic fixtures, создание временных Git repositories/commits/linked worktrees, test install/update/uninstall/rollback в выделенном synthetic home внутри sandbox. Без настоящей глобальной установки, внешней публикации, app builds и Simulator.

Рабочая область: /Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/.
Создать после разрешения; сохранить отдельные input/, candidate/, fixtures/, state/, tmp/, evidence/ и dist/.
Исходный ZIP/проверенную копию не редактировать. Candidate — отдельная копия с манифестом базовых hashes.
Не инициализировать Git в текущем app worktree ради этой библиотеки. Для candidate выбрать отдельный изолированный root; ветка codex/ioslib-v54-readiness, если пользователь разрешит Git bookkeeping.

До первого запуска проверить scripts на реальные внешние пути/network/env. Для каждого child process направить TMPDIR/TMP/TEMP, cache и explicit --state-root/--codex-home в synthetic paths. Не переопределять HOME/home/CODEX_HOME как рабочие переменные; если script без изменения системных переменных невозможно изолировать, сначала исправить интерфейс/config injection.
Контролируемое чтение установленных системных executables разрешено только по необходимости; секреты и реальные пользовательские настройки не загружать.
Python subprocess может случайно прочитать глобальный Git config: изолировать GIT_CONFIG_GLOBAL/GIT_CONFIG_NOSYSTEM и задавать synthetic author/committer локально.
Не использовать system tmp, глобальные package caches или сеть в suite.
Удалять только проверенные принадлежащие fixture пути, не широкие roots; сохранять важное failure evidence.

## 4. Правила выполнения Luna xhigh

1. Startup: canonical bootstrap → текущий router/Level 0 → этот план → актуальный evidence index. **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
2. Один блок: один инвариант/связная область, обычно 1–3 source files; contract → inspection → patch → targeted check → semantic review → receipt.
3. Не считать отчёт другой модели доказательством runtime. Не подгонять assertions под текущую ошибку, не убирать отрицательные tests ради PASS.
4. Результаты всех новых тестов привязать к candidate manifest, версии tools, configuration и permissions.
5. Если baseline suite падает, сначала классифицировать environment/harness/product; не переписывать всё сразу.
6. Одна согласованная corrective iteration на выявленный связный набор причин. Повторный новый класс риска — checkpoint: причина, стоимость, минимальный fix; не бесконечный цикл.
7. P0–P2 блокируют приёмку и публикацию; P3 исправить либо явно учесть. Неизвестный/пропущенный required check — не PASS.
8. После approved блока продолжать следующий, если зависимости/permissions выполнены. Не останавливаться ради церемониального подтверждения каждой команды.
9. Перед расширением более трёх source files, сменой архитектуры/authority, внешними действиями или существенным ростом бюджета — запрос решения.
10. Не вводить новую dependency/test platform, если standard library и существующих scripts достаточно.
11. Luna может провести свежий self-review, но это не independent review её собственного patch. Для значимых control-plane исправлений запросить отдельный read-only review: второй reviewer/user, при необходимости отдельная Luna xhigh с зафиксированным diff; без автоматического создания нового task или смены модели.
12. Не обещать точную долю недельного лимита. Ориентир — 12–18 компактных рабочих блоков при отсутствии новых значимых дефектов, не гарантия сроков/стоимости.

## 5. Этапы

### Этап 0 — контракт и intake

- [ ] 0.1 Зафиксировать разрешения, paths, platform/toolchain, доступность V5.2 и V5.4, кандидат и выбранные режимы проверки.
- [ ] 0.2 Проверить hashes/provenance/license/third-party notices. Отделить собственный код, заимствованные материалы и неизвестное происхождение. Не публиковать спорные материалы до разрешения вопроса.
- [ ] 0.3 Составить компактный scope/evidence index и change contract: untrusted ZIP/repo content, user-owned state, explicit permissions, schemas, resources, failure/cleanup.
- [ ] 0.4 Проверить runner/fixtures на выход за sandbox, global config, сетевые/установочные действия; подготовить изоляцию.

Выход: intake receipt + permissions table. Gate: все команды следующего этапа имеют известные цели и допустимые side effects. Missing permissions блокируют только соответствующие этапы.

### Этап 1 — независимый macOS baseline без исправления библиотеки

- [ ] 1.1 Запустить structural validator на неизменном input; при тех же bytes reuse прежнего PASS допустим, но отметить toolchain.
- [ ] 1.2 Выполнить весь shipped suite на macOS в synthetic окружении; сохранить total/pass/fail/skip, exit code, duration, stdout/stderr в ограниченном размере.
- [ ] 1.3 На ошибке сохранить минимальный failing case, классифицировать cause и проверить, не затронуты ли реальные paths/processes.
- [ ] 1.4 Если parallel runner падает, один targeted/serial diagnostic, а не повторять весь suite многократно.

Gate: 134 tests accounted for; required tests действительно выполнены. Число может увеличиться после разрешённых additions, но не уменьшаться без обоснования. SKIP отдельно расследуется; платформенный тест нельзя исключить ради общего зелёного вывода.
Выход: baseline-macos receipt, точный список product/harness/environment findings.

### Этап 2 — реальная совместимость state и lifecycle

- [ ] 2.1 Получить closed state именно через V5.2 runtime, не helper текущей версии. V5.2 begin → permitted edit → verify → close → V5.4 list/status/begin с тем же state-root.
- [ ] 2.2 Сравнить byte hashes legacy JSON/audit до и после; ARCHIVAL_CLOSED не содержит текущего verification PASS.
- [ ] 2.3 Active/verified V5.2, corrupt hash, foreign identity, UUID/path mismatch, unknown schema должны отказать. Проверить recovery старым runtime без удаления истории.
- [ ] 2.4 Main + настоящий linked worktree с общим git-common-dir; старый unresolved writer блокирует linked admission, closed history — нет. Независимые clones не используют один writer slot.
- [ ] 2.5 Повторить upgrade/close/reopen; проверить verify/close/begin и concurrent verify, а также прерывание между lease/session writes и повторную попытку.

Gate: история сохранена; один writer; closed терминален; нет false PASS и молчаливого сброса unresolved work.
Отдельно определить политику перехода с V5.3 schema-3/protection-version на текущую: закрытие перед обновлением, явный отказ active state и понятный recovery. Не обещать автоматическую совместимость неизвестных версий.
Выход: cross-version/lifecycle receipt и fixtures. Ненадёжность recovery требует fix до runtime readiness.

### Этап 3 — bounded processes, registry и диагностические данные

- [ ] 3.1 Повторить A52-01 на macOS: silent grandchild с inherited pipes, exited leader, closed pipes, injected read failure, output overflow, total deadline меньше subprocess timeout.
- [ ] 3.2 Проверить cleanup принадлежащих child/process group/descriptors; тестовый harness сам ограничен wall timeout и всегда чистит своих потомков. Не путать zombie с продолжающейся работой, не убивать процесс только по сохранённому устаревшему PID.
- [ ] 3.3 Измерить registry на небольшом, среднем и граничном synthetic наборе; до run зафиксировать максимальные entries/bytes/deadline. Начальный кандидат envelope: 10 000 records, 32 MiB aggregate reads, 10 s observation deadline; это проектное предложение, принять/скорректировать до проверки, не постфактум ради PASS.
- [ ] 3.4 Проверить ошибку в текущем, linked и несвязанном state, unreadable directory, symlink, malformed JSON; определить, где обоснован общий отказ, а где возможна безопасная изоляция.
- [ ] 3.5 При подтверждённой необходимости добавить aggregate budgets/fail-closed diagnostics в legacy scanner; не строить новый registry service и не игнорировать неизвестную принадлежность.
- [ ] 3.6 Устранить P3 unreachable blockers одним согласованным контрактом exception либо structured result; regression подтверждает прежний отказ active/verified.
- [ ] 3.7 Проверить весь serialized output на synthetic secrets/source bodies/remote credentials. Ограничить raw logs, не сохранять реальные секреты.

Gate: declared resource limits исполняются; timeout/overflow/partial не становится PASS; нет живых owned процессов после завершения; findings обработаны. Если масштабирование остаётся ограниченным, runtime adoption обязана иметь явно проверяемый envelope.

### Этап 4 — installer/update/uninstall/rollback

- [ ] 4.1 Synthetic Codex home: dry-run → apply reference → validate → repeat → uninstall. Проверить фактические paths/permissions и отсутствие skills в reference.
- [ ] 4.2 Full mode: только namespaced skills; collision с user-owned files/skills/AGENTS должен отказать до повреждения.
- [ ] 4.3 Реальный upgrade V5.2 → candidate и повторный upgrade, с сохранёнными пользовательскими AGENTS bytes и session history.
- [ ] 4.4 Fault injection: поздняя collision, write/permission failure, interrupted apply, dangling/parent symlink, modified owned file, unknown file inside managed tree.
- [ ] 4.5 Пройти rollback установленного candidate к сохранённому исходному состоянию; сравнить file set, hashes и права там, где контракт их сохраняет. Не удалять session evidence без явной политики.

Gate: никаких изменений вне synthetic home/declared roots; user-owned данные сохранены; partial install/rollback честно диагностирован; повторяемость проверена.
Выход: installation lifecycle matrix + пригодный операторский rollback runbook. Фактические global paths остаются нетронутыми.

### Этап 5 — проверка заявленного runtime-контракта шире author suite

- [ ] 5.1 Зафиксировать независимую от реализации таблицу ожидаемых исходов: минимум 8 allowed и 8 reject/incomplete сценариев по guard, scopes, protected files, index, refs, nested repos, freshness и errors.
- [ ] 5.2 Включить комбинированные случаи: pre-existing MM/index mutation + stage, stage+commit, non-root protected names, повтор stable partial, изменённый producer/options, Git executable spoof, unknown argv.
- [ ] 5.3 Проверить публичные CLI entrypoints, exit codes и status поля, не только private functions. Guard remains advisory; зелёный classifier не выдаёт execution authority.
- [ ] 5.4 Если candidate исправлялся, провести semantic review всего накопленного diff против pinned V5.4, а не только последнего patch; сохранить прежние закрытые инварианты.

Gate: все ожидаемые dangerous cases detected/rejected, allowed cases работают в заявленном envelope; нет ложного успеха. Этот небольшой benchmark не объявляется измерением полноты детектора на любых проектах.
Выход: runtime acceptance matrix с source locations и evidence.

### Этап 6 — пригодность knowledge для нашего iOS workflow

- [ ] 6.1 Инвентаризировать routing/licensing/conflicts; выбрать начальный adopted subset, не подключать все 60 skills/288 playbooks автоматически.
- [ ] 6.2 Проверить минимум 12 уже углублённых документов: lifetime/cancellation, retry/auth refresh, SwiftUI state/identity, migration, memory/performance, security/authentication, VoiceOver. Группировать по 2–3 документа на блок.
- [ ] 6.3 Для каждого: поддерживаемый Swift/iOS/Xcode profile, primary source и дата проверки, реальные ограничения, верность code example, отсутствие опасного универсального рецепта; актуальные API сверять с первичной документацией.
- [ ] 6.4 Сопоставить с canonical rules: ownership/concurrency, permission boundaries, testing, source-only package policy, documentation authority, dispatch API. Конфликтующий материал не активировать молча; исключить или адаптировать с явным provenance.
- [ ] 6.5 Для исполняемых Swift examples определить минимальные compile/runtime fixtures; запустить только при отдельной авторизации. Без неё обозначить examples как conceptual/unverified, не рекламировать compile-tested.
- [ ] 6.6 Составить coverage map: reviewed/adopted/reference-only/excluded/unreviewed. Для непроверенных разделов не наследовать verdict выбранной дюжины.

Gate: у каждого adopted документа понятен контракт и источник; нет открытых P0–P2 в выбранном subset; остальные не участвуют в обязательной маршрутизации.
Выход: компактный adoption map, не новый дублирующий сборник правил.

### Этап 7 — пилот полезности и совместимости

- [ ] 7.1 На согласованном disposable iOS sample либо копии одного разрешённого consumer выполнить три ограниченные задачи с reference-only subset: review concurrency, network/error flow, state/ownership.
- [ ] 7.2 Сравнить baseline «наши правила» и «наши правила + выбранные материалы» на одинаковом scope и фиксированных критериях. Не выдавать повторный ответ того же агента с уже известным решением за слепой независимый эксперимент.
- [ ] 7.3 Оценить найденные подтверждённые дефекты, ложные находки, конфликтующие советы, лишние остановки, время/объём контекста. Использовать заранее заданный answer key для synthetic примеров; не давать его detector при blind evaluation.
- [ ] 7.4 На отдельном disposable consumer включить optional runtime на три bounded write tasks, с user-owned dirty control files, permitted/forbidden edits и rollback rehearsal.
- [ ] 7.5 Проверить реальное влияние one-writer-per-common-dir на наш worktree workflow. Если обязательная сериализация неприемлема, выбрать reference-only/optional runtime; не ослаблять checks ради параллелизма.

Gate: минимум один конкретный подтверждённый дополнительный полезный результат от knowledge, ноль принятых опасных советов/неразрешённых действий; для runtime все заданные нарушения обнаружены и все allowed tasks завершены без необъяснённых блокировок.
Если польза не показана, не внедрять весь corpus «на всякий случай»; уменьшить subset либо зафиксировать отсутствие основания для adoption.
Выход: pilot report с малой выборкой и честной оговоркой, не обещание статистической гарантии.

### Этап 8 — final candidate и независимая приёмка исправлений

- [ ] 8.1 Собрать все правки в одну зафиксированную candidate identity; dependency/license/provenance сведения, hashes и ограничения актуальны.
- [ ] 8.2 Повторить final semantic review cumulative diff и affected consumers/claims. После fixes — один полный повтор review.
- [ ] 8.3 Выполнить весь suite на финальном candidate плюс integration checks, которые реально затронуты; unchanged доказательства переиспользовать по hash входов.
- [ ] 8.4 Упаковать dist, проверить extraction → manifest → validators и executable entrypoints; результаты source tree не автоматически относятся к другому ZIP.
- [ ] 8.5 Если есть control-plane corrections, получить отдельный review финального diff/receipt; при отсутствии reviewer явно оставить independent-review gate pending. Astra не обязательна: executor остаётся Luna xhigh; reviewer не объявляется независимым только из-за нового сообщения.
- [ ] 8.6 Если публикация разрешена, пройти exact-SHA/remote parity contract; иначе сохранить локальный artifact-hash receipt, без фиктивного pushed/merged статуса.

Gate: zero unresolved P0–P2 в принимаемом scope; P3 disposition; все required evidence актуальны; архив воспроизводимо идентифицирован.
Выход: candidate archive, checksums, evidence index, readiness report.

### Этап 9 — готовый пакет внедрения и решение владельца

- [ ] 9.1 Подготовить три варианта: A knowledge reference-only; B knowledge + optional runtime; C global activation. Рекомендация по умолчанию — B только после runtime gates, иначе A; C не подразумевается автоматически.
- [ ] 9.2 Для выбранного варианта определить source of truth, место pinned library code, knowledge subset, место state/logs, update owner, supported toolchain, версия и rollback.
- [ ] 9.3 Подготовить точный dry-run/apply/verify/disable/rollback порядок для реальных согласованных путей; объяснить, что installed reference меняет AGENTS и не равен passive reference.
- [ ] 9.4 Подготовить changeset для canonical integration без дублирования baseline; не применять/promote reusable rules до решения пользователя.
- [ ] 9.5 Выдать финальную матрицу готовности и список решений, необходимых только для реального включения.

Обязательная подготовка завершена, когда владелец может принять решение без дополнительного проектирования и с известным риском.
Отсутствие разрешения на global activation — ожидаемая граница, не причина делать вид, что software проверено меньше, чем фактически проверено.

### Этап 10 — фактическое включение, только по отдельному решению

Не входит в текущую авторизацию и не нужно для статуса «подготовлено к внедрению».
После выбора владельца: проверить реальные paths/permissions, сохранить recoverable baseline, применить одобренный минимальный вариант, verify, один ограниченный consumer task, подтвердить отключение/rollback route.
Ни реальная установка, ни commit/push/PR не запускаются на основании текста этого плана.

## 6. Доказательства, итоговые статусы и остановки

Один компактный evidence index, без второй telemetry platform. Для каждой строки:
ID/scenario → expected → observed → status → candidate identity → platform/tools/config → permission → command/log path → limitation.
Время/metadata не являются самостоятельным доказательством корректности. Логи ограничены и обезличены.

Финальная таблица обязана отдельно показывать:
- knowledge subset;
- runtime protection;
- legacy state/upgrade;
- installer/rollback;
- policy compatibility;
- pilot utility;
- license/provenance;
- independent review при изменениях;
- distribution identity;
- реальную activation authority.

Использовать статусы существующего governance; не изобретать machine-readable систему verdict. Документарное завершение, приёмка кандидата и deployment — разные claims.
При отсутствии required macOS evidence: runtime NOT_READY; при закрытии gates: ready только для явно выбранного scope/envelope.
User waiver фиксировать как accepted risk, никогда не переименовывать skipped test в PASS.

Остановиться и сообщить: потеря/изменение чужих данных, выход из sandbox, подозрение на real secrets, неясная recovery/authority, новый P0–P2 вне согласованного блока, повторная независимая находка другого класса, необходимость внешней установки/публикации.
Не останавливаться просто из-за очередного завершённого микрошага, если дальнейшая работа разрешена и полезна.

## 7. Поддержка после принятия

Назначить владельца version pin и обновлений. Новый ZIP/code/schema/toolchain invalidate только затронутое evidence; global auto-update не включать.
На новый upstream релиз: delta review → affected regression → cross-version check при изменении state → pilot → explicit promotion.
Никакие фоновые monitor/automation не создаются этим планом. Review триггерный, не обязательный периодический шум.

## 8. Готовый стартовый текст для Luna

«Продолжай task new-task-be0b по library-readiness-luna-xhigh.md. Модель Luna xhigh, режим эконом. Перечитать весь актуальный набор документации и правил для этого worktree и task-контекста. Старый QC remediation завершён и не является текущей задачей. Начни с этапа 0, сохрани V5.4 input неизменным, не выполняй действия без актуальной авторизации. Независимые PASS не наследуются из author reports. Отмечай фактически завершённые шаги и продолжай разрешённые этапы без ненужных пауз».

Чтобы разрешить runtime-часть, владелец отдельно добавляет явно сформулированное разрешение из раздела 3. Сам этот пример сообщения не предоставляет разрешений.

## 9. Условия приёмки самого плана

План task-local; не изменяет canonical policy и не внедряет библиотеку.
Detailed steps хранятся здесь, краткий текущий статус — в plan.md/handoff.md.
Пересматривать план при изменении candidate, режима внедрения, permissions или обнаружении нового блокирующего класса; не переписывать весь план после каждого PASS.
