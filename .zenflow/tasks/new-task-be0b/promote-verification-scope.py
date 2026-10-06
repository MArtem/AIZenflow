from pathlib import Path
v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault'); w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
d=v/'reusable/baseline/docs'
p=d/'CURRENT_USER_OVERRIDES.md';s=p.read_text();mark='## Verification And Quality\n\n';assert mark in s
rule="""<!-- Rule ID: USER.VERIFICATION.SCOPE v1.0 -->
User-approved cross-project rule, 2026-10-04: exclude all iPad verification and every
check requiring a physical device, including actual VoiceOver sessions, from plans,
acceptance prerequisites and required follow-ups for every project and task. Do not
propose, schedule, execute or ask the user to perform these checks unless a later
explicit instruction changes this rule. Continue applicable static review and permitted
iPhone Simulator verification. This does not change supported app platforms, remove
accessibility implementation requirements, or grant test/runtime authority. Retain prior
results as history; excluded checks are OMITTED_BY_USER, never PASS. Do not claim
hardware/iPad/actual VoiceOver coverage from Simulator evidence. Owner: user / canonical
rules maintainer; revisit only on explicit user change or a conflicting requested claim.

"""
s=s.replace(mark,mark+rule);p.write_text(s)
p=v/'reusable/baseline/AGENTS.md';s=p.read_text();mark='## Tests And Verification\n';assert mark in s;s=s.replace(mark,mark+'- Apply `./docs/CURRENT_USER_OVERRIDES.md` USER.VERIFICATION.SCOPE: omit all iPad checks and checks requiring a physical device, including actual VoiceOver, from every project/task plan and acceptance gate. Preserve historical evidence and report omissions without PASS; only a later explicit user instruction changes this scope.\n');p.write_text(s)
p=d/'IOS_TESTING_STRATEGY.md';s=p.read_text().replace('### Manual Simulator/Device QA','### Manual iPhone Simulator QA').replace('- iPhone and iPad adaptive layouts, resizing, keyboard, pointer, and multi-window behavior where supported\n- physical-device-only hardware, protected-data, biometrics, thermal, and background behavior','- iPhone adaptive layouts, orientation, keyboard and supported Simulator system integration')
s=s.replace('## Test Decision Matrix','Apply [USER.VERIFICATION.SCOPE](CURRENT_USER_OVERRIDES.md#verification-and-quality) before\nconstructing any matrix: omit all iPad and physical-device checks, including actual\nVoiceOver sessions, from plans and acceptance gates. Static accessibility analysis and\npermitted iPhone Simulator audits remain applicable; omitted evidence is never PASS.\n\n## Test Decision Matrix');p.write_text(s)
for name,heading in [('QA_TEST_PLAN_STANDARD.md','## Test Plan Sections'),('COMPATIBILITY_MATRIX.md','## Matrix Dimensions'),('IOS_ACCESSIBILITY_STANDARD.md','## Required Checks')]:
 p=d/name;s=p.read_text();assert heading in s
 s=s.replace(heading,'Planning scope: apply [USER.VERIFICATION.SCOPE](CURRENT_USER_OVERRIDES.md#verification-and-quality).\nExclude all iPad verification and every physical-device check, including actual VoiceOver,\nfrom plans and exit gates. Keep implementation requirements, source-level accessibility\nreview and permitted iPhone Simulator checks; exclusion does not establish coverage.\n\n'+heading)
 if name=='COMPATIBILITY_MATRIX.md':s=s.replace('- simulator vs real device','- permitted iPhone Simulator destinations')
 p.write_text(s)
p=d/'IOS_RELEASE_PRIVACY_PERFORMANCE_MATRIX.md';s=p.read_text();heading='## Platform and accessibility matrix';assert heading in s;s=s.replace(heading,heading+'\n\nPlanning follows [USER.VERIFICATION.SCOPE](CURRENT_USER_OVERRIDES.md#verification-and-quality):\nall iPad and physical-device checks, including actual VoiceOver, are omitted from plans\nand prerequisites. Supported-platform metadata and source accessibility requirements\nremain; historical or omitted evidence must not be presented as verified coverage.');p.write_text(s)
p=d/'IOS_PROJECT_WORK_SYSTEM.md';s=p.read_text();s=s.replace('Show these actions independently, including an explicit reason when not applicable:','Apply [USER.VERIFICATION.SCOPE](CURRENT_USER_OVERRIDES.md#verification-and-quality): omit\nall iPad checks and physical-device checks, including actual VoiceOver, from every\nproject/task plan and continuation gate. Retain scoped evidence limits and applicable\nsource review/iPhone Simulator checks. Show the remaining actions independently,\nincluding an explicit reason when not applicable:')
s=s.replace('| Verify feature on device | Why device-specific evidence matters, available device/environment/operator and scenario; cannot silently substitute Simulator results. |\n','');p.write_text(s)
main=v/'tasks/new-task-be0b/ios-project-work-system-plan.md';s=main.read_text();a=s.index('## Temporary verification exception');b=s.index('## Evidence keys',a)
s=s[:a]+"""## Current verification scope — all projects and tasks

User2026-10-04 explicitly promoted the earlier temporary NT-BE0B-QA-01 exception:
all iPad checks and every check requiring a physical device, including actual VoiceOver,
are removed from verification plans and acceptance prerequisites for every project/task.
Canonical owner: [USER.VERIFICATION.SCOPE v1.0](../../reusable/baseline/docs/CURRENT_USER_OVERRIDES.md#verification-and-quality).
The temporary exception is superseded; no expiration or task-only limit remains.
Historical results remain intact. Required current runtime matrix: iPhone Simulator
**iOS18.2 + iOS27**. Excluded evidence is OMITTED_BY_USER, never PASS; implementation
accessibility requirements and actual Simulator failures still apply. New task/runtime,
Library, agents/MCP, client Git and other permissions are not added by this scope rule.

"""+s[b:]
s=s.replace('Temporary NT-BE0B-QA-01 excludes every iPad/physical-device check, including actual\nVoiceOver; omissions remain unverified, never PASS. This is not a reusable rule.','Global USER.VERIFICATION.SCOPE excludes every iPad/physical-device check, including\nactual VoiceOver, for all projects/tasks; omissions remain unverified, never PASS.')
s=s.replace('| [ ] W3.3.b | Narrow/wide/resized/scroll scenario evidence | All board rows/columns reachable and no ambiguous selection under selected environment/operator |','| [x] W3.3.b | Selected iPhone widths/rotation/scroll evidence | Board corners/actions reachable on iPhone18.2/27; all iPad/live-iPad resize checks removed by global user rule |')
s=s.replace('Dynamic Type/VoiceOver results recorded, omissions remain open','Dynamic Type/iPhone results recorded; actual VoiceOver/iPad/physical checks excluded by global user rule')
s=s.replace('NT-BE0B-QA-01 now removes','Global USER.VERIFICATION.SCOPE now removes').replace('iPad/physical VoiceOver from continuation gates','all iPad/physical checks from plans and continuation gates')
main.write_text(s)
paths=[v/'tasks/new-task-be0b/plan.md',v/'tasks/new-task-be0b/handoff.md',v/'apps/BattleshipGame/TASK_BG_T01.md',v/'apps/BattleshipGame/PROJECT_CONTEXT.md',v/'apps/BattleshipGame/AUDIT_LEDGER.md']
for p in paths:
 s=p.read_text().replace('Temporary NT-BE0B-QA-01 excludes every iPad/physical-device check, including actual\nVoiceOver; omissions remain unverified, never PASS. This is not a reusable rule.','Global USER.VERIFICATION.SCOPE excludes every iPad/physical-device check, including\nactual VoiceOver, for all projects/tasks; omissions remain unverified, never PASS.')
 s=s.replace('Temporary','Global').replace('temporary no-iPad/no-physical-device exception NT-BE0B-QA-01','cross-project no-iPad/no-physical-device rule USER.VERIFICATION.SCOPE')
 s=s.replace('NT-BE0B-QA-01','USER.VERIFICATION.SCOPE').replace('../../tasks/new-task-be0b/ios-project-work-system-plan.md#temporary-verification-exception--nt-be0b-qa-01','../../reusable/baseline/docs/CURRENT_USER_OVERRIDES.md#verification-and-quality')
 s=s.replace('explicit user exception USER.VERIFICATION.SCOPE in the main plan','explicit global user rule USER.VERIFICATION.SCOPE')
 p.write_text(s)
p=w/'AGENTS.md';s=p.read_text();a=s.index('## Temporary verification scope — new-task-be0b');s=s[:a]+"""## Cross-project verification scope
<!-- AIZENFLOW_USER_VERIFICATION_SCOPE_V1 -->
User-approved 2026-10-04, for every project and task: remove all iPad checks and all
checks requiring a physical device, including actual VoiceOver, from verification
plans and acceptance/continuation gates. Do not execute or request them unless a later
explicit user instruction changes this rule. Preserve historical results; excluded
checks remain OMITTED_BY_USER, never PASS. Implementation accessibility requirements
and applicable permitted iPhone Simulator checks remain. Canonical rule:
`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/docs/CURRENT_USER_OVERRIDES.md`
USER.VERIFICATION.SCOPE v1.0. This task keeps iPhone Simulator iOS18.2 + iOS27;
no additional runtime/test/Git/Library or external-path permission is granted here.
""";p.write_text(s)
# Update exact owned local mirrors; preserve overlays and all unrelated content.
for name in ('CURRENT_USER_OVERRIDES.md','IOS_TESTING_STRATEGY.md','QA_TEST_PLAN_STANDARD.md','COMPATIBILITY_MATRIX.md','IOS_ACCESSIBILITY_STANDARD.md','IOS_RELEASE_PRIVACY_PERFORMANCE_MATRIX.md','IOS_PROJECT_WORK_SYSTEM.md'):
 local=w/'docs'/name; original=local.read_bytes(); import subprocess
 before=subprocess.check_output(['git','-C',str(v),'show','HEAD:reusable/baseline/docs/'+name])
 assert original==before, 'foreign mirror difference: '+name
 local.write_bytes((d/name).read_bytes())
for name in ('plan.md','handoff.md'):
 s=(v/'tasks/new-task-be0b'/name).read_text().replace('(ios-project-work-system-plan.md)','(/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b/ios-project-work-system-plan.md)').replace('(../../apps/BattleshipGame/','(/Users/Artem/.zenflow/worktrees/documentation-vault/apps/BattleshipGame/')
 (w/'.zenflow/tasks/new-task-be0b'/name).write_text(s)
print('Global user rule promoted into existing sources; temporary exception superseded; owned mirrors synchronized.')
