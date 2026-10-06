from pathlib import Path
import json,hashlib
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault');r=w/'.zenflow/tasks/new-task-be0b/library-canary';p=json.loads((r/'proposal.json').read_text());a=json.loads((r/'adoption-receipt.json').read_text())
labels=['bg-off-auto','bg-on-auto','bg-on-advisory','bg-restore-on-auto','tc-off-auto','tc-on-auto','tc-on-advisory','tc-final-on-auto']
steps=[json.loads((r/(label+'-receipt.json')).read_text()) for label in labels]
assert all(x['other_record_preserved'] and x['scope_fingerprint_revalidated'] for x in steps)
assert steps[0]['before_record_sha256']==steps[3]['after_record_sha256']
report=v/'tasks/new-task-be0b/ios-project-work-system-library-canary.md';assert not report.exists()
report.write_text('''# W4 Library canary — actual scoped receipt

2026-10-04; GPT-6.1 Sol/high, эконом; owner user/integrator. Exact current user chose B,
grants Library switching while improving it until common plan completion/revocation,
aims full original-plan acceptance. Other bans stay: no agents/MCP/host/config/secrets/
installers/automations/client or engine Git; all iPad/physical verification omitted globally.
Canonical docs Git remains authorized after gates. No mode or memory supplies a grant.

## Exact inputs and owned change

Root knowledge-base-next; client HEADb7c48e163d9108d1cc4b123d93456ce8f7628d93,
dirty pre-existing app/test/task work preserved. Selectors:
BattleshipGame/BattleshipGame.xcodeproj and TchopApp.xcodeproj, existing registered IDs.
Tchop own payload TchopApp/IOSLibrary/:34 regular non-executable Git-pinned files,
revision3c42e490e82866eee0f303d6340452dbf9fff5eb, aggregate
526c7b0238fd66572ef260813891562ccadcc7329a26fc25b096ac16574f641e.
Existing BG34-file payload byte-matches this pin; no BG overlay/payload change.
Handler SHA6d4f7cce88cd821ce14dec11d2ebf38d4432bfa5adf8c89294895b53bbd0452d.
54 internal links contained/resolved. Manifest metadata not copied as a35th file.

Only Tchop canary adoption: payload, new TchopApp/AGENTS.md, exact owned root Tchop
section pointer. Root shared instructions still select exact project; all other text
byte-preserved. Proposed diff reviewed before apply, exact destination absent/no overwrite,
post-check all hashes. Tchop PBX explicit groups/phases have no synchronized group or
new payload/AGENTS membership; no app source/project/scheme/resource/package change.
Initial BGON/AUTO valid; TchopUNSET. Exact absence cannot be restored by this handler;
before mutation user explicitly chose terminal TchopON/AUTO. No state deletion/repair.
Library records stay ignored outside client; raw records never copied into reports/Git.

## Actual sequential mode observations

Every row: real own matching handler CLI write, separate CLI status, exact identity
revalidated, other selected project's record hash/status unchanged.8/8 writes and8/8
independent target statuses, plus before/other-project statuses:40 CLI calls in these
steps; two initial status calls separate. Failures0; no implied app runtime execution.

| Project | Before | Command | Independently observed | Other scope |
|---|---|---|---|---|
'''+''.join(f"| {x['project']} | {x['before']['status']}/{x['before']['profile'] or 'none'} | {x['command']} | {x['observed']['status']}/{x['observed']['profile']} | {x['other_project']} {x['other_observed']['status']}/{x['other_observed']['profile'] or 'none'} preserved |\n" for x in steps)+'''
BG final ON/AUTO and record hash exactly equal initial. Tchop final ON/AUTO equals
human choice; newly valid record retained, no attempted restoration of UNSET by deletion.
Same exact project shares common-dir mode across linked worktrees; no old checkout/branch
file was edited. No record contents, lock service or host configuration imported.

## Named stage results, not retroactive validation

| Stage | KB/result before Library | Actual later action / limit |
|---|---|---|
| BG saved OFF/AUTO | Prepare/review three shipping sources and current BG-T01 diff/evidence, freeze task memory; bounded0..<10 UI input, actor owner, minimum44/viewport, known timeout/omissions | Complete KB-only current review task; no new implementation or repeated runtime needed |
| BG ON/AUTO | Frozen OFF result remains baseline | Core + inclusive/build routes applied to current candidate; retained conclusions, added0 confirmed defects; no uplift claimed |
| BG ON/ADVISORY | Local baseline remains required | Proposed conditional iPhone checks/fresh benefit observations; proposals not executed |
| TC saved OFF/AUTO | Actual AppTab→appfacade→immutableSendable manager→productbundle path and preview callers, both host consumers/resources; freeze review/memory | Existing five-key source fix retained;20/20 lookup and4/4 builds reused only at exact unchanged inputs, no relabel of original UNVERIFIED work |
| TC ON/AUTO | Frozen current OFF review packet | Same selected pinned route bytes, applied to TC current sources/entrypoints/payload/consumers; added0 confirmed defects, no BG app decision/status borrowed |
| TC ON/ADVISORY | Current local baseline and existing findings | Conditional lookup/build advice, separately scoped TC-L02 backlog and required fresh-chat observation; proposals not executed |

One integrator sequential passes, no blind/independent comparison. Source/header/handler/
mode changes have explicit authorities. ON supplies no new test/runtime/Git right;
ADVISORY advice is not performed evidence. No artificial app feature/finding/test branch.
Time/subscription tokens not measured; observed command/route bytes are not savings.

## Acceptance boundary and remaining work

W4.3.a actual saved OFF first-layer preparation/review/evidence/memory observed for
named review tasks; implementation N/A because existing source fix is retained.
W4.3.b actual ON/AUTO later challenge and ON/ADVISORY proposals observed for both scopes.
W4.3.c prior unchanged17 synthetic reader/selector cases + same-handler FIFO/lock/disabled
recovery evidence reused; no live invalid record injected. No fresh-chat negative-status
behavior inferred from these fixtures.
W4.3.d partial: actual TC OFF/BG ON and independent writes/hashes plus both TC AppTab
consumers and common root instruction diff inspected. Both host targets have one mode;
no independently moded shared Swift source claim. Fresh-chat application of the shared
root/own-selector boundaries remains unobserved; keep this leaf OPEN until that named
integration evidence/requirement is resolved, no silent narrower acceptance.

New Tchop entrypoint startup specifically requires an actual fresh chat with own pin/hash/
status before a pilot-ready claim. Current staged/static/CLI success cannot replace it.
User forbids agents/MCP; no new task/thread/reviewer is silently created. Next necessary
human action: start a fresh chat with the supplied task handoff; observer reads current
chain, confirms both actual modes, chooses exact Tchop scope and reconstructs grants/next
step. Any fresh OFF/ON/profile observation runs only under actual continuing human grant,
returns BG initial and TC selected ON/AUTO, and preserves every consumer/foreign change.
Fixture-invalid observation may use only owned isolated records, never corrupt live state.
Do not rerun app builds/UI at unchanged inputs merely for a mode/new-chat check.

LIB-004 P2 OPEN: current two passes add0 confirmed defects; general repeatable added value/
cost is not established. Same-session evidence does not close the library release gate.
Core full verdict still pending required integration evidence, A not accepted.
BG-A01 and TC-L01 retain CLOSED_SCOPED; separate TC-L02 SideMenu preview P3 remains OPEN,
no app release. Historic combined27 timeout/other failures retained; omitted iPad/physical/
actual VoiceOver never PASS. All raw commands/hashed inputs/deltas/proposals remain under
active task library-canary/; canonical contains compact evidence only.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
''')
app=v/'apps/Tchop';c=app/'PROJECT_CONTEXT.md';s=c.read_text()
s=s.replace('QC registration is owned DEFERRED, not ADOPTED. No live mode query using another project\'s\nhandler/payload, transition, library adoption, engine wiring, client Git, agent/MCP\nor unrelated external action.', 'QC registration is owned DEFERRED, not ADOPTED. Latest human canaryB authorizes own\nTchop pinned payload/entrypoint and temporary exact-project mode transitions until\ncommon improvement plan completion/revocation. Own handler/status only, no BG borrowing.\nEngine wiring/client Git/agent/MCP/unrelated external actions remain ungranted.')
s=s.replace('Tchop Library remains UNVERIFIED; full KB\ncycle complete here, no second layer or uplift. Actual saved OFF/ADVISORY/cross-mode\nproject acceptance still missing.', 'At TC-W4-01 source checkpoint Library was UNVERIFIED; that historical full KB\ncycle remains separately scoped. Current Library canary below observes later saved-mode\nreview stages; no retroactive ON validation or uplift.')
s=s.replace('Next system decision: live Library canary needs explicit transition permission, or\nbounded verdict retaining mode gaps and LIB-004 OPEN. No paused app backlog resumed.', 'Current human choice: full canaryB, temporary switching allowed, Tchop terminal ON/AUTO.\nFresh-chat/remaining integration and LIB-004 still OPEN; no paused app backlog resumed.')
s+='''\n\n## Current Library canary — own exact selector

EXPERIMENTAL_CANARY adoption, not general release/pilot-ready. User chose B and delegated\nmode switching until common improvement plan finishes/revocation; full original quality\ngoal preserved. Initial actual UNSET, human explicitly selected terminal ON/AUTO.\nOwn TchopApp/IOSLibrary/34-file Git pin3c42e490e82866eee0f303d6340452dbf9fff5eb,
aggregate526c7b0238fd66572ef260813891562ccadcc7329a26fc25b096ac16574f641e,
handler6d4f7cce88cd821ce14dec11d2ebf38d4432bfa5adf8c89294895b53bbd0452d.
New own TchopApp/AGENTS.md + root exact-selector pointer, post-apply hash/ownership/link/
explicit PBX membership checks; no shipping source/project/resource change or client Git.

Actual OFF/AUTO full current review stage → ON/AUTO scoped additive pass → ON/ADVISORY\nproposals → selected ON/AUTO. Each write independently status-confirmed; BG record hash\nand status preserved. Both Tchop host targets have one project mode; no per-target mode.\nKB results frozen before consultation; current source/caller/resource/consumer review and\n20/20 probes+four builds reused at unchanged inputs. Additive pass added0 confirmed\nfindings; no useful-delta/cost benefit or release claim. ADVISORY proposals did not run.\n[Coordinated scoped receipt](../../tasks/new-task-be0b/ios-project-work-system-library-canary.md).\nRaw mode records never copied. Absence was not repaired/deleted; valid new record retained\nas human selected. Shared common-dir identity affects linked worktrees, old files untouched.\n
Next required observation: fresh human-started chat follows root→own nested entrypoint→\npin/hash/status and reconstructs exact scope/grants/next step; unavailable agents/MCP\nnever replaced by same-session role-play. Common-root cross-project application still\nOPEN at that integration boundary; LIB-004 P2 OPEN and TC-L02 P3 separate OPEN.\n'''
c.write_text(s)
pth=app/'MANIFEST.md';s=pth.read_text().replace('- Library: UNVERIFIED for this selector; first-layer work only, no mode/payload change','- Library: EXPERIMENTAL_CANARY at exact pin3c42e490e82866eee0f303d6340452dbf9fff5eb; own TchopApp/IOSLibrary and nested/root entrypoints; observed selected ON/AUTO, fresh-chat gate OPEN; no general release or inherited status')
pth.write_text(s)
pth=v/'apps/BattleshipGame/PROJECT_CONTEXT.md';s=pth.read_text().replace('Next safe system action: W4 real shared-consumer task/mode controls; no app backlog.', 'Next safe system action: new Tchop entrypoint fresh-chat/shared-boundary observation;\ncurrent BG/TC mode canary scoped receipt below, no app backlog.')
s+='''\n\n## Current mode canary observation

Latest human canaryB selection grants temporary Library switching during the common\nimprovement plan until completion/revocation. Exact BG handler/payload unchanged at\npin3c42e490.../34 files; own full saved OFF/AUTO KB current review stage, ON/AUTO later\nchallenge, ON/ADVISORY proposal stage observed. Actual modes independently confirmed,\nTchop target record/status preserved at every BG write. Final BGON/AUTO restored and\nrecord hash exactly equals initial. No source/runtime/overlay/payload/Git change in BG.\nKB frozen before Library; added0 confirmed findings and no measured benefit.\n[Coordinated receipt](../../tasks/new-task-be0b/ios-project-work-system-library-canary.md).\nNo fresh/independent reviewer inferred. Current Tchop new entrypoint requires fresh-chat\nobservation; BG does not lend it mode/grants/evidence. LIB-004 OPEN; no app release.\n'''
pth.write_text(s)
main=v/'tasks/new-task-be0b/ios-project-work-system-plan.md';s=main.read_text()
line='| E8 | [Tchop context](../../apps/Tchop/PROJECT_CONTEXT.md), [TC-W4-01](../../apps/Tchop/history/tc-w4-01-localization-2026-10-04.md) | Exact second graph/owned association, five shared preview lookup keys repaired; two hosts, lookup20/20, four builds,17 synthetic reader/selector controls; saved OFF/ADVISORY/cross-mode workflow still open |'
assert line in s
s=s.replace(line,line+'\n| E9 | [Actual Library canary](ios-project-work-system-library-canary.md) | Own pinned Tchop adoption; both scopes saved OFF current KB review, ON/AUTO actual challenge, ON/ADVISORY advice;8/8 writes/status, other-project hashes preserved; fresh Tchop/shared-root integration and LIB-004 remain OPEN |')
s=s.replace('| [ ] W4.3.a |','| [x] W4.3.a |').replace('| [ ] W4.3.b |','| [x] W4.3.b |')
s=s.replace('| R08 | E6/E7 BG ON/AUTO scoped pass; E8 does not borrow ON | ON/ADVISORY full stage and real cross-mode workflow W4.3.b/d OPEN; no uplift claim |', '| R08 | E6/E7 prior BG pass; E9 both scopes actual ON/AUTO current-candidate review and ON/ADVISORY proposal stages | Added0 confirmed defects; no general uplift; W4.3.d fresh shared-boundary application OPEN |')
s=s.replace('| R09 | E8 complete KB-only task with second layer withheld at UNVERIFIED | Saved OFF complete cycle W4.3.a OPEN; unknown status is not OFF evidence |','| R09 | E8 historical UNVERIFIED task retained; E9 actual saved OFF preparation/review/evidence/memory tasks complete | No new implementation needed for named review tasks; no historical UNVERIFIED→OFF relabel |')
s=s.replace('| R14 | BG ON/AUTO separated from Tchop UNVERIFIED; mode/grants/readiness distinct | Live saved-mode/profile controls still OPEN;17 E8 fixtures prove only reader/refusal cases |','| R14 | E9 exact independently moded scopes/statuses, final BG initial and TC selected ON/AUTO; grants/readiness distinct | Fresh new entrypoint/shared-root application remains OPEN;17 fixtures remain synthetic |')
s=s.replace('but saved OFF/ADVISORY/real cross-mode integration remains missing.', 'but fresh Tchop entrypoint/shared-root application remains missing; actual saved modes\nand named review stages now observed in E9.')
s=s.replace('Source/runtime PASS reused at unchanged fingerprints; current task verification delegated.', 'Source/runtime PASS reused at unchanged fingerprints; current task verification delegated.\nActual user ending choice: TchopON/AUTO; initialUNSET absence not deleted/restored by repair.')
s+='''\n\nCurrent E9 result: own Tchop payload/entrypoint reviewed/applied, BG preserved.8/8 actual\nCLI transitions and separately read statuses; every other selected project hash/status\npreserved. BG exact initial ON/AUTO record restored; Tchop left in human-chosen ON/AUTO.\nW4.3.a/b closed for actual named current review tasks/stages: complete saved OFF KB\npreparation/review/evidence/memory, ON/AUTO applied selected core+two routes, ADVISORY\nproposals unexecuted. Existing shipping change need not be replayed; no new app feature.\nW4.3.d remains OPEN: actual independent states/common root diff/two host coverage checked,\nfresh application of new exact-selector entrypoint/shared-root boundary not observed.\nDirect shared Swift source across independent project modes also not claimed. The prior\nstatic/fixture matrix does not supply this fresh integration evidence. No scoped A waiver.\nNew Tchop STARTUP_RULE explicitly requires actual fresh-chat pin/entrypoint/status\nobservation before pilot-ready; current user forbids agents/MCP. Next necessary human\naction: start fresh chat with current handoff; no repeated runtime at unchanged inputs,\nno mode-write replay from memory, restore current approved ending modes after any chosen\nfresh-mode case. LIB-004 still P2 OPEN; added0 confirmed findings/cost not measured.\nThis current block does not finish the common improvement plan or expire its mode grant.\n'''
main.write_text(s)
for name in ('plan.md','handoff.md'):
 pth=v/'tasks/new-task-be0b'/name;s=pth.read_text()
 s=s.replace('- [ ] W4 live Library canary B selected: OFF/AUTO, ON/AUTO, ON/ADVISORY; exact scopes/ending-state gates.', '- [x] Actual saved OFF KB review stages, ON/AUTO pass, ON/ADVISORY proposals in BG+Tchop;8/8 transitions/status, other-project preserved.\n- [x] Own Tchop34-file pin/entrypoints applied; final TC chosen ON/AUTO, BG exact initial ON/AUTO restored.\n- [ ] W4.3.d and new Tchop fresh-chat entrypoint/shared-root integration observation.')
 s=s.replace('Tchop Library unverified, never inherits BG ON/AUTO; paused app follow-ups unchanged.', 'Tchop historical source checkpoint UNVERIFIED; current own experimental canary/final\nON/AUTO in [E9](ios-project-work-system-library-canary.md), never inherited; paused follow-ups unchanged.')
 s=s.replace('Saved OFF/ADVISORY and real cross-mode\nstages remain OPEN.', 'Actual saved OFF/ON profiles now observed in E9; fresh new entrypoint/shared-root\napplication remains OPEN.')
 s=s.replace('unchanged hash; Tchop mode/adoption UNVERIFIED, no reuse/transition.', 'unchanged hash; current E9 both own handlers observed ON/AUTO with independent\nrecord preservation, no cross-project status/grant borrowing.')
 start=s.index('Latest user selected option2/B')
 end=s.index('Global rule change',start) if name=='handoff.md' else s.index('Canonical publish only',start)
 s=s[:start]+'''Latest user chose B/full original quality scope, mode switching permitted until common\nplan completion/revocation. E9 actual8/8 switches/separate status and saved OFF KB/current\nAUTO challenge/ADVISORY proposals complete; added0 confirmed findings, no measured uplift.\nFinal BGON/AUTO restored exactly; Tchop own newly valid ON/AUTO explicitly selected.\n[E9 receipt](ios-project-work-system-library-canary.md). Raw records never copied, no repair.\nNext necessary human action: start fresh chat from supplied prompt; follow canonical\nchain and root→Tchop nested entrypoint→own pin/hash/status, verify exact scope/grants/next\nstep and common-root project separation. Current-stage success cannot invent fresh-chat\nevidence. W4.3.d/new-entrypoint integration and LIB-004 OPEN; no boundedA acceptance.\nNo repeat app runtime at unchanged inputs. Preserve paused follow-ups/old checkout/branch/\nforeign edits; no agents/MCP/host/config/secrets/installers/automations/client or engine Git.\n'''+s[end:]
 pth.write_text(s)
 local=s.replace('(ios-project-work-system-plan.md)','(/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b/ios-project-work-system-plan.md)').replace('(ios-project-work-system-library-canary.md)','(/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b/ios-project-work-system-library-canary.md)').replace('(../../apps/','(/Users/Artem/.zenflow/worktrees/documentation-vault/apps/').replace('(../../reusable/baseline/','(/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/')
 (w/'.zenflow/tasks/new-task-be0b'/name).write_text(local)
print('Actual scoped canary, own Tchop adoption/final selected state, restored BG and remaining fresh integration published into current records; general claims withheld.')
