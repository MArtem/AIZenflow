# Текущий план приёмки библиотеки

Дата: 2026-09-16. Astra; режим эконом. Fresh-entry observers: Luna Xhigh.
Процедура: [luna-final-acceptance-runbook.md](luna-final-acceptance-runbook.md).
Актуальные доказательства:
[final-acceptance-summary.md](../../library-adoption-v54/evidence/final-acceptance/final-acceptance-summary.md).

## Выполнено

- [x] Проверить отсутствие внешней папки/чужих данных и Git boundary; создать private fixture root.
- [x] Запустить шесть previously skipped тестов; сохранить первоначальные реальные failures.
- [x] Исправить два isolated skills paths, original snapshot mode и точный disable/reconnect.
- [x] Один финальный serial suite после code fixes: 199 PASS / 0 FAIL / 0 SKIP.
- [x] R1 manual lifecycle и R3 реальный .6→.7→.6 подтверждены в isolated scope.
- [x] Validator: 1366 files / 60 skills / 51 sections / 288 playbooks / 0 errors.
- [x] Удалить содержимое и саму /Users/Shared/ioslib-acceptance; отсутствие подтверждено.
- [x] Создать три нейтральные local fresh-entry задачи Luna Xhigh в зарегистрированных проектах.
- [x] Сохранить first-turn command ordering и supplementary self-reports; upstream trees чистые.
- [x] Зафиксировать непрохождение automatic common/library application gate в этих входах.
- [x] Установить разрешённую причинную границу: `.zenflow/AGENTS.md` находится выше Git-root
  пилотных проектов и по правилам Codex не входит в их project instruction chain.
- [x] Сверить это с activation boundary пакета: candidate уже требует active global AGENTS
  внутри фактического CODEX_HOME; дефект installer/runtime не установлен.
- [x] По отдельному разрешению проверить два default global candidates: override отсутствует,
  `/Users/Artem/.codex/AGENTS.md` — regular empty file (0 bytes); конфликт precedence исключён.
- [x] Сохранить прежние static pilots, включая Countries scenario table/P2 и отдельный Retry-патч.
- [x] Один новый candidate ZIP: CRC/safe paths/все 1366 file bytes совпадают с candidate.
- [x] Подготовить candidate/evidence к task commit; exact SHA/push receipt фиксируется после commit.

## Остаток и границы

- [x] Выбрать безопасную архитектуру host activation: отдельный instruction bridge к canonical
  runtime вместо смены всего Desktop CODEX_HOME или копирования runtime в real home.
- [x] Реализовать `host_entry.py connect/status/disconnect`: runtime receipt внутри `.zenflow`,
  снаружи меняется только выбранный active global AGENTS после отдельного разрешения.
- [x] Добавить synthetic roundtrip/tamper/precedence/byte-mode/race проверки внутри `.zenflow`.
- [x] Обновить deployment docs/manifests и выполнить целевой, затем один финальный suite
  (`215 total / 209 PASS / 0 FAIL / 6 external-to-Git NOT_RUN` после corrective suite).
- [x] Провести независимый Astra review; исправить найденные P1/P1/P2 по atomic rollback и
  active-override drift, а также последующие P2 для new-file, removal, exchange-cleanup durability
  и recovery-snapshot failures. Повторное независимое review требуется перед commit/push.
- [ ] После этого — наблюдение selected package/relevant route и дополнительные empty/non-iOS/linked controls.
- [ ] Отдельно согласованное продвижение candidate в canonical/активный source-in-place runtime.
- [ ] Полная приёмка: НЕ завершена; isolated lifecycle PASS не заменяет auto-delivery gate.

Однократное разрешение на /Users/Shared/ioslib-acceptance израсходовано; не создавать папку снова.
Вся дальнейшая работа только внутри /Users/Artem/.zenflow. Canonical и runtime в этом проходе
не менялись. Не запускать app tests/build/Simulator, зависимости, upstream commits/push.
Не менять Countries ради read-only pilot. Не повторять suite/архив только ради receipt.
Новые конфигурационные действия требуют отдельной точной authority.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
