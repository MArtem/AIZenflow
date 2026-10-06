from pathlib import Path
v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault'); w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
p=v/'apps/Tchop/PROJECT_CONTEXT.md';s=p.read_text()
s=s.replace('Declared resource/build-phase metadata refreshed below; resource bodies, generated compiler\ninputs and external dependency semantics remain unverified.\nInstalled toolchain/config compatibility and runtime/release evidence unverified.', 'At structural intake, resource bodies/generated inputs/runtime were unverified.\nTC-W4-01 below now verifies the selected AppTab compiler inputs, EN/RU resources and\nlookup path on the current toolchain; broader semantics and release remain unverified.')
s=s.replace('## Current structural task card — TC-SYSTEM-MAP', '## Completed structural task card — TC-SYSTEM-MAP')
s=s.replace('Remaining W4 acceptance: real shared-code/resource task if legitimately selected,\nclaim-specific execution and adverse/mode cases; this docs task does not prove them.', 'This completed structural card alone proves no semantic/runtime acceptance.\nThe current TC-W4-01 card supplies selected source/runtime evidence; saved-mode\nworkflow acceptance remains open.')
p.write_text(s)
p=v/'apps/Tchop/history/tc-w4-01-localization-2026-10-04.md';s=p.read_text().replace('All source inputs equal before/after runs.', 'All four successful host builds used the same post-fix source fingerprints.').replace('\n tab.*.stubDescription.', '\ntab.*.stubDescription.')
p.write_text(s)
p=v/'tasks/new-task-be0b/ios-project-work-system-plan.md';s=p.read_text()
s=s.replace('User2026-10-04 delegates BG-T01 test creation/modification, builds, test execution and\nnecessary Simulator QA.', 'User2026-10-04 delegates current task verification, test creation/modification, builds,\ntest execution and necessary Simulator QA; selected BG-T01 and TC-W4-01 are covered.')
needle='| E7 | [Current verification receipt](../../apps/BattleshipGame/history/bg-t01-verification-2026-10-04.md) | Native12/12, nominal phones18.2/27, AX5 flow and isolated audits/Rotate5/5 each; historical failures preserved, global user omissions, no app release |'
assert needle in s
s=s.replace(needle,needle+'\n| E8 | [Tchop context](../../apps/Tchop/PROJECT_CONTEXT.md), [TC-W4-01](../../apps/Tchop/history/tc-w4-01-localization-2026-10-04.md) | Exact second graph/owned association, five shared preview lookup keys repaired; two hosts, lookup20/20, four builds,17 synthetic reader/selector controls; saved OFF/ADVISORY/cross-mode workflow still open |')
start=s.index('| R01 | Реализованный') if '| R01 | Реализованный' in s else s.index('| R01 | E1 exact identity')
end=s.index('\n\n## 1. Цель',start)
s=s[:start]+'''| R01 | E1/E3 exact Battleship identity; E8 exact Tchop identity and eight-target graph | Named scopes observed; other selectors/platforms not inferred |
| R02 | E3 reviewed first apply; E8 owned second three-file association/post-check | Existing ownership gates complete for named pilots; no automatic future apply |
| R03 | E4 full declared BG source/flow map; E8 Tchop graph and actual preview caller/consumer trace | No whole-Tchop semantic audit or rendered-preview claim |
| R04 | E4 domain facts/unverified rows; E8 thematic localization coverage | Full audit remains a separately chosen task |
| R05 | BG-A01 CLOSED_SCOPED; TC-L01 P3 CLOSED_SCOPED; TC-L02 P3 separate OPEN; LIB-004 P2 OPEN | App preview backlog untouched; library release criteria outstanding |
| R06 | E3/E4/E8 app-owned current cards/history; W4.4.a/b freshness/conflict preservation | Relevant hashes must be revalidated on future changes |
| R07 | E5 BG packet and E8 TC compact contract/permission/consumer card | Observed task preparation for both named canaries |
| R08 | E6/E7 BG ON/AUTO scoped pass; E8 does not borrow ON | ON/ADVISORY full stage and real cross-mode workflow W4.3.b/d OPEN; no uplift claim |
| R09 | E8 complete KB-only task with second layer withheld at UNVERIFIED | Saved OFF complete cycle W4.3.a OPEN; unknown status is not OFF evidence |
| R10 | E1 capability/operator contract; actual withheld agents/MCP and baseline-only QC | No independent reviewer/engine execution claimed |
| R11 | E5/E7 BG final owned change; E8 five-key diff, both consumers/file lists/resources | Named source/output review complete; client Git not authorized |
| R12 | E7 failures/timeout/interruption retained; E8 before assertion and confined build failure retained | No omitted/unavailable result converted to PASS |
| R13 | Actual W3.4.b fresh-chat reconstruction2026-10-04 and E7 resumed verification | E8 current card/handoff refreshed; no fabricated second fresh-chat observation |
| R14 | BG ON/AUTO separated from Tchop UNVERIFIED; mode/grants/readiness distinct | Live saved-mode/profile controls still OPEN;17 E8 fixtures prove only reader/refusal cases |
| R15 | E3/E7/E8 owned diffs and preserved human/dirty state | No whole-root clean claim, no foreign cleanup |
| R16 | E8 declared shared resources/targets; AppTab exact two hosts and actual compiler inputs | Packages/Figma/migration/specialist scenarios remain separate acceptance gaps |
| R17 | Existing PASS reused at unchanged inputs; bounded routing and cards | Token/subscription savings unmeasured; no new telemetry promise |
| R18 | E3/W4.4.d exact unchanged own-entry detach dry-run | Removal not executed; central memory retained |
| R19 | E5/E8 actual contract/decomposition/plan review; corrected consumer hypothesis | Gates observed for named tasks; future tasks still require current analysis |
| R20 | BG and TC system questions/exits; no new product feature; separate TC-L02 backlog | No app expansion or automatic Library adoption |
| R21 | Current human delegation selects self-verification; E7/E8 actual iPhone18.2/27 results | Global iPad/physical exclusions OMITTED_BY_USER; no new permission from memory |'''+s[end:]
for leaf in ('W5.1.a','W5.1.c','W5.1.d','W5.3.a','W5.3.c'):
 s=s.replace('| [ ] '+leaf+' |','| [x] '+leaf+' |')
anchor='## 14. Scope guard — до и после каждого блока'
assert anchor in s
s=s.replace(anchor,'''Current W5 review packet (not an acceptance or release grant):
R01–R21 table above now maps final scoped evidence and exact remaining gaps.
Core verdict W5.1.b **PENDING_USER_SCOPE_DECISION**: named BG/TC source workflows verified,
but saved OFF/ADVISORY/real cross-mode integration remains missing. Library verdict
W5.1.c **NOT_READY_FOR_GENERAL_RELEASE**, LIB-004 P2 OPEN; passing17 codec controls does
not demonstrate stage uplift/cost. App verdict W5.1.d **NO_RELEASE_CLAIM**: selected
BG-A01/TC-L01 scopes closed, unrelated TC-L02 P3 open, no whole-app acceptance.
W5.3.a cleanup decision: retain owned raw failures/results/caches for reproducible
resume; no deletion now and no foreign cleanup. W5.3.b final system publication remains
open until W5.1.b choice; this W4/W5 review packet has its own exact commit receipt.

W5.3.c bounded choices prepared for user:

| Choice | Concrete action / benefit | Limits / authority |
|---|---|---|
| A — bounded core adoption (recommended in эконом) | Accept named KB-first BG/TC preparation→change→review→memory scope; keep saved-mode/cross-mode tests explicitly open, finish core verdict/publication | No general Library/App release, no claim those requirements passed; requires explicit acceptance of this boundary |
| B — live Library canary | Separate reviewed copy-only Tchop adoption at pin3c42e490e82866eee0f303d6340452dbf9fff5eb (34 declared files, isolated project path/owned entrypoint, no overwrite); exact selector/status first; OFF/AUTO→ON/AUTO→ON/ADVISORY on the same bounded input, compare KB result/advice/actual delta; two real consumer mode boundaries; restore exact starting state where valid | Requires explicit exemption from current “Без … Library transitions”; current status UNVERIFIED, never assume saved OFF or valid state; invalid/absent state is not repaired automatically. No fresh agents/MCP, client Git or host install. Before apply, freeze hashes/identity and review exact adoption/state/rollback diff; failure stops dependent work and preserves evidence. No automatic LIB-004 closure or independent/fresh-chat proof |

The live proposal names missing evidence; no adoption, status query, transition or
rollback has been executed. If the observed initial record cannot be restored by the
existing authorized handler, stop before mutation and present the concrete state choice.
A gives useful bounded core acceptance now; B costs another bounded integration block
and can supply mode observations, without promising measured uplift or all release gates.

'''+anchor)
p.write_text(s)
for name in ('plan.md','handoff.md'):
 p=v/'tasks/new-task-be0b'/name;s=p.read_text()
 s=s.replace('W5 final system verdict OPEN; LIB-004 P2 OPEN independently.', 'W5 R01–R21 traceability and separate Library/app verdicts prepared; core acceptance\nawaits explicit boundary choice. LIB-004 P2 OPEN independently.')
 s=s.replace('- [ ] W5 final traceability/independent system-library-app verdict and bounded adoption.', '- [x] W5 final traceability and separate Library/app verdicts; retain owned evidence, bounded choices prepared.\n- [ ] W5 core boundary decision and final system publication; saved-mode/cross-mode gaps remain.')
 s=s.replace('or choose a verdict retaining saved-mode/cross-mode gaps.', 'or choose bounded core adoption retaining saved-mode/cross-mode gaps; recommendation A\nand precise alternative B are prepared in main plan W5.')
 s=s.replace('or bounded system verdict retaining those gaps.', 'or bounded core adoption retaining those gaps; main plan W5 prepares recommended A\nand explicit-transition alternative B.')
 p.write_text(s)
 local=s.replace('(ios-project-work-system-plan.md)','(/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b/ios-project-work-system-plan.md)').replace('(../../apps/','(/Users/Artem/.zenflow/worktrees/documentation-vault/apps/').replace('(../../reusable/baseline/','(/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/')
 (w/'.zenflow/tasks/new-task-be0b'/name).write_text(local)
print('Fresh scoped traceability, separate verdicts, retention and concrete user choices prepared; no acceptance fabricated.')
