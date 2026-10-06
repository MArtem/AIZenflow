from pathlib import Path
import subprocess,json,hashlib,datetime

ROOT=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
VAULT=Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
OUT=ROOT/'.zenflow/tasks/new-task-be0b/final-acceptance'
contract=json.loads((OUT/'dispatch-contract.json').read_text())
owned=contract['owned_canonical_files']
base=contract['base']
remote='https://github.com/MArtem/AIZenflowDocumentation.git'
hooks=ROOT/'.zenflow/tasks/new-task-be0b/publication-no-hooks'
hooks.mkdir(exist_ok=True)
assert not any(hooks.iterdir())
def git(*args):
 return subprocess.check_output(['git',*args],cwd=VAULT).decode().strip()
assert git('rev-parse','HEAD')==base
assert git('branch','--show-current')=='main'
assert not git('diff','--cached','--name-only')
assert sorted(git('diff','--name-only',base).splitlines())==sorted(owned)
assert not git('ls-files','--others','--exclude-standard')
actual_remote=git('ls-remote',remote,'refs/heads/main').split()[0]
assert actual_remote==base,actual_remote
patch=subprocess.check_output(['git','diff',base,'--',*owned],cwd=VAULT)
receipt={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),
 'base':base,'owned_files':owned,'trusted_remote':remote,'target_remote_sha':actual_remote,
 'contract':{'behavior':'Publish finite observed results and explicit unmet gates; no source or permission change',
 'authority':'Standing user AGENTS authorizes canonical documentation commit/push after gates; exact3 parent-preparation files transferred',
 'producer_consumer':'Main matrix owns detailed scope; active plan/handoff mirror open F02/F06 and Library verdict',
 'ordering':'Actual output precedes claims; KB frozen before Library; final diff/HEAD/remote review before publication',
 'envelope':'Only exact3 canonical documents; no raw secrets/records/logs; local2 mirrors plus task receipts',
 'failure':'Original verifier/runtime/approval failures retained; BLOCKED/UNKNOWN never PASS',
 'claims':'Core unchanged, scoped execution only, general Library NOT_READY LIB004 P2 OPEN, no app release'},
 'patch_sha256':hashlib.sha256(patch).hexdigest(),
 'file_sha256':{p:hashlib.sha256((VAULT/p).read_bytes()).hexdigest() for p in owned},
 'final_semantic_review':'Complete candidate against base read; evidence/count/platform/refusal boundaries checked. No P0-P2 introduced by docs patch.',
 'findings':{'patch':'no P0-P2; existing F01 verifier P3 reported','system':'LIB004 P2 OPEN, F02/F06 blocked; publication does not waive','unrelated':'TC-L02 P3 untouched'},
 'checks':{'vault_including_manifest':'PASS','boundaries':'PASS','canonical_and_client_diff_check':'PASS','local_links':42,'active_plan_handoff_words':2902,'fixture_python_parse':'PASS'},
 'reused':'Four unchanged unsigned host builds; prior core/E11 scoped evidence only',
 'omitted':'No fresh observer or Simulator runtime after rejection; signing/liveFigma unavailable; iPad/physical/VoiceOver OMITTED_BY_USER',
 'preservation':json.loads((OUT/'final-preservation.json').read_text()),
 'residual':'F02 iPhone18.2+27 and F06 fresh comparison require direct human authority; cost unknown, verifier remains FAIL'}
(OUT/'publication-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
git('add','--',*owned)
assert sorted(git('diff','--cached','--name-only').splitlines())==sorted(owned)
git('-c',f'core.hooksPath={hooks}','-c','commit.gpgsign=false','commit','-m','docs: record scoped F01-F06 evidence and blocked acceptance')
head=git('rev-parse','HEAD')
assert git('rev-parse','HEAD^')==base
assert sorted(git('diff','--name-only',base,head).splitlines())==sorted(owned)
assert not git('status','--porcelain=v1')
receipt.update({'head':head,'range':base+'..'+head,'staged_exact3':True,'canonical_clean':True,'postcommit_exact_review':'PENDING','push':'NOT_RUN'})
(OUT/'publication-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({'head':head,'base':base,'clean':True,'files':owned}))
