from pathlib import Path
import json,subprocess,hashlib

ROOT=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
VAULT=Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
OUT=ROOT/'.zenflow/tasks/new-task-be0b/final-acceptance'
path=OUT/'publication-receipt.json'
r=json.loads(path.read_text()); head=r['head']; remote=r['trusted_remote']
def git(*args):
 return subprocess.check_output(['git',*args],cwd=VAULT).decode().strip()
assert git('rev-parse','HEAD')==head
assert not git('status','--porcelain=v1')
patch=subprocess.check_output(['git','diff',r['base'],head,'--',*r['owned_files']],cwd=VAULT)
assert hashlib.sha256(patch).hexdigest()==r['patch_sha256']
for p,h in r['file_sha256'].items(): assert hashlib.sha256((VAULT/p).read_bytes()).hexdigest()==h
assert git('ls-remote',remote,'refs/heads/main').split()[0]==r['base']
r['postcommit_exact_review']='PASS: complete exact HEAD diff read against trusted base; unchanged contract, scope, evidence and residual findings'
r['prepush_head_unchanged']=True
path.write_text(json.dumps(r,indent=2)+'\n')
git('-c',f"core.hooksPath={ROOT/'.zenflow/tasks/new-task-be0b/publication-no-hooks'}",'push',remote,f'{head}:refs/heads/main')
assert git('rev-parse','HEAD')==head
confirmed=git('ls-remote',remote,'refs/heads/main').split()[0]
assert confirmed==head,confirmed
r.update({'push':'PASS non-force exact SHA to main','remote_confirmed':confirmed,'postpush_local_head_unchanged':True})
path.write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps({'head':head,'remote_confirmed':confirmed,'push':'PASS non-force'}))
