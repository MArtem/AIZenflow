from pathlib import Path
import json,hashlib
v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault');w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');r=w/'.zenflow/tasks/new-task-be0b/bg-t01-verification'
h=hashlib.sha256((w/'BattleshipGame/BattleshipGameUITests/BoardInteractionTests.swift').read_bytes()).hexdigest()
rows=[]
for k in ('iphone-18-2','iphone-27-0'):
 o=r/'large-text-isolated'/k;j=json.loads((o/'result.json').read_text());s=json.loads((o/'summary.json').read_text());assert j['exit_code']==0 and j['inputs_unchanged'] and s['passedTests']==5 and not s['failedTests'];rows.append((k,j['elapsed_seconds']))
receipt=v/'apps/BattleshipGame/history/bg-t01-verification-2026-10-04.md'
s=receipt.read_text();s=s.replace('Current UI test source SHA-256 `928880','Prior nominal/combined-AX5 UI test source SHA-256 `928880')
s=s.replace('Expanded AX5 audit on iOS27 needs a bounded follow-up decision after its observed\ntimeout; do not repeat it unchanged or call it PASS. Next necessary human action: actual\nVoiceOver coordinate traversal/actions and supported\nlive iPad resizing; record environment/results. W4 also needs a legitimate accepted shared\nconsumer task; no artificial product feature or paused Tchop backlog was developed.','The preceding checkpoint retained expanded-AX5/manual gaps. Its next-step requirements\nare superseded by the user-approved global scope and isolated follow-up below. The\noriginal failed/interrupted attempts and results are not rewritten.')
s+="""

## Global user scope and isolated AX5 follow-up

User2026-10-04 first excluded iPad/physical checks temporarily, then explicitly applied
the rule to **every project and task**. Canonical
[USER.VERIFICATION.SCOPE v1.0](../../../reusable/baseline/docs/CURRENT_USER_OVERRIDES.md#verification-and-quality)
removes all iPad checks and every physical-device check, including actual VoiceOver,
from plans and prerequisites. Historical results retained; omission is never PASS.
App support/accessibility implementation requirements remain. No app release claim.

One non-shipping test-file patch split four audit types into separately named tests
and extracted the unchanged Rotate/vertical-placement/reset assertions. The original
combined method still exists; no failed test/assertion was removed or relaxed. Separate
launch per audit isolates framework state; each audit remains an actual system call.
The fifth test verifies Rotate→Vertical, row6/column10 through row10/column10 placement
and reset at AX5. Existing gameplay/corner/duplicate/rotation/native results remain
valid only at their exact unchanged method/source inputs. New UI source SHA-256: `""" +h+"""`.
Project/scheme and all three shipping sources unchanged; preserved original root
AGENTS prefix, nested overlay, foreign roadmap and34 payload hashes. Library ON/AUTO
observation reused at unchanged handler; no transition, agent/MCP or client Git.

| New attempt | Exit | Passed/failed | Wall time |
|---|---:|---:|---:|
"""
for k,elapsed in rows:s+=f'| `large-text-isolated/{k}` | 0 | 5/0 | {elapsed}s |\n'
s+="""
Exact command and input identities: each invocation.json. Xcode test timeouts enabled,
default60s/maximum90s per test; runner wall bound360s; serial owned iPhoneSE3 Simulator,
Xcode27.0/27A266a and Simulator27.0 SDK, runtime18.2 or27.0. Output/cache/DerivedData
and receipts remain under the active task root. Result.json confirms inputs unchanged;
xcresult summary confirms five passed, zero failed/skipped/expected failures. AX5 was
observed before execution, original `large` setting restored and owned Simulator
shutdown exit0 after each run; no iPad action occurred in this follow-up.

This supplies independent hit-region/description/text-clipping/Dynamic-Type outcomes
and Rotate/placement for both mandatory iPhone runtimes. The original combined iOS27
600s timeout still happened and its cause is unknown; separate five-test PASS does not
claim that original combined execution passed or prove absence of flakiness. No repeated
unchanged run, performance certification, actual VoiceOver or hardware evidence claimed.

BG-A01 geometry/interaction remediation is CLOSED_SCOPED for selected iPhone Simulator
acceptance with explicit user omissions; app release remains unverified. W3 accepted
in this revised scope, LIB-004 OPEN. W4 still needs a real accepted shared-source task
and complete mode controls; historical handler regressions are supporting evidence only.
"""
receipt.write_text(s)
card=v/'apps/BattleshipGame/TASK_BG_T01.md';s=card.read_text()
s=s.replace('Status AUTOMATED_SCENARIOS_OBSERVED_SIMULATOR_GAP_OPEN;','Status ACCEPTED_IN_SELECTED_IPHONE_SIMULATOR_SCOPE;').replace('Trigger [BG-A01 P2 OPEN]','Trigger [BG-A01 P2 CLOSED_SCOPED]')
a=s.index('AX5 iPhone18 PASS:');b=s.index('Exact commands/harness',a)
s=s[:a]+"""AX5 full combined scenario PASS on iPhone18. Original combined iPhone27 run timed
out600s with unreadable xcresult; retained, cause unknown. Smaller AX5 gameplay PASS
on27 was separate evidence. New isolated follow-up: four separately named audit
types (hit region, description, text clipping, Dynamic Type) plus Rotate/vertical
placement/reset **5/5 PASS on both iPhone18.2 and27**, at the same new test-source
hash. No shipping change or relaxed assertion. Text size restored, owned phones shutdown.
No claim that the original combined timeout itself passed or that flakiness is absent.
All iPad and physical-device checks, including actual VoiceOver, are removed from plans
by global USER.VERIFICATION.SCOPE, omitted/unverified, never PASS. BG-A01 geometry/
interaction CLOSED_SCOPED; W3 accepted within selected Simulator scope; LIB-004 OPEN.
No app/full-system/Library release claim.

"""+s[b:]
s=s.replace('- [ ] Expanded AX5 audit/Rotate on iPhone27:600s timeout; root cause unverified.','- [x] Isolated expanded AX5 audit types/Rotate on both iPhone runtimes:5/5 each;\n  original combined27 timeout retained, root cause unknown.')
s=s.replace('- [ ] BG-A01 closure/full W3 acceptance only from sufficient remaining evidence.','- [x] BG-A01 CLOSED_SCOPED and W3 selected-scope acceptance with global user omissions.')
a=s.index('Next safe step:');b=s.index('Existing labels/localization',a)
s=s[:a]+'Next system step: W4 legitimate shared-consumer task and mode-control choices. '+s[b:]
card.write_text(s)
p=v/'apps/BattleshipGame/PROJECT_CONTEXT.md';s=p.read_text().replace('Static coverage and OPEN BG-A01 P2','Static coverage and CLOSED_SCOPED BG-A01 P2')
a=s.index('Current automated matrix');b=s.index('Refresh affected records',a)
s=s[:a]+"""Current [BG-T01 card](TASK_BG_T01.md) and [verification receipt](history/bg-t01-verification-2026-10-04.md):
nominal iPhone18.2/27 scenarios and AX5 gameplay observed; isolated four audit types
plus Rotate/placement5/5 PASS per version. Original combined27 timeout retained,
cause unknown. Native12/12 reused. Original compile receipt is historical at its
project/scheme hashes; current non-shipping UI target separately recorded.
Global USER.VERIFICATION.SCOPE removes all iPad/physical-device checks, including
actual VoiceOver, from plans; no verified coverage inferred. BG-A01 CLOSED_SCOPED
for selected Simulator geometry/interaction acceptance; LIB-004 OPEN. No release claim.
Next safe system action: W4 real shared-consumer task/mode controls; no app backlog.

"""+s[b:];p.write_text(s)
p=v/'apps/BattleshipGame/AUDIT_LEDGER.md';s=p.read_text().replace('decision OPEN (runtime acceptance pending) after BG-T01 code change.','decision CLOSED_SCOPED after BG-T01 selected iPhone Simulator acceptance and explicit global user omissions.')
s=s.replace('expanded AX5 audit27 timed out; iPad/physical assistive checks now omitted by user USER.VERIFICATION.SCOPE.','original combined AX5 audit27 timed out; isolated four audit types plus Rotate/placement now5/5 PASS on both phones. All iPad/physical checks omitted by global user rule.')
s=s.replace('BG-A01 remains open for\ninteraction acceptance; no app local/merge/release PASS or system end-to-end claim.','BG-A01 is CLOSED_SCOPED for selected iPhone Simulator interaction acceptance below;\nno app release or whole-system readiness claim.')
a=s.index('BG-A01 remains P2 OPEN pending bounded');s=s[:a]+"""Global [USER.VERIFICATION.SCOPE](../../reusable/baseline/docs/CURRENT_USER_OVERRIDES.md#verification-and-quality) removes all iPad/physical checks, including actual VoiceOver,
from every project/task plan. Follow-up isolated audit types and Rotate/placement
5/5 PASS on each iPhone runtime, same new harness, shipping source unchanged.
BG-A01 P2 CLOSED_SCOPED for corrected minimum44pt geometry and selected iPhone
interaction. Omitted hardware/iPad/assistive behavior remains unverified; original
combined27 timeout remains historical, root cause unknown. No app release claim.
Library LIB-004 remains OPEN.
""";p.write_text(s)
p=v/'apps/BattleshipGame/PROJECT_MAP.md';s=p.read_text();s+=f'\nCurrent isolated follow-up UI test SHA-256 `{h}`: four separate AX5 audits and\nRotate/placement5/5 per iPhone18.2/27. Shipping hashes/project/scheme unchanged.\nAll iPad/physical checks removed from plans by global user rule; retained history is\nnot new execution or hardware/actual VoiceOver proof.\n';p.write_text(s)
main=v/'tasks/new-task-be0b/ios-project-work-system-plan.md';s=main.read_text();s=s.replace('iPad/physical VoiceOver excluded by user; expanded AX5 audit27 and full acceptance unverified;\nBG-A01 OPEN.','all iPad/physical checks excluded globally by user; isolated AX5 audits/Rotate5/5 on each iPhone runtime;\nBG-A01 CLOSED_SCOPED, W3 accepted in selected Simulator scope.')
s=s.replace('| [ ] W3.3.c |','| [x] W3.3.c |')
a=s.index('Native12/12 and nominal iPhone/iPad18.2/27 observations;');b=s.index('W3.4.b observed',a)
s=s[:a]+"""Native12/12 and nominal iPhone18.2/27 plus AX5 gameplay observed. Prior iPad
results remain history; all iPad/physical checks removed globally by user. Original
combined AX5 audit27 timeout600s retained, cause unknown. Isolated four audits plus
Rotate/vertical-placement/reset5/5 PASS per iPhone runtime at one new harness hash;
no assertion weakened/shipping patch. Settings restored; owned phones shutdown.
Shipping/foreign/payload unchanged. BG-A01 CLOSED_SCOPED for selected geometry/
interaction acceptance, LIB-004 OPEN. W3 full workflow accepted in this revised scope;
no app release/full-system/library uplift assertion.

"""+s[b:]
s=s.replace('| [ ] W4.4.a |','| [x] W4.4.a |').replace('| [ ] W4.4.b |','| [x] W4.4.b |').replace('| [ ] W4.5.a |','| [x] W4.5.a |')
s=s.replace('actual OFF/ADVISORY/invalid/ambiguity/freshness/conflict\ncanaries remain open. Current doc task does not substitute for those requirements.','actual complete OFF/ADVISORY/invalid/ambiguity controls remain open. Current doc task\ndoes not substitute for those requirements.\n\nW4.4.a observed: actual BG test-target/source changes invalidated empty-Testables and\nold UI harness evidence; project/context and separately hashed follow-up refreshed,\nunchanged shipping/model/native/payload evidence reused. W4.4.b observed: preserve\noriginal root AGENTS prefix, nested overlay, foreign roadmap and34 payload hashes;\nnew user global scope supersedes contradictory old manual gates, historical failures/\nresults retained rather than rewritten. W4.5.a decision: agents/MCP and independent\nreview remain forbidden; explicit self-review only, no high-risk app shipping/irreversible\naction performed. Independent review is unperformed, never inferred.\nHistorical corrected-handler absent/invalid/FIFO/lock/disabled-recovery checks at exact\nSHA6d4f7cce... are reused from the library receipt only within handler scope; they do\nnot prove full project workflow OFF/ADVISORY/ambiguous/shared-consumer scenarios.')
s=s.replace('Current next safe step: bounded iPhone27 expanded-AX5 timeout diagnosis, then legitimate\nshared-consumer task/current choices. iPad/physical checks are omitted by user; no synthetic\nproduct feature or live mode transition.','Current next decision: select a legitimate existing shared-consumer task for W4 and\nresolve permitted mode-control evidence, or explicitly accept a narrower system verdict.\nNo artificial product feature/live Library transition; all iPad/physical checks removed globally.')
main.write_text(s)
# Compact durable task pointers avoid repeated historical matrices.
authority="""System implementation/pilot selection/owned registration/source edits in accepted tasks
authorized; meaningful approaches need user choice. BG-T01 test changes/builds/tests/
necessary Simulator QA delegated; iPhone Simulator iOS18.2+27 required for this task.
Global [USER.VERIFICATION.SCOPE](../../reusable/baseline/docs/CURRENT_USER_OVERRIDES.md#verification-and-quality) removes all iPad/physical checks, including actual VoiceOver,
from every project/task plan and gate; exclusions never PASS. Necessary Simulator-only
operations may be outside .zenflow; project artifacts/caches/DerivedData/logs inside,
shell login:false. No agents/MCP/Library transitions/installers/host/config/secrets/
automations/client or engine Git. Canonical documentation Git authorized after gates.
Two original build grants consumed; current QA uses newer delegation.
"""
plan="""# Current execution — основной план B

Task new-task-be0b; active knowledge-base-next; GPT-6.1 Sol/high, эконом.
Main plan: [main plan](ios-project-work-system-plan.md). W1/W2 complete, W3 accepted
in selected iPhone Simulator scope; W4 partial, W5 OPEN. No background runtime job.

"""+authority+"""
- [x] Save promoted global verification scope; supersede temporary NT-BE0B-QA-01.
- [x] W3 actual fresh-chat scope recovery, source/consumer review and selected QA.
- [x] Native12/12; nominal iPhone18.2/27; AX5 gameplay and isolated audits/Rotate5/5 each.
- [x] Preserve failures/interruption/combined27 timeout; no original timeout PASS claimed.
- [x] BG-A01 CLOSED_SCOPED; W3 selected-scope receipt and memory refresh.
- [x] W4 structural map/association, freshness, foreign/conflict preservation,
  partial/interrupted recovery, detach dry-run and independent-review decision.
- [ ] W4 real accepted shared-consumer task plus complete mode-control evidence.
- [ ] W5 final traceability/independent system-library-app verdict and bounded adoption.

Current [BG-T01](../../apps/BattleshipGame/TASK_BG_T01.md) / [receipt](../../apps/BattleshipGame/history/bg-t01-verification-2026-10-04.md).
BG shipping hashes/payload/foreign edits preserved; client changes uncommitted.
Owned text settings restored/phones shutdown. Original combined27 timeout cause unknown;
isolated audit PASS covers selected checks without rewriting that failure. LIB-004 OPEN.
Tchop Library unverified, never inherits BG ON/AUTO; paused app follow-ups unchanged.

Next necessary decision: a real existing shared-consumer task for W4, with permitted
mode-control observation, or explicitly narrower system adoption. Do not invent a
product feature, run prohibited transitions/agents or reinstate omitted device gates.
Canonical publish only after exact final-diff/static/remote gates; no client Git.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
"""
handoff="""# Resume — new-task-be0b

Active `/Users/Artem/.zenflow/worktrees/knowledge-base-next`; GPT-6.1 Sol/high, эконом.
Read canonical bootstrap → baseline/router Level0 → current [main plan](ios-project-work-system-plan.md)/handoff → applicable routes/overlays. Route currently adequate.

"""+authority+"""
W1/W2 complete; W3 accepted with revised iPhone-only verification. W4 structural
Tchop map/owned association complete; W4.4.a/b/c/d observed at documented scope;
W4.5.a independent-review decision explicit (not authorized; self-review only).
W4 actual shared-source task and complete OFF/ADVISORY/UNKNOWN/ambiguous/cross-mode
controls still OPEN. Historical same-handler regression evidence supports only its
exact cases. W5 final system verdict OPEN; LIB-004 P2 OPEN independently.

BG exact selector BattleshipGame/BattleshipGame.xcodeproj, ProjectID
6a655f50-2a48-49df-9b5a-bdff693564de. Client HEAD
b7c48e163d9108d1cc4b123d93456ce8f7628d93, dirty A source plus non-shipping native/UI
verification and target/scheme registration uncommitted. Current hashes/membership
in app [context](../../apps/BattleshipGame/PROJECT_CONTEXT.md)/map. Shipping source,
foreign roadmap, original root AGENTS prefix/nested overlay and34 payload files preserved.
Root gained only owned global-scope pointer. BG handler ON/AUTO observation reused at
unchanged hash; Tchop mode/adoption UNVERIFIED, no reuse/transition.

[BG receipt](../../apps/BattleshipGame/history/bg-t01-verification-2026-10-04.md): native12/12,
nominal iPhone18.2/27, AX5 gameplay and isolated four audit types+Rotate/placement5/5
per version. Original combined27 timeout600s retained, cause unknown; no original
combined PASS/flakiness guarantee. All iPad/physical/manualVoiceOver checks removed
from plans globally by user; historical observations retained, exclusions not PASS.
BG-A01 CLOSED_SCOPED, no app release. Owned text settings restored/phones shutdown;
no runtime job. Raw products/failures/receipts remain under active task bg-t01-verification/.
Canonical exact-SHA receipts stay outside tracked content.

Next decision: real existing shared-consumer task and permissible mode-control evidence,
or explicitly narrowed system verdict. Keep paused app follow-ups/old checkout/
installation branch and foreign content. No artificial feature or prohibited action.
Global rule change is authorized promotion, no temporary task-only limit remains.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
"""
for name,s in [('plan.md',plan),('handoff.md',handoff)]:
 (v/'tasks/new-task-be0b'/name).write_text(s)
 local=s.replace('(ios-project-work-system-plan.md)','(/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b/ios-project-work-system-plan.md)').replace('(../../apps/BattleshipGame/','(/Users/Artem/.zenflow/worktrees/documentation-vault/apps/BattleshipGame/').replace('(../../reusable/baseline/','(/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/')
 (w/'.zenflow/tasks/new-task-be0b'/name).write_text(local)
state={'state':'awaiting-w4-real-task-or-explicit-bounded-verdict','global_scope':'USER.VERIFICATION.SCOPE v1.0 all projects/tasks no iPad/physical','W3':'accepted selected iPhone Simulator scope','BG-A01':'CLOSED_SCOPED','LIB-004':'OPEN','source_ui_sha256':h,'isolated_results':[{'device':k,'passed':5,'failed':0,'elapsed_seconds':sec} for k,sec in rows],'original_combined27_timeout':'retained/root cause unknown; not PASS','next':'real shared-consumer task/mode-control choices','runtime':'none; owned settings restored/simulators shutdown'}
(r/'resume-state.json').write_text(json.dumps(state,indent=2)+'\n')
print('W3 selected-scope acceptance and W4 actual observations synchronized; next genuine shared-task/mode decision explicit.')
