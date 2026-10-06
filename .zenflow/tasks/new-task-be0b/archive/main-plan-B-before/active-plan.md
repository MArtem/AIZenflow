# План — система работы над iOS-проектами

## Implementation block — 2026-10-03

Текущий запрос разрешает реализацию по S0–S12 небольшими блоками; прежняя
строка ожидания implementation scope ниже относится к запросу на план.
Модель: GPT-6.1 Sol, reasoning high; режим: эконом на время этой задачи.
Scoped user override действует до нового выбора; глобальная routing matrix не меняется.

- [x] S0: подготовить контракт R01–R18, authority/MVP/release boundaries.
- [x] S1: обследовать существующие KB/library/QC механизмы read-only;
  выбрать документальный workflow без нового verifier/helpers.
- [x] S2: опубликовать identity/permission contract и отдельный docs route.
- [x] S3: опубликовать memory skeleton/freshness и проверить metadata/links.
- [x] Canonical quality gates → complete diff → exact-HEAD receipt → push
  `d9ded311cda06d69f59079e380296b2ec7c59d50`.
- [x] S4 intake: пользователь разрешил выбор агента; выбран BattleshipGame
  в активном worktree, выполнен scoped read-only intake; status ON/AUTO наблюдён.
- [x] Registry compatibility, S4–S7 memory/ledger/packet опубликованы;
  canonical main `bd41f0874f7373d0b59c50c599a2990732817d13`.
- [x] S4 apply: пользователь разрешил три файла; before/after hashes, post-check
  и read-only detach проверены; ON/AUTO сохранён.
- [x] S5–S7: статическая карта, ledger и подготовленный BG-T01 packet.
- [x] User разрешил code edits без повторного запроса и выбрал BG-T01 A.
- [x] BG-T01: один source patch, static review и fresh memory;
  canonical publication `e89bd05ab6905a37200aa26f53124b1f8dce255f`.
- [x] BG-T01: одна initial сборка failed в sandbox; одна отдельно разрешённая
  escalated repeat сборка той же версии exit0, Xcode27.0/27A266a.
- [x] Build-memory canonical publication cb617326fd06cad4408d4ef576c32d0d6483357e, remote verified.
- [ ] User-owned interaction/VoiceOver acceptance; BG-A01 остаётся OPEN.
- [x] R19/R20/R21: proportional task cycle, bounded pilots and pre-implementation
  test/feature verification menu with explicit user selection added.
- [ ] Observed acceptance нового цикла/общих gaps перед расширенным pilot.
- [x] S8 documentary action planner и workflow stages подготовлены.
- [ ] S8 execution/fault acceptance и S9–S12 после product/source/verification решений.

S0/S1: `ios-project-work-system-s0-s1.md` (canonical task recovery).
Подготовленные reusable документы находятся рядом в task staging до canonical
публикации. Это не app adoption, end-to-end verification или общий release.
LIB-004 остаётся P2/OPEN. Два точных build-разрешения использованы; дальнейшие builds,
tests/test changes, Simulator/UI агента, agents/MCP, host/secrets и client Git не разрешены.
User делегировал выбор/использование/owned регистрацию пилотов; Tchop proposal
отложен до общей основы, authority не блокирует. S11 acceptance pending.
Pre-existing task-правки сохранены.

## Новый запрос: полный план системы

- [x] Сохранить требования и подготовить этапы S0–S12 с выходами и gates.
- [x] Отделить планирование от внедрения и прежнего limited-pilot verdict.
- [ ] Получить решение о начальном implementation scope; этапы не начинались.

Полный канонический план:
`/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b/ios-project-work-system-plan.md`.
Никаких новых подключений, host changes, builds/tests или client Git действий
этот запрос на план не разрешает. Ниже сохранён итог предыдущего этапа.

Актуализирован 2026-10-02. Task: `new-task-be0b`.
Checkout: `/Users/Artem/.zenflow/worktrees/knowledge-base-next`.
Модель: GPT-6 Sol; режим: эконом. Документационный итог и доказательства:
`/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b/ios-library-pilot-2026-09-30.md`.
Подробные первоначальные критерии: `knowledge-base-library-roadmap.md`;
это не очередь на повтор уже завершённых экспериментов.

## Решение пользователя и текущий результат

2026-10-02 пользователь выбрал рациональное завершение текущего этапа:
сохранить ограниченный пилот IOS Library, не расширять корпус или искусственные
сравнения ради положительного результата. Общий rollout не разрешён.
LIB-004 остаётся P2/OPEN для общего выпуска: устойчивое улучшение качества и
экономия токенов не доказаны. Это не waiver и не изменение исходных критериев.

- [x] A: риск-ориентированный аудит базы знаний и исправления — завершён
  READY_WITH_LIMITATIONS в документальном scope, не сертификат iOS-кода.
- [x] Публикация: точный пилот и прежние task-документы находятся в AIZenflow
  main/development; SHA `b7c48e163d9108d1cc4b123d93456ce8f7628d93`
  повторно подтверждён по remote 2026-10-02.
- [x] B: LIB-001/002/003 имеют scoped closure для точного copy-only пилота.
  Полезные источники учтены; установки и Codex runtime не являются payload.
- [x] C: V1–V3 сопоставлены, V4 implementation/resource trace завершён;
  дополнительных подтверждённых дефектов PLUS и измеренной экономии нет.
- [x] Ghibli: узкая коррекция Favorites сохранена; три новых модельных теста
  прошли на iPhone 18 Pro Simulator/iOS 27.0. UI/device/durability не доказаны.
- [x] Согласовать компактные plan/handoff и текущий verdict roadmap.
- [x] Удалить только проверенные disposable DerivedData/cache/tmp нашего запуска.
- [x] Подготовить итоговый canonical receipt и recovery task-правки.
Факт публикации подтверждается отдельным exact-HEAD/remote receipt, не этой галочкой.

## После завершения текущего этапа

LIB-004, общий release gate и полный rollout не закрывать галочками.
Польза/пропуски второго слоя могут фиксироваться только при следующей
действительно новой разрешённой задаче; это не фоновый мониторинг, не новая
автоматизация и не разрешение на новые действия. Повтор известных случаев
не планировать. Новые активации, агенты, builds/tests и client Git требуют
своего scope и разрешений.

BattleshipGame: последний наблюдённый статус ON/AUTO; сейчас status не повторялся.
Точный pin: `3c42e490e82866eee0f303d6340452dbf9fff5eb`, 34 файла;
aggregate: `526c7b0238fd66572ef260813891562ccadcc7329a26fc25b096ac16574f641e`.
Пилот не активирует библиотеку в других проектах.

Ghibli origin — авторский репозиторий, пуш не разрешён. Полезные source/test
правки остаются локально и сохранены двумя canonical recovery patches.
Чужой FilmsScreen не менять. Не создавать ненужную тестовую ветку.

Прежние детали доступны в Git history и canonical receipt.
**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
