# Независимое повторное ревью V5.3

Дата: 2026-09-11. Модель: Astra. Режим: эконом.
Архив: iOS_Engineering_AI_Library_2026_V5_3_GLOBAL_CODEX_REVIEW_READY.zip.
SHA-256: 6d02d35f7cdcc1566250ba0960619b2e681e7a967ce9dea3eae0e3a8df864e16.

## Вердикт

Три исходных замечания A52-01…03 исправлены на уровне проверенного кода и соответствующих shipped fixtures.
Обнаружен один новый P2 в совместимости session state при обновлении V5.2 → V5.3.
Глобальное внедрение/обновление пока NOT_READY. Чистая V5.3 без старого состояния может перейти к ограниченной независимой runtime-приёмке, но такая приёмка здесь не выполнена.
Выборочное справочное использование без установки остаётся допустимым под текущими правилами проекта.

## Проверки и границы

- Проверены имена 1357 ZIP entries, отсутствие traversal/дублей/архивных symlink.
- Прочитаны delta protection.py и ios_ai.py с окружающими потребителями, добавленные tests, изменения validator/install metadata и операционные утверждения.
- Независимо выполнен validate_package.py: files=1357 skills=60 sections=51 playbooks=288 errors=0. Это структурная проверка и соответствие manifest, не поведенческий PASS.
- Автор сообщает 127 PASS / 0 FAIL / 0 SKIP на Linux/Python 3.13.5, 14.29 секунды. Набор здесь НЕ запускался.
- Subprocess, concurrent-session, linked-worktree и upgrade сценарии здесь end-to-end не выполнялись. Выводы о коде не выдаются за независимое runtime evidence.
- Не запускались установка/sync/uninstall, Xcode, Swift, Simulator, device или signing.
- Изменён только этот отчёт; архив извлечён для чтения. Исходники, тесты, глобальные инструкции и существующее состояние библиотеки не менялись.
- Это ограниченный re-review V5.2 → V5.3, не повторный полный аудит 1357 файлов.

## Закрытие A52

| ID | Что исправлено | Оставшаяся проверка |
|---|---|---|
| A52-01 bounded subprocess/descendants | Pipes переведены в nonblocking; искусственные readiness events удалены; ожидание ограничено deadline/timeout; cleanup POSIX group не зависит от живости лидера. | Независимый macOS запуск silent grandchild, closed pipes и read failure fixtures. |
| A52-02 session resurrection | begin/verify/close используют единый common-dir lock; close вызывает внутренний already-locked verify без повторного flock. | Запуск barrier-controlled interleavings и сохранности audit. |
| A52-03 linked worktrees | Контракт сужен до одного writer на git-common-dir; общий lease запрещает linked writer до begin. Новый fixture действительно использует git worktree add; unrelated refs не игнорируются. | Запуск linked-worktree admission/release и third-party ref tests. |

Подход к A52-03 разумный: сужение поддерживаемого параллелизма вместо сложного координатора чужих refs.
Практический компромисс для нас: параллельные writers в linked worktrees одного репозитория будут сериализованы. Это сознательное ограничение, не новая ошибка.

## A53-01 — P2: закрытые сессии V5.2 блокируют работу после обновления

Источники:
- [GLOBAL_CODEX/runtime/bin/ios_ai.py:123](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v53-1T8nca/iOS_Engineering_AI_Library_2026_V5_3_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py:123) — validate_session требует текущую SESSION_SCHEMA=3 до обработки lifecycle.
- [GLOBAL_CODEX/runtime/bin/ios_ai.py:135](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v53-1T8nca/iOS_Engineering_AI_Library_2026_V5_3_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py:135) — list_sessions валидирует все JSON, включая closed, и превращает отказ старой схемы в invalid.
- [GLOBAL_CODEX/runtime/bin/ios_ai.py:145](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v53-1T8nca/iOS_Engineering_AI_Library_2026_V5_3_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py:145) — любое invalid блокирует active_sessions.
- [GLOBAL_CODEX/runtime/bin/ios_ai.py:179](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v53-1T8nca/iOS_Engineering_AI_Library_2026_V5_3_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py:179) — новый begin вызывает active_sessions.
- [GLOBAL_ARCHITECTURE.md:71](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v53-1T8nca/iOS_Engineering_AI_Library_2026_V5_3_GLOBAL_CODEX_REVIEW_READY/GLOBAL_ARCHITECTURE.md:71) — автор предписывает закрыть активные V5.2 sessions перед обновлением.

Сценарий:
1. V5.2 создаёт session schema=2.
2. Пользователь выполняет verify/close; файл остаётся в sessions как closed.
3. Библиотека обновляется до V5.3 с тем же external state.
4. begin V5.3 читает исторический closed JSON, отвергает schema=2, маркирует invalid и прекращает работу.
5. Пользователь выполнил указанное условие «закрыть перед обновлением», но оно не обеспечивает возможность продолжения.

Доказательство: inspected/inferred по цепочке вызовов, без реального upgrade или записи state.
Последствие — отказ рабочего процесса, а не доказанная потеря исходников. Проблема относится к сохранённому состоянию предыдущей версии; чистая установка без него этого сценария не имеет.

Требуемое исправление:
- Определить отдельный безопасный контракт для исторических завершённых сессий старой поддерживаемой схемы.
- Либо валидировать их старым reader как archival/closed и исключать из writer admission, либо выполнить явную сохраняющую историю migration/archive операцию.
- Active/verified старой схемы, malformed/unknown/foreign records по-прежнему должны блокировать или требовать явного recovery.
- Не принимать произвольный JSON только потому, что в нём написано lifecycle=closed; сохранять проверку identity/integrity.
- Не удалять все sessions/state и не рекомендовать новую state-root как незаметный обход старых обязательств.
- Исправление и инструкция upgrade должны описывать один и тот же процесс.

Регрессионная приёмка:
1. V5.2 begin → verify → close → V5.3 begin с тем же state-root работает.
2. Исторический audit остаётся доступным; прежнее evidence не повышается до V5.3 PASS.
3. Active/verified V5.2 не молча принимаются новой версией.
4. Повреждённые, foreign и неизвестные схемы остаются fail-closed.
5. Повтор upgrade/recovery идемпотентен.
6. Проверить исторические closed sessions в main и linked worktree под выбранным common-dir admission contract.

## Рекомендованный следующий шаг

Передать автору только A53-01 и критерии приёмки. Не расширять библиотеку и не переписывать уже принятые исправления.
Затем — независимый запуск synthetic suite на macOS в disposable окружении, с отдельным разрешением и всеми fixtures/state/temp внутри разрешённого sandbox.
Для первого pilot предпочесть no-install reference; installed reference всё ещё меняет глобальный слой.
Готовность knowledge corpus не следует из числа тестов runtime; прежняя выборочная оценка содержательных документов остаётся в силе.

## Receipt

Scope completed: повторное статическое ревью трёх исправлений и новой session schema.
Rules: уже загруженный canonical bootstrap/Level 0, review preflight, evidence/definition-of-done, completion contract; ios-evidence-gate повторно прочитан и применён.
Docs route: common tooling review + evidence; глубокие iOS application-runtime routes не требовались.
Durable reusable docs не менялись; local exceptions не создавались.
Checks omitted: runtime/test/install execution — текущая авторизация ограничивает их; не заявляю PASS.
Контекст обновлять не нужно для завершения этого bounded review.
Model result: Astra, без subagents.
Передача контекста: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
