# Handoff: улучшение KB + Library

2026-10-07. **IN_PROGRESS; P0/P1 scoped preparation выполнены, V2 принят; P2 IN_PROGRESS, experimental runs NOT_STARTED.**

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**: canonical bootstrap → baseline/router → Level 0 → текущие plan/handoff → применимые routes/overlays. После восстановления читать адресно, без повторных полных проходов.

- Рабочий root: `/Users/Artem/.zenflow/worktrees/knowledge-base-next`.
- Canonical task: `/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/kb-library-effectiveness-2026-10-07/`.
- Полный план: [joint-improvement-plan.md](joint-improvement-plan.md); исполнение: [plan.md](plan.md).
- Модель реализации выбрана пользователем: **GPT-6.1 Sol/medium**. Режим: **эконом**.
- Цель: максимальное обоснованное улучшение всей связки, с приоритетом правильности, устойчивости, меньших переделок и затем стоимости. Не доказывать отдельную Library любой ценой.

Готово: план принят пользователем 2026-10-07; P0 identity/permissions и P1.1 content диагностика выполнены. Результаты: [baseline-permissions.json](baseline-permissions.json), [diagnosis-design.md](diagnosis-design.md). Польза системы ещё не измерена.

Пользователь выбрал V2. [Контракт и подготовка P2](v2-contract-and-evaluation-preparation.md): owners, три темы, CXL-01 traces и шесть development-кандидатов готовы. Следующий шаг: решение по ровно одному независимому куратору Sol6.1/medium для dataset/oracle, read-only до 60 минут, без source/runtime/network/MCP/новых агентов. Агент ещё не создан. Полный dataset/holdout отсутствуют; oracle/isolation не проверены. После P5 возврат к P2.4; Frozen C только P6.3. Holdout не использовать для разработки.

Новая authority: «комить все правки и что найдешь незакомиченное, по ходу разработки, что бы ничего не потерять». Четыре Ghibli dirty файла сохранены `9e647491fa7d39d58971dadf86c9faa5c6a08e43` на `codex/preserve-ghibli-favorites-20261007`; original source bytes сохранены, checkout чистый. Origin — upstream gahntpo; коммит локальный. Evaluation baseline `524c4348…` остаётся восстановимым. Этот preservation не является новой реализацией V2 или runtime PASS.

Baseline A: AIZenflow `ad3b80c3608f949d68f324083c05154d0e23358f`, Documentation `a521aa5a5dc036f6955cfb326ad290ad27ef264b`. Сохранены 34 Library hashes; оба project payload соответствуют canonical. Drift: 1 missing, 32 stale, без unexpected/failures; blanket sync не выполнен. Старые cycle-specific execution grants завершены NT-BE0B-CLOSE-02; будущие runtime/mode действия сверять по конкретному новому блоку.

Permissions: новая подготовка плана не выдаёт blanket-grant. Сверить действующие постоянные и scoped-разрешения из разговора/канона; не просить повторно уже разрешённое и не возобновлять израсходованные grants. Новые агенты/MCP/автоматизации только по конкретному решению. Ранее разрешённые два observer-чата не являются новым лимитом на эту программу. Только `/Users/Artem/.zenflow`, shell `login:false`; ограниченное Simulator-исключение вне root — лишь для действительно необходимого и разрешённого назначения. iPad и реальные устройства полностью исключены из проверок и приёмки. Runtime iPhone 18.2/27 — по совместимости и покрытому блоку, без автоматических установок. Сохранить чужие правки; Git — по действующей явной authority и gates.

История: new-task-be0b закрыт решением NT-BE0B-CLOSE-02; Library OPTIONAL_EXPERIMENTAL, benefit не доказан. Новая программа не переписывает прошлую. При планировании AIZenflow baseline был `159984d5f75981b842780686697a3fdbcc7cbb8f`, canonical docs — `75def0809f41647acc5a0f92447f89c40ea1a5cc`; это исторические SHA до публикации нового плана, текущее состояние нужно проверить. Main освобождена из сервисного aizenflow-pr11-merge; не занимать её там повторно.

Основной риск: снова наращивать документы/пилоты без изменения outcomes. Проверять перед каждым блоком связь с R-ID, наблюдаемый механизм и условие опровержения. Две итерации на гипотезу, затем решение; бюджет конечен. Предложенные 110 попыток и пороги Q/E не являются уже принятыми обязательствами.
