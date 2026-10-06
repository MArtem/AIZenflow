from pathlib import Path
v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
t=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next/.zenflow/tasks/new-task-be0b')
def replace(p,old,new):
 s=p.read_text();assert old in s,(p,old);p.write_text(s.replace(old,new,1))
w=v/'reusable/baseline/docs/IOS_PROJECT_WORK_SYSTEM.md'
replace(w,'| Review the plan before changes | Check requirement coverage, dependency/order correctness, source/consumer agreement, failure and rollback implications, verification sufficiency and permission/resource limits.','| Review the plan before changes | Present the verification menu below after initial analysis and before implementation; resolve the user selection. Check requirement coverage, dependency/order correctness, source/consumer agreement, failure and rollback implications, verification sufficiency and permission/resource limits.')
menu='''### Verification menu before implementation

After the initial analysis of every task and before implementing it, present a compact
verification plan for the user's choice. Reuse the task packet/action table; do not hide
testing decisions inside the implementation plan or add a separate verification service.
Show these actions independently, including an explicit reason when not applicable:

| Proposed action | What the plan must specify |
|---|---|
| Write new tests | Invariants/regression scenarios, appropriate layer, exact affected test scope; value, effort and limits. This is separate from running those tests. |
| Modify existing tests | Why existing coverage needs a change, affected tests and regression risk; no automatic rewrites or removal to obtain PASS. |
| Build / compile | Exact target/configuration/destination, question answered, output/cache roots and bounds. Compilation alone does not verify feature interaction. |
| Run tests | Relevant existing/new suites and target/destination, prerequisites, deterministic scenarios and evidence; no full-suite expansion by default. |
| Verify feature on Simulator | Concrete user flows, positive/failure/boundary cases, UI/state/accessibility assertions appropriate to the feature; selected environment and manual/agent operator. |
| Verify feature on device | Why device-specific evidence matters, available device/environment/operator and scenario; cannot silently substitute Simulator results. |
| Static / other necessary checks | Complete diff/consumer/contract review and relevant static checks; additional runtime/performance/release actions only for a concrete uncertainty. |

For each action give purpose, applicability, qualitative effort/side effects, prerequisites,
benefits/limitations, recommendation and smallest adequate alternative. Keep the menu
brief for a small task; mark an irrelevant action not-applicable with a factual reason
rather than proposing ritual tests or device runs for a documentation edit. Identify
which evidence is needed for each intended completion claim and the residual risk if
omitted. Do not promise all checks or declare the feature tested from one passing layer.

The user chooses the actions to execute before implementation, unless an actual current
instruction already selects them within the exact task scope. A proposed/recommended
item is not selected, permitted, written or executed. Unresolved selection requires a
question before dependent implementation; continue independent authorized work. Record
the actual choice in the existing packet/plan, including delegated decisions and action
limits. Then independently resolve execution authority for test writing/modification,
builds, test runs, Simulator/device access and the operator. No default approval from
silence, tool availability, project source-write or pilot-selection permission.

A user-omitted check stays omitted/unverified in the final report. If this leaves a
required acceptance gate unmet, explain the limited readiness and necessary evidence;
do not turn the selection into a waiver or a false completion claim. New implementation
facts that change the relevant verification scope require a revised proposal/choice.
Existing engine/profile and evidence contracts still own execution and observed results.

'''
s=w.read_text();marker='The first layer produces a provisional result for each applicable step';assert '### Verification menu before implementation' not in s;s=s.replace(marker,menu+marker,1);w.write_text(s)
p=v/'tasks/new-task-be0b/ios-project-work-system-plan.md'
replace(p,'| R20 | Держать пилот в пределах проверки системы | У сценария названы system question, границы и exit criterion; посторонние app findings остаются в ledger, развитие приложения вынесено отдельно |','| R20 | Держать пилот в пределах проверки системы | У сценария названы system question, границы и exit criterion; посторонние app findings остаются в ledger, развитие приложения вынесено отдельно |\n| R21 | После первичного анализа до реализации дать план тестов и проверки фичи для выбора пользователя | Отдельно предложены написание/изменение тестов, сборка, прогон тестов, Simulator и device; purpose/benefit/limits/recommendation, applicability и выбранные действия записаны, permission/execution не подразумеваются |')
replace(p,'review плана до изменений → ограниченные blocks с проверками →','план проверок для user choice → review плана до изменений → ограниченные blocks с проверками →')
replace(p,'- [ ] R19: применить обязательный analysis/approaches/decomposition/plan-review cycle\n  к новой задаче, проверить small/non-trivial cases и replan по фактической evidence.','- [ ] R19/R21: применить analysis/approaches/decomposition/verification-menu/user-choice/plan-review\n  к новой задаче; проверить small/non-trivial cases и replan по фактической evidence.')
replace(p,'- [ ] Сопоставить R01–R20 с фактическими receipts; открыть remaining gaps.','- [ ] Сопоставить R01–R21 с фактическими receipts; открыть remaining gaps.')
replace(p,'R19/R20 добавлены текущим запросом пользователя; прежние R01–R18 сохранены.','R19/R20/R21 добавлены текущими запросами пользователя; прежние R01–R18 сохранены.')
with p.open('a') as f:f.write('''

R21 уточняет обязательный pre-implementation plan: после первичного анализа показать
написание новых/изменение existing tests, build, test run, feature verification на
Simulator и device отдельными действиями, с rationale/recommendation/limits и явной
неприменимостью где нужно. Пользователь выбирает фактические действия до реализации;
предложение не даёт разрешения. Current exact grants можно переиспользовать только
в их границах; все непройденные checks и зависимые acceptance gaps сохраняются явно.
Текущий documentation block: нужны static diff/links/route/governance checks; app-test
creation/run и Simulator/device feature checks не применимы. Никаких новых tests/runtime
разрешений из требования составлять план не получено. Operational menu — Section4A.
''')
for root in [v/'tasks/new-task-be0b',t]:
 h=root/'handoff.md';s=h.read_text();marker='R20: pilots answer system questions with bounded scope/exit criteria; unrelated app development separate.'
 replace(h,marker,marker+' R21: after initial analysis and before implementation present independent test-writing/modification/build/test-run/Simulator/device/static actions for user choice; no execution grant from proposing them.')
 p=root/'plan.md';replace(p,'- [x] R19/R20: mandatory proportional task cycle and bounded-pilot contract added.','- [x] R19/R20/R21: proportional task cycle, bounded pilots and pre-implementation\n  test/feature verification menu with explicit user selection added.')
print('R21 verification choice integrated; no tests/runtime grant or execution')
