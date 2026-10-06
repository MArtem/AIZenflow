from pathlib import Path
import json,hashlib,subprocess
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault');r=w/'.zenflow/tasks/new-task-be0b/library-canary/ordered-result-publication';p=r/'precommit-review.json';d=json.loads(p.read_text());hooks=w/'.zenflow/tasks/new-task-be0b/publication-no-hooks'
def git(*args):return subprocess.check_output(['git','-c','core.hooksPath='+str(hooks),'-c','commit.gpgsign=false',*args],cwd=v)
def sha(b):return hashlib.sha256(b).hexdigest()
assert hooks.is_dir() and not any(hooks.iterdir());assert git('branch','--show-current').strip()==b'main';assert git('rev-parse','HEAD').decode().strip()==d['base']
assert git('merge-base','refs/remotes/origin/main','HEAD').decode().strip()==d['base'];assert git('rev-parse','refs/remotes/origin/main').decode().strip()==d['base']
assert not git('diff','--cached','--name-only').strip()
assert git('diff','--binary','--full-index')==(r/'reviewed-tracked.patch').read_bytes()
for rel,h in d['file_sha256'].items():assert sha((v/rel).read_bytes())==h,rel
changed=set(git('diff','--name-only').decode().splitlines())|set(git('ls-files','--others','--exclude-standard').decode().splitlines());assert changed==set(d['owned_files'])
git('add','--',*d['owned_files'])
assert not git('diff','--name-only').strip() and not git('ls-files','--others','--exclude-standard').strip()
assert set(git('diff','--cached','--name-only').decode().splitlines())==set(d['owned_files'])
for rel,h in d['file_sha256'].items():assert sha(git('show',':'+rel))==h,rel
patch=git('diff','--cached','--binary','--full-index');(r/'reviewed-complete.patch').write_bytes(patch)
d.update({'trusted_remote':'https://github.com/MArtem/AIZenflowDocumentation refs/heads/main','target_remote_sha':d['base'],'merge_base':d['base'],'staged_exact9':True,'complete_patch_sha256':sha(patch)})
d['checks'].update({n:'PASS' for n in ['manifest check','vault check','boundary check','docs consistency','canonical diff check','active diff check']});p.write_text(json.dumps(d,indent=2,ensure_ascii=True)+'\n');print('Exact reviewed9 files staged; trusted main SHA/merge-basee132655; no unrelated canonical changes.')
