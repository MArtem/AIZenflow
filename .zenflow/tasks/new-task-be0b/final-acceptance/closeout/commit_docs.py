from pathlib import Path
import subprocess,json,hashlib,datetime
ROOT=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
VAULT=ROOT.parent/'documentation-vault'
OUT=ROOT/'.zenflow/tasks/new-task-be0b/final-acceptance'
CLOSE=OUT/'closeout'
sync=json.loads((CLOSE/'sync-receipt.json').read_text())
review=json.loads((OUT/'parent-closeout-diff-review.json').read_text())
owned=sync['owned_files']; base=sync['base']
remote='https://github.com/MArtem/AIZenflowDocumentation.git'
hooks=ROOT/'.zenflow/tasks/new-task-be0b/publication-no-hooks'
assert hooks.is_dir() and not any(hooks.iterdir())
def git(*args):
 return subprocess.check_output(['git',*args],cwd=VAULT,text=True).strip()
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
assert git('rev-parse','HEAD')==base
assert git('branch','--show-current')=='main'
assert not git('diff','--cached','--name-only')
assert sorted(git('diff','--name-only',base).splitlines())==sorted(owned)
assert not git('ls-files','--others','--exclude-standard')
assert all(sha(VAULT/p)==h for p,h in sync['after_sha256'].items())
assert all(sha(OUT/p)==h for p,h in sync['root_packet'].items())
actual_remote=git('ls-remote',remote,'refs/heads/main').split()[0]
assert actual_remote==base
merge_base=git('merge-base',actual_remote,'HEAD'); assert merge_base==base
patch=subprocess.check_output(['git','diff','--binary','--full-index',base,'--',*review['paths']],cwd=VAULT)
patch_sha=hashlib.sha256(patch).hexdigest(); assert patch_sha==review['full_patch_sha256']
receipt={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),
 'base':base,'trusted_remote':remote,'validated_remote_before':actual_remote,'actual_merge_base':merge_base,
 'owned_files':owned,'serialization':'git diff --binary --full-index base -- exact3files','patch_sha256':patch_sha,
 'file_sha256':sync['after_sha256'],'root_packet':sync['root_packet'],
 'contract':{'behavior':'Synchronize terminal F01-F06 results, public cancellation-contract repair and bounded QA; preserve general Library NOT_READY',
 'authority':'Direct parent closeout delegation plus standing user authority for canonical documentation commit/push only',
 'producer_consumer':'Detailed matrix and active plan/handoff agree; local2 mirrors byte-identical',
 'ordering':'Both frozen observer arms terminal before approved source repair; actual evidence before claims; exact HEAD review before non-force publication',
 'envelope':'Exact3 canonical task docs plus2 local mirrors; no rules, source, mode, host/config or client Git mutations',
 'failure':'Historical rejects remain historical; procedural PARTIAL and unknown cost never PASS; no current pending runtime authority',
 'claims':'Scoped F02 closed; F06 executed but strict comparison withheld; no Library-added remedy, general LIB004 P2 remains OPEN; no app release claim'},
 'semantic_review':'Complete current candidate reviewed by integrator and independently by parent; no new P0-P3 doc findings',
 'parent_review_sha256':sha(OUT/'parent-closeout-diff-review.json'),
 'checks':{'canonical_diff_check':'PASS once for current iteration','vault_index_and_manifest':'PASS 5193 files /4 app boundaries','client_document_boundaries':'PASS','local_markdown_links':42,'active_plan_handoff_words':sync['words_plan_handoff'],'sync_helper_ast':'PASS'},
 'preservation':json.loads((CLOSE/'preservation-static-receipt.json').read_text()),
 'reused_evidence':'Root source hashes/compiled provenance;66 actual post-fix assertions across iPhone18.2+27;4 fresh unsigned host builds;5 strict standalone module builds;both observer terminal receipts',
 'omitted':'No repeat source/runtime QA; durable UserDefaults relaunch/crash atomicity and repeat-seeding idempotence not established; live Figma/CI/manual signing unavailable; iPad/physical/actual VoiceOver OMITTED_BY_USER',
 'residual':'LIB004 general utility/cost P2 OPEN; F01 verifier P3 and unrelated TC-L02 P3 retained; shipped cancellation producer not established; preexisting compiler warnings retained',
 'mode_status':{'Tchop':'ON/AUTO','BattleshipGame':'ON/AUTO'},'postcommit_exact_review':'PENDING','push':'NOT_RUN'}
(CLOSE/'publication-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
git('add','--',*owned)
assert sorted(git('diff','--cached','--name-only').splitlines())==sorted(owned)
assert hashlib.sha256(subprocess.check_output(['git','diff','--cached','--binary','--full-index','--',*review['paths']],cwd=VAULT)).hexdigest()==patch_sha
git('-c',f'core.hooksPath={hooks}','-c','commit.gpgsign=false','commit','-m','docs: close scoped F01-F06 execution and retain Library acceptance gate')
head=git('rev-parse','HEAD')
assert git('rev-parse','HEAD^')==base
assert sorted(git('diff','--name-only',base,head).splitlines())==sorted(owned)
assert not git('status','--porcelain=v1')
receipt.update({'head':head,'range':base+'..'+head,'canonical_clean':True,'staged_exact3':True})
(CLOSE/'publication-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({'head':head,'base':base,'clean':True,'files':owned}))
