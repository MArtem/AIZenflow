from pathlib import Path
import hashlib
import json

CLIENT = Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
VAULT = Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
OUT = CLIENT / '.zenflow/tasks/new-task-be0b/final-acceptance'
contract = json.loads((OUT / 'dispatch-contract.json').read_text())
for name, digest in contract['parent_after_sha256'].items():
    assert hashlib.sha256((VAULT / name).read_bytes()).hexdigest() == digest, name

short = '''
## F01–F06 observed closeout — 2026-10-05

Permitted execution is complete at the scope below; common final acceptance is
NOT_READY. F02 iPhone runtime and F06 fresh comparison remain mandatory gaps,
not waivers. Core W1–W5/E11 remains VERIFIED_REQUIRED_CORE_MATRIX; Library remains
NOT_READY_FOR_GENERAL_RELEASE, LIB-004 P2 OPEN. No app release claim.

- [x] F01 actual standalone AppValidationCore: native XCTest11/11 PASS;
  original verifier FAIL on its own README's app-specific wording, reported P3.
- [ ] F02 final acceptance: actual adopted three-file AppDatabase native fixture
  execution PASS16 assertions across6 process phases (including repeated seeding),
 20 concurrent writes, preserved old values, rollback/reopen and injected actual
  SwiftData migration failure. SDK27 iOS strict compile PASS; iPhone18.2+27 runtime BLOCKED.
- [x] F03 scoped offline/refusal route: two actual SVG exports compile into Assets.car;
  geometry and both-host ownership checked. Live Figma/pixel/UI verification NOT_RUN.
- [x] F04 scoped boundary route: filtered selected memberships, manual/read-only
  workflow metadata; four unchanged unsigned host build results REUSED. CI invocation
  withheld; signing unavailable/BLOCKED, no credential access or release PASS.
- [x] F05 additional-platform native scope: actual macOS package/runtime evidence;
  other declared package platforms/minimum-OS runtime NOT_RUN. F02 iPhone gap retained.
- [ ] F06 fresh independent quality/cost acceptance: first dispatch rejected;
 0 observer chats created. Same-session KB-before-Library yielded0 confirmed new
  defects and a useful migration/downgrade evidence refinement, not causal proof.
  Fresh-pair metrics unavailable; tokens/account cost UNKNOWN; savings NOT_ESTABLISHED.

Automatic approval review rejected Simulator boot/spawn/shutdown because the inherited
grant was not accepted and CoreSimulator uses paths outside .zenflow. It separately
rejected creating the first read-only comparison chat because specific prompt disclosure
authority was not accepted. Direct-human questions are pending; no retry or bypass.
Next bounded continuation requires those direct grants: only two existing iPhones and
at most two20-minute read-only comparison chats. No replacement pilot/task tree.

Actual source remains unchanged and uncommitted; original failures, foreign edits,
paused follow-ups and excluded iPad/physical/actual VoiceOver checks retained.
TC restored ON/AUTO; BG exact initial ON/AUTO record preserved. Local evidence is
`.zenflow/tasks/new-task-be0b/final-acceptance/` in the active worktree; exact publication
receipt belongs there, outside tracked canonical documents. Parent checks the final
receipt; publication of this truthful blocked status does not close the remaining gates.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
'''

detail = '''
### Observed final acceptance results — 2026-10-05

Bounded contract: exercise existing mechanisms on disposable fixtures, preserve source,
user data, modes and foreign work; distinguish producer/consumer membership from actual
runtime invocation. Version state advances only after a successful migration callback;
failed writes roll back; failure/reopen must preserve seeded data. No success is inferred
from compilation, refusal, mode expectation, unavailable capability or conditional finding.
Outputs/caches/logs stay in .zenflow. Documentation-only synchronization is restricted to
these three transferred task files plus two local plan/handoff mirrors.

| Leaf | Observed evidence | Acceptance limits |
|---|---|---|
| F01 | AppValidationCore's exact19-file package universe copied unchanged; Swift6 strict native test execution11/11 PASS. | Original verify_package.sh FAIL on README app-specific wording (P3 tooling conflict); no full verifier PASS, inactive Library inheritance or declared iOS/tvOS/watchOS runtime claim. |
| F02 | Exact adopted core/actor/main-context source compiled unchanged. Disposable V1/V2 preserves old fields; typed error/write rollback, cooperative cancellation rollback,20 actor writes, separate-process reopen, callback version failure/retry/idempotence and injected actual SwiftData migration failure with old-store reopen observed.16 PASS assertions across6 phases. SDK27 deployment17 strict iOS compile PASS. | Simulator service failed in sandbox; elevated launch rejected before execution.18.2+27 runtime BLOCKED. Cancellation observed wrapped as transactionFailed, not propagation PASS. No actual app schema/caller/data, downgrade, disk-full/crash-interruption or app-release proof. |
| F03 | Actual ShellCreateAdd24×24 and PencilSimple22×22 SVG/metadata inputs and callers checked; both-host resource membership; isolated catalog actool compile PASS. | Existing local-export provenance only; Figma file/node UNKNOWN. Missing live provider and ambiguous replacement withheld; these are route applications, not executable control tests. Simulator diagnostics retained; no pixel-match/UI/accessibility runtime PASS. |
| F04 | Two exact scheme memberships filtered before output; scoped PBX membership; actual manual-quality workflow_dispatch and contents:read metadata. Four prior unsigned host builds reused at unchanged source/PBX/client HEAD. | Lexical metadata only, no general YAML validation. Selected-app QC DEFERRED; workflow existence does not establish adoption. CI off/manual execution withheld, signing credentials unavailable; no credential probe, archive or release PASS. |
| F05 | Existing macOS additional-platform evidence: AppValidationCore XCTest and actual AppDatabase SwiftData fixtures; current native runtime with SDK27. | Declared minimum deployment is not minimum-OS execution proof. Other declared platforms NOT_RUN; no install or unsupported/non-Apple success. iPhone execution remains F02's mandatory gap. |
| F06 | Three actual previously unexamined AppDatabase files frozen; own34-name pin checked; KB provisional hash saved before active Library routes. Same-session retained conclusions,0 added confirmed defects; explicit downgrade/failure evidence refinement informed F02 extra fixture. | First create_thread rejected;0 successful observer chats. No independent accepted OFF/ON comparison, measured misses/false positives or causal cost proof. Tokens/account cost UNKNOWN; savings NOT_ESTABLISHED; LIB-004 P2 OPEN. |

Initial macro sandbox failure, harness isolation compile failure (fixture corrected with
concurrent worker), original verifier failure and Simulator refusal remain in local logs.
Runtime CoreData diagnostics were retained; no warning-free claim. No production source
or existing app/package test file changed. Source/mode/pin preservation is checked again
at publication. Candidate severities are conditional; no synthetic flaw is promoted to
confirmed production P0–P2. Unrelated TC-L02 P3 remains untouched.

Execution rows F01/F03/F04/F05 are closed only for the stated scopes, with limitations
explicit. F02 and F06 required acceptance remain open after automatic approval review
rejected the inherited Simulator and chat-disclosure grants. Direct-human questions are
pending; there was no bypass, extra observer, retry wave or new permission inferred.
Overall final acceptance NOT_READY; W1–W5/E11 core VERIFIED_REQUIRED_CORE_MATRIX unchanged;
Library NOT_READY_FOR_GENERAL_RELEASE and no app release verdict. Resume only the exact
remaining two-iPhone fixtures and at most two20-minute read-only comparisons if directly
authorized; otherwise retain this truthful blocked closeout. Old waiting-for-real-task
instructions above are historical and superseded by the latest human pilot instruction.

Evidence root: active worktree `.zenflow/tasks/new-task-be0b/final-acceptance/`:
F01 logs/source-universe; F02–F04 receipts; f05-receipt.json; F06 frozen/provisional/receipt;
initial/final-preservation and external publication receipt. Fresh observer elapsed/read
overhead is unavailable, not zero. The integrator did not execute TC-OP02 fresh-observer
acceptance; historical procedural failures are not erased by this same-session work.
Canonical publication requires exact final diff, HEAD, clean state and independent remote
SHA gates. Publication itself does not close F02/F06 or LIB-004.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
'''

for leaf in ['plan.md', 'handoff.md']:
    p = VAULT / 'tasks/new-task-be0b' / leaf
    text = p.read_text()
    text = text.replace('## Current TC-OP02 — bounded protocol correction', '## Historical TC-OP02 — bounded protocol correction')
    text = text.replace('## Current next step — TC-OP02', '## Historical next step — TC-OP02')
    text = text.replace('## Current final acceptance — human-authorized execution', '## Final acceptance authority — human-authorized execution')
    text = text.replace('- [ ] F01 standalone package.\n- [ ] F02 isolated migration/concurrency.\n- [ ] F03 design-assets/Figma input/refusal.\n- [ ] F04 CI/signing boundaries.\n- [ ] F05 additional platform.\n- [ ] F06 Library quality/cost and final verdict.', 'Current checkbox outcomes are recorded once in the observed closeout below.')
    p.write_text(text.rstrip() + '\n' + short)
    (CLIENT / '.zenflow/tasks/new-task-be0b' / leaf).write_bytes(p.read_bytes())
p = VAULT / 'tasks/new-task-be0b/ios-project-work-system-plan.md'
p.write_text(p.read_text().rstrip() + '\n' + detail)
print(json.dumps({'changed': contract['owned_canonical_files'], 'mirrors': 2,
                  'active_plan_handoff_words': sum(len((VAULT / 'tasks/new-task-be0b' / n).read_text().split()) for n in ['plan.md', 'handoff.md'])}))
