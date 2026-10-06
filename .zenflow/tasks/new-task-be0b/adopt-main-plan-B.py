from pathlib import Path
import hashlib,json,subprocess
v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault');t=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next/.zenflow/tasks/new-task-be0b');ct=v/'tasks/new-task-be0b'
assert subprocess.check_output(['git','-C',str(v),'rev-parse','HEAD'],text=True).strip()=='c6e8111093aafa7debc96334c3b60c78f3b33802'
assert not subprocess.check_output(['git','-C',str(v),'status','--porcelain'],text=True).strip()
archive=ct/'archive/main-plan-B-before';assert not archive.exists();archive.mkdir(parents=True)
records={}
for label,p in [('canonical-main-plan',ct/'ios-project-work-system-plan.md'),('canonical-plan',ct/'plan.md'),('canonical-handoff',ct/'handoff.md'),('active-plan',t/'plan.md'),('active-handoff',t/'handoff.md')]:
 data=p.read_bytes();dst=archive/(label+'.md');dst.write_bytes(data)
 records[label]={'source':str(p),'archive':str(dst.relative_to(v)),'sha256':hashlib.sha256(data).hexdigest()}
 assert dst.read_bytes()==data
for label in ['active-plan','active-handoff']:
 dst=t/'archive/main-plan-B-before'/f'{label}.md';dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes((archive/(label+'.md')).read_bytes())
(archive/'IDENTITIES.json').write_text(json.dumps({'trusted_base':'c6e8111093aafa7debc96334c3b60c78f3b33802','purpose':'Exact recovery before user-approved variant B; not current authority','snapshots':records},ensure_ascii=False,indent=2)+'\n')
old=(ct/'ios-project-work-system-plan.md').read_text();design=old[old.index('## 1. Цель'):old.index('## 13. Дискретная')]
design=design.replace('как ограниченную основу, не стабильный проверенный verifier. Его actual repository,\nсхемы, CLI, зрелость и пригодность для нового сценария ещё надо обследовать read-only.','как ограниченную основу, не стабильный проверенный verifier. S1 уже обследовал exact\nlocal revision, schemas/CLI/boundaries read-only; [S0/S1 evidence](ios-project-work-system-s0-s1.md).\nЭто не current remote maturity или release validation; повторять только affected changes.')
a=design.index('Недостаёт единого проектного lifecycle');b=design.index('## 3. Пользовательские')
design=design[:a]+'''Identity/memory/task-cycle contracts реализованы в canonical workflow/template.\nОстаются observed integration acceptance, modes/freshness/recovery и реальные canaries;\nналичие документов не доказывает эти outcomes.\n\nS0/S1 policy seams решены в recorded scope: owned DEFERRED вместо silent QC/CI adoption;\nscope-appropriate analysis вместо обязательного whole-project audit любой task;\nexisting evidence vocabulary вместо нового evaluator; inactive library candidate\nне становится approved payload. Новые conflicts требуют source/authority review.\n\n'''+design[b:]
header='''# Система работы над iOS-проектами — основной план B

Принят пользователем после review структуры: сохранить S0–S12, перегруппировать
оставшуюся реализацию в W1–W5, каждый leaf имеет output/check/exit criterion.
Task new-task-be0b; active `/Users/Artem/.zenflow/worktrees/knowledge-base-next`.
GPT-6.1 Sol/high, режим эконом; scoped user override until changed. MODEL_ROUTING_RULE
перед каждым meaningful block. Один integrator, никакой независимый review по умолчанию.

Это единственный основной design/execution plan. Текущие checklist/handoff — pointers;
[точное предыдущее состояние](archive/main-plan-B-before/canonical-main-plan.md) и
[identities всех five snapshots](archive/main-plan-B-before/IDENTITIES.json) сохранены.
Accepted review: separate implementation/acceptance; R→evidence→gap matrix; correct
stage dependencies; one current state; compact task card; user-selectable check plan;
finite acceptance matrix; pilot chosen for missing evidence, not app development.

## Current result and authority

S0–S3 documentary contracts и S4 Battleship association существуют. S5–S8 bounded
outputs существуют; BG-T01 A implemented, static reviewed, exact-input compile PASS
на Xcode27.0/27A266a. Interaction/VoiceOver and full end-to-end acceptance unverified;
BG-A01 OPEN. LIB-004 P2/OPEN for general library release. W1–W5 checklist ниже не
переписывает historical receipts и не маркирует whole system ready.

User разрешил implementation системы, project source edits в accepted tasks и
самостоятельный выбор/use/owned registration любых доступных pilots внутри .zenflow.
Meaningful approaches требуют suitability/minuses/recommendation и user choice;
precise chosen verification grants не спрашивать повторно. Tests/test changes,
builds/tests/Simulator/device/Instruments, agents/MCP, Library transitions/ON, external
acts и client/engine Git всё ещё separate authority. Два BG build grants consumed.
Canonical AIZenflowDocumentation commit/push standing-authorized после gates.
No host/config/auth/Keychain/secrets/installers/automations; shell login:false.
Old new-task-be0b checkout/installation branch untouched, foreign edits retained.

## Evidence keys and reuse scope

| Key | Existing source | Scope / limit |
|---|---|---|
| E0 | [S0/S1](ios-project-work-system-s0-s1.md) | Exact local engine inventory/contract review; no executable engine or remote maturity PASS |
| E1 | [Workflow](../../reusable/baseline/docs/IOS_PROJECT_WORK_SYSTEM.md) | Human operational contract incl R19–R21; no parser/automatic enforcement proof |
| E2 | [Memory/card template](../../reusable/baseline/docs/templates/IOS_PROJECT_MEMORY.template.md) | Human projection/adaptation, no instantiated acceptance from template alone |
| E3 | [S4–S7](ios-project-work-system-s4-s7.md), [intake](ios-project-work-system-s4-intake.md) | Approved exact Battleship identity/apply/post-check/static scope |
| E4 | [Map](../../apps/BattleshipGame/PROJECT_MAP.md), [ledger](../../apps/BattleshipGame/AUDIT_LEDGER.md) | Three declared sources/one target, current dirty source hash; no whole-root semantic claim |
| E5 | [BG-T01](../../apps/BattleshipGame/TASK_BG_T01.md), [build receipt](../../apps/BattleshipGame/history/bg-t01-build-2026-10-03.md) | One-file A diff and exact compile PASS; no interaction/VoiceOver/test/release PASS |
| E6 | [Prior library pilot](ios-library-pilot-2026-09-30.md) | Prior exact payload/case evidence only; LIB-004 remains open, no unchanged PASS rerun |

## R01–R21: механизм → evidence → оставшийся gate

Все remaining gates owner integrator unless user action/choice explicitly named.
Строка описывает scoped implementation/evidence, не автоматический readiness verdict.
Revalidate relevant fingerprints/dependencies перед reuse; timestamps alone недостаточны.

| ID | Реализованный механизм / наблюдение | Remaining check/action и leaf |
|---|---|---|
| R01 | E1 exact identity + E3 зарегистрированный Battleship | Other/shared scope identity/graph observation W4.1/W4.2 |
| R02 | E3 read-only intake→reviewed exact apply→post-check | Second pilot ownership/apply, no grant transfer W4.1.b |
| R03 | E4 full static reading of declared3 sources/flows | Shared-target consumer/resource coverage W4.2.a; runtime gaps remain explicit |
| R04 | E4 domain coverage with unverified/not-applicable rows | Task/full-audit boundary W2.3.a; scoped second coverage W4.2.a |
| R05 | E4 grounded BG-A01 and separate hypotheses/questions; A accepted | Keep ranking/dependencies/disposition in selected W3/W4 task; unrelated backlog not executed |
| R06 | E1/E2/E3 app boundaries/provenance and current records | Observed refresh/foreign/conflicting record preservation W4.4.a/b |
| R07 | E5 prepared BG-T01 packet/consumers | Single compact card and new mandatory cycle acceptance W2.1/W3.2/W4.2.b |
| R08 | E3–E5 KB provisional then selected ON pass | Modes/profile/shared scopes W4.3.b/d; no measured uplift claim |
| R09 | E1 complete OFF contract, no ON dependency | Actual KB-only task cycle W4.3.a; unverified until evidence |
| R10 | E5 scoped capability table, withheld agents/runtime | Consolidation/operators W2.1/W2.4; actual adverse disposition W4.4.c |
| R11 | E5 complete owned source/consumer diff reviewed | Shared/resource consumers and final observed change W4.2.c |
| R12 | E5 failed initial build preserved; approved retry exit0, UI gap retained | Remaining named adverse cases W4.4.c, final claims W5.1 |
| R13 | E1 current startup/freshness/handoff rules | Actual resumed-context observation W3.4.b; no compaction/self-review substitute |
| R14 | E1/E3 separate mode/adoption/grants/readiness | One truthful task card/status + mode separation W2.1/W4.3 |
| R15 | E3 exact own addition/detach checks; existing dirty edits retained | W1 snapshots/static check, W4.4.b/d observed preservation |
| R16 | E4 declared single-target membership | Shared/resource graph W4.2.a/c; Figma/packages/specialist scenarios have separate declared acceptance gaps |
| R17 | E0/E1 targeted routing/evidence reuse, unknown telemetry | Compact card/invalidation W2.1/W2.3.b/W4.4.a; no savings assertion |
| R18 | E3 own-entry removalability checked read-only | Second scoped detach W4.4.d, not false actual-write claim |
| R19 | E1 mandatory proportional analysis/decomposition/plan review | W2.2.a + actual new task/changed-fact replan W3.2/W4.2 |
| R20 | User delegated pilots; main-plan bounds and exit guard | W2.5 + every W3/W4 scenario exits without unrelated development |
| R21 | E1 independent verification menu/choice/grant/claim limits | Minimum adequate recommendation W2.2; actual user selection and performed/omitted results W3.2.b/W4.2.c |

'''
(ct/'ios-project-work-system-plan.md').write_text(header+design+(t/'main-plan-B-execution-section.md').read_text())
active_plan='''# Current execution — основной план B

Task new-task-be0b; knowledge-base-next; GPT-6.1 Sol/high, эконом.
Main plan: <MAIN>. S0–S12 retained; execution W1→W2→W3/W4→W5.

- [ ] W1: exact recovery snapshots, current contract/permissions/evidence matrix,
  dependency fixes and compact current state; every leaf has output/check/exit criterion.
- [ ] W2: one card, user-selected verification, scoped audit, KB/ON/multi-project,
  environment/recovery/freshness and scope guard; contract evidence separate from acceptance.
- [ ] W3: exact Battleship full cycle/user-owned interaction/new-chat receipt.
- [ ] W4: structurally different/shared-consumer task and mode/freshness/adverse cases.
- [ ] W5: R01–R21 disposition, separate core/library/app verdicts, guide/maintenance/receipt.

Existing scope: S0–S4 documentary/adoption; E3–E5 map/audit/BG-T01 A dirty source,
compile PASS Xcode27.0/27A266a. BG-A01 OPEN for interaction/VoiceOver, LIB-004 OPEN.
Two build grants consumed. User grants system implementation, source changes in accepted
tasks and agent-selected pilot use/owned registration; meaningful approach/check choices
belong to user. No tests/test changes/builds/runtime/agents/MCP/ON/client Git authority
inferred. Canonical Git standing-authorized after gates. .zenflow only, login:false;
old checkout/installation branch/foreign roadmap/source preserved.

Verification menu current W1/W2 docs: static diff/links/R-ID/route/manifest/archive checks
selected by existing scope; app-test writing/run/build/Simulator/device not applicable.
Before subsequent implementation present useful independent checks and record user choice.
Scope guard before/after every block: R-ID/system question → necessary smallest output →
exact bounds/grant → new evidence/exit → next necessary action. No material purpose:
stop expansion, record actual outcome, separate backlog; candidate P0–P2 never waived.

Exact prior local/canonical plan/handoff and old main plan: <ARCHIVE>.
Do not replay their permissions or pending actions. Current publication SHA lives in
separate receipt. Next: finish W1 static gates/publication, then bounded W2 docs block.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
'''
active_handoff='''# Resume — основной план B

Task new-task-be0b, active /Users/Artem/.zenflow/worktrees/knowledge-base-next.
GPT-6.1 Sol/high, эконом; scoped user route until changed. Canonical bootstrap→router
Level0→current plan/handoff→ios-project-work-system/governance + actual subtask only.
Main plan: <MAIN>. User accepted variant B and ordered detailed gates plus implementation.
Current W1 contract/matrix/history/current-state work; W2 common mechanisms next,
W3/W4 bounded canaries then W5 separate verdicts. No full system PASS.

Source BG-T01 A remains uncommitted: d9134483db19a9d1e7e8edcca42f06120f66bb410c2cea124b86700146b010c1.
Exact Debug generic Simulator SDK compile PASS Xcode27.0/27A266a, initial sandbox failed
and separately approved repeat succeeded. Both grants consumed. BG-A01 OPEN pending
interaction/VoiceOver; LIB-004 OPEN. Tchop structural proposal prepared, delegated
pilot association allowed, strategically deferred; no inherited ON/source task/runtime.

Current grants: system implementation and project code within accepted task, pilot
selection/use/owned registration, canonical AIZenflowDocumentation commit/push after gates.
Meaningful approaches and independent test-writing/modification/build/test/Simulator/
device checks presented before implementation for user choice. Selection of exact action
is grant, no repeated approval. New tests/runtime/Library transitions/agents/MCP/external
acts/client or engine Git require current separate scope; none authorized by this plan.
No host/config/auth/Keychain/secrets/installers/background work; .zenflow only, login:false.
Old new-task-be0b checkout/installation branch untouched. Foreign roadmap/source edits
retained; exact old plan/handoff preserved under <ARCHIVE>, non-authoritative.

Per-block guard: R-ID/question, concrete need/reuse, bounds/grant, new evidence/exit,
post-block consistency/necessary next action. Stop scope expansion or repeating work,
not independent permitted progress; candidate P0–P2 require fix/explicit exception.
Current docs checks static; no app tests/runtime. Publication receipts stay outside
reviewed content. Next: W1 gates/publication → W2 card/freshness/recovery/guard integration.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
'''
for root in [ct,t]:
 main='[main plan](ios-project-work-system-plan.md)' if root==ct else '`/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b/ios-project-work-system-plan.md`'
 arch='[exact history](archive/main-plan-B-before/IDENTITIES.json)' if root==ct else '`/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b/archive/main-plan-B-before/IDENTITIES.json` (local active snapshots also under archive/main-plan-B-before)'
 (root/'plan.md').write_text(active_plan.replace('<MAIN>',main).replace('<ARCHIVE>',arch))
 (root/'handoff.md').write_text(active_handoff.replace('<MAIN>',main).replace('<ARCHIVE>',arch))
print('Main B adopted, exact history saved, W1 implementation/matrix/current-state prepared')
