# Независимое повторное ревью V5.4

Дата: 2026-09-11. Модель: Astra. Режим: эконом.
Архив: iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY.zip.
SHA-256: 7013500596533af138c857d4e98471f9108ffe3c6eaae4055400e439e3f522ce.

## Вердикт

**A53-01 устранено по исходникам. В проверенном delta V5.3 → V5.4 новых P0–P2 не обнаружено.**
Версия может перейти к ограниченной независимой runtime-приёмке на macOS.
Это не глобальный production/security PASS и не разрешение установки.

Предыдущие A52 исправления сохранены: protection.py отличается только версией; common-dir writer lease и сериализация lifecycle не отменены.
Справочное использование выбранных документов без установки остаётся подходящим вариантом.

## Доказательства

- Проверены безопасные имена 1357 ZIP entries, отсутствие traversal/дублей/symlink перед извлечением.
- Прочитаны полный delta CLI и новые regression fixtures, изменения архитектурного контракта, отчёт автора и validators/version metadata.
- Независимо выполнен validate_package.py: files=1357 skills=60 sections=51 playbooks=288 errors=0.
- Автор сообщает 134 PASS / 0 FAIL / 0 SKIP на Linux/Python 3.13.5, 19.81 секунды. Здесь этот набор НЕ запускался.
- Поведенческие утверждения ниже основаны на исходниках и прочитанных fixtures, не на независимом end-to-end upgrade.
- Установка, sync/uninstall, реальные session transitions, Xcode/Swift/Simulator/device/signing не запускались.
- Изменены только артефакты ревью: извлечённая копия для чтения и этот отчёт. Исходники, тесты и глобальные инструкции не менялись.
- Область: исправление A53-01 и связанные изменения, а не новый построчный аудит всех файлов библиотеки.

## Почему A53-01 закрывается на статическом уровне

| Требование | Реализация / evidence |
|---|---|
| Завершённая schema-2 history не блокирует новый writer | [GLOBAL_CODEX/runtime/bin/ios_ai.py:132](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v54-s40wNd/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py:132): compatibility reader принимает schema=2 только при lifecycle=closed. |
| Identity/integrity не пропускаются только из-за closed | Проверяются обязательные поля, UUID, типы payload, baseline hash, worktree identity; load/list сверяют UUID с именем файла. |
| Старое evidence не становится текущим PASS | [GLOBAL_CODEX/runtime/bin/ios_ai.py:149](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v54-s40wNd/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py:149): historical_evidence_only; [GLOBAL_CODEX/runtime/bin/ios_ai.py:456](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v54-s40wNd/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py:456): status ARCHIVAL_CLOSED с verification=null. |
| История остаётся доступной | Summary включает archival audit; compatibility reader создаёт копию объекта в памяти, не переписывая исторический JSON. |
| Незавершённые старые sessions не обходят gate | Schema-2 active/verified отвергаются; scanner перед begin проверяет старое состояние, относящееся к shared common-dir, включая linked worktrees. |
| Добавлены регрессии | Семь новых fixtures: closed admission, archival audit, explicit status, active/verified rejection, corrupt/foreign/unknown rejection, повторяемость/байтовая сохранность, linked-worktree legacy state. |

Fixture write_v52_session формирует schema-2 запись с помощью текущего capture, а не запускает настоящий V5.2 producer. Это полезная проверка формы, но не полное cross-version evidence. На macOS следует дополнительно получить состояние именно V5.2 runtime и открыть его V5.4 с тем же state-root.

## Неблокирующие замечания и ограничения пилота

### P3 — недостижимая ветка накопления legacy blockers

[GLOBAL_CODEX/runtime/bin/ios_ai.py:237](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v54-s40wNd/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py:237) вызывает reader, который сразу бросает исключение для schema-2 active/verified. Поэтому следующий append в blockers для этих lifecycle не исполняется; отказ происходит раньше, и безопасность не ослаблена.
Стоит упростить контракт scanner: либо он fail-closed через исключение, либо собирает структурированные blockers отдельным валидатором. Сейчас два механизма создают лишнее впечатление, что callers получают список активных старых sessions.

### Объём исторического registry и область отказа

Новый scanner перечисляет session state всех репозиториев в данном state-root перед фильтрацией по common-dir. В нём нет общего лимита числа записей/байтов/времени; ошибка чтения некоторых чужих записей может остановить admission ещё до определения принадлежности.
Это остаточный эксплуатационный риск для большого общего state-root, не измеренный здесь. Пилот ограничить небольшим disposable registry и отдельно проверить рост истории/повреждённые записи. Нельзя исправлять это безусловным игнорированием ошибок: unresolved linked writer должен по-прежнему блокировать admission.

Само сужение до одного writer на common-dir остаётся важным ограничением для нашего процесса: linked worktrees не обеспечивают параллельные writer sessions этой библиотеки. Независимые clones/repos — отдельная топология.

## Следующая приёмка: отдельное разрешение, без глобальной установки

1. Запустить полный shipped Python suite в disposable окружении на macOS; все временные каталоги/state/cache направить внутрь /Users/Artem/.zenflow.
2. Проверить настоящую цепочку V5.2 begin/verify/close → V5.4 begin на том же state-root, включая linked worktree; hash исторических JSON до/после.
3. Проверить прежние process-group и lifecycle interleavings на macOS; отличать живого потомка от platform-specific процесса завершения/reaping.
4. Проверить synthetic install/update/uninstall/rollback только с выделенным тестовым Codex home, не настоящими глобальными настройками.
5. Записать exit codes, skips, платформу, Python/Git versions и SHA этого архива. Пропуски не считать PASS.
6. По результату выбрать bounded pilot; пока не включать gate глобально и не дублировать нашу canonical policy.

Текущий запрос — ревью новой версии. Он не использован как разрешение на эти runtime/installation действия.

## Итог для автора

Новый обязательный цикл переписывания библиотеки сейчас не требуется по результатам этого ограниченного статического ревью. P3 можно устранить небольшим упрощением; проверку масштабирования registry включить в дальнейшее укрепление.
Следующий источник полезных доказательств — независимая macOS-приёмка, а не увеличение числа документов или самодекларируемых закрытых замечаний.

## Receipt

Scope completed: bounded static re-review A53-01 и delta V5.4.
Rules: ранее загруженный canonical bootstrap/Level 0, review preflight, evidence/definition-of-done, completion contract; ios-evidence-gate повторно прочитан.
Docs route: common tooling review + evidence. Domain-wide iOS knowledge audit намеренно не повторялся.
Durable docs: не менялись. Local exceptions: не создавались.
Build/tests: структурная проверка выполнена, runtime suite не выполнен по текущим ограничениям.
Context health: контекст обновлять не нужно для завершения этого ревью.
Model result: Astra, без subagents.
Передача: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
