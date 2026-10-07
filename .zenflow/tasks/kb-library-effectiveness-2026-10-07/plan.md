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
- [ ] P2.4 initial: curator and CXL prototype complete; exactly two authorized delivery workers completed. Future execution requires a new bounded decision.
- [ ] P3: качество и адресность базы знаний — NOT_STARTED.
- [x] CXL-01 bounded prototype: module + routing + 8 Swift checks завершены как candidate.
- [ ] P4: PARTIAL — CXL-01 module candidate подготовлен; exact example parity, type-check и 8/8 local model PASS. App adoption/delivery benefit NOT_MEASURED; остальные темы не начаты.
- [ ] P5: PARTIAL - pilot01 delivered the module before final review verdict; A/C scoped outcomes tied. v0.2 review slice delivered in pilot02, outcomes tied.
- [ ] P2.4 final: восемь delivery-попыток, стоимость, бюджет основной серии — NOT_STARTED.
- [ ] P6: development, ограниченные исправления, frozen C — NOT_STARTED.
- [ ] P7: независимый holdout, анализ, решение — NOT_STARTED.
- [ ] P8: обычный workflow, публикация, обратимость — NOT_STARTED.
- [ ] P9: поддержка, итог и закрытие — NOT_STARTED.

Next safe step: publish pilot02, then user selects KB-first consolidation or a distinct bounded hypothesis. All six delivery executor grants are consumed.

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

## Delivery pilot 01 and candidate v0.2

- [x] User authorized exactly two fresh read-only GPT-6.1 Sol/medium executors, 600s each; grant consumed.
- [x] A34/C35 and shared source/task/required-KB envelopes verified; original projects unchanged.
- [x] Both reviews received; public DEV-C01 oracle read only after both outputs completed.
- [x] Module delivery PASS before final adjudication; scoped static outcomes 1/1 versus 1/1;
  zero incremental confirmed defects/capabilities. Severity headings are not extra discoveries.
- [x] v0.2: review slice 499 words versus full v0.1 module 1265; exact checked Swift example retained.
  Task-history link removed from reusable boundary. Required normative KB reads unchanged.
- [x] v0.2 delivery PASS; benefit NOT_ESTABLISHED; active app payloads/pins/modes untouched.

[Results](delivery-pilot-01/results.md), [adjudication](delivery-pilot-01/adjudication.json),
[future candidate pin](cxl01-evidence/candidate-payload-v0.2.json). The v0.1 pin remains historical
pilot01 input, not a live v0.2 manifest. Observed 138/132s do not establish efficiency: partial
startup clocks, single attempts, extra selected KB reads differ, token cost UNKNOWN. Grader is
unblinded module author; procedural separation only, holdout unopened. Swift8 PASS reused because
exact code is unchanged. This tie does not close P6/P7 or justify topic expansion/rollout.
The subsequent pilot02 completed that bounded fix plus clean control on eligible Firefox sources.
Do not repeat this hypothesis merely to seek a positive outcome.

Latest boundary: [pilot02 results](delivery-pilot-02/results.md), four authorized fresh Sol6.1/medium executors completed; grant consumed. Fix semantic checks and apply-check PASS both, success control zero findings both; outcomes TIED, incremental benefit NOT_ESTABLISHED. C v0.2 delivery PASS; original projects unchanged, holdout unopened, no runtime. Stop this hypothesis pending user choice: recommended KB-first consolidation versus a distinct bounded hypothesis. No further agent/runtime grant; full plan/dataset/C remain incomplete/not frozen.
