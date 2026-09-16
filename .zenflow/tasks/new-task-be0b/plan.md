# Текущий план приёмки библиотеки

Дата: 2026-09-16. Исполнитель текущего исправления: Astra; режим эконом.
Подробная процедура: [luna-final-acceptance-runbook.md](luna-final-acceptance-runbook.md).
Актуальное состояние и доказательства:
[final-acceptance-summary.md](../../library-adoption-v54/evidence/final-acceptance/final-acceptance-summary.md).
Этот checklist заменяет устаревшие статусы предыдущих проходов, но не расширяет authority.

## Завершено

- [x] Исправить manual harness: отдельные shell-строки, общий builder для activation/reconnect.
- [x] Проверять сборку/синтаксис команд независимо от Git-dependent deployment skip.
- [x] Сделать исторический ZIP явным входом; проверить pinned SHA до Git boundary.
- [x] Один финальный library suite: 199 total / 193 PASS / 0 FAIL / 6 SKIP.
- [x] Validator: 1366 files / 60 skills / 51 sections / 288 playbooks / 0 errors.
- [x] Завершить Countries scenario table; P2 отмены оформить как finding read-only пилота.
- [x] Сохранить Retry-патч Ghibli; подготовить отдельную чистую GhibliSwiftUIApp-entry.
- [x] Сверить чистоту Firefox/Countries и доступность saved projects.
- [x] Попытаться добавить проекты через Codex UI: инструмент вернул safety prohibition.
- [x] Синхронизировать canonical/source и существующий reference runtime; validator PASS.
- [x] Создать один новый ZIP и сверить все 1366 файлов с candidate/canonical.
- [x] Исправить противоречивые статусы и убрать утверждение, что skips доказывают отсутствие ошибок.
- [x] Подготовить исправления T/V к отдельным commits; exact HEAD и push receipt — в финальном сообщении после публикации.

## Остаток

- [ ] Пользователь добавляет три точных pilot roots в Codex; затем нейтральные fresh-entry tasks.
- [ ] Реально наблюдать host common delivery и выбор исправленного пакета.
- [ ] Завершить fresh-entry matrix, включая отдельный non-iOS контроль.
- [ ] R3 и остальные positive external lifecycle: нужна разрешённая область вне любого Git.
- [ ] Итоговая полная приёмка: BLOCKED до закрытия этих evidence gates.

## Границы

Все project artifacts внутри /Users/Artem/.zenflow. Не обходить Git/UI safety boundary.
Library tests и commits/push T/V разрешены. Upstream commits/push, зависимости, Xcode,
app tests и Simulator не разрешены. Countries остаётся read-only; его P2 не требует изменения
upstream для приёмки review deliverable. Три статических пилота не заменяют свежую host-задачу.
Не повторять suite/archive/runtime sync без изменения риска или исполняемого кода.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
