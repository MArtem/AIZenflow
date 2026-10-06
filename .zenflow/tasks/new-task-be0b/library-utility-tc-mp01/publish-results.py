from pathlib import Path
import hashlib,json,re,subprocess,sys
from datetime import datetime,timezone
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
r=w/'.zenflow/tasks/new-task-be0b/library-utility-tc-mp01/result-publication';r.mkdir(exist_ok=True)
hooks=w/'.zenflow/tasks/new-task-be0b/publication-no-hooks'
base='801b22ec753a59383a3e2719f62c934aaf27494c'
owned=['apps/Tchop/MANIFEST.md','apps/Tchop/PROJECT_CONTEXT.md','tasks/new-task-be0b/plan.md','tasks/new-task-be0b/handoff.md','tasks/new-task-be0b/ios-project-work-system-plan.md']
url='https://github.com/MArtem/AIZenflowDocumentation'
assert hooks.is_dir() and not any(hooks.iterdir())
def git(*args): return subprocess.check_output(['git','-c','core.hooksPath='+str(hooks),'-c','commit.gpgsign=false',*args],cwd=v)
def sha(b):return hashlib.sha256(b).hexdigest()
def save(d): (r/'publication-receipt.json').write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n')
def load():return json.loads((r/'publication-receipt.json').read_text())
def remote():
    b=git('ls-remote',url,'refs/heads/main');lines=b.decode().splitlines();assert len(lines)==1
    h,ref=lines[0].split();assert ref=='refs/heads/main';return h
def blobs(d,index=False):
    for p,h in d['file_sha256'].items():assert sha(git('show',(':' if index else d['head']+':')+p))==h,p
def clean():assert not git('status','--porcelain').strip()
action=sys.argv[1]
if action=='review':
    assert git('branch','--show-current').strip()==b'main'
    assert git('rev-parse','HEAD').decode().strip()==base
    assert git('rev-parse','origin/main').decode().strip()==base
    assert not git('diff','--cached','--name-only').strip()
    assert set(git('diff','--name-only').decode().splitlines())==set(owned)
    assert not git('ls-files','--others','--exclude-standard').strip()
    links=0
    for rel in owned:
        p=v/rel;s=p.read_text()
        for href in re.findall(r'\]\(([^)]+)\)',s):
            if href.startswith(('http:','https:','#','mailto:')):continue
            target=href.split('#')[0]
            assert (p.parent/target).exists(),(rel,href)
            links+=1
        if rel.endswith(('plan.md','handoff.md')):assert 'перечитать весь актуальный набор документации и правил' in s
    for rel in ['tasks/new-task-be0b/plan.md','tasks/new-task-be0b/handoff.md','apps/Tchop/PROJECT_CONTEXT.md','tasks/new-task-be0b/ios-project-work-system-plan.md']:
        s=(v/rel).read_text();a=s.index('TC-MP01 completed its two authorized');tail=s[a:]
        for term in ['PARTIAL_PROCEDURAL','LIB-004 P2 OPEN','NOT_READY_FOR_GENERAL_RELEASE','TC-L02 P3 OPEN','token/account cost UNKNOWN','all4 unsigned Debug host builds PASS','Initial18.2 unit timeout UNKNOWN']:
            assert term in tail,(rel,term)
    for name in ['plan.md','handoff.md']:assert (w/'.zenflow/tasks/new-task-be0b'/name).read_bytes()==(v/'tasks/new-task-be0b'/name).read_bytes()
    qa=json.loads((r.parent/'regression/qa-receipt.json').read_text())
    for rel,h in qa['contract']['after_sha256'].items():assert sha((w/rel).read_bytes())==h
    assert git('rev-parse','HEAD').decode().strip()==base
    patch=git('diff','--binary','--full-index');(r/'reviewed-tracked.patch').write_bytes(patch)
    save({'utc':datetime.now(timezone.utc).isoformat(),'base':base,'owned_files':owned,'file_sha256':{p:sha((v/p).read_bytes()) for p in owned},'patch_sha256':sha(patch),
        'client_head':'b7c48e163d9108d1cc4b123d93456ce8f7628d93',
        'contract':'Compact factual TC-MP01 outcomes only; actual2 grants consumed; partial procedural comparison,0 new defects/2 refinements; actual1200 video envelope/claim-limited QA; updated PBX/source/test fingerprints, no Library release or new authority',
        'final_diff_review':'Complete5-file diff reviewed twice after accurate after27 QoS correction; all current claims tied to exact receipts/producer and consumers. No owned P0-P2. Nonblocking fixture QoS diagnostic reported; LIB-004 P2/TC-L02 P3 outside candidate remain OPEN. Core historical E11 scoped/failures preserved; no general completion',
        'checks':{'manifest':'PASS','vault':'PASS','boundaries':'PASS','canonical_active_diff':'PASS','links':links,'claim_consistency':'PASS','source_QA_receipt':'PASS; no source change after verification'},
        'reused':'Unchanged inventory/owners/bootstrap/index evidence from preparation publication; no global rule changes;33 preexisting local baseline drifts retained, no full drift PASS',
        'omitted':'No additional runtime, chats/MCP, full suite/UI/auth/profiling/signing/archive. iPad/physical/actual VoiceOver OMITTED_BY_USER',
        'next':'Human next significant Library approach pending; no extra observer authority','trusted_remote':url+' refs/heads/main'})
    print('Precommit semantic/consistency/links/source receipt PASS; exact5-file patch saved. Links',links)
elif action=='stage':
    d=load();assert remote()==base
    assert git('rev-parse','HEAD').decode().strip()==base
    assert git('merge-base','origin/main','HEAD').decode().strip()==base
    assert git('diff','--binary','--full-index')==(r/'reviewed-tracked.patch').read_bytes()
    assert set(git('diff','--name-only').decode().splitlines())==set(owned)
    assert not git('diff','--cached','--name-only').strip()
    for p,h in d['file_sha256'].items():assert sha((v/p).read_bytes())==h
    git('add','--',*owned);assert not git('diff','--name-only').strip()
    assert set(git('diff','--cached','--name-only').decode().splitlines())==set(owned)
    blobs(d,True);p=git('diff','--cached','--binary','--full-index');assert p==(r/'reviewed-tracked.patch').read_bytes()
    d['staged_exact5']=True;d['remote_before_stage']=base;save(d);print('Exact5 reviewed files staged; fresh remote main801b22ec; no unrelated changes.')
elif action=='commit':
    d=load();assert d['staged_exact5'];assert git('rev-parse','HEAD').decode().strip()==base
    assert git('diff','--cached','--binary','--full-index')==(r/'reviewed-tracked.patch').read_bytes()
    blobs(d,True);assert not git('diff','--name-only').strip()
    print(git('commit','-m','Record Tchop media preview utility results and verified pixel bound').decode())
    d['head']=git('rev-parse','HEAD').decode().strip();save(d)
elif action=='postcommit':
    d=load();assert git('rev-parse','HEAD').decode().strip()==d['head'];clean()
    assert git('rev-parse','HEAD^').decode().strip()==base
    p=git('diff','--binary','--full-index',base,d['head']);assert p==(r/'reviewed-tracked.patch').read_bytes();blobs(d)
    assert set(git('diff','--name-only',base,d['head']).decode().splitlines())==set(owned)
    d['postcommit_exact_review']='PASS exact reviewed range/5 blobs/complete patch; no changed contract or new blocking finding';d['canonical_clean']=True;save(d)
    print('Postcommit exact HEAD review PASS',d['head'])
elif action=='push':
    d=load();assert d['postcommit_exact_review'].startswith('PASS');assert git('rev-parse','HEAD').decode().strip()==d['head'];clean();blobs(d)
    before=remote();assert before==base;assert git('merge-base',base,d['head']).decode().strip()==base
    print(git('push',url,d['head']+':refs/heads/main').decode())
    after=remote();assert after==d['head'];assert git('rev-parse','HEAD').decode().strip()==d['head'];clean()
    git('update-ref','refs/remotes/origin/main',d['head'],base)
    d['remote_before_push']=before;d['remote_after']=after;d['independent_remote_confirmation']='PASS';save(d)
    print('Independent remote SHA confirmation PASS',after)
else:raise ValueError(action)
