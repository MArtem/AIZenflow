# Текущий план — первый рабочий knowledge-профиль

Дата: 2026-09-13. Task: new-task-be0b. Review/planning: GPT-6 Astra.
Режим: эконом. Статус: V4 проверен адресно; есть обязательные исправления.
Текущая просьба пользователя: оценка и исполнимый план, без внедрения в этом turn.
Этот документ заменяет последовательность дальнейших действий из
library-adoption-corrective-luna-xhigh.md; предыдущий подробный план сохранён как история.

## Решение о продукте

Первый выпуск — автоматически выбираемые дополнительные iOS-проверки через существующий
canonical bootstrap/router. Пользователь не перечисляет документы при каждой задаче.
Три стартовые темы: cancellation/task lifetime, SwiftUI ownership/identity, auth/retry/logout.
Глубокие исходные материалы доступны по необходимости, а не загружаются все одновременно.

Это не daemon, Git hook, Swift dependency, глобальный набор 60 skills или обязательная
protection session. Существующие разрешения и engineering gates продолжают действовать.
Польза — конкретные проверки и найденные/предотвращённые ошибки в реальных задачах.
Гарантированный прирост на каждом запросе и нулевой риск не являются критериями выпуска.

## Проверенные факты V4

Корень W: /Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54.
Candidate C: W/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY.
V4 ZIP: W/dist/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY_LUNA_XHIGH_CORRECTIVE_CANDIDATE_V4.zip.
SHA-256: ca72d11a5f3d376ddda726504406ebb3e52bd00243b2c41cc4e960810cb39b5b.
Canonical base: cb8ffedf7e5c032478e36fa8f2f1e751952ad76b; checkout clean при ревью.

- В этом ревью SHA архива подтверждён, ZIP совпадает с C по bytes каждого файла;
  PACKAGE_FILE_MANIFEST.json не имеет расхождений.
- 143/143 и extracted validator — предыдущие фактически наблюдавшиеся результаты;
  полный suite сейчас не повторялся. Они не доказывают полноту покрытия.
- Разделение post-publication cleanup и rollback, deadline после validation и private
  identity fixture являются реальными адресными улучшениями.
- Existing route rehearsal доказывает разрешение явно переданного route ID,
  checks/disable в disposable consumer; автоматический выбор по обычной задаче не доказан.
- L2 обнаруживает возможную пользу, но сохранённые JSON являются редактированными сводками
  исходных ответов. Нельзя называть их raw/sealed outputs или независимой строгой приёмкой.
- A получал общий ENGINEERING_CHANGE_QUALITY_STANDARD, а не доказанно полный релевантный
  canonical iOS route. Все семь документов B загружались даже для одной узкой темы.
- 236.8–244.0% — bytes выбранных файлов относительно экспериментального A-input.
  Это не измеренные tokens, стоимость, wall time или overhead полной реальной задачи.
  Старый frozen gate не переписывать в PASS. Его отрицательный результат сохранить,
  но не переносить на все способы автоматического применения библиотеки.

## Findings Astra

| ID | Приоритет / граница | Подтверждение | Требуемый результат |
|---|---|---|---|
| V4-A1 | P1 installer, не knowledge | reference → full; сбой записи registry после размещения skills. Registry restored=true, registry_skill_count=0, actual_ioslib_skill_count=60. Rollback в C/sync_global.py:295 обходит только backups; новые targets без backup не откатываются. CLI может сообщить none_or_rolled_back при оставшихся skills. | Запретить приёмку/install/full; до его отдельного использования устранить partial installation и ложный rollback status. |
| V4-A2 | P2 evidence | results/*.json переписаны при сохранении; T1 выбраны из повторных запусков без заранее закреплённого выбора; elapsed estimates менялись/не измерены. Stage 20 составлен исполнителем после исправлений, повторный независимый review исправленного diff не показан. | Честно обозначить provenance/ограничения; не приписывать исполнителю независимую окончательную приёмку. |
| V4-A3 | P2 integration | canonical-route.patch добавляет явно выбираемый ID со всеми 7 docs; обычный task → route activation не реализован. PROFILE import source ../proposed-integration/PROFILE.md относительно source_root не существует. | Определить и проверить настоящий task → relevant checks путь; исправить source-root mapping и применимость полного пакета. |
| V4-A4 | P3 maintenance | plan.md ранее говорил «реализация не начата» при handoff «S0–S7 завершены»; patch содержит две строки shell/RVM stderr. | Один актуальный статус, чистый patch, отсутствие claims шире evidence. |

Диагностический fixture V4-A1:
W/candidate/test-tmp/tmp0gc0fksl.
В нём сохранены только synthetic home/skills; real global home, app source, refs не менялись.
Обычный OSError был получен при искусственном сбое registry; старый registry остался с 0 skills,
на диске осталось 60 ioslib-* directories. Это новый непокрытый сценарий, а не опровержение
того, что исправление исходного late-cleanup случая работает.

## K1. Исправить приёмочные выводы один раз

- [ ] В одном изменении согласовать stage 18/19/20, L2 RESULTS и актуальные candidate claims.
  Отдельно: synthetic tests PASS; independent findings received; implementer fixes;
  final independent re-review pending; integration pending.
- [ ] Сохранённые результаты пометить как normalized summaries. Восстановить raw outputs
  из доступной истории verbatim с agent ID и provenance, только если это доступно без
  домыслов; отсутствующие данные оставить UNKNOWN. Не восстанавливать «сырые» ответы
  обратным пересказом JSON и не проводить новые запуски только ради ремонта истории.
- [ ] Сохранить исторический NO_DEMONSTRATED_GAIN и его overhead gate; пометить ограничения
  дизайна сравнения. Не говорить «библиотека бесполезна» и не говорить «польза доказана».
- [ ] Installer/runtime в accepted profile исключены. V4-A1 остаётся явным открытым дефектом;
  никакого whole-library PASS или одобрения полного V4 install.
- [ ] Зафиксировать, что настоящий запрос на global home/install/hooks/network не следует
  из внедрения знаний; exact consumer activation требует соответствующего решения.

Готово: будущий исполнитель/владелец видит одинаковый статус, не делает install из green suite.

## K2. Сформировать компактный автоматический профиль

- [ ] Сопоставить полезные проверки с уже существующими canonical standards/references.
  Переносить только недостающие проверки; одинаковый материал не дублировать ради библиотеки.
- [ ] Подготовить тематическое подключение через существующий router:
  concurrency → task ownership, cancellation, stale success/error;
  SwiftUI → stable owner/model identity, task key, invalidation;
  auth/network → session generation, single-flight, logout, permitted replay.
- [ ] Обычная задача выбирает одну тему; пересекающаяся — необходимые темы. Не загружать
  все семь длинных файлов по умолчанию. Сначала компактные checks; deep reference — по
  конкретной неоднозначности/риску. Целевой компактный слой до 600 слов на тему,
  до 1200 при двух темах; это предел новой конфигурации, не пересмотр старого gate.
- [ ] Иметь один явный opt-in на проект для пилота и одно выключение; далее пользователь
  не должен вводить route ID в каждом запросе. Записать краткую task→route связь в реально
  читаемом existing router/skill entrypoint; не создавать второй диспетчер.
- [ ] Подготовить exact source/mirror mapping, корректный PROFILE source root, чистый patch,
  version/pin и attribution. Проверить каждую source path + SHA до promotion.
- [ ] Выбрать минимальную проверку целостности, нужную для контролируемого advisory snapshot.
  Не расширять общий resolver в filesystem security sandbox. Три повторных хеширования
  не дают immutable consumer read; сохранить честный claim и не усложнять ради этого.
  Если resolver всё же меняется, проверить обычные routes/overlays/fallback совместно.
- [ ] Unknown/non-iOS/disabled задачи не активируют профиль. Missing/changed optional payload
  явно отключает только его advice; mandatory project quality gates не становятся PASS.

Готово: проверяемый task-local changeset автоматически подбирает релевантные checks;
нет full-corpus default, дополнительных полномочий или зависимости от installer.

## K3. Одна ограниченная приёмка пути использования

- [ ] Использовать существующий disposable consumer/harness и исправить только нужные сценарии.
  Проверить три обычных запроса без упоминания route ID, выбор relevant docs, non-iOS,
  unknown/missing/altered inputs, запрет тестов, dirty state и выключение.
- [ ] Разделить deterministic resolver result и фактическое следование агента маршруту.
  Команда resolver с явно переданным ID не заменяет agent-entrypoint acceptance.
- [ ] Зафиксировать inputs/selected docs/bytes (tokens если доступны), actual start/end для
  elapsed time, useful findings и false positives. Не использовать оценку времени модели
  как замер.
- [ ] Один адресный review окончательного K2 diff на конфликты authority, правильность
  checks, side effects и fallback. Это можно выполнить текущей Astra; не требуется
  обязательный каскад нескольких моделей.
- [ ] Для сравнения качества брать полноценный соответствующий canonical baseline.
  Не искать новую обязательную ошибку на каждом примере и не подбирать примеры до PASS.
  Если нужна отдельная blind оценка, один bounded прогон по заранее заданным inputs;
  её raw outputs неизменны, key открыт evaluator только после закрытия обеих arms.
- [ ] Успех технической приёмки: routing/disable работает, нет новых полномочий/side effects,
  компактный context budget выдержан, нет известных P0–P2 в принятом knowledge scope.
  Утверждение об универсальном приросте качества по нескольким примерам не делать.

Готово: подготовлен конкретный пакет для однократного owner approval на активацию.
Не начинать второй benchmark framework, orchestration system или полный аудит 60 skills.

## K4. Внедрение и реальная польза

- [ ] До внешних изменений назвать exact canonical diff/paths, первый проект и отключение.
  Кандидат на первый consumer — текущий repository
  /Users/Artem/.zenflow/worktrees/new-task-be0b; перед активацией сверить его актуальный
  профиль/overlay и выбранные пользователем реальные задачи. Не придумывать продуктовые правки.
- [ ] Проверить standing-authority: canonical bounded commit/push в документационной
  библиотеке уже предусмотрены reusable rules; новое решение нужно на применение нового
  профиля и затронутые реальные consumers, а не повторно на каждую локальную проверку.
  Global runtime/full installer в это решение не входят.
- [ ] При разрешённой активации применить reviewed canonical knowledge change, проверить
  index/mirror/route consistency, commit и remote SHA по существующему quality contract.
- [ ] На одном выбранном проекте сопровождать три настоящие задачи:
  read-only review; обычное исправление; работа с имеющимся dirty state/важной границей.
  Брать реальные потребности, не внедрять искусственные баги ради демонстрации.
  Source edits/build/tests — по действующей авторизации самой задачи.
- [ ] Для каждой сохранить коротко: что выбрано автоматически; какая рекомендация добавилась
  к текущим правилам; её code anchor и практическая ценность; false positives; overhead;
  были ли ненужные остановки. Если baseline уже всё покрывает, честно отметить дублирование.
- [ ] Проверить выключение и восстановление прежнего процесса. Определить сопровождение:
  владелец — существующий docs owner; pin меняется вручную, новый review только на delta.
- [ ] После трёх задач принять один результат: рабочий профиль для этого проекта / одна
  конкретная корректировка / reference-only для неокупившейся темы. Не начинать ещё цикл
  без реальной ошибки или нового требования.
- [ ] Расширять принятый профиль на явно согласованные iOS projects через existing bootstrap.
  Неподключённые проекты и непроверенные домены не включать в coverage.

Критерий продукта: профиль фактически используется автоматически на выбранном проекте,
полезные рекомендации подтверждены на его коде, baseline не ухудшен, выключение проверено.
Если реальных задач сейчас нет — readiness for pilot, а не consumer acceptance.

## I1. Отдельно: условие будущей приёмки installer

Не является зависимостью K1–K4, поскольку knowledge-профиль не вызывает installer.
Этот P1 нельзя скрывать, объявлять исправленным или разрешать full install до устранения.

- [ ] Учёт всех успешно опубликованных targets, включая новые без backup; обратный rollback
  только для owned unchanged incoming content, сохранение concurrent user changes.
- [ ] При реальных leftovers возвращать rollback_incomplete, а не none_or_rolled_back.
- [ ] Узкие fixtures: reference→full + metadata failure; later new-target failure;
  modified new target preserved. Проверить registry↔on-disk target set, не только existence
  трёх metadata files.
- [ ] Проверить existing late-cleanup fix без повторной регрессии; один full suite после
  final code change и один независимый review installer delta перед принятием installer.

## Ограничение работы и полномочия

Сейчас выполнены review и обновление task-плана; candidate/канонические правила не исправлялись.
Разрешённые локальные candidate/fixture работы из прошлой команды не требуют повторного grant
при возобновлении исполнения. Реальные activation/consumer decisions проверяются отдельно.
Не публиковать исходный корпус под выдуманной лицензией; internal-only не заменяет provenance.
Для private local review не нужен новый license-сервис; перед распространением проверить
действительные права/attribution, при недостающих данных сохранить ограничение на публикацию.

Один проход K1–K3, затем конкретное решение о K4. I1 — отдельный blocker соответствующего
компонента, не повод откладывать работающий knowledge-продукт и расширять framework.

## Checklist текущего review turn

- [x] Проверить V4 identities, ключевые fixes, claims и предложения.
- [x] Подтвердить V4-A1 одним synthetic failure scenario.
- [x] Разобрать ограничения A/B без переписывания исторического gate.
- [x] Подготовить ограниченный план исправлений, приёмки и внедрения.
- [ ] Реализовать K1–K3.
- [ ] Выполнить approved K4 и закрыть consumer acceptance.
- [ ] I1: принять installer отдельным решением после исправления P1.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
