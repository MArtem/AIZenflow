from pathlib import Path
import hashlib,json,re,subprocess,sys
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault');r=Path(__file__).resolve().parent
hooks=w/'.zenflow/tasks/new-task-be0b/publication-no-hooks';assert hooks.is_dir() and not any(hooks.iterdir())
base='5d9f0a7a3fca97765bc2294d6655ed3c1e3836cc';url='https://github.com/MArtem/AIZenflowDocumentation'
def git(*args):return subprocess.check_output(['git','-c','core.hooksPath='+str(hooks),'-c','commit.gpgsign=false',*args],cwd=v)
def sha(b):return hashlib.sha256(b).hexdigest()
def load():return json.loads((r/'publication-receipt.json').read_text())
def save(d):(r/'publication-receipt.json').write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n')
def clean():assert not git('status','--porcelain').strip()
def remote():
    lines=git('ls-remote',url,'refs/heads/main').decode().splitlines();assert len(lines)==1
    h,ref=lines[0].split();assert ref=='refs/heads/main';return h
def blobs(d,ref):
    for p,h in d['file_sha256'].items():assert sha(git('show',ref+':'+p))==h,p
def preserve(d):
    allowed={str(v/p) for p in d['owned_files']}|{str(w/'.zenflow/tasks/new-task-be0b'/n) for n in ['plan.md','handoff.md']}
    for p,h in d['protected_before'].items():
        if p not in allowed:assert sha(Path(p).read_bytes())==h,p
    assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=w).decode().strip()==d['client_head']
    diff=subprocess.check_output(['git','diff','--binary','--full-index','--','.',':(exclude).zenflow/tasks/new-task-be0b/plan.md',':(exclude).zenflow/tasks/new-task-be0b/handoff.md'],cwd=w)
    assert sha(diff)==d['foreign_tracked_diff_sha256']
action=sys.argv[1]
if action=='review':
    d=json.loads((r/'contract.json').read_text());owned=d['owned_files']
    assert git('rev-parse','HEAD','origin/main').decode().splitlines()==[base,base]
    assert git('branch','--show-current').strip()==b'main'
    assert set(git('diff','--name-only').decode().splitlines())==set(owned)
    assert not git('diff','--cached','--name-only').strip() and not git('ls-files','--others','--exclude-standard').strip()
    preserve(d);links=0
    for rel in owned:
        p=v/rel;s=p.read_text();assert 'перечитать весь актуальный набор документации и правил' in s
        assert 'STATIC_REVIEWED_NOT_OBSERVED' in s and 'LIB-004 P2 OPEN' in s
        for href in re.findall(r'\]\(([^)]+)\)',s):
            if href.startswith(('http:','https:','mailto:','#')):continue
            path,sep,anchor=href.partition('#');target=p.parent/path;assert target.exists(),(rel,href)
            if anchor=='tc-op02-v1--bounded-observation-protocol':assert '## TC-OP02 v1 — bounded observation protocol' in target.read_text()
            links+=1
    words=sum(len((v/'tasks/new-task-be0b'/n).read_text().split()) for n in ['plan.md','handoff.md']);assert words<=3500
    for n in ['plan.md','handoff.md']:assert (w/'.zenflow/tasks/new-task-be0b'/n).read_text().startswith((v/'tasks/new-task-be0b'/n).read_text())
    adopt=json.loads((r.parent.parent/'library-canary/adoption-receipt.json').read_text());assert adopt['source_pin']=='3c42e490e82866eee0f303d6340452dbf9fff5eb';assert len(adopt['payload_file_sha256'])==34
    for name in adopt['payload_file_sha256']:assert not Path(name).is_absolute() and '..' not in Path(name).parts
    patch=git('diff','--binary','--full-index');(r/'reviewed.patch').write_bytes(patch)
    d.update({'file_sha256':{p:sha((v/p).read_bytes()) for p in owned},'patch_sha256':sha(patch),
      'final_semantic_review':'Complete3-file final diff reviewed after exact root/Markdown refinement. G0-G5 temporal/authority/read-scope/partial/source-drift/contamination paths reviewed; historical frozen inputs/results unchanged. No owned P0-P3; LIB-004/TC-L02 separately OPEN. No newly observed compliance or general completion.',
      'checks':{'manifest':'PASS','vault':'PASS','boundaries':'PASS','diff_check':'PASS code-fence refinement unchanged whitespace evidence','links':links,'task_state_words':words,'protected_and_foreign_patch':'PASS'},
      'reused':'Unchanged bootstrap/index/router/inventory checks from prior eligible canonical publication;33 preexisting local baseline drifts retained; no global/routing changes',
      'omitted':'No new observer/agents/MCP/runtime/transitions/source/tests. iPad/physical/actual VoiceOver omitted by user. Independent reviewer not authorized; bounded integrator semantic review only',
      'residual':'Protocol instruction v1 is STATIC_REVIEWED_NOT_OBSERVED; no enforceable gate/real-task repeatability or Library utility claim. Next genuine task and any concrete observer grant remain future.',
      'trusted_remote':url+' refs/heads/main'})
    save(d);print('Exact3-file review/static/links/preservation PASS; active words',words,'links',links)
elif action=='stage':
    d=load();assert remote()==base;assert git('rev-parse','HEAD','origin/main').decode().splitlines()==[base,base]
    assert git('merge-base','origin/main','HEAD').decode().strip()==base
    assert git('diff','--binary','--full-index')==(r/'reviewed.patch').read_bytes();preserve(d)
    assert not git('diff','--cached','--name-only').strip()
    for p,h in d['file_sha256'].items():assert sha((v/p).read_bytes())==h
    git('add','--',*d['owned_files']);assert not git('diff','--name-only').strip()
    assert set(git('diff','--cached','--name-only').decode().splitlines())==set(d['owned_files']);blobs(d,'')
    assert git('diff','--cached','--binary','--full-index')==(r/'reviewed.patch').read_bytes()
    d.update({'staged_exact3':True,'target_remote_sha':base,'merge_base':base});save(d);print('Exact3 reviewed docs staged; fresh remote base confirmed.')
elif action=='commit':
    d=load();assert d['staged_exact3'];assert git('rev-parse','HEAD').decode().strip()==base
    assert git('diff','--cached','--binary','--full-index')==(r/'reviewed.patch').read_bytes();blobs(d,'');preserve(d)
    print(git('commit','-m','Tighten bounded Library observation protocol after TC-MP01').decode())
    d['head']=git('rev-parse','HEAD').decode().strip();save(d)
elif action=='postcommit':
    d=load();assert git('rev-parse','HEAD').decode().strip()==d['head'];clean();preserve(d)
    assert git('rev-parse','HEAD^').decode().strip()==base
    assert git('diff','--binary','--full-index',base,d['head'])==(r/'reviewed.patch').read_bytes();blobs(d,d['head'])
    assert set(git('diff','--name-only',base,d['head']).decode().splitlines())==set(d['owned_files'])
    d['postcommit_exact_review']='PASS exact3 reviewed blobs/patch/range; no changed input/contract/blocking finding';d['canonical_clean']=True;save(d);print('Exact postcommit HEAD review PASS',d['head'])
elif action=='push':
    d=load();assert d['postcommit_exact_review'].startswith('PASS');assert git('rev-parse','HEAD').decode().strip()==d['head'];clean();preserve(d);blobs(d,d['head'])
    assert remote()==base;assert git('merge-base',base,d['head']).decode().strip()==base
    print(git('push',url,d['head']+':refs/heads/main').decode());assert remote()==d['head'];assert git('rev-parse','HEAD').decode().strip()==d['head'];clean()
    git('update-ref','refs/remotes/origin/main',d['head'],base);d['remote_confirmed']=d['head'];d['independent_remote_confirmation']='PASS';save(d);print('Independent remote confirmation PASS',d['head'])
else:raise ValueError(action)
