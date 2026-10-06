from pathlib import Path
import hashlib,json,subprocess
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault');r=w/'.zenflow/tasks/new-task-be0b/tc-w4-localization'
receipt=json.loads((r/'publication-receipt.json').read_text());base=receipt['base'];owned=receipt['owned_files'];hooks=w/'.zenflow/tasks/new-task-be0b/publication-no-hooks'
assert hooks.is_dir() and not list(hooks.iterdir())
def run(args):
 p=subprocess.run(args,cwd=v,capture_output=True);assert p.returncode==0,(args,p.stdout.decode(),p.stderr.decode());return p.stdout
assert run(['git','rev-parse','HEAD']).decode().strip()==base
assert not run(['git','diff','--cached','--name-only'])
for rel,digest in receipt['file_sha256'].items():assert hashlib.sha256((v/rel).read_bytes()).hexdigest()==digest,rel
run(['git','add','--',*owned])
assert set(run(['git','diff','--cached','--name-only']).decode().splitlines())==set(owned)
patch=run(['git','diff','--cached','--binary','--no-ext-diff']);(r/'reviewed-final.patch').write_bytes(patch)
receipt['patch_sha256']=hashlib.sha256(patch).hexdigest();receipt['remote_base_observed']=base
(r/'publication-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(run(['git','-c','core.hooksPath='+str(hooks),'-c','commit.gpgsign=false','commit','-m','Record Tchop shared-source canary and scoped system verdicts']).decode())
head=run(['git','rev-parse','HEAD']).decode().strip();assert run(['git','diff','--binary','--no-ext-diff',base,head])==patch
for rel,digest in receipt['file_sha256'].items():assert hashlib.sha256(run(['git','show',head+':'+rel])).hexdigest()==digest,rel
assert not run(['git','status','--porcelain'])
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=w).decode().strip()==receipt['client_head']
assert hashlib.sha256((w/'TchopApp/Models/AppTab.swift').read_bytes()).hexdigest()==receipt['Tchop_source_sha256']
receipt.update(reviewed_head=head,review_range=base+'..'+head,postcommit_review='Exact HEAD patch byte-equal to complete reviewed candidate; all committed file hashes match; contract/consumers/authority/failure/mirrored claims reviewed; no new owned P0-P3',canonical_clean=True,client_head_unchanged=True,publication='committed, exact HEAD reviewed; push pending')
(r/'publication-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps({'reviewed_head':head,'canonical_clean':True,'client_head_unchanged':True}))
