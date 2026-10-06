from pathlib import Path
import hashlib, json, subprocess
from datetime import datetime, timezone

w = Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
v = Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
r = w / '.zenflow/tasks/new-task-be0b/library-utility-tc-mp01'
g = r / 'regression'
base = '801b22ec753a59383a3e2719f62c934aaf27494c'
owned = ['apps/Tchop/MANIFEST.md', 'apps/Tchop/PROJECT_CONTEXT.md',
         'tasks/new-task-be0b/plan.md', 'tasks/new-task-be0b/handoff.md',
         'tasks/new-task-be0b/ios-project-work-system-plan.md']
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def load(p): return json.loads(p.read_text())
def save(p, d): p.write_text(json.dumps(d, indent=2, ensure_ascii=False) + '\n')
assert subprocess.check_output(['git','rev-parse','HEAD'], cwd=v).decode().strip() == base
assert not subprocess.check_output(['git','status','--porcelain'], cwd=v).strip()
contract = load(g / 'contract.json')
for rel,h in contract['after_sha256'].items(): assert sha(w / rel) == h, rel
protected = load(r / 'comparison-preservation-baseline.json')['protected_hashes']
changed = {p:(h,sha(Path(p))) for p,h in protected.items() if sha(Path(p)) != h}
expected = {str(w / p) for p in contract['before_sha256']}
# The comparison baseline was captured under OFF; accept only the exact approved ON receipt.
mode = load(r/'mode-observations/tc-on-receipt.json')
mode_path = str(v/'tasks/reference-status/29105892f934e061fdd32f67692fa1829dedbfd2485966b4d6288a7bfbfbf24d.json')
assert protected[mode_path] == mode['before_record_sha256']
assert sha(Path(mode_path)) == mode['after_record_sha256']
expected.add(mode_path)
assert set(changed) == expected, changed
assert sha(w / '.zenflow/tasks/new-task-be0b/knowledge-base-library-roadmap.md') == 'cf53082f94335c991c1a526bb50bbfbca909234b08219c4744653a608d0f4835'
results = {str(p.relative_to(g)):load(p) for p in g.glob('**/result.json') if 'build-cache' not in p.parts}
for stage in ['after-18.2-TchopApp-test','after-27.0-TchopApp-test']:
    s = load(g / stage / 'summary.json')
    assert s['result']=='Passed' and s['passedTests']==3 and s['failedTests']==0
    assert s['devicesAndConfigurations'][0]['passedTests']==8
for k,d in results.items():
    if k.startswith(('after-','component-after/')): assert d['exit_code']==0, k
save(g / 'qa-receipt.json', {
    'utc':datetime.now(timezone.utc).isoformat(), 'case':'TC-MP01',
    'contract':contract, 'terminal_results':results,
    'actual_unit_after':'3 test functions / 8 parameter runs PASS each on iPhone18.2 and27; only FeedMediaPreviewRendererTests',
    'native_component':'Exact production renderer slices, fixture-only file resolver; baseline two dimension failures each, after14/14 assertions each; not app fallback/cache/state integration',
    'geometry':'2048x1536 / 1536x2048 -> 1200x900 / 900x1200; preferred orientation/aspect retained',
    'host_builds':'All4 unsigned Debug TchopApp/Ocean destination builds PASS; cached SDK27 inputs reused, not independent SDK18.2 compilation',
    'toolchain':'Xcode27.0 27A266a; SDKiPhoneSimulator27.0; AppleSwift6.4 swiftlang-6.4.0.34.1 clang-2100.3.34.1; component arm64-apple-ios17.0-simulator Swift6 strict complete warnings-as-errors',
    'failures_retained':'iOS18.2 baseline timeout124 at603.176sec UNKNOWN cause/incomplete assertions; completed27 baseline actual2048>1200 FAIL plus fixture QoS runtime warning. LaterPASS does not rewrite baseline. Preexisting FoundationModelsOnDeviceAIManager.swift86 deprecation untouched.',
    'diagnostic_scope':'Initial automatic diagnostic collection error retained; no host/config/snapshot contents read. Own incomplete verbose bundle removed after compact failure/compile evidence retention. Subsequent collect-test-diagnostics never; no hidden host-launch-root-cause claim',
    'preservation':{'protected_total':len(protected),'unchanged':len(protected)-len(changed),'changed_existing_source':sorted(p for p in changed if p!=mode_path),'authorized_mode_transition':mode_path,'new_test':contract['owned_paths'][2],'mode':'TC ON/AUTO restored to pre-canary ON hash; BG exact record preserved','client_git':'HEAD unchanged, no client commit/push','foreign_roadmap':'preserved'},
    'simulators':load(g/'final-simulator-state.json'),
    'omitted':'Full suite/UI/auth/performance/memory/CI/archive/signing not executed; iPad/physical/actual VoiceOver OMITTED_BY_USER',
    'residual':'F1 exposure/cancellation overlap and cache/PDF/aggregate hypotheses unverified; LIB-004 OPEN, Library NOT_READY_FOR_GENERAL_RELEASE; TC-L02 OPEN',
    'next':'Publish compact canonical results after exact gates; significant next Library approach awaits human choice; no extra chat grant'
})
ad = load(r / 'parent-adjudication.json')
ad['parent_adjudication']['F2'] = 'Original video intake copies without pixel reduction; bounded actual regression confirms2048px output. Existing1200 photo envelope applied to video. Both iPhone runtimes verify1200 geometry/orientation/fallback; cache byte budget/pressure remains unknown.'
ad['verification_complete'] = 'qa-receipt.json: unit3 functions/8 parameter runs each; native14 assertions each; all4 host builds PASS.18.2 initial timeout UNKNOWN preserved;27 baseline real FAIL preserved.'
ad['preservation_final'] = '104/107 comparison hashes unchanged; approved View/PBX plus exact authorized TC OFF->ON transition differ; new test recorded. TC restored pre-canary ON/AUTO bytes and BG unchanged. Both selected phones Shutdown.'
ad['terminal_failures'].append('Closure preservation assertion initially compared OFF baseline against ON as if the baseline were ON; failed before writes. Corrected only using exact existing tc-on receipt before/after hashes, not a general waiver.')
save(r / 'parent-adjudication.json', ad)

common = '''TC-MP01 completed its two authorized sequential read-only observations at frozen source
and canonical801b22ec753a59383a3e2719f62c934aaf27494c. Both are PARTIAL_PROCEDURAL;
strict comparison is not accepted. OFF hashed1368 extra pin blobs (5,139,382 logical
bytes) beyond34 adopted names; no Library text applied. ON first-layer ordering and
scheme-output scope also incomplete. Library produced0 new defects/remedies and2
evidence/severity refinements, not established causal/general utility. Actual combined
turn time1734.973sec; token/account cost UNKNOWN. Exactly2 grants consumed; no new chats/MCP.
Parent traced current media producers: same-identity URL replacement not established,
so no speculative F1 state rewrite. Original video intake is not spatially reduced;
confirmed preview oversize fixed using existing1200px photo envelope. Only View,
new FeedMediaPreviewRendererTests and existing-unit PBX membership changed; both hosts
consume View, new test only TchopAppTests. Native baseline oversized on both iPhones;
after1200x900/900x1200,14/14 assertions each. Actual unit3 functions/8 parameter runs
PASS each on18.2+27; all4 unsigned Debug host builds PASS with SDK27/cache reuse.
Initial18.2 unit timeout UNKNOWN retained; completed27 baseline real2048>1200 FAIL retained.
No smoothness/memory/stale-result/auth/UI/full-suite/release claim. iPad/physical/actual
VoiceOver OMITTED_BY_USER. TC and BG ON/AUTO; BG exact record preserved, TC restored
initial ON bytes. Source HEAD unchanged, foreign edits/paused follow-ups retained.
Full exact local evidence: library-utility-tc-mp01/regression/qa-receipt.json and
parent-adjudication.json. General improvement plan/LIB-004 P2 OPEN; Library
NOT_READY_FOR_GENERAL_RELEASE; TC-L02 P3 OPEN. Next significant approach awaits
human choice: bounded observation-protocol correction (recommended) or next real app task.
Canonical documentation alone publishable after exact final-diff/HEAD/remote gates.
'''
for rel in ['tasks/new-task-be0b/plan.md','tasks/new-task-be0b/handoff.md']:
    p=v/rel; s=p.read_text(); a=s.index('User delegated selection of the most useful next approach.'); b=s.index('**перечитать весь актуальный набор',a)
    s=s[:a]+common+'\n'+s[b:]
    if rel.endswith('/plan.md'):
        a=s.index('## TC-MP01 — next genuine Library utility case')
        s=s[:a]+'''## TC-MP01 — completed bounded media case

- [x] Select genuine existing media preview case; freeze source/task and consumer identity.
- [x] Exactly2 authorized OFF/ON observations executed; both PARTIAL, strict protocol not PASS.
- [x] Adjudicate0 new Library defects/remedies and2 refinements; costs/causality limitations retained.
- [x] Confirm and fix only video pixel envelope; selected unit/native checks and4 builds PASS.
- [x] Synchronize compact app/task evidence for exact publication gates; actual remote receipt is external.
- [ ] Human chooses next significant Library approach; no extra chat/MCP/runtime authority implied.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
'''
    p.write_text(s)

p=v/owned[4]; s=p.read_text(); a=s.index('## Current TC-MP01 preparation — 2026-10-05')
s=s[:a]+'''## Current TC-MP01 result — 2026-10-05

'''+common+'''
OFF observer01a10935-7070-7b91-91be-15db2d050ac6 and ON observer01a10943-5869-7980-9c11-fa894388f4db
used the same frozen task/model/source. OFF semantic candidates preceded its pin overscan;
ON own provisional KB result was frozen before Library. Their individual receipts retain
startup/scope failures, output clipping/recovery and available read metrics. Neither arm
supports a clean token/cost comparison, missed-findings completeness or repeatability claim.
Historical E11 ordered-startup PASS remains scoped; these new gaps are separately retained.

| Current claim | iPhone18.2 | iPhone27.0 |
|---|---|---|
| Baseline native geometry | FAIL2048px,2 dimension assertions | FAIL2048px,2 dimension assertions |
| Baseline actual unit | TIMEOUT124, assertions incomplete | FAIL1/3 functions,2/8 parameter runs |
| After native exact renderer | PASS14/14,1200px/orientation/fallback | PASS14/14,1200px/orientation/fallback |
| After actual selected unit | PASS3/3 functions,8/8 parameter runs | PASS3/3 functions,8/8 parameter runs |
| Unsigned Debug TchopApp + Ocean | PASS both | PASS both |

Xcode27.0 build27A266a, SDKiPhoneSimulator27.0; runtimes18.2/27.0, not two SDK versions.
Native component uses actual renderer slices plus fixture-only direct-file resolver;
app fallback/cache/state integration remains outside that claim. Invalid/missing image,
video and PDF preserve nil. Existing FoundationModels package deprecation untouched;
baseline27 fixture QoS warning retained, no blanket warning-free claim. Both selected phones Shutdown.
Source current SHA256: View2322c43b56437039ba3aeefdd2dfc7559308513eda4d706346f6c1fd64b4c0b8;
PBX8c3f7c9cf8ed6b4fe13975e4d0523b89aa378a68045d9264201d6e0c8957a47b;
new test66c520d9da9eaa9d82e3f915856255e864c75a230910e9bdf47d57388fd967f3.
Frozen pre-review hashes remain immutable in frozen-inputs.json. Current producer trace
rejects definite P1 URL-replacement impact; lazy-lifetime cancellation overlap, decoded
cache budget, aggregate admission/PDF/cancellation latency remain unverified hypotheses.
No current confirmed defect is silently waived; no broad app architecture/cache-policy fix.

Current5-file evidence synchronization is subject to publication gates and separate
external exact-SHA/remote receipt. Client source/tests stay uncommitted; no client Git permission inferred.
No raw diagnostic bundles or reference-mode records belong in canonical docs.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
'''
p.write_text(s)

p=v/owned[0];s=p.read_text().replace('test targets metadata only','selected TC-MP01 existing-unit suite runtime verified; other unit/UI coverage unverified')
s=s.replace('strict first-read order verified scoped in E11; no general release or inherited status','strict first-read order verified scoped in historical E11; latest TC-MP01 comparison PARTIAL_PROCEDURAL, LIB-004 OPEN; NOT_READY_FOR_GENERAL_RELEASE or inherited status')
s=s.replace('completed TC-W4-01/E11 evidence and current prepared TC-MP01 media-preview lifecycle card; two bounded observer grants confirmed; execution pending.','completed TC-W4-01/E11 and TC-MP01 bounded video-preview correction/QA; two observer grants consumed, strict Library comparison PARTIAL.')
p.write_text(s)

p=v/owned[1];s=p.read_text().replace('Project SHA-256 a915c271ddb824b5548a6a8192ec7b5af761517e6eb9abbf1ba4bf8618d10ffb.','Current project SHA-2568c3f7c9cf8ed6b4fe13975e4d0523b89aa378a68045d9264201d6e0c8957a47b.\nIntake project SHA-256a915c271ddb824b5548a6a8192ec7b5af761517e6eb9abbf1ba4bf8618d10ffb; TC-MP01 added only one existing-unit source membership.')
s=s.replace('| 11 metadata only |','| 12; selected TC-MP01 suite verified |')
a=s.index('## Current prepared task card — TC-MP01')
s=s[:a]+'''## Current completed bounded task — TC-MP01

'''+common+'''
Current source SHA256 View2322c43b56437039ba3aeefdd2dfc7559308513eda4d706346f6c1fd64b4c0b8,
new test66c520d9da9eaa9d82e3f915856255e864c75a230910e9bdf47d57388fd967f3;
media model78825d4c2e4037ecc35566779d2d616b2cd885f1adb712955d427f563a87b9d3 unchanged.
Both host Sources154/widget5/share27 unchanged; unit now12, UI1 unchanged.
Only selected FeedMediaPreviewRendererTests executed; other unit/UI coverage not implied.
Current3-file source/test patch remains working-tree-only. Historical structural intake
scope/clean project observation above is not a current clean-source claim.
[Canonical result and exact claim matrix](../../tasks/new-task-be0b/ios-project-work-system-plan.md#current-tc-mp01-result--2026-10-05).
Local exact artifacts resolve under repository-root .zenflow/tasks/new-task-be0b/;
revalidate source/mode/current permissions before reuse, never derive authority from memory.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
'''
p.write_text(s)

for name in ['plan.md','handoff.md']:
    (w/'.zenflow/tasks/new-task-be0b'/name).write_text((v/'tasks/new-task-be0b'/name).read_text())
card=r/'card.md';s=card.read_text();s=s.replace('PREPARED_OBSERVER_GRANT_CONFIRMED.','OBSERVATIONS_PARTIAL; BOUNDED_VIDEO_FIX_QA_PASS.')
a=s.index('- [ ] Actual OFF review');b=s.index('Proposed comparison:',a)
s=s[:a]+'''- [x] Actual OFF/ON observations completed; strict startup/scope PARTIAL, no clean comparison PASS.
- [x] Parent adjudication:0 new defects/remedies,2 evidence refinements; causality/cost unknown.
- [x] Narrow confirmed video1200px envelope fix; unit/native both iPhones and4 host builds PASS.
- [x] Compact canonical evidence synchronized for publication gates; exact remote receipt external.
- [ ] Human chooses next significant Library approach; no additional chats/MCP authorized.

Current outcome: regression/qa-receipt.json and parent-adjudication.json. Both records
ON/AUTO with pre-canary ON hashes restored/preserved;104/107 comparison fingerprints unchanged,
only approved View/PBX and exact authorized TC transition differ, plus new selected test. Baseline18.2 timeout UNKNOWN and27
real FAIL retained. General Library NOT_READY_FOR_GENERAL_RELEASE, LIB-004/TC-L02 OPEN.
The following comparison/verification text records the original preparation, not pending
execution or a renewed grant.

'''+s[b:]
card.write_text(s)
print('Saved exact QA receipt; synchronized5 owned canonical files and local task mirrors. No client Git mutations.')
