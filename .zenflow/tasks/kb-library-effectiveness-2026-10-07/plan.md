# KB + Library: execution state

Дата: 2026-10-07. Статус: **IN_PROGRESS — V2 принят, P2 подготовка**.
Автор: GPT-6 Astra/medium. Будущий исполнитель: **GPT-6.1 Sol/medium**, режим **эконом**.
Цель: измеримо улучшить качество и эффективность всей связки KB + Library.

Полный план и критерии: [joint-improvement-plan.md](joint-improvement-plan.md).
Canonical: `/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/kb-library-effectiveness-2026-10-07/`.
Рабочий checkout: `/Users/Artem/.zenflow/worktrees/knowledge-base-next`.
Локальные три task-документа — точные зеркала canonical; глобальные правила ими не меняются.

- [x] Подготовить полный план с критериями проверки, принятия, неудачи и goal-drift.
- [x] План принят пользователем 2026-10-07: «Приступай к реализации плана созданного астра».
- [x] P0: scope/permissions, baseline, исходные проблемы — ACCEPTED_STATIC/SCOPED; [receipt](baseline-permissions.json).
- [x] P1: scoped audit, выбор V2 и контракты слоёв — ACCEPTED_SCOPED как дизайн; [контракт](v2-contract-and-evaluation-preparation.md).
- [ ] P2.1–P2.3: IN_PROGRESS; разрешённый куратор `/root/p2_case_curator` завершён, один fresh-context Sol6.1/medium, до 60 минут. Parent не читает sealed holdout. [Протокол](evaluation-protocol-draft.md) DRAFT_NOT_FROZEN; полный dataset/oracle/isolation ещё не приняты.
- [ ] P2.4 initial: curator preparation завершена; CXL-01 prototype 30–60 минут разрешён и выполнен. Delivery workers/budget ещё не приняты.
- [ ] P3: качество и адресность базы знаний — NOT_STARTED.
- [x] CXL-01 bounded prototype: module + routing + 8 Swift checks завершены как candidate.
- [ ] P4: PARTIAL — CXL-01 module candidate подготовлен; exact example parity, type-check и 8/8 local model PASS. App adoption/delivery benefit NOT_MEASURED; остальные темы не начаты.
- [ ] P5: доставка, failure cases, наблюдаемость — NOT_STARTED.
- [ ] P2.4 final: восемь delivery-попыток, стоимость, бюджет основной серии — NOT_STARTED.
- [ ] P6: development, ограниченные исправления, frozen C — NOT_STARTED.
- [ ] P7: независимый holdout, анализ, решение — NOT_STARTED.
- [ ] P8: обычный workflow, публикация, обратимость — NOT_STARTED.
- [ ] P9: поддержка, итог и закрытие — NOT_STARTED.

Следующий безопасный шаг: exact final-diff review и публикация CXL-01/curator evidence; затем предложенный ограниченный A/C delivery pilot. Его новые executors ещё не разрешены. Полезные найденные изменения коммитить по прямому указанию пользователя; постоянные разрешения не запрашивать повторно.

Найденные четыре dirty файла Ghibli проверены и сохранены локальным коммитом `9e647491fa7d39d58971dadf86c9faa5c6a08e43`, ветка `codex/preserve-ghibli-favorites-20261007`; checkout чистый. Origin upstream gahntpo, не пользовательский publication target; push не выполнен. Исходный evaluation HEAD `524c4348…` сохранён. Runtime evidence в этом блоке NOT_RUN.

Основная проверка A/C: текущая связка против улучшенной, одинаковая модель Sol6.1/medium. Предложено 110 основных попыток; объём и численные пороги ещё требуют принятия после калибровки. Отдельная польза Library не обязательна. Искомый положительный результат не гарантирован.

Все подробные evidence, leaf-критерии и ограничения — в полном плане; этот файл не дублирует их. Новая программа не переоткрывает закрытый цикл new-task-be0b.

Новое обязательное завершение: все полезные результаты затронутых repositories слить в main/development, проверить содержание/историю, удалённые SHA и реальные checkout. [Git targets/acceptance](evaluation-protocol-draft.md). Для Ghibli user-owned remote пока не выбран; upstream push не предполагается.

## CXL-01 boundary, 2026-10-07

Пользователь принял блок: один модуль + entry/router, максимум три active Markdown files; один
Swift fixture, type-check + 8 local deterministic scenarios; 30–60 минут. Без app source, app
builds/Simulator/network/installations. Это НЕ восемь delivery attempts. Куратор завершён: 12+12
candidate cases, 3 clean controls в каждом split; public и 24 input/oracle hashes PASS без раскрытия
sealed text. P2 остаётся PARTIAL_NOT_FROZEN; eligibility/oracle/isolation/future executor gates открыты.
CXL-01: 8/8 local model PASS; candidate, benefit NOT_MEASURED. [Evidence](cxl01-evidence/README.md).
Новый module/router не скопирован в active app payloads и не меняет их pins/modes. Следующий этап:
проверить доставку candidate C и определить ограниченный fresh-context A/C pilot; новые execution
workers/agents и их бюджет требуют конкретного решения, не следуют из Swift grant.
