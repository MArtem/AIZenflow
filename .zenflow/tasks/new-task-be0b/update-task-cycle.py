from pathlib import Path
import subprocess,hashlib
v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
t=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next/.zenflow/tasks/new-task-be0b')
assert subprocess.check_output(['git','-C',str(v),'rev-parse','HEAD'],text=True).strip()=='cb617326fd06cad4408d4ef576c32d0d6483357e'
assert not subprocess.check_output(['git','-C',str(v),'status','--porcelain'],text=True).strip()
# Contract: mandatory proportional pre-task analysis/plan/decomposition/plan review;
# separate post-change evidence and memory. Explicit pilot delegation is current-task
# authority only; no runtime, Library, Git or product-development scope is inherited.
def replace(p,old,new):
 s=p.read_text(); assert old in s,(p,old);p.write_text(s.replace(old,new,1))
w=v/'reusable/baseline/docs/IOS_PROJECT_WORK_SYSTEM.md'
replace(w,'task preparation through the `ios-project-work-system` route, after canonical bootstrap\nand Level 0.','task preparation through the `ios-project-work-system` route, after canonical bootstrap\nand Level 0. For each task in this workflow, apply the preparation/execution cycle in\nSection 4A before its implementation; scale its detail to the actual risk and scope.')
section='''## 4A. Analyze, plan, decompose and review every task

Every task starts with an explicit preparation result, including a bug, feature,
refactor, audit, resource change or documentation task. Use the existing task packet
and plan; the [preflight](AGENT_PREFLIGHT_CHECKLIST.md) and
[change quality contract](ENGINEERING_CHANGE_QUALITY_STANDARD.md) remain authoritative.
A small task may express the entire cycle in a few lines. Greater ambiguity, impact
or consumer count requires deeper analysis and finer blocks, not fewer quality gates.
Record concise conclusions, decisions and evidence references, not private reasoning
transcripts or a second set of reports. Task preparation itself runs this cycle with
its own bounded objective; it does not recursively create a preparation task.

| Step | Required output / check |
|---|---|
| Analyze intent and context | Objective, current versus required behavior, acceptance/non-goals; exact identity, relevant source freshness, ownership, consumers, constraints, risks and missing decisions. Separate facts, assumptions and product questions. |
| Compare material approaches | When several approaches change behavior, ownership, compatibility, UX or meaningful cost/risk, give suitability, benefits, downsides and a recommendation. Obtain the user's choice unless current explicit authority already selects or delegates that decision. Routine implementation details do not require another approval. |
| Define contract and plan | Relevant invariants and failure semantics under the existing change standard; bounded outcome, affected paths/consumers, current authority and the sequence needed to reach acceptance. |
| Decompose | Small complete blocks ordered by dependencies. For each block identify its output, affected scope, completion criterion, relevant verification and required decisions/permissions. One small change can be one block; do not invent layers, services or parallel writers to lengthen the plan. |
| Review the plan before changes | Check requirement coverage, dependency/order correctness, source/consumer agreement, failure and rollback implications, verification sufficiency and permission/resource limits. Resolve material ambiguity or a blocking gap before dependent work; continue independent authorized work. A plan does not grant its proposed executions. |
| Execute and check each block | Targeted inspection, one bounded patch, permitted invariant-derived verification and review. Record actual results and mark completed steps only after their criteria are met. New facts, scope, permissions or a failed check trigger affected analysis and plan review before dependent continuation. |
| Review the whole result | Complete owned diff and affected consumers/claims under the engineering gate. Reuse unchanged valid evidence; distinguish static, compile, interaction and release claims. Unrun checks remain visible; confirmed candidate P0–P2 prevent completion without the governed correction/explicit exception. |
| Refresh and hand off | Update affected project memory, findings and task state; record exact evidence, residual risk and next safe action. Preserve human edits and decisions. Final completion and publication follow existing authority/gates, never a plan checkbox alone. |

The first layer produces a provisional result for each applicable step before an
approved ON second-layer challenge under Section 6. OFF retains this complete cycle.
Plan review is the integrator's review unless a separately authorized independent
review actually occurs. No automatic agents, test creation, builds, Simulator, MCP,
Library transition or publication follows from this mandatory quality cycle.

Pilot tasks use the same cycle with a narrower purpose: answer a named system-acceptance
question. Before acting, name the smallest scenario and evidence, file/action bounds,
ending event and exit criterion in the existing packet. Select/associate a pilot only
under current exact or explicitly delegated authority. Stop expanding it when the
question is answered or requires a missing decision/action. App findings remain in its
ledger; unrelated features, architectural improvements and backlog execution require a
separate product task. A chosen pilot is not authority to finish developing that app.

'''
s=w.read_text();assert '## 4A.' not in s;s=s.replace('## 5. Plan capabilities for the prepared task',section+'## 5. Plan capabilities for the prepared task',1);w.write_text(s)
replace(w,'| Task/action preparation | Intent/acceptance, change contract, affected files, independent permissions and useful checks | Smallest adequate evidence/action and remaining uncertainty |','| Task/action preparation | Intent/context analysis, material approach choice, contract, dependency-ordered blocks, reviewed plan and independent permissions/checks (Section 4A) | Requirement/consumer coverage, plan ordering, smallest adequate evidence/action and remaining uncertainty |')
p=v/'tasks/new-task-be0b/ios-project-work-system-plan.md'
replace(p,'| R18 | Отключить/отвязать проект без разрушения | Dry-run удаления только собственных project entrypoints; память сохраняется |','| R18 | Отключить/отвязать проект без разрушения | Dry-run удаления только собственных project entrypoints; память сохраняется |\n| R19 | Перед каждой задачей анализировать, планировать, декомпозировать и проверять план; затем проверять блоки и весь результат | Existing packet содержит цель/context/варианты/contract, зависимости и критерии блоков; plan review выполнен до изменений, actual evidence и память обновлены |\n| R20 | Держать пилот в пределах проверки системы | У сценария названы system question, границы и exit criterion; посторонние app findings остаются в ledger, развитие приложения вынесено отдельно |')
replace(p,'## 8. Подготовка и исполнение task\n\nПеред реализацией сформировать packet:','## 8. Подготовка и исполнение task\n\nДля каждой задачи обязателен цикл: анализ цели и свежего контекста → сравнение\nсущественных подходов и user choice → change contract/plan → декомпозиция по\nзависимостям → review плана до изменений → ограниченные blocks с проверками →\nreview полного результата → обновление памяти/handoff. Использовать существующий\npacket и plan; operational contract — [workflow Section 4A](../../reusable/baseline/docs/IOS_PROJECT_WORK_SYSTEM.md#4a-analyze-plan-decompose-and-review-every-task).\nГлубина пропорциональна риску: небольшая задача допускает один block и несколько\nстрок подготовки, сохраняя все применимые gates. New evidence/failure/scope change\nтребуют пересмотреть затронутую часть плана до зависимого продолжения.\n\nПеред реализацией сформировать packet:')
replace(p,'7. Discrete plan, полезные skills/tools/agents, evidence strategy и stop conditions.','7. Reviewed discrete plan: dependencies, output/paths, completion criterion и verification\n   для каждого block; полезные skills/tools/agents, evidence strategy и stop conditions.')
replace(p,'- [x] Change contract, discrete plan, permissions и verification mapping.','- [x] Change contract, discrete plan, permissions и verification mapping для BG-T01.\n- [ ] R19: применить обязательный analysis/approaches/decomposition/plan-review cycle\n  к новой задаче, проверить small/non-trivial cases и replan по фактической evidence.')
replace(p,'- [ ] User выбирает/разрешает два проекта: существующий и иной/new или multi-target.','- [ ] Агент выбирает два проекта в явно делегированном pilot scope пользователя:\n  существующий и иной/new или multi-target; записать exact identities и owned adoption diff.\n- [ ] R20: до каждого pilot scenario определить system question, минимальный scope,\n  ending event и exit criterion; не превращать его в app-development backlog.')
replace(p,'- [ ] Сопоставить R01–R18 с фактическими receipts; открыть remaining gaps.','- [ ] Сопоставить R01–R20 с фактическими receipts; открыть remaining gaps.')
with p.open('a') as f:f.write('''

## User requirement/authority update — 2026-10-03

R19/R20 добавлены текущим запросом пользователя; прежние R01–R18 сохранены.
Mandatory task cycle реализован в existing workflow Section4A; реализация документа
не доказывает observed acceptance нового цикла. Каждый block проверяется против
своего contract; полный результат — против исходной цели и complete owned diff.
Для meaningful вариантов по-прежнему нужны suitability/minuses/recommendation и
выбор пользователя; routine code writes в согласованной задаче повторно не спрашивать.

User явно разрешил выбирать/использовать любые доступные проекты как пилоты по
усмотрению агента внутри .zenflow. Это покрывает scoped intake и reviewed owned
memory/entrypoint association для выбранного pilot; отдельный вопрос на регистрацию
Tchop больше не нужен. Это task delegation, не reusable blanket permission и не grant
на Library ON/transition, tests/test changes, builds/Simulator/Instruments, agents/MCP,
host/secrets, внешние действия или client Git. Предыдущие два build grants использованы.
Пилот обязан иметь system question, границы и exit criterion; unrelated app development
отдельно. Приоритет — завершить общую основу; prepared Tchop proposal отложен по
порядку работ, не из-за отсутствия apply authority. Перед later apply сверить before
hashes/actual dirty state; не replay старый patch автоматически.
''')
# Replace only current checkpoint claims; keep historical authority/results intact.
for root in [v/'tasks/new-task-be0b',t]:
 h=root/'handoff.md';s=h.read_text();limit=s.index('**перечитать весь актуальный набор документации')
 first=s[:limit]
 first=first.replace('exact three-file apply choice pending; no registration/ON/source task/runtime inferred.','pilot selection/use/owned registration delegated by current user; proposal strategically deferred. No ON/source task/runtime inferred.')
 first=first.replace('Tchop structural proposal prepared locally; exact three-file apply decision pending,\nno registration/ON/Tchop source task/runtime. Publish current docs after quality gates;','Tchop structural proposal prepared locally; pilot selection/use/owned registration now delegated,\nproposal strategically deferred while closing general mechanisms. No ON/Tchop source task/runtime;')
 first=first.replace('Next: publish refreshed build evidence; await manual interaction and Tchop apply decisions.','Next: finish common task-cycle/permission/evidence mechanisms, then bounded canaries; manual BG interaction remains pending.')
 first+='R19: every task uses analysis, meaningful alternatives/user choice, contract/plan, decomposition, pre-change plan review, block/final verification and affected memory refresh. R20: pilots answer system questions with bounded scope/exit criteria; unrelated app development separate.\n\n'
 h.write_text(first+s[limit:])
 pl=root/'plan.md';s=pl.read_text()
 if root==t:
  s=s.replace('Tchop structural intake/proposal подготовлены; регистрация и S11 acceptance pending.','User делегировал выбор/использование/owned регистрацию пилотов; Tchop proposal\nотложен до общей основы, authority не блокирует. S11 acceptance pending.',1)
  marker='- [ ] User-owned interaction/VoiceOver acceptance; BG-A01 остаётся OPEN.'
 else:
  s=s.replace('- [ ] Exact Tchop proposal apply decision; S11/S12 end-to-end/release incomplete.','- [ ] Deferred Tchop apply under delegated pilot authority; S11/S12 end-to-end/release incomplete.',1)
  marker='- [ ] Manual interaction/VoiceOver acceptance; BG-A01 OPEN, LIB-004 OPEN.'
 s=s.replace(marker,marker+'\n- [x] R19/R20: mandatory proportional task cycle and bounded-pilot contract added.\n- [ ] Observed acceptance нового цикла/общих gaps перед расширенным pilot.',1)
 pl.write_text(s)
print('Task cycle and bounded delegated pilot scope updated; no pilot/app/runtime change')
