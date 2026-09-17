# План приёмки библиотеки — завершён

Дата: 2026-09-18. Исполнитель: GPT-5.6 Sol; режим `эконом`.
Процедура: [luna-final-acceptance-runbook.md](luna-final-acceptance-runbook.md).
Актуальное evidence:
[final-acceptance-summary.md](../../library-adoption-v54/evidence/final-acceptance/final-acceptance-summary.md).

## Завершено

- [x] Исправлен P3 QUICKSTART без расширения CLI; package manifest обновлён.
- [x] Candidate validator: 1367 файлов, 60 skills, 51 sections, 288 playbooks, 0 ошибок.
- [x] Candidate `48cb8ad3596c22de4bd6d24fe2b63d861bd93db1` опубликован в dev-ветку.
- [x] Effective Desktop home подтверждён по процессу: `CODEX_HOME` unset, `HOME=/Users/Artem`.
- [x] Canonical payload продвинут в `reusable/ios-engineering-library/v5.4`.
- [x] Source-in-place runtime обновлён двухшагово и возвращён на canonical source.
- [x] Installation validator PASS; host bridge подключён к `/Users/Artem/.codex/AGENTS.md`.
- [x] `host_entry.py status`: connected, без errors/warnings; исходные bytes/mode сохранены receipt.
- [x] Fresh-entry PASS: Ghibli, Firefox и Countries автоматически получили router/common baseline.
- [x] Empty control: common route delivered, `review_required` без выдуманного проекта.
- [x] Non-iOS control: iOS-специфический контракт корректно проигнорирован.
- [x] Linked control: физический root/common Git dir/worktree Git dir различены корректно.
- [x] Финальный ZIP: 1367 файлов, CRC/safe paths/byte identity PASS,
  SHA-256 `8f18964f1020da6ece7b77fbd785916a9064a4719d70cfcfef6901d993d5e99f`.
- [x] Canonical опубликован и remote подтверждён на
  `71c38bacc9efd11161d5e75cf54e7d352e994c3d`; task closeout публикуется этим финальным commit.

## Сохраняемые ограничения

- App/Xcode builds, Simulator, зависимости и upstream pilot-project mutations не выполнялись.
- Suite `215 / 209 PASS / 0 FAIL / 6 NOT_RUN` не перезапускался после документационной P3-правки;
  шесть lifecycle-сценариев имеют отдельное прежнее PASS evidence.
- `/Users/Shared/ioslib-acceptance` не создавать без нового разрешения.
- Rollback host connection: сначала проверенный `host_entry.py disconnect`, затем при необходимости
  runtime rollback штатным `sync_global.py`.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
