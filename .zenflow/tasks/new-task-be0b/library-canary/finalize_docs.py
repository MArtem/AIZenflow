from pathlib import Path
import re
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
def replace(path,old,new):
 s=path.read_text(); assert s.count(old)==1,(path,old); path.write_text(s.replace(old,new))
p=v/'apps/Tchop/PROJECT_CONTEXT.md'
replace(p,'map is supplemented by TC-W4-01 scoped shared-source workflow. Complete saved-mode\ncycles and Library uplift remain unobserved.','map is supplemented by TC-W4-01 scoped shared-source workflow and E9 saved-mode\nreview stages. Fresh entrypoint/shared-root integration and general Library uplift\nremain unobserved.')
replace(p,'KB result: accurate declared graph + preserved human state; Tchop mode/adoption remains','Historical structural-intake result: accurate declared graph + preserved human state;\nat that checkpoint Tchop mode/adoption remained')
replace(p,'The current TC-W4-01 card supplies selected source/runtime evidence; saved-mode\nworkflow acceptance remains open.','The later TC-W4-01 card supplies selected source/runtime evidence; E9 below supplies\nactual saved-mode review stages. Fresh entrypoint/shared-root integration remains open.')
p=v/'tasks/new-task-be0b/ios-project-work-system-plan.md'
replace(p,'W4 scoped observation: exact three-file apply/post-check','Historical W4 structural-intake observation: exact three-file apply/post-check')
replace(p,'TC-W4-01 now supplies real shared-source semantic change; complete saved OFF/ADVISORY\nand real cross-mode cycles remain open. Named reader/selector refusal controls below','TC-W4-01 subsequently supplied real shared-source semantic change; at that earlier\ncheckpoint saved-mode observations were missing. Current E9 below supplies actual\nOFF/AUTO, ON/AUTO and ON/ADVISORY stages; fresh integration remains open. Named reader/selector refusal controls below')
replace(p,'W4.3.c: actual Tchop unverified second layer withheld +15 owned synthetic reader cases','At the TC-W4-01 source checkpoint, W4.3.c: actual Tchop unverified second layer withheld\n+15 owned synthetic reader cases')
replace(p,'case to exact observed scope/gap/owner, not full W4 acceptance. W4.3.a actual KB-only\ncycle completed while UNVERIFIED, but saved OFF control still missing; W4.3.b/d need\nreal profile/cross-mode observations or explicit bounded requirement decision.','case to exact observed scope/gap/owner, not full W4 acceptance. That earlier KB-only\ncycle completed while UNVERIFIED. E9 below subsequently closes W4.3.a/b for named\nsaved-mode review stages; W4.3.d still needs fresh shared-boundary integration evidence.')
a=s=p.read_text(); start=s.index('W5.3.c bounded choices prepared for user:'); end=s.index('\n## 14.',start)
s=s[:start]+'''W5.3.c choices and actual user decision:

| Choice | Concrete action / benefit | Current status / limits |
|---|---|---|
| A — bounded core adoption | Accept only named KB-first source workflows and defer missing mode/integration requirements | Not selected; no narrower acceptance waiver |
| B — live Library canary | Own Tchop34-file adoption at pin3c42e490e82866eee0f303d6340452dbf9fff5eb; saved OFF/AUTO, ON/AUTO and ON/ADVISORY on bounded inputs; independent BG/Tchop modes and all Tchop host consumers | Selected and authorized. E9 actual adoption and named stages complete; BG initial ON/AUTO restored, initial TchopUNSET replaced with explicitly chosen ON/AUTO. Fresh entrypoint/shared-root integration and LIB-004 remain open |

No invalid/absent record is repaired automatically. Same-session CLI/static evidence
supplies neither a fresh-chat observation nor independent review. Both Tchop hosts share
one selector/mode; different project modes must never be assigned to those targets.
BG/Tchop mode separation does not itself prove a shared Swift change across independent
projects. W4.3.d retains that limitation and the required fresh shared-root integration.
''' +s[end:]; p.write_text(s)
replace(p,'Next safe action: freeze exact pin/adoption diff, observe initial statuses and execute\nbounded OFF/AUTO→ON/AUTO→ON/ADVISORY under this actual grant, with safe ending-state\nresolution before mutation if initial UNSET cannot be restored by the handler. No repair.','Current E9 has completed the reviewed adoption and bounded mode stages. Next safe\naction: publish the reviewed receipt, then obtain actual fresh-chat entrypoint/shared-root\nobservation under the continuing human grant. Tchop terminal ON/AUTO was explicitly\nchosen before its first write; no absence restoration or repair.')
p=v/'tasks/new-task-be0b/handoff.md'
replace(p,'foreign roadmap, original root AGENTS prefix/nested overlay and34 payload files preserved.\nRoot gained only owned global-scope pointer. BG handler ON/AUTO observation reused at','foreign roadmap, BG nested overlay and34 payload files preserved. Root edits are\nlimited to the owned global-scope pointer and owned Tchop Library entrypoint; all other\nroot text is byte-preserved against the canary input. BG handler ON/AUTO observation reused at')
replace(p,'four host builds PASS;17 synthetic reader/selector controls PASS, no live mode changes.','four host builds PASS;17 synthetic reader/selector controls PASS. That source checkpoint\nperformed no live mode changes; E9 below records the later authorized transitions.')
p=v/'tasks/new-task-be0b/plan.md'
replace(p,'after selected B evidence; saved-mode/cross-mode gaps remain.','after selected B evidence; fresh-entrypoint/shared-root integration remains open.')
# Local recovery mirrors only current task-owned files; retain canonical absolute links.
for name in ('plan.md','handoff.md'):
 s=(v/'tasks/new-task-be0b'/name).read_text()
 def link(m):
  dest=m.group(2)
  if dest.startswith(('http','/','#')):return m.group(0)
  return '['+m.group(1)+']('+str((v/'tasks/new-task-be0b'/dest).resolve())+')'
 (w/'.zenflow/tasks/new-task-be0b'/name).write_text(re.sub(r'\[([^\]]+)\]\(([^)]+)\)',link,s))
p=w/'.zenflow/tasks/new-task-be0b/library-canary/plan.md'
s=p.read_text().replace('- [ ]','- [x]')
s=s.replace('- [x] Sync current app/task memory and publish canonical docs after exact review/gates.','- [x] Sync current app/task memory.\n- [ ] Publish canonical docs after exact review/gates.\n- [ ] Actual fresh-chat entrypoint/shared-root observation; cannot be produced in this chat.')
p.write_text(s)
print('Owned current claims corrected; historical scopes retained; local recovery synchronized.')
