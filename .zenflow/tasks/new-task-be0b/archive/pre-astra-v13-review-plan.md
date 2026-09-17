# План исполнения Luna xhigh — подключение знаний и внедрение библиотеки

Дата: 2026-09-14. Task: new-task-be0b. Автор плана: Astra.
Режим: эконом. Luna xhigh — исполнитель по выбору пользователя; Astra — проверка
архитектурных отклонений и окончательного исправления операций установки.
Этот план заменяет редакцию 2026-09-13; её содержательные ограничения сохранены ниже.

## Цель

Сначала обеспечить автоматический общий вход в СУЩЕСТВУЮЩИЕ знания для текущих и
новых проектов под /Users/Artem/.zenflow. Затем внедрить полную самостоятельную iOS
engineering library двумя способами: ручная раскладка/подключение и installer,
автоматизирующий ту же спецификацию. Новая библиотека не зависит от нашей canonical
библиотеки; на существующем Mac совместимость задаётся отдельным локальным профилем.

Весь корпус доступен; обязательные общие правила читаются при старте, тематические
материалы выбираются по задаче. Нельзя загружать все документы/запускать всех subagents
на каждой задаче или считать наличие файлов доказательством использования.
Нулевой риск и гарантированный универсальный прирост качества не обещаются.

## Подтверждённое состояние

- Canonical bootstrap доступен; canonical HEAD:
  cb8ffedf7e5c032478e36fa8f2f1e751952ad76b.
- Предыдущая проверка нашла 16 Git-корней первого уровня и 15 bootstrap entries.
  PanModal получил два новых файла, но 2026-09-14 они всё ещё untracked.
  Полный inventory nested/non-Git/active consumers НЕ завершён.
- Родительский .zenflow/AGENTS.md существует. Effective host entrypoint и свежие
  Desktop open/create/import sessions не проверены. Универсальное подключение НЕ принято.
- Candidate C:
  /Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY
- Финальный task-local corrective candidate V13: version `5.4-review-ready.5`.
  Archive SHA-256:
  `30ae363ea5441013937d3bc657fb91c1a086fe4ab3869b9692bd4051531516d8`;
  package/extracted validator: `1360 files, 60 skills, 51 sections, 288 playbooks`;
  source/extracted suite: `156/156 PASS`. V11/V12 остаются историческими и не являются
  delivery artifact; V13 — последний архив до независимой re-review.
- Исторические V11 findings: post-rename journal gap, installer-only portable wording и
  overstrong independent-review wording. Они исправлены/уточнены в V13 и остаются в evidence
  как historical input, а не как открытые дефекты V13.
- Старый proposed-integration имеет неверный относительный PROFILE path и shell stderr
  в patch; не применять его. Frozen NO_DEMONSTRATED_GAIN сохранить как исторический результат.

## Общие ограничения исполнения

Начать с актуального bootstrap, Level 0 и выбранных task routes. Следовать существующей
авторизации candidate/fixture/test работ; app builds/tests/Simulator отдельно не разрешены.
Сохранять пользовательские изменения. Не активировать новый runtime при ремонте старых правил.
Не менять CODEX_HOME рабочего Mac, sandbox, approvals, trust, auth, модель или launch settings.
Не устанавливать hooks/daemon/watchers, не делать auto-download/update.
Ручной способ не должен требовать install_global.py, sync_global.py или uninstall_global.py.
Installer не получает дополнительных полномочий по сравнению с ручным способом.
Commit/push app repositories только по действующей точной авторизации; canonical docs —
по standing authority и engineering gate. Не считать untracked adoption переносимым исправлением.

Внешние host-файлы требуют отдельной точной authority по действующим ограничениям пользователя.
Подготовить внутри task готовый проект изменения и список необходимых файлов до вопроса.
Запросить только реально недостающую authority; не повторять разрешённые действия.
Не читать auth.json, history/sessions, credentials или весь home.
При реальном блокере host-этапа можно готовить независимые candidate-исправления ниже,
но нельзя закрывать автоподключение формальным PASS или выдавать wrapper за покрытие Desktop.

## 1. ПЕРВЫЙ ПРИОРИТЕТ — исправить вход в текущую библиотеку

- [ ] Уточнить inventory реальных active consumers: existing/new/imported/worktree,
  nested и non-Git. Archives/fixtures/dependencies не считать проектами для массовой записи.
- [ ] Проверить реальные способы старта Codex; определить effective global instruction file
  и возможный AGENTS.override.md. При необходимости запросить точное чтение
  /Users/Artem/.codex/AGENTS.md и /Users/Artem/.codex/AGENTS.override.md;
  config.toml читать адресно только если это требуется для выяснения discovery.
- [ ] Подготовить короткий entrypoint в уже используемом Codex home:
  для проектов внутри /Users/Artem/.zenflow до первой проектной операции прочитать
  текущий canonical GLOBAL_RULES_BOOTSTRAP.md; для остальных проектов не применять
  scoped baseline. Сохранить существующий текст и учитывать приоритет override.
  Не заменять builtin instructions и не менять CODEX_HOME.
- [ ] После точного preview/authority применить запись; проверить, что она не требует
  уже существующего repo AGENTS для своего обнаружения.
- [ ] Довести root adoption существующих consumers малыми партиями: корректные ссылки,
  fallback, nested conflicts. Проверить PanModal и получить недостающую commit authority
  для переносимого исправления. Не менять app source или Git refs без разрешения.
- [ ] Согласовать canonical bootstrap, шаблон нового проекта и checker:
  global entrypoint обеспечивает первый вход, root entry обеспечивает переносимость.
  Отсутствующий root файл не должен мешать загрузке глобальных знаний.

Готово: общий вход доставляется до первого действия; источник истины один, клиентский
код сохранён, механизм не зависит от новой standalone библиотеки.

## 2. ПЕРВЫЙ ПРИОРИТЕТ — доказать использование текущих знаний

- [ ] Свежие Codex sessions с обычной задачей без слов о библиотеке:
  существующий проект, новый пустой Git root, imported root без AGENTS, новый worktree,
  nested cwd, non-Git и non-iOS проект.
- [ ] Проверить missing canonical и конфликтующий override в fixtures:
  fallback/явный неполный статус, отсутствие ложного current-canonical PASS.
- [ ] Для каждой проверки записать: startup flow, root, реально загруженный entrypoint,
  canonical revision, выбранные тематические документы и как они повлияли на действие.
  Разделять file-present / instruction-loaded / route-used / checks-executed.
- [ ] Подтвердить доступность всех заявленных тематических маршрутов статически;
  поведенческие сценарии выбрать по риску. Не выдавать несколько примеров за испытание
  каждого знания. Проверять маршрутизацию релевантных знаний, не чтение всего корпуса.
- [ ] Сохранить компактный отчёт покрытия и отдельно перечислить неподдержанные flows.
  Старые сессии с уже загруженными инструкциями не считать свежей проверкой.
- [ ] Объявить исправление завершённым лишь после actual first-entry evidence.
  Обычный Desktop/open/import flow с неполученными правилами блокирует этот этап.

## 3. Зафиксировать единый продукт и два способа подключения

- [x] Сохранить полный корпус; составить компактную capability matrix:
  функция/тема → вход → prerequisites/permissions → проверка → статус.
  Включить skills, review, subagents, validators, runtime и installation lifecycle.
  Матрица сохранена в `library-adoption-v54/evidence/23-capability-matrix.md` и не скрывает
  pending/синтетические статусы.
- [x] Определить одну раскладку: versioned payload, отдельные profile/ownership/state,
  минимальные host entrypoints. Пути задаются профилем; пользовательские абсолютные
  пути и наша canonical библиотека не являются зависимостью поставки. Зафиксировано в
  `GLOBAL_MANIFEST.json`, `GLOBAL_ARCHITECTURE.md` и manual deployment contract.
- [x] Ручной runbook описывает реальные операции раскладки/регистрации, проверку и
  отключение без запуска installer. Installer выполняет те же операции.
  `MANUAL_DEPLOYMENT.md` и relocatable `MANUAL_SHIM` не запускают installer; `--portable-area`
  оставлен только явным installer-rehearsal профилем и не выдан за основное внедрение.
- [ ] Существующий Mac: corpus неизменен, решения о дублях — внутри отдельного профиля.
  Автоисключение лишь при точном совпадении и подтверждённом активном внешнем источнике.
  Semantic overlap — кандидат для проверки; partial overlap не выключает весь раздел.
  Конфликт не считать дублем; изменившийся hash/недоступность инвалидирует решение.
- [ ] Обычный запрос выбирает маршрут; review/subagents имеют единые triggers и лимиты.
  Недоступная функция имеет статус unavailable, не simulated PASS.
- [ ] Уточнить происхождение/права на распространение материалов; license не выдумывать.
  Подготовить все остальные результаты до запроса реально отсутствующих данных.

Готово: зафиксирована точная спецификация manual/installer parity, без новой платформы
и без обязательной миграции Codex окружения.

## 4. Один corrective patch установки и доказательств

- [x] Исправить журналирование операций с возможным исключением после публикации.
  Рассмотреть rename/fsync, backup publication, metadata publication и позднее удаление.
  Journal теперь позволяет установить фактическое состояние после частичного успеха.
- [x] Проверить ту же границу у fresh install, sync и uninstall:
  не сообщать none_or_rolled_back, если остались targets или потерян backup.
  Не удалять/перезаписывать concurrent user changes.
- [x] Узкие fixtures: ошибка до/после rename; metadata failure; later-target failure;
  concurrent edit; late backup cleanup; повторный запуск; symlink/escape; disable.
  Сравнивать полное множество targets и registry, а не один skill/три metadata файла.
- [x] Убедиться, что расположение, ownership, source identity, containment и профиль
  сохраняются при install/update/disable для обоих способов.
- [x] Исправить provenance/status отчёта: self-test, independent review и historical
  evidence различаются; не называть summaries raw outputs.
  V13 report прямо оставляет independent review/provenance/adoption открытыми.
- [x] Старые proposed-integration артефакты исправить, если они используются новым
  контрактом, иначе явно вывести из активного пути. Убрать shell stderr/неверные ссылки.
  Старый patch не используется; active path — manual runbook/installer contract.
- [ ] Review полного окончательного diff на Astra до принятия installer;
  Luna не объявляет собственную повторную проверку независимой.

Готово: все подтверждённые P0–P2 закрыты в проверяемом scope, остаточные ограничения
описаны без обещания защиты всего Mac.

## 5. Конечная приёмка обоих способов

- [ ] Две synthetic конфигурации: clean без наших правил и existing с дублями/конфликтами.
- [ ] Manual и installer размещают один release; сравнить effective entrypoints, IDs/hashes,
  профиль совместимости, права, маршруты и disable/update semantics.
  Нормализовать только различающиеся пути, не фактические результаты.
- [ ] Проверить обычный review, implementation task и межтематическую задачу;
  missing payload, read-only/dirty project, запрещённые tests/network/subagents.
- [ ] Проверить свежую сессию после отключения. Ранее прочитанные инструкции не стираются
  из уже существующего контекста; это не дефект удаления.
- [x] После последнего source/test изменения выполнить один relevant full suite.
  Не повторять PASS без изменённых входов или нового риска.
- [ ] Один короткий pilot на реальных задачах после готовности подключения:
  найденные полезные дефекты, ложные замечания, затраты контекста, лишние остановки.
  Не вводить новый benchmark framework и не подбирать выборку до PASS.

## 6. Поставка и внедрение

- [x] Собрать task-local corrective archive до финальной независимой приёмки; проверить
  извлечённое содержимое и SHA. Это candidate artifact, не утверждение release acceptance.
  Не создавать ZIP после каждой мелкой правки.
- [ ] Показать точные paths/diff подключения; применить ручной путь в выбранной области
  после действующей authority. Сохранить текущую canonical библиотеку.
- [ ] Подтвердить работу в существующем и первом новом/imported проекте.
- [x] Передать manual runbook, installer commands, update/disable и список ограничений.
  Составлено в candidate `MANUAL_DEPLOYMENT.md`, `README.md`, `QUICKSTART.md` и installer docs.
- [ ] Синхронизировать canonical/task recovery документы на значимой границе по governance.
- [ ] Итог: что реально подключено, какие flows покрыты, что использовано на практике,
  какие функции недоступны, какой release принят. Не подменять обе приёмки portable-only.

## Правило работы Luna

Идти по этапам; не расширять архитектуру из-за смежной идеи. Не выдавать разрешение на
чтение host-файлов за разрешение на запись или установку runtime. Не останавливаться
для повторного одобрения уже разрешённых candidate/fixture работ. Если требуется новое
архитектурное решение, показать конкретный дефект и ограниченный вариант решения.
План остаётся незавершённым, пока пункты 1–2 не доказаны.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
