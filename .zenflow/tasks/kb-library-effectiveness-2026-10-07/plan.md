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
- [ ] P2.1–P2.3: IN_PROGRESS; шесть development-кандидатов, traces/oracle и isolation draft. Полный dataset/holdout/validated oracle ещё не готовы.
- [ ] P2.4 initial: бюджет разработки и калибровки — NOT_STARTED.
- [ ] P3: качество и адресность базы знаний — NOT_STARTED.
- [ ] P4: один сквозной практический модуль, затем 2–4 темы — NOT_STARTED.
- [ ] P5: доставка, failure cases, наблюдаемость — NOT_STARTED.
- [ ] P2.4 final: восемь delivery-попыток, стоимость, бюджет основной серии — NOT_STARTED.
- [ ] P6: development, ограниченные исправления, frozen C — NOT_STARTED.
- [ ] P7: независимый holdout, анализ, решение — NOT_STARTED.
- [ ] P8: обычный workflow, публикация, обратимость — NOT_STARTED.
- [ ] P9: поддержка, итог и закрытие — NOT_STARTED.

Следующий безопасный шаг: решение по одному независимому куратору задач Sol6.1/medium и ограниченному бюджету P2; [конкретный scope](v2-contract-and-evaluation-preparation.md). Полезные найденные изменения коммитить по новому прямому указанию пользователя; runtime/agents/MCP этим не разрешены. Действующие постоянные разрешения не запрашивать повторно.

Найденные четыре dirty файла Ghibli проверены и сохранены локальным коммитом `9e647491fa7d39d58971dadf86c9faa5c6a08e43`, ветка `codex/preserve-ghibli-favorites-20261007`; checkout чистый. Origin upstream gahntpo, не пользовательский publication target; push не выполнен. Исходный evaluation HEAD `524c4348…` сохранён. Runtime evidence в этом блоке NOT_RUN.

Основная проверка A/C: текущая связка против улучшенной, одинаковая модель Sol6.1/medium. Предложено 110 основных попыток; объём и численные пороги ещё требуют принятия после калибровки. Отдельная польза Library не обязательна. Искомый положительный результат не гарантирован.

Все подробные evidence, leaf-критерии и ограничения — в полном плане; этот файл не дублирует их. Новая программа не переоткрывает закрытый цикл new-task-be0b.
