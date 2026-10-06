from pathlib import Path
import json
v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault');w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');r=w/'.zenflow/tasks/new-task-be0b/tc-w4-localization'
c=json.loads((r/'contract-before.json').read_text());e=json.loads((r/'verification-preservation.json').read_text());m=json.loads((r/'mode-reader-result.json').read_text());app=v/'apps/Tchop'
history=app/'history';history.mkdir(exist_ok=True)
p=history/'tc-w4-01-localization-2026-10-04.md';assert not p.exists()
p.write_text(f"""# TC-W4-01 — shared preview localization receipt

2026-10-04; GPT-6.1 Sol/high, эконом; owner user/integrator, self-review only.
ProjectID7aab0419-fa15-469e-96e7-9b84e21b321a, TchopApp.xcodeproj in active
knowledge-base-next. Client HEAD{c['client_head']}; source dirty/uncommitted.
User selected real W4 task, then «выбери сам» delegated finding/choosing the task.
Current task's self-verification and iPhone18.2/27 instructions applied directly;
no BG memory-derived grant, Library adoption/transition or client Git.

## Contract, actual consumers and finding

Existing AppTab.placeholderDescription calls five tab.*.placeholderDescription keys
absent from both323-key product resource tables; existing translations are named
 tab.*.stubDescription. Producer AppTab → TabStubView → existing pinned TabStubView
preview and mixes StubTabNavigationRootView preview. Main Mixes/Pinned/Chat routes
use FeatureTabNavigationRootView; no authenticated navigation crash claimed.
The initial live-route hypothesis was corrected after actual root inspection.
TC-L01 P3 developer-preview lookup defect, CLOSED_SCOPED after the following evidence.
No new placeholder feature, changed product copy, persistence, async work or fallback.

One shipping file TchopApp/Models/AppTab.swift: exactly five literal key replacements;
property/cases/IDs/navigation unchanged. Consumer fileRefA00000220000000000000001,
buildFileA00000120000000000000001 in both host Sources phases. Exact consumers:
TchopApp/A000000C0000000000000001 and TchopAppOcean/B00000080000000000000001.
Neither widgets nor share consume AppTab; localization resources still belong to all
six shipping targets and were unchanged. Source choice: fix callers to the existing
keys; renaming resource keys would change shared resource API without a need.
Synchronous immutable lookup, five-case input; failure retains existing Debug assertion
and Release raw-key behavior, no suppression/production fallback invented.
Before AppTab SHA-256{c['before_sha256']['TchopApp/Models/AppTab.swift']}.
After SHA-256{e['after_AppTab_sha256']}.
Project and both schemes remain at the structural context hashes.

## Verification and retained failures

One ephemeral Foundation-only Simulator probe compiles actual AppTab, app facade,
LocalizationManager and product bundle provider, Swift6 strict-complete/warnings-as-errors,
iOS17 Simulator deployment target, SDKiPhoneSimulator27.0/Xcode27.0/27A266a.
Its .app bundle contains exact original EN/RU product resources. It compares the actual
property result through the app facade with that language bundle's existing translation,
checks requested process language and fails on mismatch; no copied lookup implementation.
Before: iPhone18.2 EN process exit133, assertion for tab.news.placeholderDescription;
retained exact stderr. This observes property lookup, not rendered preview/whole app.
After:5/5 each EN and RU on iPhone18.2 and27.0,20 actual property assertions, exit0,
empty stderr. Process-specific AppleLanguages/AppleLocale arguments; no Simulator-wide
language/text setting change. Both own iPhone Simulators shutdown in finally, exit0.

Unsigned Debug builds with explicit destinations:

| Scheme/destination | Exit | Elapsed |
|---|---:|---:|
"""+''.join(f"| {key} | {value['exit_code']} | {value['elapsed_seconds']}s |\n" for key,value in e['builds'].items())+"""
Compiler/SDK remain27; runtime destinations18.2/27 are a separate dimension. First
confined attempt TchopApp18.2 exit70 before compilation: CoreSimulator inaccessible,
destination unavailable. Retained; necessary Simulator-authorized service access
then produced the four separate successful results, not a rewritten first PASS.
All source inputs equal before/after runs. Emitted host SwiftFileLists each include
actual AppTab; built TchopApp.app/TchopAppOcean.app EN/RU tables each contain323 keys
and match entire original resource dictionaries. No project/scheme/target/signing change,
package resolution, app launch/auth/network, installed tool, host/config/secret access.
QC owned DEFERRED revisited for selected source/target/settings; baseline-only review,
no engine/profile/runner adoption. Builds/probe verify selected contracts; they do not
prove rendered SwiftUI preview, authenticated UX, every target path or release readiness.

## Control cases and acceptance boundary

Existing handler SHA6d4f7cce88cd821ce14dec11d2ebf38d4432bfa5adf8c89294895b53bbd0452d,
unchanged pinned module, imported without side effects. Synthetic reader15 cases PASS:
ON/OFF×AUTO/ADVISORY, absent record, wrong consumer identity, schema2/boolean schema,
unsupported mode/profile, duplicate field, oversize/malformed input, independent second
consumer OFF and refusal to borrow another consumer's ON. Two synthetic exact-selector
refusals PASS: no selector with two fixture projects; escaping selector.17/17 total.
Only _record receives the owned fixture directory fd; scope is called only for negative
selectors in that fixture. No operate/status CLI, _write, live STATE_DIR access, actual
project mode, fabricated app identity or transition. Reader inputs unchanged during each
call. Unchanged prior FIFO/lock/disabled-recovery checks reused within their scope.
These prove named record/selector controls, not a project workflow in every profile.

| W4 case | Actual disposition | Remaining owner/action |
|---|---|---|
| Shared real task | TC-W4-01 fixed, two hosts compiled and resources/properties checked | Integrator memory/owned final-diff publication |
| Complete first layer without adopted Library | Actual TC-W4-01 complete at Tchop UNVERIFIED, no inherited BG ON | Saved OFF full-cycle case still not observed |
| ON/AUTO + ON/ADVISORY | BG actual ON/AUTO receipt reused; synthetic record formats PASS | User decision: live profile canary or explicitly bounded verdict |
| UNKNOWN/invalid/ambiguous refusal | Tchop second layer withheld; named reader/selector fixtures PASS | No live identity/repair/activation claimed |
| Different modes across consumers | Synthetic consumer identities independent; actual BG ON/Tchop UNVERIFIED kept separate | Full real cross-mode shared-consumer stage unobserved |
| Freshness/dirty/conflict/adverse/resume/detach | Existing scoped receipts reused; AppTab dirty hash/current memory refreshed; confined failure preserved | No full detach/runtime/new-chat proof inferred from fixtures |
| Independent review | User forbids agents/MCP; complete self-review only | No independent review claim |

Tchop Library UNVERIFIED unchanged; full KB preparation/change/review/memory only.
No second-layer useful delta or Library uplift asserted. BG ON/AUTO does not apply here;
LIB-004 remains OPEN. Global USER.VERIFICATION.SCOPE excludes all iPad/physical checks,
including actual VoiceOver, from all plans. Exclusion never PASS; no release claim.
Separate TC-L02 P3 OPEN: SideMenu #Preview asks missing menu.footer while shell.sideMenu.footer
exists; source untouched, outside this one-file canary, not a production navigation defect.

Raw before/after probes, compile/build inputs/results, resources/file-list proof and
17-case controls remain under active task tc-w4-localization/. No raw products in vault.
Useful failures retained; no cleanup of foreign state. Project/scheme/resource/other
observed source hashes unchanged; client HEAD unchanged. Exact canonical publication
receipt stays outside tracked content. Next decision: live Library profile observation
requires changing the explicit transition prohibition, or accept a bounded system verdict
that keeps those cases and LIB-004 open; no automatic app/library expansion.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
""")
p=app/'PROJECT_CONTEXT.md';s=p.read_text().replace('# Tchop project context — structural canary intake','# Tchop project context — shared consumer canary')
s=s.replace('No Tchop app implementation task chosen;\ndo not invent product changes or resume paused Share Extension follow-up.','User2026-10-04 chose real W4 task and delegated selection (выбери сам). TC-W4-01\nselected/fixed existing AppTab preview localization keys; current card/evidence below.\nPaused Share Extension follow-up remains paused; no new product feature.')
s=s.replace('No mode query using another project\'s\nhandler/payload, transition, library adoption, engine wiring, client Git, build/tests,\nagent/MCP or external action.','No live mode query using another project\'s\nhandler/payload, transition, library adoption, engine wiring, client Git, agent/MCP\nor unrelated external action. Current human self-verification delegation supplies\nTC-W4-01 probe/unsigned builds; structural intake itself granted none.')
s=s.replace('Current result is\nstructural preparation; end-to-end canary, multi-mode runtime and library uplift unrun.','Current structural\nmap is supplemented by TC-W4-01 scoped shared-source workflow. Complete saved-mode\ncycles and Library uplift remain unobserved.')
s+="""

## Current task card — TC-W4-01

Status VERIFIED_SCOPED; user delegated task selection2026-10-04. System need
R03/R07/R11/R16/R19–R21: real bounded shared-source change with all consumers covered.
Existing AppTab description keys were absent; correct existing stubDescription keys in
one file, no new copy/feature/fallback. Actual callers are existing SwiftUI previews;
main Mixes/Pinned/Chat screens use different components. Consumer AppTab fileRef
A00000220000000000000001 enters only TchopApp and TchopAppOcean Sources.
Five literal replacements, property/cases/IDs/state/navigation preserved.

Current AppTab SHA-256 `""" +e['after_AppTab_sha256']+"""`.
Project/scheme/resource/other observed source hashes unchanged; client source dirty
and uncommitted. Complete diff reviewed against the five-key contract.
[Scoped receipt](history/tc-w4-01-localization-2026-10-04.md): actual-source before
assertion exit133, after EN/RU×iPhone18.2/27 lookup20/20; four unsigned host/destination
builds PASS, both emitted AppTab file lists and built locale dictionaries verified.
First confined CoreSimulator exit70 retained separately. No rendered-preview or
authenticated app/release claim. Owned phones shutdown; outputs/caches inside .zenflow.
QC DEFERRED revisited, baseline-only review; no engine wiring.

Existing same-hash reader/selector controls17/17 synthetic PASS, exact limits in receipt;
no live status/transition/identity borrowing. Tchop Library remains UNVERIFIED; full KB
cycle complete here, no second layer or uplift. Actual saved OFF/ADVISORY/cross-mode
project acceptance still missing. Global USER.VERIFICATION.SCOPE removes all iPad/
physical checks, including actual VoiceOver, from every plan; omissions never PASS.

TC-L01 P3 CLOSED_SCOPED: AppTab preview lookup repaired. Separate TC-L02 P3 OPEN:
SideMenu #Preview missing menu.footer key; production footer uses existing shell key.
Not changed by this one-file task; report rather than expand source scope.
Next system decision: live Library canary needs explicit transition permission, or
bounded verdict retaining mode gaps and LIB-004 OPEN. No paused app backlog resumed.
""";p.write_text(s)
p=app/'MANIFEST.md';s=p.read_text();s=s.replace('- `plans/package-adoption-audit.md`:', '- `PROJECT_CONTEXT.md`: current TC-W4-01 shared preview-localization card and scoped acceptance.\n- `history/tc-w4-01-localization-2026-10-04.md`: exact source/consumer/build/probe/control evidence and remaining gaps.\n- `plans/package-adoption-audit.md`:');p.write_text(s)
main=v/'tasks/new-task-be0b/ios-project-work-system-plan.md';s=main.read_text();s=s.replace('| [ ] W4.2.b |','| [x] W4.2.b |').replace('| [ ] W4.2.c |','| [x] W4.2.c |').replace('| [ ] W4.3.c |','| [x] W4.3.c |').replace('| [ ] W4.5.b |','| [x] W4.5.b |')
s=s.replace('code/resource semantic change, actual complete OFF/ADVISORY/invalid/ambiguity controls remain open. Current doc task\ndoes not substitute for those requirements.','TC-W4-01 now supplies real shared-source semantic change; complete saved OFF/ADVISORY\nand real cross-mode cycles remain open. Named reader/selector refusal controls below\nare actual synthetic tests, not fabricated full-profile/new-chat observations.')
a=s.index('### W5. Решение');s=s[:a]+"""Current W4.2.b/c receipt: [TC-W4-01](../../apps/Tchop/history/tc-w4-01-localization-2026-10-04.md).
User chose real task and delegated selection; five shared AppTab lookup literals fixed,
actual preview callers traced, two host memberships/file lists checked. Before actual
property assertion exit133; after EN/RU×iPhone18.2/27 lookup20/20 and four unsigned
host builds PASS. First confined destination/CoreSimulator failure exit70 retained;
service-capable retry under existing Simulator grant. Main tab routes do not use these
preview components; no new product/production-navigation/release claim.
W4.3.c: actual Tchop unverified second layer withheld +15 owned synthetic reader cases
and2 exact-selector refusal cases PASS at unchanged handler hash. No live records,
transitions or app identity created. W4.5.b finite acceptance table maps every remaining
case to exact observed scope/gap/owner, not full W4 acceptance. W4.3.a actual KB-only
cycle completed while UNVERIFIED, but saved OFF control still missing; W4.3.b/d need
real profile/cross-mode observations or explicit bounded requirement decision.
TC-L02 P3 separate SideMenu preview key mismatch reported outside one-file task.

"""+s[a:]
s=s.replace('Current next decision: select a legitimate existing shared-consumer task for W4 and\nresolve permitted mode-control evidence, or explicitly accept a narrower system verdict.','Current user selected and delegated the real shared task; TC-W4-01 is verified scoped.\nNext decision: allow a precisely bounded live Library profile canary despite the current\ntransition prohibition, or explicitly accept a system verdict retaining those gaps.')
main.write_text(s)
for name in ('plan.md','handoff.md'):
 p=v/'tasks/new-task-be0b'/name;s=p.read_text()
 s=s.replace('BG-T01 test changes/builds/tests/\nnecessary Simulator QA delegated','Current task self-verification delegated; BG-T01 and chosen TC-W4-01 test/probe changes,\nbuilds/tests/necessary Simulator QA selected')
 s=s.replace('- [ ] W4 real accepted shared-consumer task plus complete mode-control evidence.','- [x] User selects real W4 task and delegates selection; TC-W4-01 five AppTab preview keys fixed.\n- [x] Both hosts×both destinations build PASS; EN/RU×both runtimes lookup20/20.\n- [x] W4.3.c named synthetic reader/selector controls17/17; finite W4 receipt/gaps matrix.\n- [ ] W4 actual saved OFF/ADVISORY/cross-mode stages; live transitions remain forbidden.')
 s=s.replace('W4 actual shared-source task and complete OFF/ADVISORY/UNKNOWN/ambiguous/cross-mode\ncontrols still OPEN.','W4 real shared-source TC-W4-01 verified; named UNKNOWN/invalid/selector refusal controls\nobserved within actual-withheld/synthetic scope. Saved OFF/ADVISORY and real cross-mode\nstages remain OPEN.')
 s=s.replace('Tchop Library unverified, never inherits BG ON/AUTO; paused app follow-ups unchanged.','Tchop Library unverified, never inherits BG ON/AUTO; paused app follow-ups unchanged.\n[TC-W4-01 receipt](../../apps/Tchop/history/tc-w4-01-localization-2026-10-04.md): shared\nAppTab preview lookup repaired,20/20 resource assertions, four host builds,17 scoped\nreader/refusal controls; no rendered preview/authenticated UI/release proof. Source\nuncommitted; SideMenu preview missing key separately reported P3.')
 s=s.replace('Next necessary decision: a real existing shared-consumer task for W4, with permitted\nmode-control observation, or explicitly narrower system adoption.','Next necessary decision: a bounded live Library profile canary needs explicit change\nto the transition prohibition, or choose a verdict retaining saved-mode/cross-mode gaps.')
 s=s.replace('Next decision: real existing shared-consumer task and permissible mode-control evidence,\nor explicitly narrowed system verdict.','[TC-W4-01](../../apps/Tchop/history/tc-w4-01-localization-2026-10-04.md): one AppTab source\nchanged, actual preview property failure reproduced,20/20 after lookup assertions and\nfour host builds PASS;17 synthetic reader/selector controls PASS, no live mode changes.\nBoth host resource tables match original323-key dictionaries. SideMenu preview mismatch\nis separate P3, source untouched; no authenticated navigation or rendered-preview claim.\nNext decision: live Library profile observation requires explicit transition permission,\nor bounded system verdict retaining those gaps.')
 p.write_text(s)
 local=s.replace('(ios-project-work-system-plan.md)','(/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b/ios-project-work-system-plan.md)').replace('(../../apps/','(/Users/Artem/.zenflow/worktrees/documentation-vault/apps/').replace('(../../reusable/baseline/','(/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/')
 (w/'.zenflow/tasks/new-task-be0b'/name).write_text(local)
state={'state':'TC-W4-01 verified scoped; awaiting real Library profile authorization or bounded verdict','source_AppTab_sha256':e['after_AppTab_sha256'],'source_commit':'not authorized/uncommitted','builds':'four host/destination PASS','lookups':'20/20 EN/RU across iPhone18.2/27','mode_controls':'17 synthetic PASS, no live transition/state access','Library_Tchop':'UNVERIFIED','other_finding':'TC-L02 P3 SideMenu preview key mismatch outside one-file task','remaining':'saved OFF/ADVISORY/real cross-mode stage evidence, LIB-004 OPEN','runtime':'none; owned phones shutdown'}
(r/'resume-state.json').write_text(json.dumps(state,indent=2)+'\n')
print('Canonical Tchop/task memory synced; real shared canary and narrow control evidence separated from remaining live-mode gaps.')
