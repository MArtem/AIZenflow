# Handoff: улучшение KB + Library

2026-10-07. **IN_PROGRESS; P0/P1 scoped preparation выполнены, V2 принят; P2 IN_PROGRESS, pilot01 DONE: delivery PASS, outcomes TIED; full experiments NOT_FROZEN.**

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**: canonical bootstrap → baseline/router → Level 0 → текущие plan/handoff → применимые routes/overlays. После восстановления читать адресно, без повторных полных проходов.

- Рабочий root: `/Users/Artem/.zenflow/worktrees/knowledge-base-next`.
- Canonical task: `/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/kb-library-effectiveness-2026-10-07/`.
- Полный план: [joint-improvement-plan.md](joint-improvement-plan.md); исполнение: [plan.md](plan.md).
- Модель реализации выбрана пользователем: **GPT-6.1 Sol/medium**. Режим: **эконом**.
- Цель: максимальное обоснованное улучшение всей связки, с приоритетом правильности, устойчивости, меньших переделок и затем стоимости. Не доказывать отдельную Library любой ценой.

Готово: план принят пользователем 2026-10-07; P0 identity/permissions и P1.1 content диагностика выполнены. Результаты: [baseline-permissions.json](baseline-permissions.json), [diagnosis-design.md](diagnosis-design.md). Польза системы ещё не измерена.

Пользователь выбрал V2 и разрешил ровно одного куратора: `/root/p2_case_curator`, GPT-6.1 Sol/medium, fork none, до 60 минут, read-only sources/task evidence writes, без source/runtime/network/MCP/дочерних агентов. Он завершён: 12 development + 12 sealed holdout кандидатов; hashes проверены без раскрытия sealed text. Parent читает только curator public summary/manifest/development, НЕ sealed holdout tasks/answers. [Протокол](evaluation-protocol-draft.md) DRAFT_NOT_FROZEN; dataset/oracle/isolation ещё не приняты. Grant не включает новых executor/grader. После P5 возврат к P2.4; Frozen C только P6.3.

Новая authority: «комить все правки и что найдешь незакомиченное, по ходу разработки, что бы ничего не потерять». Четыре Ghibli dirty файла сохранены `9e647491fa7d39d58971dadf86c9faa5c6a08e43` на `codex/preserve-ghibli-favorites-20261007`; original source bytes сохранены, checkout чистый. Origin — upstream gahntpo; коммит локальный. Evaluation baseline `524c4348…` остаётся восстановимым. Этот preservation не является новой реализацией V2 или runtime PASS.

Новое final Git требование: после плана все полезные результаты объединить в main/development затронутых repos. Targets/критерии в evaluation-protocol-draft; проверять ancestry И content/checkout, свежие remote refs, exact HEAD receipts. Documentation development existence/divergence проверить; Ghibli user-owned publication remote не выбран. Без force/reset/clean, удаления уникальной истории или занятия main сервисным worktree.

Baseline A: AIZenflow `ad3b80c3608f949d68f324083c05154d0e23358f`, Documentation `a521aa5a5dc036f6955cfb326ad290ad27ef264b`. Сохранены 34 Library hashes; оба project payload соответствуют canonical. Drift: 1 missing, 32 stale, без unexpected/failures; blanket sync не выполнен. Старые cycle-specific execution grants завершены NT-BE0B-CLOSE-02; будущие runtime/mode действия сверять по конкретному новому блоку.

Permissions: новая подготовка плана не выдаёт blanket-grant. Сверить действующие постоянные и scoped-разрешения из разговора/канона; не просить повторно уже разрешённое и не возобновлять израсходованные grants. Новые агенты/MCP/автоматизации только по конкретному решению. Ранее разрешённые два observer-чата не являются новым лимитом на эту программу. Только `/Users/Artem/.zenflow`, shell `login:false`; ограниченное Simulator-исключение вне root — лишь для действительно необходимого и разрешённого назначения. iPad и реальные устройства полностью исключены из проверок и приёмки. Runtime iPhone 18.2/27 — по совместимости и покрытому блоку, без автоматических установок. Сохранить чужие правки; Git — по действующей явной authority и gates.

История: new-task-be0b закрыт решением NT-BE0B-CLOSE-02; Library OPTIONAL_EXPERIMENTAL, benefit не доказан. Новая программа не переписывает прошлую. При планировании AIZenflow baseline был `159984d5f75981b842780686697a3fdbcc7cbb8f`, canonical docs — `75def0809f41647acc5a0f92447f89c40ea1a5cc`; это исторические SHA до публикации нового плана, текущее состояние нужно проверить. Main освобождена из сервисного aizenflow-pr11-merge; не занимать её там повторно.

Основной риск: снова наращивать документы/пилоты без изменения outcomes. Проверять перед каждым блоком связь с R-ID, наблюдаемый механизм и условие опровержения. Две итерации на гипотезу, затем решение; бюджет конечен. Предложенные 110 попыток и пороги Q/E не являются уже принятыми обязательствами.

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

## Latest boundary: pilot01 and v0.2

User authorized exactly two fresh read-only Sol6.1/medium executors, 600s each.
/root/delivery_review_01 and /root/delivery_review_02 completed; grant consumed. A34 baseline
versus C35 v0.1, identical required KB/source/task envelope. C consulted module before final
verdict; both scoped static success, zero incremental confirmed findings. Two C P2 headings
versus A P2+observation do not establish gain; independent publication-defect severity UNKNOWN.
Observed 138/132s are not an efficiency effect; tokens UNKNOWN, unblinded parent grader and
selected extra KB paths differ. [Results](delivery-pilot-01/results.md). Original project
HEAD/status unchanged; holdout NOT_READ.

v0.2 prepared within V2: bounded review slice (499 words), exact full checked example unchanged;
reusable task-history link removed. New hashes: cxl01-evidence/candidate-payload-v0.2.json.
Old candidate-payload.json and pilot01 snapshots are immutable historical v0.1 inputs.
v0.2 delivery/benefit NOT_RUN/NOT_ESTABLISHED; no app pins/modes/source changes, no new
runtime/agent grant. Preserve raw outputs and their severity labels without claiming a gain.
Next: publish this boundary, then bounded fix + clean control; new workers/checks and eligibility
need their respective decisions. Do not blindly repeat this review or expand module topics.

Prepared next decision: [Firefox constrained-fix + success-control proposal](delivery-pilot-02-proposal/README.md), exactly four fresh Sol6.1/medium executors, 600s each, 40-minute total cap; no original source changes/app builds/runtime/network/MCP. NOT_AUTHORIZED.
