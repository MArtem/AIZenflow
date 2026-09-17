#!/usr/bin/env python3
"""Fail-closed structural validator for the review-ready package. Standard library only."""
import ast, hashlib, json, os, re, stat, sys
from pathlib import Path

ROOT=Path(__file__).resolve().parent
ERRORS=[]

def err(msg): ERRORS.append(msg)

def regular_walk(root):
    for base,dirs,files in os.walk(str(root),topdown=True,followlinks=False,onerror=lambda e: err('package walk failed: '+type(e).__name__)):
        b=Path(base)
        for name in list(dirs):
            p=b/name
            try: st=os.lstat(str(p))
            except OSError as e: err('lstat failed: %s: %s'%(p,e)); dirs.remove(name); continue
            if stat.S_ISLNK(st.st_mode): err('symlink directory must not be shipped: %s'%p); dirs.remove(name)
            elif not stat.S_ISDIR(st.st_mode): err('non-directory tree entry: %s'%p); dirs.remove(name)
        for name in files:
            p=b/name
            try: st=os.lstat(str(p))
            except OSError as e: err('lstat failed: %s: %s'%(p,e)); continue
            if stat.S_ISLNK(st.st_mode): err('symlink file must not be shipped: %s'%p)
            elif not stat.S_ISREG(st.st_mode): err('non-regular file must not be shipped: %s'%p)
            yield p

files=list(regular_walk(ROOT))
for p in files:
    rel=p.relative_to(ROOT).as_posix()
    if '__pycache__' in p.parts or p.suffix=='.pyc': err('bytecode cache must not be shipped: '+rel)

required=[
 'README.md','QUICKSTART.md','MANUAL_DEPLOYMENT.md','MANUAL_SHIM/bin/ios_ai.py','MANUAL_SHIM/bin/manual_preflight.py','MANUAL_SHIM/INSTALLATION.md','MANUAL_SHIM/INSTALLATION.json.template','PROJECT_REFERENCE_OPT_IN.md','REVIEW_FINDINGS_MATRIX.md','REVIEW_READY_VALIDATION_REPORT.md','CAPABILITY_MATRIX.md',
 'GLOBAL_ARCHITECTURE.md','GLOBAL_MANIFEST.json','install_global.py','sync_global.py','uninstall_global.py','host_entry.py',
 'validate_global_install.py','tests/run_all.py','tests/test_review_ready.py',
 'GLOBAL_CODEX/AGENTS.global.block.md','GLOBAL_CODEX/KNOWLEDGE_ROUTER.md','GLOBAL_CODEX/KNOWLEDGE_PROFILE.schema.json','GLOBAL_CODEX/runtime/bin/ios_ai.py','GLOBAL_CODEX/runtime/knowledge_profile.py',
 'GLOBAL_CODEX/runtime/vendor/adapt_project.py','GLOBAL_CODEX/runtime/protection/protection.py',
 '31_DEEP_PLAYBOOKS/COMMON_EXECUTION_CONTRACT.md','40_REPO_AUTOMATION/swift_risk_scan.py',
 '33_CODE_PATTERNS/CP-03_TASK_LIFETIME.md','00_META/CURRENT_OFFICIAL_REFERENCES.md'
]
for rel in required:
    if not (ROOT/rel).is_file(): err('missing required file: '+rel)

# Evidence consistency: shipped test count must agree with the manifest/report.
shipped_test_count = None
try:
    test_tree = ast.parse((ROOT/'tests/test_review_ready.py').read_text(encoding='utf-8'), filename='tests/test_review_ready.py', feature_version=(3,9))
    shipped_test_count = sum(
        1 for node in test_tree.body if isinstance(node, ast.ClassDef)
        for child in node.body if isinstance(child, (ast.FunctionDef, ast.AsyncFunctionDef)) and child.name.startswith('test_')
    )
    if shipped_test_count <= 0:
        err('no shipped regression tests discovered')
except Exception as e:
    err('unable to count shipped regression tests: %s'%e)

# Python syntax: require every shipped Python file to parse using Python 3.9 grammar.
for p in [x for x in files if x.suffix=='.py']:
    try: ast.parse(p.read_text(encoding='utf-8'),filename=str(p),feature_version=(3,9))
    except Exception as e: err('Python 3.9 parse failure %s: %s'%(p.relative_to(ROOT),e))

skills=list((ROOT/'GLOBAL_CODEX/skills').glob('*/SKILL.md'))
if len(skills)!=60: err('skills %d/60'%len(skills))
for p in skills:
    name=p.parent.name
    if not name.startswith('ioslib-'): err('non-namespaced bundled skill: '+name)
    try: t=p.read_text(encoding='utf-8')
    except Exception as e: err('unreadable skill %s: %s'%(p,e)); continue
    if not t.startswith('---\n') or '\nname:' not in t or '\ndescription:' not in t: err('bad skill frontmatter: '+name)
    m=re.search(r'^name:\s*([^\n]+)$',t,re.M)
    if not m or m.group(1).strip()!=name: err('skill frontmatter name does not match directory: '+name)
    if '$ios-' in t: err('generic internal skill reference remains: '+name)
    if not (p.parent/'references/global-runtime.md').is_file(): err('missing runtime reference: '+name)

for p in (ROOT/'GLOBAL_CODEX/skills').rglob('*'):
    if p.is_file() and p.suffix in {'.md','.yaml','.yml'}:
        text=p.read_text(encoding='utf-8',errors='replace')
        if '$ios-' in text: err('non-namespaced internal skill reference: '+str(p.relative_to(ROOT)))

sections=[p for p in ROOT.iterdir() if p.is_dir() and re.match(r'^\d\d_',p.name)]
if len(sections)!=51: err('knowledge sections %d/51'%len(sections))
playbooks=list((ROOT/'31_DEEP_PLAYBOOKS').glob('OP-*.md'))
if len(playbooks)!=288: err('deep playbooks %d/288'%len(playbooks))
old_phrase='Enumerate domain-specific edge cases from the existing implementation and acceptance criteria'
for p in playbooks:
    if old_phrase in p.read_text(encoding='utf-8',errors='replace'): err('unreduced boilerplate remains: '+p.name)

priority_knowledge=[
 '03_CONCURRENCY/IOS-03-06_TASK_LIFETIME.md','03_CONCURRENCY/IOS-03-07_CANCELLATION.md',
 '08_NETWORKING/IOS-08-03_RETRY_BACKOFF.md','08_NETWORKING/IOS-08-02_AUTH_REFRESH.md',
 '05_SWIFTUI/IOS-05-02_STATE_OWNERSHIP.md','05_SWIFTUI/IOS-05-03_VIEW_IDENTITY.md',
 '12_SECURITY_PRIVACY/IOS-12-03_AUTHENTICATION.md','12_SECURITY_PRIVACY/IOS-12-12_SECURITY_REVIEW.md',
 '11_PERFORMANCE_MEMORY/IOS-11-11_PERF_BUDGET.md','11_PERFORMANCE_MEMORY/IOS-11-05_MEMORY_LEAK.md',
 '09_PERSISTENCE_DATA/IOS-09-05_MIGRATIONS.md','13_ACCESSIBILITY_LOCALIZATION/IOS-13-01_VOICEOVER.md']
for rel in priority_knowledge:
    p=ROOT/rel
    if not p.is_file(): err('missing priority knowledge: '+rel); continue
    t=p.read_text(encoding='utf-8',errors='replace').lower()
    for token in ('scenario','common wrong approach','preferred approach','verification','compatibility','checked','https://'):
        if token not in t: err('priority knowledge missing %s: %s'%(token,rel))
    if 'trap' not in t and 'edge case' not in t: err('priority knowledge missing traps/edge cases: '+rel)

try:
    manifest=json.loads((ROOT/'GLOBAL_MANIFEST.json').read_text(encoding='utf-8'))
    if manifest.get('version')!='5.4-review-ready.7': err('manifest version mismatch')
    if manifest.get('default_install_mode')!='reference': err('reference must be default install mode')
    if manifest.get('skill_namespace')!='ioslib-': err('manifest skill namespace mismatch')
    if manifest.get('status')!='review_candidate_independent_review_required': err('manifest must not claim independent acceptance')
    runtime=manifest.get('runtime',{})
    if runtime.get('cli_version')!='5.4-review-ready.7': err('manifest CLI version mismatch')
    if runtime.get('protection_version')!='5.4-review-ready.5': err('manifest protection compatibility mismatch')
    if runtime.get('adapter_version')!='5.4-review-ready.7': err('manifest adapter version mismatch')
    observed=manifest.get('test_suite',{}).get('observed_release_working_tree',{})
    if shipped_test_count is not None:
        observed_total=observed.get('total')
        observed_pass=observed.get('pass')
        observed_fail=observed.get('fail')
        observed_skip=observed.get('skip')
        if (observed_total!=shipped_test_count or not all(isinstance(v,int) and v>=0 for v in
                (observed_pass,observed_fail,observed_skip)) or
                observed_pass+observed_fail+observed_skip!=observed_total):
            err('manifest test evidence count/result does not match shipped suite')
except Exception as e: err('invalid GLOBAL_MANIFEST.json: %s'%e)

try:
    report=(ROOT/'REVIEW_READY_VALIDATION_REPORT.md').read_text(encoding='utf-8')
    if shipped_test_count is not None:
        manifest_suite=manifest.get('test_suite',{}).get('observed_release_working_tree',{})
        for token in (f"total: **{manifest_suite.get('total')}**",
                      f"PASS: **{manifest_suite.get('pass')}**",
                      f"FAIL: **{manifest_suite.get('fail')}**",
                      f"SKIP: **{manifest_suite.get('skip')}**"):
            if token not in report: err('validation report test evidence is stale: missing '+token)
except Exception as e:
    err('unable to verify validation report evidence: %s'%e)

# K05 package file manifest: verify every shipped regular file except the manifest itself.
try:
    pfm_path=ROOT/'PACKAGE_FILE_MANIFEST.json'
    pfm=json.loads(pfm_path.read_text(encoding='utf-8'))
    if pfm.get('schema_version')!=1: err('PACKAGE_FILE_MANIFEST schema mismatch')
    if pfm.get('generated_for')!='5.4-review-ready.7': err('PACKAGE_FILE_MANIFEST version mismatch')
    entries=pfm.get('files')
    if not isinstance(entries,list): raise ValueError('files must be a list')
    expected={}
    for item in entries:
        rel=item.get('path') if isinstance(item,dict) else None
        if not rel or rel in expected or rel=='PACKAGE_FILE_MANIFEST.json' or rel.startswith('/') or '..' in Path(rel).parts:
            err('invalid/duplicate PACKAGE_FILE_MANIFEST path: '+repr(rel)); continue
        expected[rel]=item
    actual={p.relative_to(ROOT).as_posix():p for p in files if p.relative_to(ROOT).as_posix()!='PACKAGE_FILE_MANIFEST.json'}
    for rel,p in actual.items():
        item=expected.get(rel)
        if item is None: err('PACKAGE_FILE_MANIFEST missing shipped file: '+rel); continue
        data=p.read_bytes(); h=hashlib.sha256(data).hexdigest()
        if item.get('sha256')!=h or item.get('size')!=len(data): err('PACKAGE_FILE_MANIFEST stale entry: '+rel)
    for rel in expected:
        if rel not in actual: err('PACKAGE_FILE_MANIFEST lists missing file: '+rel)
except Exception as e: err('invalid PACKAGE_FILE_MANIFEST.json: %s'%e)

critical=(ROOT/'GLOBAL_CODEX/AGENTS.global.block.md').read_text(encoding='utf-8',errors='replace').lower() if (ROOT/'GLOBAL_CODEX/AGENTS.global.block.md').exists() else ''
for token in ['advisory classifier','not a backup','ignored','project-local','knowledge','knowledge_router.md','profile status']:
    if token not in critical: err('global safety block missing concept: '+token)

cli=(ROOT/'GLOBAL_CODEX/runtime/bin/ios_ai.py').read_text(encoding='utf-8',errors='replace') if (ROOT/'GLOBAL_CODEX/runtime/bin/ios_ai.py').exists() else ''
if '--allow-git-metadata' in cli: err('obsolete broad allow-git-metadata still exposed')
if 'BASELINE.json' in cli: err('obsolete shared BASELINE.json still exposed by CLI')
if '--parallel' in cli: err('same-worktree parallel writer CLI flag must not be exposed')
if 'declared-policy' not in cli or 'effective-policy' in cli: err('policy command must be explicitly declared-policy, not effective-policy')

global_block=(ROOT/'GLOBAL_CODEX/AGENTS.global.block.md').read_text(encoding='utf-8',errors='replace') if (ROOT/'GLOBAL_CODEX/AGENTS.global.block.md').exists() else ''
if 'one writer session per Git common directory' not in global_block: err('global block missing one-writer-per-git-common-dir contract')
if 'linked worktrees share that writer slot' not in global_block: err('global block must serialize linked worktrees that share Git common-dir')

scanner=(ROOT/'40_REPO_AUTOMATION/swift_risk_scan.py').read_text(encoding='utf-8',errors='replace') if (ROOT/'40_REPO_AUTOMATION/swift_risk_scan.py').exists() else ''
if r'\btry!\b' in scanner: err('legacy broken force-try regex remains')
if 'source_bodies_emitted' not in scanner: err('risk scanner must explicitly state source-body emission policy')

print('Review-ready package validation: files=%d skills=%d sections=%d playbooks=%d errors=%d'%(len(files),len(skills),len(sections),len(playbooks),len(ERRORS)))
for e in ERRORS: print('ERROR',e)
raise SystemExit(0 if not ERRORS else 1)
