from pathlib import Path
import hashlib,json,re,subprocess
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault');r=w/'.zenflow/tasks/new-task-be0b/tc-w4-localization'
def run(args,cwd):
 p=subprocess.run(args,cwd=cwd,capture_output=True);assert p.returncode==0,(args,p.stderr.decode());return p.stdout
def sha(b):return hashlib.sha256(b).hexdigest()
owned=['MANIFEST.md','MANIFEST_SUMMARY.md','apps/Tchop/MANIFEST.md','apps/Tchop/PROJECT_CONTEXT.md','apps/Tchop/history/tc-w4-01-localization-2026-10-04.md','tasks/new-task-be0b/plan.md','tasks/new-task-be0b/handoff.md','tasks/new-task-be0b/ios-project-work-system-plan.md']
base='4c3a901243a6788cfce59ec3db09d037062651a3'
assert run(['git','rev-parse','HEAD'],v).decode().strip()==base
changed=run(['git','diff','--name-only'],v).decode().splitlines()+run(['git','ls-files','--others','--exclude-standard'],v).decode().splitlines()
assert set(changed)==set(owned),changed
assert not run(['git','diff','--cached','--name-only'],v)
contract=json.loads((r/'contract-before.json').read_text());preservation=json.loads((r/'verification-preservation.json').read_text())
old=(r/'before-AppTab.swift').read_text();after=(w/'TchopApp/Models/AppTab.swift').read_text()
expected=old
for tab in ('news','mixes','pinned','chat','profile'):
 before='"tab.'+tab+'.placeholderDescription"';assert old.count(before)==1
 expected=expected.replace(before,'"tab.'+tab+'.stubDescription"')
assert after==expected
assert sha(after.encode())==preservation['after_AppTab_sha256']
for rel,expected_hash in contract['before_sha256'].items():
 if rel!='TchopApp/Models/AppTab.swift':assert sha((w/rel).read_bytes())==expected_hash,rel
assert run(['git','rev-parse','HEAD'],w).decode().strip()==contract['client_head']
prior=json.loads((w/'.zenflow/tasks/new-task-be0b/global-verification-preservation.json').read_text())
for rel,expected_hash in prior['preserved'].items():
 b=(w/rel).read_bytes()
 if rel=='AGENTS.md':
  marker=b'## Cross-project verification scope';assert marker in b
  b=b.split(marker,1)[0].rstrip(b'\n')+b'\n'
 assert sha(b)==expected_hash,rel
payload=json.loads((w/'.zenflow/tasks/new-task-be0b/w3-pin-equality-receipt.json').read_text())
for entry in payload['files']:assert sha((w/'BattleshipGame/IOSLibrary'/entry['path']).read_bytes())==entry['sha256'],entry['path']
links=0
for rel in owned:
 path=v/rel;s=path.read_text()
 assert not re.search(r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|\bgh[pousr]_[A-Za-z0-9]{30,}|\bsk-[A-Za-z0-9]{35,}',s),rel
 for target in re.findall(r'\]\(([^)]+)\)',s):
  if target.startswith(('https:','http:','app:','#')):continue
  target=target.split('#',1)[0]
  if not target:continue
  p=Path(target) if target.startswith('/') else path.parent/target
  assert p.exists(),(rel,target);links+=1
for name in ('plan.md','handoff.md'):
 canon=(v/'tasks/new-task-be0b'/name).read_text()
 local=canon.replace('(ios-project-work-system-plan.md)','(/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b/ios-project-work-system-plan.md)').replace('(../../apps/','(/Users/Artem/.zenflow/worktrees/documentation-vault/apps/').replace('(../../reusable/baseline/','(/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/')
 assert (w/'.zenflow/tasks/new-task-be0b'/name).read_text()==local,name
words=sum(len((v/'tasks/new-task-be0b'/x).read_text().split()) for x in ('plan.md','handoff.md'));assert words<=3500
main=(v/'tasks/new-task-be0b/ios-project-work-system-plan.md').read_text();leaves=re.findall(r'^\| \[[ x]\] (W\d+\.\d+\.[a-z]) \|',main,re.M)
assert len(leaves)==len(set(leaves))==62,len(leaves)
# Both tracked diff checks already returned0 at these unchanged candidate hashes.
# --no-index returned1 with empty diagnostics because the new file differs from /dev/null.
history_lines=(v/'apps/Tchop/history/tc-w4-01-localization-2026-10-04.md').read_text().splitlines()
assert all(line.rstrip()==line for line in history_lines)
receipt={'base':base,'owned_files':owned,'file_sha256':{rel:sha((v/rel).read_bytes()) for rel in owned},'contract':'Five existing AppTab key literals only; actual preview callers/two host consumers; immutable sources/resources outside fix; authority separate from memory; factual runtime failures retained; exact synthetic controls vs unobserved live modes; separate core/library/app verdicts, no scope acceptance fabricated','review':'Complete final eight-file canonical candidate including new history plus one-source diff reviewed; actual callers/mirrored claims traced; source assertions, successful build inputs/resources and reader fixtures match receipts; no owned P0-P3. TC-L02 P3 outside candidate explicitly OPEN. Self-review only; agents/MCP prohibited.','checks':{'exact_five_key_diff':'PASS','input_foreign_preservation':'PASS','payload34_hashes':'unchanged','links':links,'task_words':words,'plan_leaves':len(leaves),'diff_check':'PASS canonical+active+new history','scoped_secret_patterns':'PASS candidate only','vault':'PASS','manifest':'PASS','boundaries':'PASS','consistency':'PASS','lookups':'20/20','host_builds':'4/4','synthetic_reader_selector':'17/17'},'reused':'unchanged bootstrap/router/Level0/index gates and historical handler FIFO/lock/disabled recovery at exact same hash; no new broad scan/build rerun','context_health':'canonical direct route current; known33 pre-existing local baseline drift, zero related changes in current candidate; no full baseline-drift PASS','omitted':'global iPad/physical/actual VoiceOver; rendered previews/authenticated app/UI/release; full saved OFF/ADVISORY/cross-mode stages; independent review','residual':'LIB-004 P2 OPEN; W4 mode integration OPEN; TC-L02 P3 separate OPEN; original BG combined27 timeout cause unknown; core verdict needs explicit scope decision','client_head':contract['client_head'],'Tchop_source_sha256':preservation['after_AppTab_sha256'],'Library_Tchop':'UNVERIFIED unchanged','Library_BG':'ON/AUTO last exact observed record; no live query/transition in current block','publication':'reviewed candidate, not yet committed'}
(r/'publication-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({'gates':'PASS','owned_files':len(owned),'links':links,'task_words':words,'plan_leaves':len(leaves),'client_preserved':True}))
