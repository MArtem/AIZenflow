from pathlib import Path
import json,re,hashlib,subprocess
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault');r=w/'.zenflow/tasks/new-task-be0b/library-canary';out=r/'fresh-result-publication';out.mkdir(exist_ok=True)
def sha(b):return hashlib.sha256(b).hexdigest()
def git(root,*args):return subprocess.check_output(['git',*args],cwd=root)
owned=['MANIFEST.md','MANIFEST_SUMMARY.md','apps/BattleshipGame/PROJECT_CONTEXT.md','apps/Tchop/MANIFEST.md','apps/Tchop/PROJECT_CONTEXT.md','tasks/new-task-be0b/plan.md','tasks/new-task-be0b/handoff.md','tasks/new-task-be0b/ios-project-work-system-plan.md','tasks/new-task-be0b/ios-project-work-system-fresh-chat-check.md']
# Current own local recovery only; absolute canonical links.
for name in ('plan.md','handoff.md'):
 p=v/'tasks/new-task-be0b'/name;s=p.read_text()
 def link(m):
  d=m.group(2)
  if d.startswith(('http','/','#')):return m.group(0)
  return '['+m.group(1)+']('+str((p.parent/d).resolve())+')'
 (w/'.zenflow/tasks/new-task-be0b'/name).write_text(re.sub(r'\[([^\]]+)\]\(([^)]+)\)',link,s))
assert len((v/'tasks/new-task-be0b/plan.md').read_text().split())+len((v/'tasks/new-task-be0b/handoff.md').read_text().split())<=3500
assert git(v,'rev-parse','HEAD').decode().strip()=='332a794d033f705bfe93dbc40674ca78f0b3982a'
assert not git(v,'diff','--cached','--name-only').strip()
changed=set(git(v,'diff','--name-only').decode().splitlines())|set(git(v,'ls-files','--others','--exclude-standard').decode().splitlines());assert changed==set(owned),changed
before=json.loads((r/'fresh-chat-check/after-preservation.json').read_text())
exceptions=set(str(v/p) for p in owned)|{'.zenflow/tasks/new-task-be0b/plan.md','.zenflow/tasks/new-task-be0b/handoff.md'}
for rel,h in before['protected_hashes'].items():
 if rel in exceptions:continue
 p=Path(rel) if rel.startswith('/') else w/rel;assert sha(p.read_bytes())==h,rel
links=0
for rel in owned:
 p=v/rel;b=p.read_bytes();assert not re.search(rb'(?m)[ \t]+$',b),rel
 assert not re.search(rb'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|\bgh[pousr]_[A-Za-z0-9]{30,}|\bAKIA[A-Z0-9]{16}\b',b),rel
 for d in re.findall(r'\]\(([^)]+)\)',b.decode()):
  if d.startswith(('http','/','#')):continue
  assert (p.parent/d.split('#')[0]).resolve().exists(),(rel,d);links+=1
new=v/'tasks/new-task-be0b/ios-project-work-system-fresh-chat-check.md'
assert 'FC-P3-01 OPEN' in new.read_text() and '18 separate status' in new.read_text() and '5 observations' not in new.read_text() # table contains distinct API cases; no fabricated full suite
assert '[x] W4.3.d' in (v/'tasks/new-task-be0b/ios-project-work-system-plan.md').read_text()
patch=git(v,'diff','--binary','--full-index');(out/'reviewed-tracked.patch').write_bytes(patch)
d={'base':'332a794d033f705bfe93dbc40674ca78f0b3982a','owned_files':owned,'file_sha256':{p:sha((v/p).read_bytes()) for p in owned},'reviewed_tracked_patch_sha256':sha(patch),'client_head':'b7c48e163d9108d1cc4b123d93456ce8f7628d93','contract':'Publish actual scoped observer result; human one-chat scope only; first read-order fails strict acceptance and stays OPEN; shared-instruction W4.3.d sufficiency derived from original consumer requirement, no independently moded Swift/general readiness or A waiver; records preserved, API-vs-CLI distinction, history retained','final_semantic_review':'Entire nine-file candidate/new receipt and current root/nested authority, real observer transcript/stage/preservation/negative evidence reviewed; all mirrored current claims agree. No owned P0-P2. FC-P3-01 procedural P3 explicitly reported OPEN; no source fix indicated; old E9 historical. TC-L02 outside app P3 and LIB-004 release P2 remain OPEN. Parent source/hash adjudication is not independent code review.','checks':{'candidate_links':links,'candidate_whitespace_scoped_secret_patterns':'PASS','source_foreign_payload_root_preservation':'PASS current hashes excluding exact task/canonical doc owners','bootstrap_index':'reuse unchanged PASS from332a794','prior_runtime':'reuse eligible TC20/4 and selected BG evidence; no new runtime','drift':'known33 pre-existing local baseline drift, no candidate baseline change; not full PASS'},'context_health':'adequate for bounded result publication; next ordered startup requires an actual new chat and new human approval','omitted':'new runtime/ADVISORY/old17-suite/physical/iPad/actual VoiceOver/unapproved agents/MCP/source edits; no Library cost/uplift proof','next_action':'one separately approved read-only ordered startup, prepared task; no duplicate mode cycles/fixtures/runtime'}
assert git(w,'rev-parse','HEAD').decode().strip()==d['client_head'];(out/'precommit-review.json').write_text(json.dumps(d,indent=2,ensure_ascii=True)+'\n');print('PASS exact nine-file ownership, links/claims, source preservation, compact recovery and complete semantic review; strict startup FC-P3-01 reported OPEN.')
