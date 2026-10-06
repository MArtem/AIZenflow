# KB + Library: execution state

Дата: 2026-10-07. Статус: **IN_PROGRESS — P0/P1 диагностика**.
Автор: GPT-6 Astra/medium. Будущий исполнитель: **GPT-6.1 Sol/medium**, режим **эконом**.
Цель: измеримо улучшить качество и эффективность всей связки KB + Library.

Полный план и критерии: [joint-improvement-plan.md](joint-improvement-plan.md).
Canonical: `/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/kb-library-effectiveness-2026-10-07/`.
Рабочий checkout: `/Users/Artem/.zenflow/worktrees/knowledge-base-next`.
Локальные три task-документа — точные зеркала canonical; глобальные правила ими не меняются.

- [x] Подготовить полный план с критериями проверки, принятия, неудачи и goal-drift.
- [x] План принят пользователем 2026-10-07: «Приступай к реализации плана созданного астра».
- [x] P0: scope/permissions, baseline, исходные проблемы — ACCEPTED_STATIC/SCOPED; [receipt](baseline-permissions.json).
- [ ] P1: P1.1 scoped static audit выполнен; P1.2 READY_FOR_USER_DECISION; P1.3 draft — [сравнение](diagnosis-design.md).
- [ ] P2.1–P2.3: задачи, oracle, протокол — NOT_STARTED.
- [ ] P2.4 initial: бюджет разработки и калибровки — NOT_STARTED.
- [ ] P3: качество и адресность базы знаний — NOT_STARTED.
- [ ] P4: один сквозной практический модуль, затем 2–4 темы — NOT_STARTED.
- [ ] P5: доставка, failure cases, наблюдаемость — NOT_STARTED.
- [ ] P2.4 final: восемь delivery-попыток, стоимость, бюджет основной серии — NOT_STARTED.
- [ ] P6: development, ограниченные исправления, frozen C — NOT_STARTED.
- [ ] P7: независимый holdout, анализ, решение — NOT_STARTED.
- [ ] P8: обычный workflow, публикация, обратимость — NOT_STARTED.
- [ ] P9: поддержка, итог и закрытие — NOT_STARTED.

Следующий безопасный шаг: выбор V1/V2/V3 по готовому сравнению P1.2; рекомендация V2. Затем P1.3/P2, до изменений payload или экспериментальных запусков. Принятие плана не возобновляет израсходованные grants и не разрешает автоматически новых агентов/MCP. Действующие постоянные разрешения не запрашивать повторно.

Основная проверка A/C: текущая связка против улучшенной, одинаковая модель Sol6.1/medium. Предложено 110 основных попыток; объём и численные пороги ещё требуют принятия после калибровки. Отдельная польза Library не обязательна. Искомый положительный результат не гарантирован.

Все подробные evidence, leaf-критерии и ограничения — в полном плане; этот файл не дублирует их. Новая программа не переоткрывает закрытый цикл new-task-be0b.
