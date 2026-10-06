from pathlib import Path
import hashlib,json,subprocess
from datetime import datetime,timezone
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault');r=w/'.zenflow/tasks/new-task-be0b/final-acceptance';r.mkdir(exist_ok=True)
base='3955d424901a411bdae1e71bb3d37eed0f212eb0'
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=v).decode().strip()==base
assert not subprocess.check_output(['git','status','--porcelain'],cwd=v).strip()
owned=['tasks/new-task-be0b/plan.md','tasks/new-task-be0b/handoff.md','tasks/new-task-be0b/ios-project-work-system-plan.md']
grant='''Latest actual human2026-10-05: «смотри, пока что реальных задач не ожидается,
поэтому если нужно запускать пилоты и так далее, делай это, нужно в новом чате,
делай это и иди к финалу, заканчивай все пункты». This supersedes waiting for a real
task and permits necessary bounded pilot/new-chat work toward this common plan.
It does not waive findings or retained secrets/host/config/installers/automations,
physical-device/iPad exclusions, foreign/old-checkout preservation or client/engine Git restrictions.
'''
section='''
## Final acceptance execution — F01–F06

'''+grant+'''
Current owner: one fresh GPT-6.1 Sol/high integrator, эконом; parent validates final
evidence/publication. One coordinated writer, no autonomous task tree. At most2 additional
fresh read-only comparison chats if needed for Library evidence; necessary built-in
project/creation/status/result metadata only, no child agents/MCP/messages. No retries
or extra comparison waves without a concrete new finding and renewed scope assessment.
Tests/fixtures and relevant builds selected under current delegated QA; iPhone18.2+27
for iOS runtime. Each implementation block≤3 source files; isolated fixture data only.
Existing PASS reused, no pilot feature/backlog development or forced positive result.

| Leaf | Finite output and evidence required |
|---|---|
| F01 | Standalone package workflow on an actual existing package (prefer AppValidationCore): exact Package.swift/source/test universe, isolated package verification and relevant platform evidence; unknown Library selector is not inherited ON. |
| F02 | Migration/concurrency on actual adopted AppDatabase mechanism with disposable old/new data fixtures: version/preservation/failure/rollback/reopen and actor isolation; no real user-data reset, no production migration invention. |
| F03 | Design-assets/Figma route: actual scoped local/exported inputs, ownership/mapping/ambiguity and missing-provider handling. Distinguish offline export acceptance from unperformed live Figma access; no installer or fake remote proof. |
| F04 | CI/signing route: authoritative membership and permission/secret/output boundaries, manual/off and unavailable credential cases, reuse unsigned-build evidence. No active workflow, host provisioning or external CI execution from this grant. |
| F05 | Additional supported platform: existing package macOS/native availability and selected iPhone matrix; unsupported/uninstalled environments explicitly refused. No platform installation or removed physical/iPad checks. |
| F06 | Library quality/cost: fresh predeclared scoped scenarios on previously unexamined actual source; full KB before Library, useful delta/false positives/misses/authority and actual elapsed/read overhead. Use corrected TC-OP02 protocol, preserve negative results/UNKNOWN tokens. No universal savings or automatic LIB-004 closure. |

Close each row only for its observed universe and explicit remaining gates; record
not_run/blocked honestly. Attempt actual bounded checks rather than substituting a new
document for evidence. No synthetic case is called a production flaw. If an external
capability/credential is needed but denied, complete the route/refusal evidence and
retain that external acceptance gap; do not invent a waiver. General release remains
blocked by any confirmed P0–P2 or unmet mandatory evidence. Final report must separate
completed execution rows, accepted system scope, Library verdict and external remaining actions.

Existing pilot choices are delegated. Prefer available source under .zenflow; public
Countries/Firefox/Ghibli acceptance repositories may be read in exact bounded scopes,
never whole-app revived. Library installed in Tchop/BG at pin3c42e490...; don't adopt
or inherit mode into new selectors. Preserve final TC ON/AUTO and BG exact original record.
Canonical3 task docs currently owned by parent preparation are transferred to the
fresh integrator for synchronization/final gates; other canonical edits need an exact
in-scope contract before mutation. Commit/push only AIZenflowDocumentation after gates.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
'''
before={p:hashlib.sha256((v/p).read_bytes()).hexdigest() for p in owned}
for rel in owned:
 p=v/rel;s=p.read_text();s+='\n'+(section if rel==owned[2] else '## Current final acceptance — human-authorized execution\n\n'+grant+'\n[Finite F01–F06 matrix](ios-project-work-system-plan.md#final-acceptance-execution--f01f06) owns the next execution.\nNo longer waiting for a real task. One fresh integrator owns pilot execution and exact final publication; no false PASS or removed requirements.\n\n'+ ('- [ ] F01 standalone package.\n- [ ] F02 isolated migration/concurrency.\n- [ ] F03 design-assets/Figma input/refusal.\n- [ ] F04 CI/signing boundaries.\n- [ ] F05 additional platform.\n- [ ] F06 Library quality/cost and final verdict.\n' if rel==owned[0] else '')+'\n**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**\n');p.write_text(s)
for n in ['plan.md','handoff.md']:(w/'.zenflow/tasks/new-task-be0b'/n).write_text((v/'tasks/new-task-be0b'/n).read_text())
(r/'dispatch-contract.json').write_text(json.dumps({'utc':datetime.now(timezone.utc).isoformat(),'base':base,'owned_canonical_files':owned,'parent_before_sha256':before,'parent_after_sha256':{p:hashlib.sha256((v/p).read_bytes()).hexdigest() for p in owned},'grant':'Actual latest human quote in F01–F06; no self-issued authority','client_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=w).decode().strip(),'scope':'One fresh integrator for finiteF01–F06; at most2 necessary comparative read-only chats; constrained retained prohibitions','protected_receipt':str(w/'.zenflow/tasks/new-task-be0b/library-utility-tc-mp01/protocol-correction/publication-receipt.json'),'parent_ownership_transfer':'exact3 files are preparation, not foreign edits; fresh integrator reviews whole candidate before publication'},indent=2,ensure_ascii=False)+'\n')
print('Prepared finiteF01–F06 execution contract; owned3 dirty canonical docs transferred explicitly; no runtime/new chat dispatched yet.')
