from pathlib import Path
import subprocess
vault=Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
task=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next/.zenflow/tasks/new-task-be0b')
assert subprocess.check_output(['git','-C',str(vault),'rev-parse','HEAD'],text=True).strip()=='e89bd05ab6905a37200aa26f53124b1f8dce255f'
assert not subprocess.check_output(['git','-C',str(vault),'status','--porcelain'],text=True).strip()
# Contract: exact-input compile evidence updates current consumers, not historical
# failure outcomes, continuing grants, runtime readiness, source or Library state.
def replace(path,old,new):
 p=vault/path
 s=p.read_text()
 assert old in s, (path,old)
 p.write_text(s.replace(old,new,1))
app=Path('apps/BattleshipGame')
history=app/'history/bg-t01-build-2026-10-03.md'
(vault/history).parent.mkdir(exist_ok=True)
assert not (vault/history).exists()
(vault/history).write_text((task/'bg-t01-build-receipt.md').read_text())
replace(app/'TASK_BG_T01.md','Status IMPLEMENTED_STATIC_RUNTIME_PENDING;','Status IMPLEMENTED_COMPILE_PASS_INTERACTION_PENDING;')
replace(app/'TASK_BG_T01.md','Runtime/tests/client Git remain separately controlled; no runtime execution grant.','User separately allowed one build and one escalated repeat; both consumed. Compile PASS is in history/bg-t01-build-2026-10-03.md. No tests, Simulator launch/UI, further build or client Git grant.')
replace(app/'TASK_BG_T01.md',"Required user action for acceptance (not performed by agent): compile selected app with\nthe user's toolchain; then verify narrow and wide/resized windows, horizontal/vertical",'Compilation now PASS for exact current inputs on Xcode27.0/27A266a; [build receipt](history/bg-t01-build-2026-10-03.md).\nRequired user action for acceptance (not performed by agent): verify narrow and wide/resized windows, horizontal/vertical')
replace(app/'AUDIT_LEDGER.md','One app, three sources, assets, no package references; toolchain unknown','One app, three sources, assets, no package references; current candidate Debug generic Simulator SDK compile PASS, Xcode27.0/27A266a (receipt below)')
replace(app/'AUDIT_LEDGER.md','CHECKED membership / UNVERIFIED compile','CHECKED membership / COMPILE_PASS scoped')
replace(app/'AUDIT_LEDGER.md','Remaining: compilation and supported-width/assistive interaction acceptance.','Compilation PASS for exact candidate; remaining supported-width/assistive interaction acceptance.')
replace(app/'AUDIT_LEDGER.md','UI assertion, device hit testing, compile or VoiceOver proof.','UI assertion, device hit testing or VoiceOver proof. Exact candidate compile now PASS; [receipt](history/bg-t01-build-2026-10-03.md).')
replace(app/'AUDIT_LEDGER.md','runner/toolchain\nnot adopted or executed; baseline-only static review','QC runner not adopted or executed; Xcode27.0 scoped build executed, baseline-only review')
replace(app/'PROJECT_CONTEXT.md','Config/toolchain requirements changes; installed toolchain remains unknown','Config/toolchain requirements changes; installed Xcode27.0/27A266a observed for BG-T01 build, receipt below')
replace(app/'PROJECT_CONTEXT.md','| Test creation/modification/execution, builds/UI/Simulator/Instruments | Not authorized in system task | not_run |','| Builds | Two exact grants consumed: initial sandbox failure, escalated repeat exit0 | [receipt](history/bg-t01-build-2026-10-03.md); further builds need a new grant |\n| Test creation/modification/execution, UI/Simulator/Instruments | Not authorized in system task | not_run |')
replace(app/'PROJECT_CONTEXT.md','Runtime/build/test/UI/accessibility/performance/release: not_run; no readiness PASS. BG-T01 geometry amended in code; interaction acceptance pending.','Exact BG-T01 Debug generic Simulator SDK compilation PASS, Xcode27.0/27A266a; [receipt](history/bg-t01-build-2026-10-03.md). Test/UI/accessibility/performance/release not_run; no readiness PASS. BG-T01 interaction acceptance pending.')
replace(app/'PROJECT_CONTEXT.md','user-owned compilation/interaction evidence pending','compilation PASS; user-owned interaction evidence pending')
replace(app/'PROJECT_MAP.md','Shared scheme | BuildAction → BattleshipGame | Empty Testables; no build/test success inferred','Shared scheme | BuildAction → BattleshipGame | Empty Testables; current exact candidate build PASS per receipt below; no test success')
with (vault/app/'PROJECT_MAP.md').open('a') as f:f.write('\nCompilation delta: [BG-T01 build receipt](history/bg-t01-build-2026-10-03.md), exact unchanged source hashes, Xcode27.0/27A266a, Debug generic Simulator SDK, exit0. Emitted arm64/x86_64 SwiftFileLists include these three declared sources plus generated asset symbols; no UI/test/release proof or general resource-coverage claim.\n')
plan=Path('tasks/new-task-be0b/ios-project-work-system-plan.md')
replace(plan,'worktree — `knowledge-base-next`, GPT-6 Sol / эконом.','worktree — `knowledge-base-next`, GPT-6.1 Sol/high / эконом. Scoped user override until changed, not global routing-matrix promotion.')
replace(plan,'- [ ] Intent/scope/acceptance clarification и freshness check.','- [x] Intent/scope/acceptance clarification и freshness check для BG-T01 A.')
replace(plan,'Следующее действие пользователя: compile/interaction','Компиляция BG-T01 PASS на exact inputs; следующее действие пользователя: interaction')
with (vault/plan).open('a') as f:f.write('''

## Current model/build checkpoint — 2026-10-03

User selected GPT-6.1 Sol/high, scoped until changed; эконом persists. Targeted
self-review is not independent evidence. One initial build failed nested sandbox;
only after explicit A repeat/escalation grant did the same-source Debug generic
Simulator SDK build exit0 on Xcode27.0/27A266a. Both grants consumed; no tests,
Simulator launch/UI, further build, signing or client Git permission. Receipt:
[BG-T01 compile evidence](../../apps/BattleshipGame/history/bg-t01-build-2026-10-03.md).
BG-A01 remains OPEN for interaction/VoiceOver; LIB-004 OPEN. S8 observed unavailable
execution and separately approved recovery only; denied/timeout/cancelled cases unrun.
S9 mode matrix and S10 full interaction acceptance remain incomplete, not blanket PASS.
Tchop structural second-canary intake/three-file proposal prepared locally, apply pending;
no S11 completion or inherited ON. Historical no-build/model text above is superseded
only within these current exact grants; it never permits their replay.
''')
state=Path('tasks/new-task-be0b/handoff.md')
s=(vault/state).read_text();end=s.index('# S8 documentary continuation')
(vault/state).write_text('''# Current checkpoint — BG-T01 compile PASS, interaction pending — 2026-10-03

Active knowledge-base-next; Task new-task-be0b. GPT-6.1 Sol/high, эконом,
scoped user override until changed; current MODEL_ROUTING_RULE before each block.
BG-T01 A source hash d9134483db19a9d1e7e8edcca42f06120f66bb410c2cea124b86700146b010c1,
uncommitted in client. Project code edits allowed; compare meaningful alternatives.
Initial build sandbox failed; separately approved escalated same-source repeat exit0,
Xcode27.0/27A266a. Both build grants consumed; exact evidence in
[build receipt](../../apps/BattleshipGame/history/bg-t01-build-2026-10-03.md).
No tests/Simulator/UI/VoiceOver, further build, agents/MCP/host/secrets/client Git.
BG-A01 OPEN for manual interaction; LIB-004 OPEN; S9–S12 not complete.
Tchop structural proposal prepared locally; exact three-file apply decision pending,
no registration/ON/Tchop source task/runtime. Publish current docs after quality gates;
exact-HEAD/remote receipt stays separate. Preserve local task edits and old checkout.
Historical pending-choice/model/no-build text below is superseded only by actual current
human grants, not a permission to replay historical actions.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

'''+s[end:])
state=Path('tasks/new-task-be0b/plan.md')
s=(vault/state).read_text()
(vault/state).write_text('''# Current work-system checkpoint — 2026-10-03

Current task follows [S0–S12 plan](ios-project-work-system-plan.md), active knowledge-base-next.
GPT-6.1 Sol/high, эконом; scoped user selection until changed, global matrix unchanged.

- [x] S0–S4 documentary contracts and Battleship association; S5–S8 bounded outputs.
- [x] BG-T01 A chosen/implemented/static reviewed; unchanged-input compile PASS,
  Xcode27.0/27A266a, after one failure and separately approved repeat.
- [ ] Manual interaction/VoiceOver acceptance; BG-A01 OPEN, LIB-004 OPEN.
- [ ] S8 remaining fault cases, S9 mode matrix, S10 complete acceptance.
- [ ] Exact Tchop proposal apply decision; S11/S12 end-to-end/release incomplete.

Both build grants consumed; no further builds/tests/Simulator/agents/MCP/client Git.
Source edits allowed but compare meaningful alternatives before choosing. Canonical
publication standing-authorized after gates; exact receipt separate. Older engine plan
below is retained history and does not replace current task/model/authority.

'''+s)
print('Updated owned canonical build claims/task state; preserved source and historical sections')
