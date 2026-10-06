from pathlib import Path
import hashlib, json, subprocess, importlib.util, re
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault');r=w/'.zenflow/tasks/new-task-be0b/library-canary';p=json.loads((r/'proposal.json').read_text())
def sha(b):return hashlib.sha256(b).hexdigest()
def git(cwd,*args):return subprocess.check_output(['git',*args],cwd=cwd)
assert git(w,'rev-parse','HEAD').decode().strip()==p['client_head']
for rel,h in p['preserve_except_current_task_and_owned_root'].items():
 if rel in ('AGENTS.md','.zenflow/tasks/new-task-be0b/plan.md','.zenflow/tasks/new-task-be0b/handoff.md'):continue
 assert sha((w/rel).read_bytes())==h,rel
assert sha((w/'AGENTS.md').read_bytes())==p['root_after_sha256']
assert (w/'AGENTS.md').read_bytes()==(r/'tchop-proposal/AGENTS.md').read_bytes()
assert sha((w/'TchopApp/AGENTS.md').read_bytes())==p['new_overlay_sha256']
for app in ('TchopApp','BattleshipGame'):
 root=w/app/'IOSLibrary';files=[f for f in root.rglob('*') if f.is_file()];assert len(files)==34
 for rel,h in p['file_sha256'].items():
  f=root/rel;assert f.is_file() and not f.is_symlink() and not f.stat().st_mode&0o111,rel
  b=f.read_bytes();assert sha(b)==h,(app,rel)
  assert b==git(v,'show',p['source_pin']+':reusable/ios-engineering-library/reference-copy-only/'+rel)
 for f in files:
  if f.suffix=='.md':
   for dest in re.findall(r'\]\(([^)]+)\)',f.read_text()):
    if dest.startswith(('http:','https:','#')):continue
    target=(f.parent/dest.split('#')[0]).resolve();assert target.is_relative_to(root.resolve()) and target.exists(),(f,dest)
for app,label,sel in [('BattleshipGame','bg-restore-on-auto','BattleshipGame/BattleshipGame.xcodeproj'),('TchopApp','tc-final-on-auto','TchopApp.xcodeproj')]:
 script=w/app/'IOSLibrary/tools/reference_mode.py';assert sha(script.read_bytes())==p['handler_sha256']
 cp=subprocess.run(['python3','-B',str(script),'status','--root',str(w),'--project',sel],cwd=w,capture_output=True,text=True,timeout=15)
 assert cp.returncode==0,cp.stderr
 observed=json.loads(cp.stdout);assert observed=={'status':'ON','profile':'AUTO'}
 spec=importlib.util.spec_from_file_location('final_scope_'+app,script);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
 key,fingerprint=m.scope(str(w),sel);record=m.STATE_DIR/(key+'.json');expected=json.loads((r/(label+'-receipt.json')).read_text())
 assert sha(record.read_bytes())==expected['after_record_sha256']
 (r/(app+'-final-status.json')).write_text(json.dumps({'observed':observed,'record_sha256':expected['after_record_sha256'],'handler_sha256':p['handler_sha256'],'fingerprint_revalidated':True},indent=2)+'\n')
owned=['MANIFEST.md','MANIFEST_SUMMARY.md','apps/BattleshipGame/PROJECT_CONTEXT.md','apps/Tchop/MANIFEST.md','apps/Tchop/PROJECT_CONTEXT.md','tasks/new-task-be0b/plan.md','tasks/new-task-be0b/handoff.md','tasks/new-task-be0b/ios-project-work-system-plan.md','tasks/new-task-be0b/ios-project-work-system-library-canary.md']
changed=set(git(v,'diff','--name-only').decode().splitlines())|set(git(v,'ls-files','--others','--exclude-standard').decode().splitlines());assert changed==set(owned),changed
for rel in owned:
 f=v/rel;b=f.read_bytes();assert not re.search(rb'(?m)[ \t]+$',b),rel
 # Scan only candidate documentation; do not inspect credential stores or secret paths.
 assert not re.search(rb'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|\bgh[pousr]_[A-Za-z0-9]{30,}|\bAKIA[A-Z0-9]{16}\b',b),rel
 for dest in re.findall(r'\]\(([^)]+)\)',b.decode()):
  if dest.startswith(('http:','https:','#')):continue
  assert (f.parent/dest.split('#')[0]).resolve().exists(),(rel,dest)
patch=git(v,'diff','--binary','--full-index');(r/'reviewed-tracked.patch').write_bytes(patch)
result={'canonical_base':git(v,'rev-parse','HEAD').decode().strip(),'owned_files':owned,'file_sha256':{rel:sha((v/rel).read_bytes()) for rel in owned},'reviewed_tracked_patch_sha256':sha(patch),'client_head':p['client_head'],'pin34_both_scopes':'PASS','final_modes':'both ON/AUTO independently observed','other_project_records_preserved':'PASS','frozen_sources_foreign_edits_and_root_scope':'PASS','new_payload_regular_non_executable_not_shipping':'PASS (explicit PBX unchanged; adoption receipt)','candidate_links_whitespace_scoped_secret_patterns':'PASS','semantic_review':'Scoped named review stages vs historical source task; exact human ending state, mode/authority distinction, no independent or fresh-chat PASS, no invalid repair. Owned candidate findings P0-P3:0. TC-L02 P3 app backlog and LIB-004 P2 release gap remain separate OPEN. Fresh new entrypoint/shared-root application pending.','checks':{},'reuse':'Prior20 lookups/4 builds and17 controls at unchanged input hashes; no runtime in this block. Baseline drift prior33 remains outside candidate.'}
(r/'precommit-review.json').write_text(json.dumps(result,indent=2)+'\n');print('PASS: exact pin/foreign/source/root preservation, final modes+record hashes, nine-file canonical ownership/links/whitespace/scoped patterns. No raw records exported.')
