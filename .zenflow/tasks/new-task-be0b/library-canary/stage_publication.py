from pathlib import Path
import subprocess,json,hashlib
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault');r=w/'.zenflow/tasks/new-task-be0b/library-canary';p=r/'precommit-review.json';d=json.loads(p.read_text());hooks=w/'.zenflow/tasks/new-task-be0b/publication-no-hooks'
assert hooks.is_dir() and not any(hooks.iterdir())
def git(*args):return subprocess.check_output(['git','-c','core.hooksPath='+str(hooks),'-c','commit.gpgsign=false',*args],cwd=v)
def sha(b):return hashlib.sha256(b).hexdigest()
assert git('rev-parse','HEAD').decode().strip()==d['canonical_base']=='bef68b8de0c7668fdfc65ae759fec61be1f4b913'
assert git('branch','--show-current').strip()==b'main'
assert not git('diff','--cached','--name-only').strip()
for rel,h in d['file_sha256'].items():assert sha((v/rel).read_bytes())==h,rel
assert git('diff','--binary','--full-index')==(r/'reviewed-tracked.patch').read_bytes()
assert set(git('diff','--name-only').decode().splitlines())|set(git('ls-files','--others','--exclude-standard').decode().splitlines())==set(d['owned_files'])
git('add','--',*d['owned_files'])
assert not git('diff','--name-only').strip()
assert not git('ls-files','--others','--exclude-standard').strip()
assert set(git('diff','--cached','--name-only').decode().splitlines())==set(d['owned_files'])
for rel,h in d['file_sha256'].items():assert sha(git('show',':'+rel))==h,rel
patch=git('diff','--cached','--binary','--full-index');(r/'reviewed-complete.patch').write_bytes(patch)
d['complete_reviewed_patch_sha256']=sha(patch);d['remote_base_observed']='bef68b8de0c7668fdfc65ae759fec61be1f4b913';d['staged_exact_owned_files']=True;p.write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n')
print('STAGED exact9 reviewed files; all blobs match complete candidate; no unrelated or unstaged canonical change.')
