from pathlib import Path
import hashlib, json

ROOT = Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
VAULT = Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
OUT = Path(__file__).resolve().parent
contract = json.loads((OUT / 'contract.json').read_text())
text = {}
for name, digest in contract['before_sha256'].items():
    path = VAULT / name
    assert not path.is_symlink()
    data = path.read_bytes()
    assert hashlib.sha256(data).hexdigest() == digest, name
    text[name] = data.decode()
for name in ['plan.md', 'handoff.md']:
    assert (ROOT / '.zenflow/tasks/new-task-be0b' / name).read_text() == text['tasks/new-task-be0b/' + name]

pointer = '''**Current status: CLOSED_SCOPED_BY_USER — 2026-10-05.** Human «заканчивай»
after the offered experimental-Library closure selects completion of this cycle.
Core W1–W5 and authorized finite pilot/repair execution are complete in their recorded
scopes. Library remains EXPERIMENTAL / NOT_READY_FOR_GENERAL_RELEASE; LIB-004 P2 OPEN.
This supersedes earlier continue/pending-choice/full-general-acceptance instructions;
it does not turn F06 partial evidence or any unavailable check into PASS.
Closure decision/exception: NT-BE0B-CLOSE-01 in the canonical main plan.
No further action is pending in this accepted cycle. Resume only under a new explicit task.

'''
for name in ['plan.md', 'handoff.md']:
    key = 'tasks/new-task-be0b/' + name
    lines = text[key].split('\n', 1)
    lines[0] = '# Closed cycle — new-task-be0b' if name == 'plan.md' else '# Closed task — new-task-be0b'
    text[key] = lines[0] + '\n\n' + pointer + lines[1].lstrip('\n')
    text[key] = text[key].replace('## F01–F06 current closeout — confirmed continuation',
                                '## Previous F01–F06 closeout — before user closure')
    text[key] += '''
## Final task state

- [x] Human selects closure with experimental Library; NT-BE0B-CLOSE-01 recorded.
- [x] Preserve verified QA and its limits; no additional pilot/review/runtime cycle.
- [x] Main decision and both local mirrors synchronized; exact publication receipt is external.

TC/BG recorded ON/AUTO remains unchanged. Cycle-specific discretionary Library-switching
and pilot/runtime authority ends; consumed observer grants do not carry into future work.
LIB-004 P2 OPEN, F01 verifier P3 and TC-L02 P3 remain explicit outside this closed cycle.
No general Library rollout or app release is accepted. Source remains uncommitted;
foreign work, raw failures/results and paused human decisions are retained.
Publication evidence: active `final-acceptance/user-closure/publication-receipt.json`.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
'''

key = 'tasks/new-task-be0b/ios-project-work-system-plan.md'
first, rest = text[key].split('\n', 1)
text[key] = first + '\n\n' + pointer + rest.lstrip('\n')
text[key] = text[key].replace('## Current result and authority', '## Earlier result and authority — historical')
text[key] = text[key].replace('### Current confirmed continuation and final evidence',
                            '### Previous confirmed continuation — before user closure')
text[key] += '''
## NT-BE0B-CLOSE-01 — user-selected cycle closure

- Title/status/date: Close the current improvement cycle with experimental Library;
  ACCEPTED / 2026-10-05 (Europe/Kyiv).
- Owner/app/task: human user / multi-project work-system / new-task-be0b only.
- Authority: human «заканчивай» directly after the recommendation to finish this cycle
  with experimental Library versus preserving full general acceptance for a new approach.
- Affected requirement: the earlier full common-improvement goal and reusable stop rule
  requiring a higher-authority exception when P2 remains. This explicit task-local decision
  permits cycle closure while LIB-004 P2 OPEN blocks general Library release.
- Local exception/scope: CLOSED_SCOPED_BY_USER for current implementation/pilot cycle.
  Core VERIFIED_REQUIRED_CORE_MATRIX and scoped F01–F05/F02 repair QA remain accepted;
  F06 observations were executed but strict quality/cost acceptance remains unpassed.
  General acceptance is neither claimed nor waived by this closure.
- Rationale/risk: current authorized execution is exhausted; repeated same-case reviews
  do not establish incremental value. Library added0 confirmed defects/remedies; costs
  UNKNOWN and procedural limitations persist. Experimental use is confined to already
  selected pilots/modes; no new rollout, selector adoption, service or provider follows.
- Verification: reuse exact66 after assertions,5 package module compile results and4
  unsigned host builds only at unchanged source/provenance hashes. Final docs diff,
  mirrors/preservation and canonical exact-HEAD/remote gates are checked for this closure.
- Expiration/review trigger: task is closed. A future explicit Library-improvement or
  general-release request must reassess LIB-004 and obtain its own necessary permissions.
  Current-cycle temporary Library transitions and discretionary pilot/runtime work end.
  Consumed observer grants are not reusable; existing TC/BG ON/AUTO records are preserved.
- Storage/promotion: this owning task plan; linked by plan/handoff. Promotion allowed: no.

F01 verifier P3 and unrelated TC-L02 P3 stay reported; source changes remain uncommitted.
iPad/physical/actual VoiceOver remain OMITTED_BY_USER globally. Existing failures, modes,
paused app decisions and foreign work are preserved; no cleanup or additional QA is run.
No pending human decision or automatic continuation remains for this cycle. Canonical
publication evidence is kept externally at active
`.zenflow/tasks/new-task-be0b/final-acceptance/user-closure/publication-receipt.json`.
This exception applies only to new-task-be0b and never weakens another task or reusable rule.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
'''

assert sum(len(text['tasks/new-task-be0b/' + n].split()) for n in ['plan.md', 'handoff.md']) <= 3500
for name, value in text.items():
    (VAULT / name).write_text(value)
for name in ['plan.md', 'handoff.md']:
    (ROOT / '.zenflow/tasks/new-task-be0b' / name).write_text(text['tasks/new-task-be0b/' + name])
(OUT / 'sync-receipt.json').write_text(json.dumps({
    'status': 'USER_CLOSURE_DOCUMENTED', 'owned': list(text),
    'after_sha256': {n: hashlib.sha256(t.encode()).hexdigest() for n, t in text.items()},
    'combined_plan_handoff_words': sum(len(text['tasks/new-task-be0b/' + n].split()) for n in ['plan.md', 'handoff.md']),
    'mirrors': '2/2 byte-identical', 'new_shared_rule': False}, indent=2) + '\n')
print('Exact3 task docs and2 mirrors updated; task-local closure, Library gate preserved')
