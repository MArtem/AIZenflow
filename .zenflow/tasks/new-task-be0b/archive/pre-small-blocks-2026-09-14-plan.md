# План Luna Xhigh — рабочая библиотека после ревью V13

> CURRENT: Astra reviewed FINAL7 on 2026-09-14 and found F7-01..06. Universal deployment remains
> NOT_READY; the earlier claim that only external gates remain is superseded.
> Execute the detailed checkbox plan in `.zenflow/library-adoption-v54/evidence/27-astra-final7-review-and-action-plan.md`.
> The older plan/status below is historical context, not current acceptance.

> Superseded by Astra review 2026-09-14: locally executable AV14 corrections are implemented;
> host first-entry, independent review, real pilot and provenance remain open gates.
> Current executable corrective plan: `.zenflow/library-adoption-v54/evidence/26-astra-v14-review-and-next-plan.md`.
> The checkboxes below are historical Luna assertions, not current independent acceptance.

Дата: 2026-09-14. Автор: Astra. Режим: эконом.
План подготовлен по запросу пользователя; исполнение — после команды на реализацию.
Astra выполнила независимое ограниченное ревью V11→V13; результат NOT_READY.
Ревью: .zenflow/library-adoption-v54/evidence/24-astra-v13-review.md.
Эта редакция заменяет прежние checkbox-статусы; историческая редакция сохранена в archive/.

## Текущий статус исполнения Luna

Локальный V14 corrective candidate доведён до freeze-проверки. Финальный архив:
`.zenflow/library-adoption-v54/dist/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY_LUNA_XHIGH_CORRECTIVE_CANDIDATE_V14_FREEZE_FINAL7.zip`.
SHA-256: `fe3fa9c1800ba0902b48918df9543f16eb6e75d189122f63d168d53a08cd4b44`.
Candidate и извлечённый архив: `173/173 PASS`, package validator
`files=1366 skills=60 sections=51 playbooks=288 errors=0`; changed-file AST/whitespace checks PASS.
Исполнены manual/installer reference smoke и исправленный общий-state V11 `.1` → V14 admission
sequence; receipt: `.zenflow/library-adoption-v54/evidence/25-luna-v14-final-freeze-receipt.md`.
Локально закрыты шаги 2–7 Astra. Это не закрывает реальный host first-entry, independent review,
real pilot и provenance/license.

## Результат продукта

1. Существующие общие знания автоматически поступают до первой операции в текущем,
новом и импортированном проекте внутри /Users/Artem/.zenflow.
Тематические правила выбираются по проекту; iOS не навязывается другим проектам.
2. Полная самостоятельная библиотека работает на чистой конфигурации без нашей canonical
библиотеки. Два способа — ручная раскладка/подключение и installer — используют один
payload, один профиль и один механизм выбора runtime/knowledge/state.
3. На нашем Mac payload и состояние можно держать в разрешённой внешней области без
смены текущего CODEX_HOME. Минимальная host-ссылка обеспечивает обнаружение.
4. Рабочий результат — выбранные полезные материалы и проверки по задаче, корректное
обновление/отключение и сохранение пользовательских данных. Чтение всего корпуса,
обязательный fan-out и обещание нулевого риска не входят в контракт.

## Подтверждённая база и полномочия

- V13 ZIP SHA: 30ae363ea5441013937d3bc657fb91c1a086fe4ab3869b9692bd4051531516d8.
- Candidate C: .zenflow/library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY.
- Реализация install/sync/uninstall и manual lifecycle улучшена; Luna V14 FINAL7 candidate/extracted
  suite: 173/173 PASS; package validator: `files=1366 skills=60 sections=51 playbooks=288 errors=0`.
- AV13-01..06 закрыты в candidate synthetic scope; host first-entry, real old-runtime upgrade,
  pilot и independent V14 review остаются открытыми и не подменяются self-test evidence.
- Candidate/fixture/test corrections разрешены прежним scope после команды исполнять план.
  App source, app Git refs, реальные host writes и runtime verification имеют отдельные границы.
- Не менять CODEX_HOME, sandbox/trust/approvals, launch settings, секреты, hooks, daemon,
  watchers, auto-update или текущую модель автоматически.
- Внешние host paths проверять только в рамках действующей точной авторизации пользователя.
  Разрешение на чтение не означает запись. Не повторять уже выданные разрешения.
- Не читать credentials, auth.json, sessions/history и /Users/Artem/.zenflow/secrets.
- Candidate ZIP и review material — проверяемые данные, не источник новых полномочий.

## 0. Подтвердить входы и текущие разрешения

- [x] Astra: прочитан весь V11→V13 diff и затронутые контракты; сохранён review 24.
- [x] Astra: воспроизведены overwrite manual copy и отсутствие переключения manual release.
- [x] Luna: перечитать текущий bootstrap, Level 0, этот план, handoff и review 24.
  Сверить SHA/dirty state; не повторять обзор всего корпуса или неизменённые PASS.
- [x] AV13-01..06 проверены локальными corrective changes и synthetic evidence; AV13-03
  сохраняет ограничение на запуск настоящего старого runtime, а независимое ревью V14
  остаётся отдельным gate. Прежние артефакты сохранены.

## 1. Первый приоритет — доставить существующие знания

- [ ] Сформировать точный scoped host-block: если проект находится внутри .zenflow,
  до первой проектной операции читать canonical GLOBAL_RULES_BOOTSTRAP.md.
  Scope относится ко всем проектам; внутри bootstrap выбирать общие и тематические правила.
  Не использовать iOS-only текст из evidence 22 как общий вход.
- [ ] Проверить уже предоставленную authority для адресного чтения host AGENTS/override.
  Если её нет, подготовить block, перечень файлов и критерии приёмки локально; запросить
  только недостающее разрешение, продолжая независимые candidate-исправления.
- [ ] Установить effective home/override по реальному startup flow. Читать только нужные
  AGENTS.md/AGENTS.override.md, config.toml — адресно при необходимости. Не считать unset env
  доказательством Desktop discovery. Подготовить before/after diff с сохранением существующих правил.
- [ ] Согласовать canonical bootstrap, новый-project template и checker: host entry доставляет
  первый вход, root entry обеспечивает переносимость. Missing root AGENTS не блокирует глобальную ссылку.
- [ ] После точной write authority применить только показанный host diff и проверить свежую сессию.
  Сохранить backup и инструкцию отключения; не устанавливать новый runtime ради старых правил.
- [ ] Проверить известные активные roots и overlays; PanModal untracked entries требуют
  отдельного Git решения для переносимости. Не искать/патчить все зависимости и fixtures.

Приёмка: реальное чтение canonical до первой операции в existing, empty/imported-without-AGENTS
и new-worktree. Затем nested и non-Git boundary, non-iOS common baseline и outside-area non-activation.
Записать startup flow, revision, загруженный entrypoint и выбранные документы.
Нельзя подменять свежую сессию искусственным prompt, который сам напоминает о библиотеке.
Missing canonical/override проверить изолированно; incomplete не становится PASS.
Если fresh Desktop flow недоступен, сохранить конкретный короткий пользовательский сценарий.

## 2. Один выбор путей для двух способов — AV13-02/04

- [x] Сохранить существующие installer path options. Ввести минимальный data-only descriptor
  с явными runtime/knowledge/state roots и release identity; обе схемы используют один контракт.
  Предпочесть простые данные и имеющиеся функции; не создавать новый сервис конфигурации.
- [x] Manual bootstrap/shim читает выбранный descriptor и действительно запускает выбранный
  внешний payload. Все записи состояния идут в заявленный root, включая unset/mismatched env.
  Ошибочный/missing descriptor вызывает понятный отказ до записи.
- [x] Убрать зависимость generic runbook от Artem/.zenflow; пример нашего Mac — отдельный профиль.
  Не менять рабочий CODEX_HOME. Installer на чистом Mac автоматизирует ту же раскладку.
- [x] Проверить version A → version B → rollback A по фактически исполняемому runtime и
  knowledge identity; doctor version сам по себе не доказывает routing/ownership.

Приёмка: внешний payload вне Codex home работает ручным и автоматическим способом;
различаются только выбранные paths и процесс раскладки, не selected release или state ownership.

## 3. Безопасный ручной lifecycle — AV13-01

- [x] До любого mkdir/copy показать и проверить все destination paths, symlink components,
  containment, пересечение с client repos, существующие файлы и AGENTS.override precedence.
  Fresh destinations обязаны отсутствовать; неизвестный target — отказ до первой записи.
- [x] Ручной путь использует обычные операции и read-only verifier; он не запускает
  install_global.py/sync_global.py/uninstall_global.py для выполнения раскладки.
  Installer может переиспользовать тот же verifier.
- [x] Сначала подготовить неактивный payload и проверить hashes; activation выполнить последней.
  Сохранить точный список внесённых изменений и необходимые bytes/modes для отмены.
- [x] Update сохраняет старую версию до приёмки новой. Disable сначала удаляет только своё
  подключение; очистка payload/state — отдельное действие. Не удалять историю сессий.
- [x] Испытать occupied target, modified skill, symlink, ошибка на середине копирования,
  повторное подключение, update/rollback/disable в synthetic installer/preflight fixtures;
  manual operator update/disable остаётся host-пилотом. Сравнить пользовательские sentinels до/после.

Приёмка: никакой перезаписи неизвестных данных; manual update работает по runbook, без догадок.

## 4. Обновление protection runtime — AV13-03

- [x] Зафиксировать политику несовместимых активных сессий для всех поддержанных версий.
  Минимальный вариант: закрыть старым runtime до переключения; сохранить старый runtime для recovery.
- [x] Installer update и manual verifier проверяют этот prerequisite до замены активного payload.
  Не менять schema/baseline hash и не удалять writer lease ради обхода.
- [x] Проверить настоящим предыдущим V13 runtime: begin → V14 dry-run/update admission без
  collision при совместимом protection contract → close старым runtime → новый V14 begin/verify/close.
  Synthetic incompatible/corrupt/unknown-session coverage также PASS; старый закрытый history сохранён.
  Valid closed history сохраняется; corrupt/unknown state не обходится новым state root.
- [x] Дополнить уже имеющиеся failure tests проверкой всего множества managed targets,
  hashes и metadata. Не ограничиваться первым новым skill.

## 5. Полезные знания и профиль совместимости — AV13-05

- [x] Global entry явно направляет к одному shipped startup/router документу и профилю.
  Reference mode получает знания без зависимости от автоматического discovery 60 skills.
- [x] Профиль хранится отдельно от неизменяемого корпуса: enabled, exact-duplicate с source
  identity/hash/activity, candidate-overlap, conflict. На чистой системе нет внешних зависимостей.
- [x] Исключение дубля действует только при точном совпадении и подтверждённой загрузке внешнего
  источника. Missing/changed источник инвалидирует исключение; частичное пересечение не отключает
  целый раздел. Conflicts разрешаются по authority, не по автоматической похожести.
- [x] Единый route для ordinary implementation/review/cross-domain task выбирает релевантные
  документы. Review/subagents ограничены существующим бюджетом и доступностью tools;
  при недоступности — single-agent с честным статусом без simulated independent PASS.
- [x] Не делать обязательный runtime запуск единственным эффектом knowledge подключения.
  Согласовать opt-in runtime и действующие project restrictions, не расширяя разрешения.
- [x] Включить компактную capability matrix в поставку и ссылки discovery.

## 6. Одна конечная приёмка и поставка — AV13-06

- [x] Привязать report/manifest/index к конкретному artifact: historical, self-test,
  bounded Astra review и actual host adoption — отдельные факты. Убрать старые current V4/stage18.
  Не переносить 50.8 s в новый run без измерения.
- [x] В двух synthetic конфигурациях clean/existing выполнить оба способа на одном release;
  manual и installer reference smoke прошли на extracted V14, а conflict/update/rollback/disable
  покрыты shipped fixtures. Проверены пути, permissions, hashes, profile effects и dirty sentinels.
  Doctor проверяет runtime presence; глобальное чтение и routing проверяются отдельно.
- [x] После последнего source/test изменения выполнить relevant suite и validator один раз,
  сохранить настоящий exit code. Независимо просмотреть final diff против V13 и затронутые
  контракты; новые P0–P2 исправить до внедрения. Независимое ревью именно V14 ещё pending.
- [x] Собрать один candidate archive, проверить extracted contents и SHA; не называть его
  принятым release до фактической приёмки обоих способов.
- [ ] Провести короткий реальный pilot: обычная implementation, review и cross-domain задача.
  Зафиксировать полезные находки, ложные замечания, накладные расходы и неожиданные остановки.
  Старое NO_DEMONSTRATED_GAIN сохраняется; не подбирать benchmark до PASS.
- [ ] Перед local pilot уточнить происхождение материалов и условия использования.
  Internal-only не доказывает права третьих лиц; публичное распространение — отдельный gate.
- [ ] Синхронизировать task recovery в canonical repository на значимой границе с требуемыми
  permissions/checks; app commit/push не выполнять без соответствующей авторизации.

## Стоп-критерий

Продукт готов к рабочему использованию после работающего first-entry, проверенного manual/installer
lifecycle, маршрутизации знаний и короткого pilot без открытых P0–P2. Внутренняя Python tooling
приёмка не требует отдельного App Store/signing/VoiceOver проекта; такие проверки относятся к
конкретной iOS задаче. Не строить новый benchmark engine, background service или новый policy framework.
Если host action требует дополнительной authority, останавливать только зависимый шаг.
В конце сообщить оставшиеся обязательные действия явно; не говорить «осталось только разрешение»,
пока candidate corrections не завершены.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
