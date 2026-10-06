from pathlib import Path
v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
exception="""## Temporary verification exception — NT-BE0B-QA-01

Status APPROVED; owner/approver user; approved2026-10-04 in this task.
Authority: «пока что ... проверки любые на айпад не нужны, и все что требует
реальный девайс, типа VoiceOver ... тоже не нужны. Иди дальше».
Scope: new-task-be0b system implementation and its selected pilots in this active
worktree only. Affected acceptance: W3.3.b/c and task-relevant compatibility/
accessibility evidence requirements, including BG-T01. All iPad checks and all checks
requiring a physical device, including actual VoiceOver traversal, are excluded.
Do not execute them or request them as prerequisites for continuing this task.
Required runtime matrix remains iPhone Simulator **iOS18.2 + iOS27**. Existing evidence
is retained; exclusion is OMITTED_BY_USER, never PASS. Simulator-only audits and
observable iPhone failures remain applicable; release/device/accessibility certification
is outside this exception. No known inaccessible critical flow is approved for shipping.
Reason: user narrows current verification scope; residual risk: iPad/hardware/assistive
behavior remains unknown. Mitigation: retain static geometry/consumer review and scoped
iPhone checks, publish exact omissions and failures. Expiry/revisit: user changes this
instruction, task scope expands, or an app release/device-support claim is proposed.
Revalidation then requires separately authorized relevant checks. Rollback: remove only
this owned overlay/exception, keep historical evidence. No reusable-rule promotion.
Applicable contracts: QC.EXCEPTION.CONTRACT v1.0; local exception process.

"""
paths=[v/'tasks/new-task-be0b/ios-project-work-system-plan.md',v/'tasks/new-task-be0b/plan.md',v/'tasks/new-task-be0b/handoff.md',v/'apps/BattleshipGame/TASK_BG_T01.md']
old='Mandatory task matrix: **iOS18.2 + iOS27**, iPhone/iPad; this is not a reusable rule.'
new='Mandatory current task matrix: **iOS18.2 + iOS27**, iPhone Simulator only.\nTemporary NT-BE0B-QA-01 excludes every iPad/physical-device check, including actual\nVoiceOver; omissions remain unverified, never PASS. This is not a reusable rule.'
for p in paths:
 s=p.read_text(); assert old in s,p; s=s.replace(old,new)
 s=s.replace('VoiceOver experience, live iPad window resizing and physical-device/release evidence\nremain unverified. BG-A01 P2 OPEN; LIB-004 P2 OPEN; no whole-system/app readiness PASS.','VoiceOver experience, all iPad and physical-device checks are OMITTED_BY_USER\n(NT-BE0B-QA-01), still unverified and no longer continuation gates. Expanded AX5\naudit27 remains unverified separately. BG-A01 P2 OPEN; LIB-004 P2 OPEN; no app release PASS.')
 if p.name=='ios-project-work-system-plan.md':
  s=s.replace('## Evidence keys and reuse scope',exception+'## Evidence keys and reuse scope')
  s=s.replace('VoiceOver/live resize, expanded AX5 audit27 and full acceptance unverified;','iPad/physical VoiceOver excluded by user; expanded AX5 audit27 and full acceptance unverified;')
  s=s.replace('Current next human gate: VoiceOver/live iPad resize; then a legitimate accepted shared\nconsumer task/current choices. No synthetic product feature or live mode transition.','Current next safe step: bounded iPhone27 expanded-AX5 timeout diagnosis, then legitimate\nshared-consumer task/current choices. iPad/physical checks are omitted by user; no synthetic\nproduct feature or live mode transition.')
  s=s.replace('was refreshed; shipping source/foreign/pin unchanged. W3.3.b/c remain open for actual\nVoiceOver/live resizing; BG-A01/LIB-004 OPEN. W3.4.a records current disposition,','was refreshed; shipping source/foreign/pin unchanged. NT-BE0B-QA-01 now removes\niPad/physical VoiceOver from continuation gates; expanded iPhone27 audit remains\nunverified. BG-A01/LIB-004 OPEN. W3.4.a records current disposition,')
 elif p.name=='TASK_BG_T01.md':
  s=s.replace('Status AUTOMATED_SCENARIOS_OBSERVED_MANUAL_ACCEPTANCE_OPEN;','Status AUTOMATED_SCENARIOS_OBSERVED_SIMULATOR_GAP_OPEN;')
  s=s.replace('- [ ] Actual VoiceOver traversal and activation across both boards, coordinates/states,\n  offscreen scroll, placement/fire/reset; automated descriptions do not replace it.\n- [ ] Supported live iPad window resize: sizing and accurate actions after width changes.','- OMITTED_BY_USER NT-BE0B-QA-01: actual VoiceOver, all iPad and physical-device checks;\n  no PASS or release certification inferred.')
  start=s.index('Next required user action:');end=s.index('Existing labels/localization',start)
  s=s[:start]+'Next safe step: bounded isolated iPhone27 Simulator diagnosis of the expanded AX5\naudit timeout; no iPad or physical-device execution/request. '+s[end:]
  s=s.replace('necessary Simulator QA. Necessary','necessary Simulator QA. Current task exception: [NT-BE0B-QA-01](../../tasks/new-task-be0b/ios-project-work-system-plan.md#temporary-verification-exception--nt-be0b-qa-01). Necessary')
 elif p.name=='plan.md':
  s=s.replace('- [ ] W3: actual VoiceOver/live iPad resize acceptance and expanded AX5 audit27 gap; BG-A01 P2 OPEN.','- [x] Save user-approved temporary no-iPad/no-physical-device exception NT-BE0B-QA-01.\n- [ ] W3: bounded expanded AX5 audit27 diagnosis; BG-A01 disposition at narrowed scope.')
  s=s.replace('Next necessary user action: report VoiceOver and supported live iPad resize observations.\nContinue only the grounded correction if they fail; compare meaningful approaches.','Next safe step: bounded iPhone27 expanded-AX5 timeout diagnosis, then W4 grounded\nshared-consumer task selection; compare meaningful approaches. No iPad/physical check gate.')
 else:
  s=s.replace('Next required human action: actual VoiceOver traversal/actions and live iPad resize\nresult with environment. No more unchanged PASS reruns. Then choose a legitimate','Next safe step: bounded expanded AX5 iPhone27 timeout diagnosis; iPad/physical checks\nare omitted by explicit user exception NT-BE0B-QA-01 in the main plan. Then choose a legitimate')
 p.write_text(s)
p=v/'apps/BattleshipGame/PROJECT_CONTEXT.md';s=p.read_text().replace('mandatory iOS18.2+27 iPhone/iPad matrix','mandatory iOS18.2+27 iPhone Simulator matrix; NT-BE0B-QA-01 excludes all iPad/physical checks')
s=s.replace('VoiceOver/live resize/device/release remain unverified; BG-A01 and LIB-004 OPEN.\nNext safe action: user provides actual VoiceOver and supported iPad resize observations.','VoiceOver/iPad/device checks are OMITTED_BY_USER under [NT-BE0B-QA-01](../../tasks/new-task-be0b/ios-project-work-system-plan.md#temporary-verification-exception--nt-be0b-qa-01); release remains unverified. BG-A01 and LIB-004 OPEN.\nNext safe action: bounded expanded-AX5 iPhone27 timeout diagnosis; no iPad/physical gate.')
p.write_text(s)
p=v/'apps/BattleshipGame/AUDIT_LEDGER.md';s=p.read_text().replace('real assistive traversal and live iPad resizing acceptance remain.','iPad/physical assistive checks now omitted by user NT-BE0B-QA-01.').replace('large-text and VoiceOver placement/fire/reset checks. Residual: device behavior unrun.','large-text Simulator placement/fire/reset checks. Residual: iPad/physical/VoiceOver unverified and omitted by user.')
s=s.replace('BG-A01 remains P2 OPEN for actual VoiceOver and supported live-resize acceptance;\nautomated audits do not close those gates. Library LIB-004 remains separately OPEN.','BG-A01 remains P2 OPEN pending bounded expanded-AX5 iPhone27 timeout disposition.\n[NT-BE0B-QA-01](../../tasks/new-task-be0b/ios-project-work-system-plan.md#temporary-verification-exception--nt-be0b-qa-01) excludes all iPad/physical checks, including actual VoiceOver, from this task;\nomission never becomes PASS or an app release verdict. Library LIB-004 remains OPEN.')
p.write_text(s)
p=w/'AGENTS.md';s=p.read_text();assert 'AIZENFLOW_NEW_TASK_BE0B_VERIFICATION_SCOPE_V1' not in s
s+="""
## Temporary verification scope — new-task-be0b
<!-- AIZENFLOW_NEW_TASK_BE0B_VERIFICATION_SCOPE_V1 -->
User-approved 2026-10-04, for this task and its selected system pilots only: all iPad
checks and all checks requiring a physical device, including actual VoiceOver, are
not required. Do not run/request them as continuation gates. Record OMITTED_BY_USER,
not PASS. Keep iPhone Simulator iOS18.2 + iOS27 verification and actual Simulator
failures in scope. Canonical exception NT-BE0B-QA-01 with limits/revisit triggers:
`/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b/ios-project-work-system-plan.md`.
Temporary until user changes it or task scope/release claims require reassessment;
no reusable promotion or other permissions granted.
"""
p.write_text(s)
for name in ('plan.md','handoff.md'):
 s=(v/'tasks/new-task-be0b'/name).read_text().replace('(ios-project-work-system-plan.md)','(/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b/ios-project-work-system-plan.md)').replace('(../../apps/BattleshipGame/','(/Users/Artem/.zenflow/worktrees/documentation-vault/apps/BattleshipGame/')
 (w/'.zenflow/tasks/new-task-be0b'/name).write_text(s)
print('Updated task-scoped exception, current memory and owned AGENTS suffix; reusable rules unchanged.')
