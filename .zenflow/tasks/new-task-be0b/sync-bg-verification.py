import hashlib,json,pathlib,re

local=pathlib.Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
vault=pathlib.Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
root=local/'.zenflow/tasks/new-task-be0b/bg-t01-verification'
app=vault/'apps/BattleshipGame'
task=vault/'tasks/new-task-be0b'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def terminal(relative):
    p=root/relative
    result=json.loads((p/'result.json').read_text())
    summary=json.loads((p/'summary.json').read_text()) if (p/'summary.json').exists() else {'passedTests':'unavailable','failedTests':'unavailable'}
    return result,summary
rows=[]
for relative in ['matrix-final/iphone-18-2','matrix-final/ipad-18-2','matrix-final/iphone-27-0','matrix-final/ipad-27-0','matrix-followup/ipad-18-2','large-text/iphone-18-2','large-text/iphone-27-0','large-text-flow/iphone-27-0']:
    result,summary=terminal(relative)
    assert result['inputs_unchanged']
    rows.append(f"| `{relative}` | {result['exit_code']} | {summary['passedTests']}/{summary['failedTests']} | {result['elapsed_seconds']}s |")
matrix='\n'.join(rows)
for family in ['iphone-18-2','iphone-27-0']:
    receipt=json.loads((root/'large-text'/family/'text-size.json').read_text())
    assert receipt['selected']=='accessibility-extra-extra-extra-large' and receipt['restored']
assert terminal('large-text/iphone-18-2')[0]['exit_code']==0
assert terminal('large-text-flow/iphone-27-0')[0]['exit_code']==0
project_sha=sha(local/'BattleshipGame/BattleshipGame.xcodeproj/project.pbxproj')
scheme_sha=sha(local/'BattleshipGame/BattleshipGame.xcodeproj/xcshareddata/xcschemes/BattleshipGame.xcscheme')
test_sha=sha(local/'BattleshipGame/BattleshipGameUITests/BoardInteractionTests.swift')
transfer='**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**'
current='''User2026-10-04 delegates BG-T01 test creation/modification, builds, test execution and
necessary Simulator QA. Necessary Simulator operations alone may use external paths;
project artifacts/caches/DerivedData/logs stay in `/Users/Artem/.zenflow`, shell login:false.
Mandatory task matrix: **iOS18.2 + iOS27**, iPhone/iPad; this is not a reusable rule.
Two original build grants remain consumed; current execution uses the newer delegation.
No agents/MCP, Library transitions, installers, secrets/host/config, automations or
client/engine Git authority. Canonical AIZenflowDocumentation Git remains authorized after gates.'''
summary='''Native actual-model12/12 PASS on macOS, reused at unchanged hashes. Debug build/test
actions executed on iPhoneSE3 and iPadPro11M4 with iOS18.2/27.0; Xcode27.0/27A266a,
iPhoneSimulator27.0 SDK, Swift6/strict complete. SDK and runtime are separate dimensions.
Both phones and iPad27: three nominal UI scenarios PASS. iPad18: rotation/audit PASS;
placement initially failed an immediate state assertion, then the focused scenario
PASS after predicate-based state waiting, without repeated taps. Retain the initial
failure; one successful follow-up does not prove absence of flakiness.
AX5 iPhone18 PASS: hit-region/description/text-clipping/Dynamic-Type audits, ship
Rotate button, vertical placement, scrolled gameplay/duplicate/reset. Expanded AX5
iPhone27 run timed out600s; xcresult unreadable, failing operation/root cause unknown.
One smaller AX5 gameplay/duplicate/reset scenario PASS on iPhone27, without the expanded
audit/Rotate scenario. That timeout remains unverified, never superseded by narrower PASS.
Original text settings restored. Nominal, expanded AX5 and narrower flow results use separately recorded harness inputs.
Unchanged rotation/audit evidence reused; no claim of one final four-test suite on every device.
VoiceOver experience, live iPad window resizing and physical-device/release evidence
remain unverified. BG-A01 P2 OPEN; LIB-004 P2 OPEN; no whole-system/app readiness PASS.'''

# Preserve the native/preflight stages as history, then make the current disposition explicit.
p=app/'history/bg-t01-verification-2026-10-04.md';s=p.read_text()
s=s.replace('## Disposition and next action','## Historical disposition — before explicit Simulator exception')
s=s.replace('Claim: native gameplay regression', 'Initial-stage claim: native gameplay regression',1)
s+='''
## Current Simulator authority, matrix and result — 2026-10-04

'''+current+'\n\n'+summary+'''

| Local artifact directory | Exit | Passed/failed tests | Elapsed |
|---|---:|---:|---:|
'''+matrix+f'''

All directories above are under `{root}`; raw xcresult, videos, images and build products
remain there, outside the vault. Each invocation.json records arguments, isolated
environment, owned UDID and input hashes; result.json records exit/time/unchanged inputs;
summary.json is xcresulttool test-results summary when available. The600s timeout
has result.json plus failed summary/activity retrieval receipts, no terminal test counts. Dynamic Type setting receipts are
text-size.json. No runtime, device or app unrelated to these four owned devices was changed.

Current UI test source SHA-256 `{test_sha}`.
Project SHA-256 `{project_sha}`; scheme `{scheme_sha}`.
One non-shipping XCTest UI target/source and scheme registration were added after the
exception; the three shipping sources, their app target settings/phases/resources and
dependencies remain unchanged from the prior compile receipt. project-preservation-review.json
records semantic comparison of original objects/actions and foreign/Library hash preservation.
QC remains owned DEFERRED; new test graph reviewed under baseline, no engine adoption.

Preserved earlier evidence: ui-iphone (2/3, invalid app-root frame predicate),
matrix/iphone-18-2 (user pause, BUILD INTERRUPTED, no terminal PASS),
matrix-resume/iphone-18-2 (2/3, portrait checked before geometry settled), and
matrix-final/ipad-18-2 (2/3, placement state). Final orientation assertions wait on
main-window geometry, drag coordinates use that window, placement waits on cell state.
No shipping patch was made to obtain a passing test. These are evidence-backed harness
changes; the iPad failure's exact underlying latency remains uncertain. macOS AVFoundation
decoded only the saved Simulator recording to local diagnostic frames; no tool installed.
The initial confined decode failed; the necessary service-capable decode succeeded.

Plan review/KB provisional retained missing manual proof and exact action/source bounds.
Then approved ON/AUTO copied test-strategy/evidence guidance retained independent grants,
real-state synchronization and failed/interrupted evidence. Self-review only; no measured
Library uplift. Source/membership memory refreshed; no mode or permission restored from history.
Expanded AX5 audit on iOS27 needs a bounded follow-up decision after its observed
timeout; do not repeat it unchanged or call it PASS. Next necessary human action: actual
VoiceOver coordinate traversal/actions and supported
live iPad resizing; record environment/results. W4 also needs a legitimate accepted shared
consumer task; no artificial product feature or paused Tchop backlog was developed.
'''
p.write_text(s)

# Active task card is a compact projection; historical actions remain in linked receipts/Git.
(app/'TASK_BG_T01.md').write_text(f'''# BG-T01 — board interaction acceptance

Status AUTOMATED_SCENARIOS_OBSERVED_MANUAL_ACCEPTANCE_OPEN; 2026-10-04.
Owner user; integrator GPT-6.1 Sol/high, эконом, self-review only.
ProjectID `6a655f50-2a48-49df-9b5a-bdff693564de`; root
`{local}`; selector `BattleshipGame/BattleshipGame.xcodeproj`.
Client HEAD `b7c48e163d9108d1cc4b123d93456ce8f7628d93`, dirty source/test graph uncommitted.
Identity/current shipping hashes: [context](PROJECT_CONTEXT.md), [map](PROJECT_MAP.md).
Trigger [BG-A01 P2 OPEN](AUDIT_LEDGER.md); system question R07/R11–R13/R19–R21:
fresh context → selected approach/permissions → owned change → honest verification/memory/resume.

## Accepted behavior and bounded contract

User selected A2026-10-03 after comparison: minimum44pt cells, board minimum467pt,
horizontal scroll at narrow widths and fill at wider widths. Alternative B, compact
board plus coordinate selection/confirmation, would change interaction and was not selected.
Behavior preserves10×10 coordinates, placement/ship rotation/start/fire/duplicate/winners/reset.
GameBoardView produces geometry; two board consumers and BoardCellButton intents use it;
MainActor game remains state owner. Finite positive width updates; input coordinates0..<10,
fixed200 cell envelope, no new I/O/cache/service. No clipped/unreachable/ambiguous targets
or false accessibility success. Product source patch remains one ContentView file.
Test graph is separate non-shipping verification; no dependency/asset/config migration.

## Current authority and selected checks

{current}

Delegation supersedes the earlier user-owned QA menu only in this scope. Native regression
was selected for domain invariants; a runnable excepted Simulator then justified one UI
source + project + scheme block (3 files), with real coordinate actions instead of mirrored
geometry arithmetic. Each failure was preserved and diagnosed before a bounded harness
change. Devices/accounts/network, performance/Instruments, archive/signing and unrelated
features were not selected. Existing unchanged model/source/pin evidence was reused.

{summary}

Exact commands/harness versions/UDIDs/outcomes/failures/limits:
[verification receipt](history/bg-t01-verification-2026-10-04.md).
Original compile and implementation provenance: [build receipt](history/bg-t01-build-2026-10-03.md).
Historical card/menus are also retained in canonical Git at the preceding publication;
their grants and next actions are superseded by this current card.

## Checks and remaining exit criterion

- [x] Exact identity, current instructions/grants, preserved dirty state and handler hash.
- [x] Existing A source/consumer review; actual-model12 regression checks.
- [x] App/UI-test target graph and complete owned diff reviewed, shipping settings preserved.
- [x] Nominal iPhone/iPad18.2/27 scrolling, corner reachability, coordinate gameplay,
  duplicate/reset, orientation and visible hit-region/description scenarios observed.
- [x] AX5 gameplay on both phones; expanded audit/Rotate/vertical placement on iPhone18.
- [ ] Expanded AX5 audit/Rotate on iPhone27:600s timeout; root cause unverified.
- [x] Actual new-chat pre-QA restoration W3.4.b; user-pause interruption/resume retained.
- [ ] Actual VoiceOver traversal and activation across both boards, coordinates/states,
  offscreen scroll, placement/fire/reset; automated descriptions do not replace it.
- [ ] Supported live iPad window resize: sizing and accurate actions after width changes.
- [ ] BG-A01 closure/full W3 acceptance only from sufficient remaining evidence.

Next required user action: report those two manual observations with device/runtime,
text size and result; a failure returns to the smallest grounded correction and meaningful
approach choice. Existing labels/localization, icon, performance and other backlog are
outside this system canary. No app release, Library release or generic reliability claim.

KB first, then approved ON/AUTO pass: current handler/payload validated, copied test/evidence
guidance retained independent permissions and manual limits. No new Library-only defect,
measured uplift, delegate, MCP or transition. Fresh source/target/scheme changes invalidate
affected memory only; source data/grants come from actual inputs and human instructions.
Rollback would remove only unchanged owned additions; no rollback/client commit performed.

{transfer}
''')

p=app/'PROJECT_CONTEXT.md';s=p.read_text()
s=s.replace('Identity contract version: 1. Observed 2026-10-03;', 'Identity contract version: 1. Refreshed 2026-10-04;')
s=s.replace('BG-T01 now changes ContentView.swift;', 'BG-T01 changes ContentView.swift and now adds a non-shipping UI test target/scheme;')
s=s.replace('One app target, BattleshipGame; PBX ID 5A1B2C3D4E5F600000000040','One shipping app BattleshipGame (PBX5A1B2C3D4E5F600000000040) plus non-shipping BattleshipGameUITests (PBXB60100000000000000000005)')
s=s.replace('47cff5b4dcb8923a6816ad3a0642ab10a24bd7099fea5292c34e7a0cde8b4b3c',project_sha)
s=s.replace('Shared scheme BattleshipGame declares that app BuildAction; Testables empty','Shared scheme BattleshipGame preserves app actions; one UI Testable, serial, test-only build entry')
s=s.replace('b25b65c0d3e66d4a18c6bec3b8f7d3984748cccedc1dd7e038b1b0641e2ed449',scheme_sha)
s=re.sub(r'\| Builds \|.*\n\| BG-T01 test creation/execution and Simulator QA \|.*\n', '| Builds/tests/Simulator QA | User2026-10-04 delegates exact BG-T01 verification; necessary Simulator-only external exception; mandatory iOS18.2+27 iPhone/iPad matrix, outputs .zenflow | Native12/12 and scoped UI/AX5 observations; failures/omissions in [receipt](history/bg-t01-verification-2026-10-04.md) |\n',s)
s=s.replace('revisited for BG-T01: bounded baseline-only static review, no adoption claim;', 'revisited for BG-T01 source and new UI test graph: baseline contract/target/settings review, no adoption claim;')
start=s.index('Exact BG-T01 Debug generic Simulator SDK compilation PASS,')
end=s.index('\nRefresh affected records',start)
s=s[:start]+'''Current automated matrix and limitations: [BG-T01 card](TASK_BG_T01.md) and
[verification receipt](history/bg-t01-verification-2026-10-04.md). Both runtime versions
and families observed; AX5 gameplay on both phones, expanded AX5 audit27 timed out. Native12/12 retained. Original compile receipt
remains historical at its original project/scheme hashes, not reused for the new test graph.
VoiceOver/live resize/device/release remain unverified; BG-A01 and LIB-004 OPEN.
Next safe action: user provides actual VoiceOver and supported iPad resize observations.
'''+s[end:]
s=s.replace('status observed ON/AUTO on 2026-10-03;', 'status revalidated ON/AUTO on 2026-10-04;')
p.write_text(s)

p=app/'PROJECT_MAP.md';s=p.read_text().replace('Single app target; iPhone/iPad family 1,2; no extension/test target declared','One shipping app plus non-shipping UI-test target; iPhone/iPad family1,2; no extension')
s=s.replace('Empty Testables; current exact candidate build PASS per receipt below; no test success','One serial UI Testable; original app actions preserved; exact per-run inputs/results in verification receipt')
s+='''
## Current verification graph and evidence — 2026-10-04

BattleshipGameUITests depends on the app target; its source is
BattleshipGame/BattleshipGameUITests/BoardInteractionTests.swift. No test source enters
shipping PBXSources; original app phases/configs/resources/three sources are preserved.
Standalone native model harness remains outside Xcode. Current nominal runtime matrix
and phone AX5 gameplay/expanded-audit limits are scoped in [receipt](history/bg-t01-verification-2026-10-04.md).
They supersede earlier unrun rotation/scroll claims only for observed environments;
live resize, actual VoiceOver and hardware remain unverified. Old target/scheme facts
belong to their exact historical compile inputs, not this new verification graph.
'''
p.write_text(s)

p=app/'AUDIT_LEDGER.md';s=p.read_text()
s=s.replace('runtime layout unrun','selected nominal/AX5 scenarios observed; live resize/VoiceOver unverified')
s=s.replace('VoiceOver/focus/contrast/large text unrun','VoiceOver/focus/contrast unverified; phone AX5 automation observed')
s=s.replace('One app, three sources, assets, no package references;', 'One shipping app plus non-shipping UI target, three app sources/assets, no package references;')
s=s.replace('| Testing | UNVERIFIED | Empty scheme Testables, no declared test target; tests are not authorized |','| Testing | CHECKED scoped automated | Native12/12; nominal iPhone/iPad18.2/27 and phone AX5 observations, retained failures/limits in verification receipt; real VoiceOver unverified |')
s=s.replace('remaining supported-width/assistive interaction acceptance.', 'nominal widths/rotation and phone AX5 gameplay now observed; expanded AX5 audit27 timed out; real assistive traversal and live iPad resizing acceptance remain.')
s=s.replace('no executed\nUI assertion, device hit testing or VoiceOver proof.', 'executed UI assertions are now scoped in the verification receipt; no hardware or actual VoiceOver proof.')
s+='''
## Runtime disposition — 2026-10-04

[Current evidence](history/bg-t01-verification-2026-10-04.md) adds both-version/family
nominal scenarios and phone AX5; iPad18 immediate placement failure retained with
one state-wait follow-up PASS, no guarantee of no flakiness. Expanded AX5 audit27 timed out600s; narrower flow is separate evidence. Shipping source unchanged.
BG-A01 remains P2 OPEN for actual VoiceOver and supported live-resize acceptance;
automated audits do not close those gates. Library LIB-004 remains separately OPEN.
'''
p.write_text(s)

p=task/'ios-project-work-system-plan.md';s=p.read_text()
s=s.replace('Interaction/VoiceOver and full end-to-end acceptance unverified;', 'Nominal and AX5 gameplay observed in the current receipt; VoiceOver/live resize, expanded AX5 audit27 and full acceptance unverified;')
start=s.index('2026-10-04 user «делай проверки тесты и так далее сам»')
end=s.index('No host/config/auth/Keychain/secrets/installers/automations;',start)
s=s[:start]+current+'\n'+s[end:]
start=s.index('Subsequent user-delegated verification recorded')
end=s.index('\nW3.4.b observed',start)
s=s[:start]+'''Subsequent user-delegated verification and Simulator-only exception:
[receipt](../../apps/BattleshipGame/history/bg-t01-verification-2026-10-04.md).
Native12/12 and nominal iPhone/iPad18.2/27 observations; AX5 gameplay on both phones.
Expanded AX5 audit/Rotate PASS on18.2;27 run timed out600s, unreadable xcresult.
One narrower AX5 flow PASS on27 does not close the expanded audit gate.
Original failures and user pause/interruption retained; state-wait follow-up separately
labelled. New non-shipping test graph invalidated original empty-Testables memory and
was refreshed; shipping source/foreign/pin unchanged. W3.3.b/c remain open for actual
VoiceOver/live resizing; BG-A01/LIB-004 OPEN. W3.4.a records current disposition,
W3.5.a is a scoped partial canary receipt, not full W3 acceptance.
'''+s[end:]
for leaf in ['W3.4.a','W3.5.a','W4.4.c']:
    s=s.replace('| [ ] '+leaf+' |','| [x] '+leaf+' |')
s+='''
Current common adverse-case observation W4.4.c: confined preflight unavailable,
initial build/test failures preserved, user-pause BUILD INTERRUPTED and actual resumed
matrix recorded in the BG receipt. No unavailable/partial/interrupted result became PASS.
This closes that named common observation only, not Tchop shared change or full W4.
Current next human gate: VoiceOver/live iPad resize; then a legitimate accepted shared
consumer task/current choices. No synthetic product feature or live mode transition.
'''
p.write_text(s)

plan=f'''# Current execution — основной план B

Task new-task-be0b; worktree `{local}`; GPT-6.1 Sol/high, эконом.
Main plan: [main plan](ios-project-work-system-plan.md). W1/W2 published; W3/W4 partial,
W5 OPEN. Resume after user shutdown request2026-10-04 completed; no background job.

{current}

- [x] W3.4.b actual pre-QA new-chat scope/permission recovery.
- [x] Native actual-model12/12 and UI graph/preservation review.
- [x] Mandatory iPhone/iPad iOS18.2/27 nominal observations; phone AX5 gameplay on both versions.
- [x] Preserve failed/interrupted results, current app memory/partial scoped receipt.
- [x] W4.4.c common unavailable/failed/partial/interrupted/resumed observation, BG scope.
- [ ] W3: actual VoiceOver/live iPad resize acceptance and expanded AX5 audit27 gap; BG-A01 P2 OPEN.
- [ ] W4: real accepted shared-consumer task and remaining mode/freshness/conflict cases.
- [ ] W5: requirement dispositions, separate system/library/app verdicts, final adoption.

{summary}

App evidence/card: [BG-T01](../../apps/BattleshipGame/TASK_BG_T01.md),
[receipt](../../apps/BattleshipGame/history/bg-t01-verification-2026-10-04.md).
Tchop structural graph/association remains current; unknown Library never inherits BG ON.
No source feature chosen in Tchop. Existing preserved snapshots stay under archive/main-plan-B-before.

Next necessary user action: report VoiceOver and supported live iPad resize observations.
Continue only the grounded correction if they fail; compare meaningful approaches.
Do not develop unrelated pilots/backlog, switch Library, invoke agents/MCP, install tools,
touch old worktree/installation branch, host/config/secrets, or client Git.
Canonical publication only after complete owned-diff/semantic/static gates; exact-SHA
receipt stays outside tracked state. No app/full-system/Library release declaration.

{transfer}
'''
handoff=f'''# Resume — new-task-be0b

Worktree `{local}`. GPT-6.1 Sol/high, эконом; current route adequate.
Read canonical bootstrap → baseline/router Level0 → current main plan/handoff →
ios-project-work-system and actual subtask routes/overlays. Main plan:
[main plan](ios-project-work-system-plan.md). App [BG-T01](../../apps/BattleshipGame/TASK_BG_T01.md).

{current}

{summary}

Source A remains dirty hash d9134483db19a9d1e7e8edcca42f06120f66bb410c2cea124b86700146b010c1.
Native test source + one UI source/project/scheme addition are uncommitted in client;
client HEAD b7c48e163d9108d1cc4b123d93456ce8f7628d93. Foreign roadmap/entrypoints,
original model/app entry and34 copied Library files preserved. Handler revalidated
ON/AUTO for exact Battleship selector only; Tchop mode unverified, no inheritance.
Original shipping project objects/scheme actions preserved except owned test registration.

W1/W2 complete; W3.2.b/W3.4.b choice/recovery recorded, W3.4.a/W3.5.a partial receipt;
W3 full acceptance remains OPEN. W4 structural map done; common adverse W4.4.c observed;
shared source task/modes/freshness/conflict acceptance remains OPEN. W5 final verdict OPEN.
App evidence: [receipt](../../apps/BattleshipGame/history/bg-t01-verification-2026-10-04.md).
Local raw artifacts: `.zenflow/tasks/new-task-be0b/bg-t01-verification/`; preserve all
failed/interrupted attempts. Four owned UDIDs in owned-simulators.json. Publication
receipt separately outside tracked content; no raw products/logs in the vault.

Next required human action: actual VoiceOver traversal/actions and live iPad resize
result with environment. No more unchanged PASS reruns. Then choose a legitimate
shared-consumer task; do not invent a feature to complete W4. Keep paused app follow-ups,
old checkout/installation branch and foreign edits. No client Git or mode transitions.

{transfer}
'''
for name,body in [('plan.md',plan),('handoff.md',handoff)]:
    (task/name).write_text(body)
    localbody=body.replace('[main plan](ios-project-work-system-plan.md)',f'`{task}/ios-project-work-system-plan.md`').replace('../../apps/BattleshipGame/',str(app)+'/')
    (local/'.zenflow/tasks/new-task-be0b'/name).write_text(localbody)
print('App/task memory synchronized; runtime matrix scoped, historical failures retained, manual gates OPEN.')
