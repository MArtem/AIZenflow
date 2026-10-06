from pathlib import Path
import json,hashlib,subprocess

ROOT=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
VAULT=Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
OUT=ROOT/'.zenflow/tasks/new-task-be0b/final-acceptance'
BASE='cd36cc5664ac7155eb268b6af41fdab5298d6cee'
freeze=json.loads((OUT/'f06/parent-confirmed/freeze.json').read_text())
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=VAULT,text=True).strip()==BASE
assert not subprocess.check_output(['git','status','--porcelain=v1'],cwd=VAULT,text=True).strip()
for p,h in freeze['document_sha256'].items(): assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h,p

short='''## F01–F06 current closeout — confirmed continuation

The human confirmed both remaining actions in the parent chat («подтверждаю»), then
separately approved «Разрешаю patch и необходимую QA». Root performed Simulator,
exactly2 read-only OFF/ON chats and the guarded6-source correction; integrator owns
this single3-document synchronization and publication. Those exact observer grants
are consumed. No new automatic pilot/chat/QA loop follows.

- [x] F01 native AppValidationCore11/11; original verifier FAIL remains reported P3.
- [x] F02 component migration/concurrency runtime: original mechanism16 assertions
  per iPhone18.2/27; separately approved cancellation correction, after33 per runtime
  (66 total), including migration/rollback/reopen. Six baseline type mismatches per
  runtime retained; public contract fixed, shipped CancellationError producer unproven.
- [x] F03 offline two-SVG/catalog/mapping/refusal scope; live Figma NOT_RUN.
- [x] F04 static/manual/off/signing-unavailable scope; new affected-source unsigned
  TchopApp/Ocean builds PASS on both destinations (four fresh builds).
- [x] F05 native additional-platform scope; all5 AppDatabase package modules compile
  with Swift6 strict diagnostics. Minimum-OS and other declared runtime coverage NOT_RUN.
- [x] F06 exactly2 fresh authorized observations executed before any source change.
  Both PARTIAL_PROCEDURAL; strict pair withheld. Library added0 confirmed defects/remedies.
- [ ] F06 general quality/cost acceptance: LIB-004 P2 OPEN; Library
  NOT_READY_FOR_GENERAL_RELEASE. Plans prime the case; prompt-path clarification,
  late reads/probes and metrics prevent a blind/causal comparison. Costs UNKNOWN,
  savings NOT_ESTABLISHED. Human decision on this remaining gate, not repeated passed QA.

Core W1–W5/E11 remains VERIFIED_REQUIRED_CORE_MATRIX. Authorized component execution
and cancellation-fix QA are closed scoped; common general acceptance remains NOT_READY.
No actual app schema/user-data, all-backend cancellation or app-release claim.
In-memory version-store checks do not prove durable checkpoint relaunch/crash atomicity.
Old seeding occurs on two distinct stores, not seed-repeat idempotence. Package driver
language-mode warnings and existing host AI deprecation retained; no warning-free claim.
TC-L02 P3 remains untouched. Six source files remain uncommitted; client HEAD unchanged.
Import-only source-copy adaptation, outside-six foreign work and paused follow-ups preserved.
TC finalON/AUTO, BG exact initialON/AUTO; both selected phones verified Shutdown.

Historical initial sandbox/macro/harness failures and automatic approval rejections remain
in evidence; direct human confirmation subsequently enabled root execution. Approval is
no longer pending and these earlier refusals are not current runtime/chat blockers.
Evidence root in active worktree: `.zenflow/tasks/new-task-be0b/final-acceptance/`;
`f02/parent-resume/runtime-receipt.json`, `f06/parent-confirmed/parent-adjudication.json`,
`cancellation-regression/{application-receipt,semantic-review,qa-receipt}.json` and
`closeout/publication-receipt.json`. Parent independently reviews final publication.
iPad/physical/actual VoiceOver remain OMITTED_BY_USER; liveFigma/CI/signing remain unperformed.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
'''

detail='''
### Current confirmed continuation and final evidence

This section supersedes the historical blocked snapshot above. Human in parent chat
confirmed both requests («подтверждаю»), including necessary existing CoreSimulator
operations outside .zenflow and exactly2 bounded read-only comparison chats. Root
performed those actions directly, keeping project outputs/caches/logs inside .zenflow.
After both observers were terminal, the human separately approved «Разрешаю patch и
необходимую QA»: exact6 AppDatabase source files, three mechanism/mirror pairs,24 additions.
This is a scoped override of the earlier three-source block bound, not a global exception.
Integrator only synchronizes the3 transferred task docs and their2 local mirrors.

Change contract: update observed state from terminal evidence; preserve old failures,
foreign/source ownership and six-source candidate identities. Main matrix owns scope;
plan/handoff mirror its checkboxes/verdict. OFF/ON freeze ends before approved source
mutation. Failure, partial protocol, missing metrics or unavailable provider never PASS.
Publication of the evidence does not change Library requirements or authorize new work.

| Leaf | Current terminal evidence | Acceptance boundary |
|---|---|---|
| F01 | Existing AppValidationCore native XCTest11/11 PASS reused; exact19 original package files preserved. | Original verifier FAIL on own README wording, P3 reported; no package release/minimum-OS/all-platform/warning-free claim. |
| F02 | Root resumed original disposable migration fixture16 assertions on each iPhone18.2/27. Approved default cancellation correction in exact6 active/vault sources; prepatch6 type mismatches per runtime retained. After17 cancellation +16 migration/reopen assertions per runtime=33 each/66 total; strict SDK27/deployment17 compile, both phones Shutdown. | CLOSED_SCOPED component/runtime/repair QA. Six closure-thrown cancellation boundaries preserve CancellationError; writes roll back before rethrow, unsuccessful migration callback does not advance fixture version. No observed shipped cancellation producer, real app schema/data, all-backend propagation, downgrade or crash-atomic checkpoint proof. |
| F03 | Existing offline SVG geometry/catalog compile and both-host mapping evidence reused unchanged. | Scoped offline/refusal closure only; live Figma/node provenance/pixel-match/UI verification NOT_RUN. |
| F04 | Root ran four fresh unsigned Debug TchopApp/Ocean builds on destinations18.2/27 after the affected-source patch, all exit0; authoritative membership unchanged. Earlier workflow/manual/off refusal evidence retained. | Fresh patch builds replace prior reused builds as affected-source evidence. No actual CI run, signed archive, provisioning/credential probe or release PASS; app QC remains DEFERRED. |
| F05 | All5 standalone AppDatabase modules compiled natively with Swift6/strict complete/warnings-as-errors, preserving source-only import adaptation; native AppValidationCore test evidence retained. F02 iPhone runtime now observed. | Compile/runtime scopes distinguished. SwiftPM driver language-mode override warnings retained; declared minimum native OS and other package platforms not executed. |
| F06 | Exactly2 fresh GPT-6.1 Sol/high OFF/ON observers completed at frozen cd36cc5/current source before patch. Both own statuses observed; exact34 pin pairs, filtered two-scheme/source memberships, ON immutable full-KB hash before Library. Parent adjudicated0 new confirmed Library defects and0 new remedies. | Execution complete scoped; strict pair WITHHELD. OFF mandatory local health read late; ON nested absence probes late and metrics partial. Mandatory plans prime prior same-case conclusions; path clarification means prompts not byte-identical. No blind/causal discovery, complete precision/recall or general cost benefit. LIB-004 P2 OPEN. |

The correction preserves closure-thrown cancellation in actor/main read/write/batch and
the common migration runner; it does not auto-abort from a cancelled flag, remove read
context caller discipline, make context-wide rollback narrower or make migration callback
and durable checkpoint atomic. Typed/generic mapping remains unchanged. Actual app caller
inspection did not establish CancellationError production or reliance on previous wrapping;
the repair applies the public default contract, not a proven shipped bug or Library-added fix.
CoreData-specific manager mapping is unchanged. Core mirrors match byte-for-byte; existing
AppDatabaseCore import removal in active main/actor copies is preserved.

The two old phases seed distinct success/failure stores, not repeat-seed idempotence.
Cancellation/version checkpoints use an in-memory fixture store; separate-process SwiftData
reopen proves only the disposable store cases, not UserDefaults checkpoint durability or
crash interruption. Existing FoundationModelsOnDeviceAIManager86 deprecation in host builds
and package-driver language-mode warnings are retained; no warning-free or broad app PASS.
F01 verifier P3 and unrelated TC-L02 P3 remain reported. No existing app/package test file
was changed by this correction; no client commit/push or package adoption occurred.

Actual observer metadata turn durations OFF1088.912s/ON946.995s, combined2035.907s.
Their wall receipts report1046.956s/903.935s; these differ from task metadata and are not
continuous comparable monotonic measurements. OFF text571596 logical bytes including
rereads (518222 unique); ON641711 requested (614051 unique), including51811 Library
route bytes and80.905s wall Library stage. Definitions/priming/procedural differences
preclude causal savings. Physical/context bytes, tokens and account cost UNKNOWN.
Historical failed dispatch plus the two subsequently authorized successful chats are
distinct; both2 observer grants consumed. No replacement observer or retry wave authorized.

Root receipts under active `.zenflow/tasks/new-task-be0b/final-acceptance/`:
`f02/parent-resume/runtime-receipt.json`, `f06/parent-confirmed/parent-adjudication.json`,
`cancellation-regression/{application-receipt,semantic-review,qa-receipt}.json`, after/baseline
runtime receipts and exact host/package results. Integrator verifies terminal log counts,
source candidate SHA, exact outside-six/owned-mirror foreign diff and final mode preservation;
full final-doc diff and exact-HEAD/clean/remote publication receipt is stored separately in
`closeout/publication-receipt.json`, never inserted as a self-referential tracked SHA.

Final verdict: authorized finite execution and F02 correction QA completed scoped;
core VERIFIED_REQUIRED_CORE_MATRIX unchanged. Common general acceptance NOT_READY,
Library NOT_READY_FOR_GENERAL_RELEASE, LIB-004 P2 OPEN; no app-release claim. Earlier
approval rejections are history, not current pending authority. Preserve TC finalON/AUTO,
BG exact initialON/AUTO, shutdown phones, foreign work/paused decisions and global user
omissions. Stop automatic comparisons and repeated passed QA. The next necessary human
decision concerns the remaining general Library acceptance/evidence requirement; no silent
waiver, new pilot, service, corpus expansion or general-ready threshold is introduced.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
'''

for name in ['plan.md','handoff.md']:
 p=VAULT/'tasks/new-task-be0b'/name; text=p.read_text()
 marker='## F01–F06 observed closeout — 2026-10-05'
 assert text.count(marker)==1
 text=text.split(marker)[0].rstrip()+'\n\n'+short
 p.write_text(text); (ROOT/'.zenflow/tasks/new-task-be0b'/name).write_text(text)
p=VAULT/'tasks/new-task-be0b/ios-project-work-system-plan.md'; text=p.read_text()
marker='### Observed final acceptance results — 2026-10-05'
assert text.count(marker)==1
text=text.replace(marker,'### Historical blocked acceptance snapshot — 2026-10-05\n\nThe following checkpoint predates direct confirmation and root execution; its blocked/\npending states and unmodified-source claims are historical. Current outcome follows below.')
p.write_text(text.rstrip()+'\n'+detail)
owned=['tasks/new-task-be0b/'+n for n in ['plan.md','handoff.md','ios-project-work-system-plan.md']]
r={'base':BASE,'owned_files':owned,'before_sha256':freeze['document_sha256'],
 'after_sha256':{n:hashlib.sha256((VAULT/n).read_bytes()).hexdigest() for n in owned},
 'words_plan_handoff':sum(len((VAULT/'tasks/new-task-be0b'/n).read_text().split()) for n in ['plan.md','handoff.md']),
 'contract':'Terminal-evidence update only; exact3 canonical docs+2 local mirrors; retain failures, conditional reachability and general NOT_READY; no source/rules/runtime/mode permission change',
 'root_packet':{n:hashlib.sha256((OUT/n).read_bytes()).hexdigest() for n in ['f06/parent-confirmed/parent-adjudication.json','f02/parent-resume/runtime-receipt.json','cancellation-regression/qa-receipt.json','cancellation-regression/application-receipt.json','cancellation-regression/semantic-review.json']}}
assert r['words_plan_handoff']<=3500
(OUT/'closeout/sync-receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps({'changed':owned,'words':r['words_plan_handoff'],'mirrors':2}))
