# Handoff — база знаний → библиотека

Дата: 2026-09-29. Task: `new-task-be0b`. Активный checkout:
`/Users/Artem/.zenflow/worktrees/knowledge-base-next`, ветка
`codex/knowledge-base-next`. Прежний `new-task-be0b` worktree и его
`codex/audit-remediation-luna` — исторический/грязный источник; не продолжать
работу и не сливать его установочную историю.

## Действующая цель и authority

Этап A — ревью и стабилизация базы знаний (первого слоя) — завершён с
оговорками. Далее этап B — copy-only библиотека, затем этап C — проверка их
совместной работы. Исполнимый план: `knowledge-base-library-roadmap.md`;
finding/evidence: `knowledge-base-audit-ledger.md`. Для этапа A пользователь
выбрал GPT-6 Sol и режим `эконом`. Новые запросы пользователя и каноническое
`MODEL_ROUTING_RULE.md` имеют приоритет над историческими моделями.

Перед работой применять корневой `AGENTS.md`, canonical bootstrap и
маршрутизатор/Level 0. Старые QC/V5.4 планы ниже task archive и Git history —
доказательства истории, не активное поручение и не authority.

## Текущее доказанное состояние

- A-I1–A-I6 завершены как риск-ориентированный документальный и статический
  аудит. Вердикт A: READY_WITH_LIMITATIONS для базы знаний как первого слоя;
  это не production-сертификат iOS-кода и не готовность copy-only библиотеки.
- `AIZenflow` `origin/main` и `origin/development` после закрытия KB-004:
  `71c4a73d770f6590ef1951cf1fec9b88b6ef00e2`.
  `AIZenflowDocumentation/main` после частичного B0–B5:
  `498367d8f23cc15f6ecc0ed67e216c58ba8f836b`.
  Перед новым push проверять удалённые ссылки заново.
- В новом чате из чистого checkout наблюдалась загрузка корневого AGENTS,
  canonical bootstrap/baseline, полного Level 0, текущих task plan/handoff;
  маршрут context-transfer применён. Это доказывает startup для того SHA,
  но не выбор всех specialist skills, runtime iOS/build или каждый optional
  документ. `CODEX_HOME`/`HOSTNAME` в том отчёте были unknown.
- После точечного переноса 40 документов/навыков прошли docs
  consistency/index/bootstrap/router/boundaries, iOS registry/framework,
  baseline mirror drift, context-cost и `git diff --check`. Build/tests,
  Simulator, Instruments не запускались.
- Нет известных открытых P0–P3 в проверенном документальном scope: KB-004
  закрыт разделением required/optional в resolver и отчёте стоимости;
  KB-012 — компактизацией task-state. Фактическое чтение optional-документов,
  актуальность каждого deep API-тезиса и автоматическая активация каждого
  specialist skill не доказаны.

## Следующий безопасный шаг

Этап B в работе: 60 бывших `ioslib-*` entrypoints классифицированы,
30 candidate allowlist-файлов и 48 локальных ссылок прошли статический
структурный контроль; шесть specialist routes добавлены. B2 подтвердил
per-Xcode-project границу, но command service не реализован. B4 исправил
ложную полноту в неактивном Xcode-сканере и исключил три небезопасных старых
скрипта; B5 зафиксировал только статические сценарии. B0–B6 не закрыты.
Далее — проверить реализацию режимных переходов, оставшиеся полезные
навыки/маршруты, семантические зависимости payload и реальные сценарии.
Не заявлять
готовность библиотеки по одной структурной проверке.
При будущих публикациях переносить только проверенные правки из этой чистой
ветки в `development`/`main`; не merge старой ветки.

Не менять Codex host, установщики, `config.toml`, auth или Keychain. Не запускать
build/tests/Simulator/Instruments и не менять тесты без отдельного разрешения.
Исторические прежние Level 0 файлы сохранены в `archive/` и Git; они не являются
текущими инструкциями.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
