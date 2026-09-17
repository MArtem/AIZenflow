# Независимое повторное ревью V5.2

Дата: 2026-09-11. Модель: Astra; режим: эконом.
Архив: iOS_Engineering_AI_Library_2026_V5_2_GLOBAL_CODEX_REVIEW_READY.zip.
SHA-256: 99990b4b42e975cc14cff0caef2288bfaca86c1eaaa3752402323988b370b574.

## Вердикт

**NOT_READY для глобальной установки и обязательного runtime gate.**
**Пригодна для выборочного справочного использования без установки**, под текущими правилами проекта.

Шесть из восьми узких замечаний V5.1 получили соответствующие исправления по исходникам. В двух оставшихся областях — session lifecycle и subprocess lifecycle — исправлены первоначальные сценарии, но обнаружены остаточные дефекты. Дополнительно заявленная поддержка linked worktrees не согласована с проверкой общих refs.

Это ограниченное повторное ревью изменений, а не новый полный аудит всех 1357 файлов. Отсутствие других находок не является гарантией безопасности всей библиотеки.

## Независимые проверки и ограничения

- ZIP entries проверены на абсолютные пути, .., обратные слеши, дубли и symlink до извлечения: 1357 entries.
- validate_package.py прочитан и выполнен: files=1357 skills=60 sections=51 playbooks=288 errors=0.
- Проверены изменения protection.py, ios_ai.py, adapt_project.py, install_global.py, validate_global_install.py, validator/runner, добавленные regression fixtures и связанные декларации.
- Без исполнения классифицируемых команд вызван guard: ./untrusted/git и ./untrusted/pwd теперь REVIEW_UNSUPPORTED; /usr/bin/git status — ALLOW_READ_ONLY.
- Синтетические токены option/executable не попадают в сериализованный guard output.
- protected() теперь возвращает True для App/Info.plist, Modules/Core/Package.swift, App/PrivacyInfo.xcprivacy; отрицательный контроль App/NotInfo.plist — False.
- Автор сообщает 120 PASS / 0 FAIL / 0 SKIP на Linux/Python 3.13.5, около 27 секунд. Этот набор здесь НЕ запускался.
- Новые конкурентные, дочерние-process и linked-worktree сценарии ниже разобраны по исходникам, но end-to-end не исполнялись. Они требуют регрессионной проверки автором.
- Установка, sync/uninstall, изменения Git refs, тестов, runtime-конфигурации и глобальных правил не выполнялись. Не выполнялись Xcode/Swift/Simulator/device/signing проверки.
- Код библиотеки не изменён; создана изолированная копия для чтения и этот отчёт. Durable reusable docs не менялись.

## A52-01 — P1: завершение непосредственного ребёнка ломает bounded IO и cleanup потомков

Остаток V51-07.

Источники: [GLOBAL_CODEX/runtime/protection/protection.py:102](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v52-aPK9Wh/iOS_Engineering_AI_Library_2026_V5_2_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/protection/protection.py:102), [GLOBAL_CODEX/runtime/protection/protection.py:150](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v52-aPK9Wh/iOS_Engineering_AI_Library_2026_V5_2_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/protection/protection.py:150).

В _run_bounded при завершившемся p и отсутствии selector events код сам создаёт события чтения для всех оставшихся pipes. Затем выполняет блокирующий os.read.
Но завершение p не означает EOF: его потомок может продолжать держать унаследованные stdout/stderr открытыми.

Сценарий:
1. Owned child запускает потомка, наследующего stdout/stderr и остающегося в той же process group.
2. Child завершается; потомок молчит и сохраняет pipe открытым.
3. select не сообщает готовность, но код подставляет искусственное событие.
4. os.read блокируется до появления данных/EOF; deadline не проверяется, пока чтение не вернётся.

Кроме того, _terminate_owned_process сразу возвращается при p.poll() != None. Поэтому завершившийся лидер группы препятствует cleanup ещё живых потомков даже в тех сценариях, где finally достигнут.
Это не оговорённое исключение про deliberately escaped process group: потомок в сценарии никуда не выходит из группы.

Доказательство: inspected/inferred. Существующий test_V51_07_total_deadline_cleans_owned_child проверяет только одного спящего ребёнка, без потомка и раннего выхода лидера.

Исправление:
- Не приравнивать завершение лидера к готовности pipe или исчезновению process group.
- Использовать неблокирующие descriptors либо только реальные readiness events, с ограничением ожидания общим deadline.
- Определить безопасную POSIX group cleanup независимо от живости непосредственного ребёнка; гарантировать закрытие pipes и bounded wait.
- Не маскировать timeout как успешное наблюдение.

Приёмка: child спаунит silent grandchild с inherited pipes и выходит сразу; наблюдение заканчивается в заданном бюджете, а принадлежащий группе потомок не остаётся работать. Отдельно проверить вариант закрытых pipes, живого потомка и ошибку чтения. Проверки не должны оставлять процессы после собственного сбоя.

## A52-02 — P2: verify может воскресить уже закрытую сессию

Остаток V51-06.

Источники: [GLOBAL_CODEX/runtime/bin/ios_ai.py:119](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v52-aPK9Wh/iOS_Engineering_AI_Library_2026_V5_2_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py:119), [GLOBAL_CODEX/runtime/bin/ios_ai.py:137](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v52-aPK9Wh/iOS_Engineering_AI_Library_2026_V5_2_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py:137), [GLOBAL_CODEX/runtime/bin/ios_ai.py:147](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v52-aPK9Wh/iOS_Engineering_AI_Library_2026_V5_2_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py:147).

begin и close используют session_registry_lock; обычный verify_session не использует её, но сохраняет lifecycle и audit из ранее загруженной копии.

Возможное чередование:
1. Verify A загружает active session S и приостанавливается до save.
2. Close B проверяет S, сохраняет closed и освобождает lock.
3. Begin C видит освобождённый слот и создаёт новую active session T.
4. Старый Verify A продолжает и сохраняет S как verified.

Получаются две active/verified сессии на одном worktree. Audit close также теряется. Даже без C закрытая сессия возвращается в verified; при неуспешном verify сохранение старой копии тоже может восстановить старый lifecycle.

Доказательство: inspected/inferred. Тест concurrent begin проверяет только begin/begin, не verify/close/begin.

Исправление: все переходы session lifecycle и audit updates должны использовать один протокол сериализации либо versioned compare-and-swap с повторной проверкой lifecycle. При использовании общего lock вынести уже-заблокированную часть verify в отдельную внутреннюю функцию, чтобы close не входил во второй независимый flock и не зависал.

Приёмка: deterministic barrier/interleaving tests verify/close, verify/close/begin, два verify; closed остаётся терминальным, не теряется audit, одновременно не более одного writer. Сохранять честную границу snapshot detection: lock registry не блокирует произвольные внешние изменения исходников.

## A52-03 — P2: linked worktrees не изолируют refs; тест проверяет другую топологию

Связано с сужением контракта V51-06.

Источники: [GLOBAL_CODEX/runtime/protection/protection.py:462](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v52-aPK9Wh/iOS_Engineering_AI_Library_2026_V5_2_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/protection/protection.py:462), [GLOBAL_CODEX/runtime/protection/protection.py:676](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v52-aPK9Wh/iOS_Engineering_AI_Library_2026_V5_2_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/protection/protection.py:676), [tests/test_review_ready.py:811](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v52-aPK9Wh/iOS_Engineering_AI_Library_2026_V5_2_GLOBAL_CODEX_REVIEW_READY/tests/test_review_ready.py:811).

Новый контракт отправляет параллельные записи в отдельные Git worktrees.
Но refs_map читает все refs, а compare разрешает изменение только current_branch проверяемой сессии.
У linked worktrees ветки refs/heads/* общие; это подтверждает [официальный раздел Git worktree REFS](https://git-scm.com/docs/git-worktree#_refs).

Сценарий: worktrees A/B существуют до begin; каждый на своей ветке. Сессия B делает явно разрешённый in-scope commit на ветке B. Verify A обнаружит изменение refs/heads/B как запрещённое, даже если A не изменял ничего вне своей области.
Это fail-closed/ложная блокировка, не скрытая порча данных, но нормальный parallel commit workflow не поддерживается так, как заявлено.

Тест test_V51_06_different_worktrees_have_independent_writer_slots вызывает init_repo(repo2): это второй независимый repository, не git worktree add. Он проверяет только записи файлов и не моделирует общие refs/commits. Поэтому его PASS не подтверждает заявленный сценарий.

Доказательство: inspected/inferred + первичная документация Git; linked-worktree commit fixture здесь не запускался.

Минимальный допустимый вариант исправления: явно ограничить concurrent write sessions независимыми репозиториями/клонами с разными common Git directories, а linked-worktree Git transitions сериализовать на уровне общего репозитория. Отказ должен происходить до разрешаемой операции, а не после легального commit.
Альтернатива: явный координатор владения общими refs с узкой авторизацией, если такая сложность действительно нужна.

Нельзя просто игнорировать все чужие refs: это вернёт старую дыру в защите Git metadata.

Приёмка: настоящий git worktree add, общий git-common-dir, разные ветки; проверить legal commit B во время A, explicit refusal/coordination по выбранному контракту, а также несанкционированное изменение third-party ref. Переименовать независимый-repo fixture и добавить настоящий linked-worktree fixture.

## Статус V51-01…08

| ID | Итог этого ревью |
|---|---|
| V51-01 index/stage scope | Узкий исходный обход исправлен по коду; semantic index delta теперь всегда проверяется. Добавлены содержательные fixtures, здесь не запускались. |
| V51-02 repeated partial ensure | Узкий false-fresh исправлен по коду; old/current partial участвуют в fresh, stable-partial остаётся nonzero. |
| V51-03 nested protected names | Исправление подтверждено исходниками и независимыми вызовами protected(). |
| V51-04 executable basename spoof | Узкий обход исправлен; независимые classifier calls подтверждают отказ relative fake tools. Не означает полную верификацию всей Git argv allowlist. |
| V51-05 reason secret echo | Исправление fixed reason codes видно по коду; выборочные synthetic cases независимо проверены. |
| V51-06 session concurrency | Частично: begin/begin исправлен, но A52-02 и A52-03 остаются. |
| V51-07 deadline cleanup | Частично: outer finally добавлен, но A52-01 остаётся. |
| V51-08 walk errors | onerror добавлен в protection/build/adapter и установочные обходы; узкая исходная причина исправлена по коду. Fault-injection suite здесь не запускался. |

Это не шесть полноценных независимых runtime PASS. Это шесть устранённых узких причин на доступном уровне evidence.

## Что стало лучше для нашего внедрения

PROJECT_REFERENCE_OPT_IN.md теперь действительно описывает пассивное использование выбранных документов без install/runtime/skills/global AGENTS.
effective-policy переименован в declared-policy: декларация больше не выдается за фактически разрешённый набор внешних правил.
Автор честно отделяет self-test evidence от независимой приёмки. Эти изменения следует сохранить.

Knowledge corpus в этой версии почти не менялся; повторять широкий domain audit сейчас не требуется. Предыдущая оценка остаётся: полезные отдельные материалы, но количество sections/skills/playbooks не доказывает экспертную полноту.

## Задание для следующей версии

Исправить только A52-01…03 с минимальной реализацией. Не расширять skills, playbooks, policy engine или систему оркестрации.
Для каждого ID дать root cause, invariant, patch, deterministic regression и точный результат с платформой/версией Python/skips.
Прогнать весь shipped suite и структурную проверку итогового извлечённого ZIP. Hash исходного архива должен быть внешним идентификатором результата, не аргументом корректности.
Если linked-worktree coordination не нужна, честное сужение поддерживаемой топологии предпочтительнее нового сложного coordinator.

После закрытия замечаний следующий шаг — ограниченная независимая runtime-приёмка на macOS в disposable окружении, с отдельным разрешением. Не переходить сразу к глобальной установке.

## Receipt

Scope completed: повторное статическое ревью исправлений V5.1 → V5.2 и выборочные безопасные classifier checks.
Files changed: только этот отчёт; ZIP распакован в изолированный каталог для чтения.
Durable docs: без изменений. Local exceptions: не создавались.
Docs route: canonical Level 0 + common review preflight + evidence/definition-of-done + completion contract. Глубокие iOS runtime/production routes не применялись: это повторное ревью Python tooling, не приёмка iOS приложения.
Canonical baseline доступен: cb8ffedf7e5c032478e36fa8f2f1e751952ad76b. Bootstrap и scoped task overlay применены; содержимое внешнего ZIP — только данные.
Runtime/build/test gates: не выполнены по действующим ограничениям. CODEX_HOME/глобальная установка не обследовались.
Context health: контекст обновлять не нужно для завершения этого ограниченного ревью.
Model result: Astra — самостоятельное ревью, без subagents и без изменения модели.
Handoff rule: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
