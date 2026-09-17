from __future__ import annotations
import contextlib, hashlib, importlib.util, io, json, os, shutil, stat, subprocess, sys, tempfile, threading, time, types, unittest, zipfile
from unittest import mock
from pathlib import Path, PurePosixPath

ROOT=Path(__file__).resolve().parents[1]
# Synthetic Git identity avoids two config subprocesses for every temporary repo.
os.environ.setdefault('GIT_AUTHOR_NAME','Synthetic Test')
os.environ.setdefault('GIT_AUTHOR_EMAIL','synthetic@example.invalid')
os.environ.setdefault('GIT_COMMITTER_NAME','Synthetic Test')
os.environ.setdefault('GIT_COMMITTER_EMAIL','synthetic@example.invalid')
CLI=ROOT/'GLOBAL_CODEX/runtime/bin/ios_ai.py'
RISK_SCAN=ROOT/'40_REPO_AUTOMATION/swift_risk_scan.py'
sys.path.insert(0,str(ROOT))

# The runner accepts an operator-selected fixture root so the shipped tests remain portable.
# Release evidence runs set this inside the approved .zenflow sandbox; a clean Mac may provide a
# different temporary root. Positive deployment tests require that root to be outside every Git
# repository and are explicitly NOT_RUN when the host offers no such permitted path.
TEST_TMP_ROOT=Path(os.environ.get('IOSLIB_TEST_TMP_ROOT', str(Path(tempfile.gettempdir())/'ioslib-test-tmp'))).expanduser().absolute()
def test_tmpdir():
    TEST_TMP_ROOT.mkdir(parents=True,exist_ok=True)
    return Path(tempfile.mkdtemp(dir=TEST_TMP_ROOT))

import install_global as I
import sync_global as S
import uninstall_global as U
import host_entry as H

def load(name,path):
    spec=importlib.util.spec_from_file_location(name,path); mod=importlib.util.module_from_spec(spec); sys.modules[name]=mod; assert spec and spec.loader; spec.loader.exec_module(mod); return mod
P=load('review_test_protection',ROOT/'GLOBAL_CODEX/runtime/protection/protection.py')
A=load('review_test_adapter',ROOT/'GLOBAL_CODEX/runtime/vendor/adapt_project.py')
C=load('review_test_cli',CLI)
V=load('review_test_validate_global_install',ROOT/'validate_global_install.py')
M=load('review_manual_preflight',ROOT/'MANUAL_SHIM/bin/manual_preflight.py')

def run(argv,cwd=None,env=None,check=False):
    p=subprocess.run([str(x) for x in argv],cwd=str(cwd) if cwd else None,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    if check and p.returncode!=0: raise AssertionError(f'command failed {argv}: rc={p.returncode}\nout={p.stdout}\nerr={p.stderr}')
    return p

def git(repo,*args,check=True): return run(['git',*args],repo,check=check)

def init_repo(path:Path,files=None):
    path.mkdir(parents=True,exist_ok=True); git(path,'init','-q')
    for rel,text in (files or {'A.swift':'let a = 1\n','B.swift':'let b = 1\n'}).items():
        p=path/rel; p.parent.mkdir(parents=True,exist_ok=True); p.write_text(text)
    git(path,'add','.'); git(path,'commit','-m','baseline'); return path

def cli(repo:Path,state:Path,*args):
    return run([sys.executable,CLI,'--state-root',state,*args,'--repo',repo]) if args and args[0] in {'build-phases','context','path','effective-policy'} else run([sys.executable,CLI,'--state-root',state,*args])

def protect(repo:Path,state:Path,*args):
    return run([sys.executable,CLI,'--state-root',state,'protect',*args,'--repo',repo])

def parse_json_stream(text):
    return json.loads(text)

def install_args(home:Path,skills:Path,mode='reference',source_in_place=True,preflight_id=None):
    return types.SimpleNamespace(codex_home=str(home),runtime_root=None,skills_root=str(skills),agents_file=None,use_source_in_place=source_in_place,mode=mode,preflight_id=preflight_id,dry_run=False)

_REAL_GIT_ROOT_FOR_DESTINATION=I._git_root_for_destination

def _external_test_git_root(path):
    root, issue = _REAL_GIT_ROOT_FOR_DESTINATION(path)
    # The controlled runner may execute with an elevated HOME while the approved
    # fixture root remains under /Users/Artem/.zenflow. Treat only this explicit
    # operator-selected fixture subtree as external; production Git-boundary
    # enforcement remains unmodified.
    path=Path(path).absolute()
    fixture=TEST_TMP_ROOT
    if root == Path.home() or path == fixture or fixture in path.parents:
        return None, None
    return root, issue

def external_fixture_available():
    """Return whether this host exposes a permitted target outside every detected Git root."""
    root, issue = _REAL_GIT_ROOT_FOR_DESTINATION(TEST_TMP_ROOT)
    return root is None and issue is None

def fresh_install(home:Path,skills:Path,mode='reference'):
    home.mkdir(parents=True,exist_ok=True)
    if not (home/'AGENTS.md').exists(): (home/'AGENTS.md').write_bytes(b'# synthetic user rules\n')
    a=install_args(home,skills,mode)
    # Synthetic fixtures are deliberately local unit tests. They do not alter production Git
    # boundary policy, and the real CLI cases below remain unmocked when an external root exists.
    with mock.patch.object(I,'_git_root_for_destination',side_effect=_external_test_git_root):
        pre=I.build_preflight(a,False); a.preflight_id=pre['preflight_id']; return I.apply_fresh(pre,a)

def run_bounded(argv,cwd=None,env=None,timeout=3):
    try:
        return subprocess.run([str(x) for x in argv],cwd=str(cwd) if cwd else None,env=env,
                              text=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=timeout)
    except subprocess.TimeoutExpired as error:
        raise AssertionError(f'bounded CLI timeout after {timeout}s: {argv}') from error

class GuardTests(unittest.TestCase):
    def test_F01_guard_unknown_mutation(self):
        for cmd in ['touch Example.swift','echo value > Example.swift','mystery --x','echo "bad','cat a | cat','pwd && touch x','git status & touch x','git -C "$PWD" status','echo $(id)','python3 -c "print(1)"','curl https://example.invalid','pod install','fastlane release']:
            with self.subTest(cmd=cmd): self.assertNotEqual(P.command_guard(cmd)['classification'],'ALLOW_READ_ONLY')
    def test_F01_git_global_options(self):
        self.assertEqual(P.command_guard('git -C . status')['classification'],'ALLOW_READ_ONLY')
        self.assertNotEqual(P.command_guard('git -C . add file')['classification'],'ALLOW_READ_ONLY')
        self.assertNotEqual(P.command_guard('git -c core.pager=cat status')['classification'],'ALLOW_READ_ONLY')
        self.assertNotEqual(P.command_guard('git --git-dir=.git status')['classification'],'ALLOW_READ_ONLY')
    def test_F01_safe_git(self):
        self.assertEqual(P.command_guard('git status')['classification'],'ALLOW_READ_ONLY')
        self.assertEqual(P.command_guard('git diff')['classification'],'ALLOW_READ_ONLY')
        self.assertEqual(P.command_guard('git remote -v')['classification'],'ALLOW_READ_ONLY')
        self.assertEqual(P.command_guard('git remote get-url origin')['classification'],'ALLOW_READ_ONLY')
        self.assertNotEqual(P.command_guard('git remote show origin')['classification'],'ALLOW_READ_ONLY')
        self.assertNotEqual(P.command_guard('git remote add origin https://example.invalid/repo.git')['classification'],'ALLOW_READ_ONLY')
        self.assertNotEqual(P.command_guard('git branch new-work')['classification'],'ALLOW_READ_ONLY')
    def test_F08_guard_secret_nonretention(self):
        secret='SYNTHETIC_API_KEY_qwerty_12345'
        r=P.command_guard(f'curl -H "Authorization: Bearer {secret}" https://example.invalid')
        self.assertNotIn(secret,json.dumps(r)); self.assertNotIn('Authorization',json.dumps(r)); self.assertIn('command_sha256',r)
    def test_F08_guard_leading_assignment_nonretention(self):
        secret='SYNTHETIC_ASSIGNMENT_SECRET_12345'
        r=P.command_guard(f'API_KEY={secret} git status')
        encoded=json.dumps(r)
        self.assertNotIn(secret,encoded); self.assertNotIn('API_KEY=',encoded)
        self.assertEqual(r['classification'],'REVIEW_UNSUPPORTED'); self.assertEqual(r['executable'],'unknown')

class SecureWriteTests(unittest.TestCase):
    def setUp(self): self.td=test_tmpdir(); self.state=self.td/'state'; self.out=self.td/'outside'; self.out.mkdir()
    def tearDown(self): shutil.rmtree(self.td,ignore_errors=True)
    def test_F02_dangling_symlink(self):
        self.state.mkdir(); target=self.out/'new.txt'; dest=self.state/'x.json'; dest.symlink_to(target)
        with self.assertRaises(P.ProtectionError): P.secure_write(dest,'secret')
        self.assertFalse(target.exists())
    def test_F02_existing_symlink(self):
        self.state.mkdir(); target=self.out/'existing.txt'; target.write_text('before'); dest=self.state/'x.json'; dest.symlink_to(target)
        with self.assertRaises(P.ProtectionError): P.secure_write(dest,'after')
        self.assertEqual(target.read_text(),'before')
    def test_F02_parent_symlink(self):
        real=self.out/'real'; real.mkdir(); parent=self.td/'link'; parent.symlink_to(real,target_is_directory=True)
        with self.assertRaises(P.ProtectionError): P.secure_write(parent/'x.json','after')
        self.assertFalse((real/'x.json').exists())
    def test_F02_race_like_destination_replacement(self):
        self.state.mkdir(); target=self.out/'victim.txt'; target.write_text('before'); dest=self.state/'x.json'
        original=P.os.replace; fired={'v':False}
        def raced(src,dst,*args,**kwargs):
            if not fired['v'] and dst==dest.name and kwargs.get('dst_dir_fd') is not None:
                fired['v']=True
                try: os.symlink(str(target),dest.name,dir_fd=kwargs['dst_dir_fd'])
                except FileExistsError: pass
            return original(src,dst,*args,**kwargs)
        P.os.replace=raced
        try: P.secure_write(dest,'safe')
        finally: P.os.replace=original
        self.assertTrue(fired['v']); self.assertEqual(target.read_text(),'before'); self.assertEqual(dest.read_text(),'safe'); self.assertFalse(dest.is_symlink())

    def test_F02_permission_failure_rejected(self):
        self.state.mkdir(); dest=self.state/'x.json'; original=P.os.fchmod
        def denied(fd,mode): raise PermissionError('synthetic chmod denial')
        P.os.fchmod=denied
        try:
            with self.assertRaises(P.ProtectionError): P.secure_write(dest,'secret')
        finally: P.os.fchmod=original
        self.assertFalse(dest.exists())

class ProtectionSessionTests(unittest.TestCase):
    def setUp(self):
        self.td=test_tmpdir(); self.repo=init_repo(self.td/'repo'); self.state=self.td/'state'
    def tearDown(self): shutil.rmtree(self.td,ignore_errors=True)
    def args(self,allow=None,allow_dirty=None,allow_protected=None,allow_nested=None,transitions=None,parallel=False,task=''):
        return types.SimpleNamespace(allow=allow or [],allow_dirty=allow_dirty or [],allow_protected=allow_protected or [],allow_nested=allow_nested or [],git_transition=transitions or [],parallel=parallel,task=task)
    def begin(self,**kwargs): return C.begin_session(self.repo,self.state,self.args(**kwargs))['session_id']
    def verify(self,sid): return C.verify_session(self.repo,self.state,sid,True)
    def write_v52_session(self,repo=None,lifecycle='closed',sid=None,mutate=None):
        repo=repo or self.repo; sid=sid or str(__import__('uuid').uuid4()); baseline=P.capture(repo)
        scope={'allow':['A.swift'],'allow_dirty':[],'allow_protected':[],'allow_nested':[],'git_transitions':[],'task':None}
        audit=[{'at':'2026-09-11T00:00:00+00:00','event':'begin','scope_sha256':C.jhash(scope)}]
        if lifecycle in {'verified','closed'}: audit.append({'at':'2026-09-11T00:01:00+00:00','event':'verify','result':'PASS'})
        if lifecycle=='closed': audit.append({'at':'2026-09-11T00:02:00+00:00','event':'close'})
        data={'schema_version':2,'session_id':sid,'lifecycle':lifecycle,'created_at':'2026-09-11T00:00:00+00:00','baseline':baseline,'baseline_sha256':C.jhash(baseline),'scope':scope,'writer_model':'one-writer-per-worktree','audit':audit}
        if mutate: mutate(data)
        path=C.sessions_dir(repo,self.state)/(sid+'.json'); P.save_json(path,data); return sid,data,path

    def test_A53_01_closed_v52_session_allows_v53_begin_same_state(self):
        legacy,_,_=self.write_v52_session(lifecycle='closed')
        current=C.begin_session(self.repo,self.state,self.args(allow=['B.swift']))['session_id']
        self.assertNotEqual(current,legacy); self.assertTrue(C.close_session(self.repo,self.state,current)['ok'])

    def test_A53_01_archival_audit_remains_visible_without_evidence_promotion(self):
        legacy,data,path=self.write_v52_session(lifecycle='closed'); before=path.read_bytes()
        rows=C.list_sessions(self.repo,self.state); row=next(x for x in rows if x['session_id']==legacy)
        self.assertEqual(row['lifecycle'],'closed'); self.assertEqual(row['schema_version'],2)
        self.assertEqual(row['compatibility'],'legacy-v5.2-closed-archival'); self.assertTrue(row['historical_evidence_only'])
        self.assertEqual(row['audit'],data['audit']); self.assertEqual(path.read_bytes(),before)
        loaded=C.load_session(self.repo,self.state,legacy); self.assertTrue(loaded['_historical_evidence_only'])

    def test_A53_01_explicit_status_does_not_reverify_archival_v52_evidence(self):
        legacy,_,_=self.write_v52_session(lifecycle='closed')
        proc=protect(self.repo,self.state,'status','--session',legacy)
        self.assertEqual(proc.returncode,0,proc.stderr); payload=json.loads(proc.stdout)
        self.assertEqual(payload['status'],'ARCHIVAL_CLOSED'); self.assertTrue(payload['historical_evidence_only'])
        self.assertIsNone(payload['verification']); self.assertEqual(payload['schema_version'],2)

    def test_A53_01_active_or_verified_v52_session_blocks_upgrade(self):
        for lifecycle in ('active','verified'):
            with self.subTest(lifecycle=lifecycle):
                sid,_,path=self.write_v52_session(lifecycle=lifecycle)
                with self.assertRaises(C.P.ProtectionError) as ctx: C.begin_session(self.repo,self.state,self.args(allow=['B.swift']))
                self.assertIn('shares this Git common directory',str(ctx.exception))
                path.unlink()

    def test_A53_01_corrupt_foreign_and_unknown_sessions_fail_closed(self):
        cases=[]
        def corrupt(d): d['baseline_sha256']='0'*64
        cases.append(corrupt)
        other=init_repo(self.td/'foreign',{'A.swift':'let x = 1\n'})
        def foreign(d):
            d['baseline']['repository_identity']['worktree']=str(other.resolve()); d['baseline_sha256']=C.jhash(d['baseline'])
        cases.append(foreign)
        def unknown(d): d['schema_version']=99
        cases.append(unknown)
        for mutate in cases:
            with self.subTest(case=mutate.__name__):
                _,_,path=self.write_v52_session(lifecycle='closed',mutate=mutate)
                with self.assertRaises(C.P.ProtectionError): C.begin_session(self.repo,self.state,self.args(allow=['B.swift']))
                path.unlink()

    def test_A53_01_upgrade_compatibility_is_idempotent_and_preserves_legacy_json(self):
        legacy,_,path=self.write_v52_session(lifecycle='closed'); before=path.read_bytes()
        for _ in range(2):
            self.assertEqual(C.active_sessions(self.repo,self.state),[])
            sid=C.begin_session(self.repo,self.state,self.args(allow=['B.swift']))['session_id']
            self.assertTrue(C.close_session(self.repo,self.state,sid)['ok'])
            self.assertEqual(path.read_bytes(),before)
        row=next(x for x in C.list_sessions(self.repo,self.state) if x['session_id']==legacy)
        self.assertTrue(row['historical_evidence_only'])

    def test_A53_01_linked_worktree_closed_legacy_allowed_but_shared_active_legacy_blocks(self):
        git(self.repo,'branch','legacy-linked'); linked=self.td/'legacy-linked'; git(self.repo,'worktree','add','-q',str(linked),'legacy-linked')
        self.write_v52_session(repo=self.repo,lifecycle='closed')
        linked_closed,_,_=self.write_v52_session(repo=linked,lifecycle='closed')
        sid=C.begin_session(linked,self.state,self.args(allow=['B.swift']))['session_id']; self.assertTrue(C.close_session(linked,self.state,sid)['ok'])
        linked_row=next(x for x in C.list_sessions(linked,self.state) if x['session_id']==linked_closed); self.assertTrue(linked_row['historical_evidence_only'])
        active,_,active_path=self.write_v52_session(repo=self.repo,lifecycle='active')
        with self.assertRaises(C.P.ProtectionError): C.begin_session(linked,self.state,self.args(allow=['A.swift']))
        self.assertTrue(active_path.exists()); self.assertEqual(C.P.load_json(active_path)['session_id'],active)

    def test_A53_01_legacy_scanner_rejects_intermediate_symlink_escape(self):
        for component in ('protection','sessions'):
            with self.subTest(component=component):
                scoped=self.td/component; repo=init_repo(scoped/'repo'); self.write_v52_session(repo=repo,lifecycle='closed')
                state_dir=C.repo_state_dir(repo,self.state); protection=state_dir/'protection'; sessions=protection/'sessions'
                outside=scoped/'outside'; outside.mkdir(parents=True)
                target=outside/component; target.mkdir()
                victim=protection if component=='protection' else sessions
                if component=='protection': shutil.rmtree(protection)
                else: shutil.rmtree(sessions)
                victim.symlink_to(target,target_is_directory=True)
                with self.assertRaises(C.P.ProtectionError): C._scan_legacy_v52_shared_writer_blockers(repo,self.state)

    def test_A53_01_legacy_scanner_deadline_covers_final_record_read(self):
        self.write_v52_session(lifecycle='closed')
        original_loader=C.P.secure_read_json; original_deadline=C.LEGACY_SCAN_DEADLINE_SECONDS; called={'value':False}
        def slow_loader(path,max_bytes=4*1024*1024,expected_identity=None):
            called['value']=True; time.sleep(0.05); return original_loader(path,max_bytes=max_bytes,expected_identity=expected_identity)
        C.P.secure_read_json=slow_loader; C.LEGACY_SCAN_DEADLINE_SECONDS=0.01
        try:
            with self.assertRaises(C.P.ProtectionError) as ctx:
                C._scan_legacy_v52_shared_writer_blockers(self.repo,self.state)
            self.assertIn('deadline',str(ctx.exception))
            self.assertTrue(called['value'])
        finally:
            C.P.secure_read_json=original_loader; C.LEGACY_SCAN_DEADLINE_SECONDS=original_deadline

    def test_A54_02_legacy_scanner_deadline_covers_final_record_validation(self):
        self.write_v52_session(lifecycle='closed')
        original_validate=C._validate_session_record; original_deadline=C.LEGACY_SCAN_DEADLINE_SECONDS
        def slow_validate(*args,**kwargs):
            result=original_validate(*args,**kwargs); time.sleep(0.05); return result
        C._validate_session_record=slow_validate; C.LEGACY_SCAN_DEADLINE_SECONDS=0.01
        try:
            with self.assertRaises(C.P.ProtectionError) as ctx:
                C._scan_legacy_v52_shared_writer_blockers(self.repo,self.state)
            self.assertIn('deadline',str(ctx.exception))
        finally:
            C._validate_session_record=original_validate; C.LEGACY_SCAN_DEADLINE_SECONDS=original_deadline

    def test_A53_01_legacy_scanner_enforces_exact_aggregate_byte_boundary(self):
        _,_,path=self.write_v52_session(lifecycle='closed'); size=path.stat().st_size; original=C.LEGACY_SCAN_MAX_BYTES
        try:
            C.LEGACY_SCAN_MAX_BYTES=size
            self.assertEqual(C._scan_legacy_v52_shared_writer_blockers(self.repo,self.state),[])
            C.LEGACY_SCAN_MAX_BYTES=size-1
            with self.assertRaises(C.P.ProtectionError) as ctx:
                C._scan_legacy_v52_shared_writer_blockers(self.repo,self.state)
            self.assertIn('byte budget',str(ctx.exception))
        finally:
            C.LEGACY_SCAN_MAX_BYTES=original

    def test_A54_02_legacy_scanner_enforces_per_file_byte_boundary(self):
        _,_,path=self.write_v52_session(lifecycle='closed'); original=C.LEGACY_SCAN_MAX_FILE_BYTES
        try:
            C.LEGACY_SCAN_MAX_FILE_BYTES=path.stat().st_size-1
            with self.assertRaises(C.P.ProtectionError) as ctx:
                C._scan_legacy_v52_shared_writer_blockers(self.repo,self.state)
            self.assertIn('file byte budget',str(ctx.exception))
        finally:
            C.LEGACY_SCAN_MAX_FILE_BYTES=original

    def test_A53_01_legacy_scanner_rejects_file_replacement_between_stat_and_read(self):
        _,_,path=self.write_v52_session(lifecycle='closed'); replacement=self.td/'replacement-target'; replacement.write_bytes(path.read_bytes()); replacement.chmod(0o600)
        original_loader=C.P.secure_read_json; fired={'value':False}
        def raced_loader(target,max_bytes=4*1024*1024,expected_identity=None):
            if not fired['value']:
                fired['value']=True; target.unlink(); replacement.rename(target)
            return original_loader(target,max_bytes=max_bytes,expected_identity=expected_identity)
        C.P.secure_read_json=raced_loader
        try:
            with self.assertRaises(C.P.ProtectionError): C._scan_legacy_v52_shared_writer_blockers(self.repo,self.state)
            self.assertTrue(fired['value'])
        finally:
            C.P.secure_read_json=original_loader

    def test_A53_01_legacy_scanner_iteration_failure_is_nonpass(self):
        self.write_v52_session(lifecycle='closed'); original_scandir=C.os.scandir; calls={'value':0}
        def failed_scandir(path):
            calls['value']+=1
            if calls['value']==2: raise OSError('synthetic iteration failure')
            return original_scandir(path)
        C.os.scandir=failed_scandir
        try:
            with self.assertRaises(C.P.ProtectionError) as ctx:
                C._scan_legacy_v52_shared_writer_blockers(self.repo,self.state)
            self.assertIn('iteration failed',str(ctx.exception))
        finally:
            C.os.scandir=original_scandir

    def test_F03_rebegin_does_not_replace_session(self):
        sid=self.begin(allow=['A.swift'])
        with self.assertRaises(C.P.ProtectionError): C.begin_session(self.repo,self.state,self.args(allow=['A.swift']))
        self.assertIn(sid,[x['session_id'] for x in C.list_sessions(self.repo,self.state)])
    def test_F03_same_worktree_parallel_session_rejected(self):
        self.begin(allow=['A.swift'])
        with self.assertRaises(C.P.ProtectionError):
            C.begin_session(self.repo,self.state,self.args(allow=['B.swift'],parallel=True))
        self.assertEqual(len(C.active_sessions(self.repo,self.state)),1)
    def test_F03_malformed_session_fail_closed(self):
        self.begin(allow=['A.swift']); d=C.sessions_dir(self.repo,self.state); C.P.secure_write(d/'deadbeef.json','{"schema_version":1}')
        with self.assertRaises(C.P.ProtectionError): C.begin_session(self.repo,self.state,self.args(allow=['B.swift'],parallel=True))
    def test_F04_commit_inside_scope(self):
        sid=self.begin(allow=['A.swift'],transitions=['commit']); (self.repo/'A.swift').write_text('let a = 2\n'); git(self.repo,'add','A.swift'); git(self.repo,'commit','-m','allowed')
        r=self.verify(sid); self.assertTrue(r['ok'],r)
    def test_F04_commit_outside_scope(self):
        sid=self.begin(allow=['A.swift'],transitions=['commit']); (self.repo/'B.swift').write_text('let b = 2\n'); git(self.repo,'add','B.swift'); git(self.repo,'commit','-m','outside')
        r=self.verify(sid); self.assertFalse(r['ok']); self.assertIn('committed path outside declared write scope: B.swift',r['violations'])
    def test_F04_config_mutation(self):
        sid=self.begin(allow=['A.swift'],transitions=['commit']); git(self.repo,'config','synthetic.key','value'); r=self.verify(sid); self.assertFalse(r['ok']); self.assertIn('local Git config/remotes changed',r['violations'])
    def test_F04_ref_mutation(self):
        sid=self.begin(allow=['A.swift'],transitions=['commit']); git(self.repo,'tag','synthetic-tag'); r=self.verify(sid); self.assertFalse(r['ok']); self.assertTrue(any('Git ref changed' in x for x in r['violations']))
    def test_F04_branch_change(self):
        sid=self.begin(allow=['A.swift'],transitions=['commit']); git(self.repo,'switch','-c','synthetic-branch'); r=self.verify(sid); self.assertFalse(r['ok']); self.assertIn('branch/HEAD attachment changed',r['violations'])
    def test_F04_staging_outside_scope(self):
        sid=self.begin(allow=['A.swift'],transitions=['stage']); (self.repo/'B.swift').write_text('let b = 3\n'); git(self.repo,'add','B.swift'); r=self.verify(sid); self.assertFalse(r['ok']); self.assertIn('semantic Git index path outside declared write scope: B.swift',r['violations'])
    def test_F04_preexisting_staged_blob_change_with_commit_transition(self):
        # Keep A.swift staged across an unrelated allowed commit, but replace only A's
        # index blob. Path-set comparison alone would miss this semantic index mutation.
        (self.repo/'A.swift').write_text('let a = 20\n'); git(self.repo,'add','A.swift')
        sid=self.begin(allow=['B.swift'],transitions=['commit'])
        blob=self.td/'replacement.blob'; blob.write_text('let a = 999\n')
        oid=git(self.repo,'hash-object','-w',str(blob)).stdout.strip()
        git(self.repo,'update-index','--cacheinfo','100644',oid,'A.swift')
        (self.repo/'B.swift').write_text('let b = 2\n')
        git(self.repo,'commit','--only','B.swift','-m','allowed B only')
        r=self.verify(sid)
        self.assertFalse(r['ok']); self.assertIn('semantic Git index changed without declared stage transition: A.swift',r['violations'])
    def test_F04_dirty_baseline_not_absorbed_into_commit(self):
        (self.repo/'A.swift').write_text('let a = 20\n')
        sid=self.begin(allow=['A.swift'],allow_dirty=['A.swift'],transitions=['commit']); git(self.repo,'add','A.swift'); git(self.repo,'commit','-m','dirty baseline')
        r=self.verify(sid); self.assertFalse(r['ok']); self.assertTrue(any('pre-existing dirty path was incorporated into commit' in x for x in r['violations']))
    def test_F05_nested_dirty_content(self):
        nested=init_repo(self.repo/'Nested',{'File.swift':'let x = 1\n'}); (nested/'File.swift').write_text('let x = 2\n')
        sid=self.begin(); (nested/'File.swift').write_text('let x = 3\n'); r=self.verify(sid); self.assertFalse(r['ok']); self.assertIn('nested repository changed: Nested',r['violations'])
    def test_F05_nested_staged_content(self):
        nested=init_repo(self.repo/'Nested',{'File.swift':'let x = 1\n'}); (nested/'File.swift').write_text('let x = 2\n'); git(nested,'add','File.swift')
        sid=self.begin(); (nested/'File.swift').write_text('let x = 3\n'); git(nested,'add','File.swift'); r=self.verify(sid); self.assertFalse(r['ok']); self.assertIn('nested repository changed: Nested',r['violations'])
    def test_F05_nested_git_symlink_fails_closed(self):
        nested=self.repo/'NestedSymlink'; nested.mkdir(); outside=self.td/'outside-git'; outside.mkdir()
        (nested/'.git').symlink_to(outside,target_is_directory=True)
        with self.assertRaises(P.ObservationError): P.capture(self.repo)

    def test_F05_nested_repository_recurses_to_second_level(self):
        nested=init_repo(self.repo/'Nested',{'Outer.swift':'let outer = 1\n'})
        inner=init_repo(nested/'Inner',{'Inner.swift':'let inner = 1\n'})
        sid=self.begin()
        saved=C.load_session(self.repo,self.state,sid)['baseline']['nested_repositories']
        self.assertIn('Nested',saved); self.assertIn('Inner',saved['Nested'].get('nested_repositories',{}))
        (inner/'Inner.swift').write_text('let inner = 2\n')
        r=self.verify(sid); self.assertFalse(r['ok']); self.assertIn('nested repository changed: Nested',r['violations'])
    def test_F06_git_observation_failure(self):
        baseline=C.P.capture(self.repo); (self.repo/'.git'/'HEAD').rename(self.repo/'.git'/'HEAD.synthetic-hidden')
        r=C.P.compare(self.repo,baseline); self.assertFalse(r['ok']); self.assertEqual(r['status'],'NON_PASS')
    def test_F06_budget_exhaustion(self):
        (self.repo/'Dir').mkdir(); baseline=C.P.capture(self.repo); b=C.P.Budget(max_files_visited=0,max_files_inspected=10,max_total_bytes=1024*1024,total_deadline_seconds=5)
        r=C.P.compare(self.repo,baseline,budget=b); self.assertFalse(r['ok']); self.assertEqual(r['status'],'NON_PASS'); self.assertIn('budget',json.dumps(r).lower())
    def test_cli_session_id_resolves_only_writer(self):
        sid=self.begin(allow=['A.swift'])
        self.assertEqual(C.resolve_session_id(self.repo,self.state,None),sid)
    def test_F03_session_id_requires_canonical_uuid(self):
        for bad in ['deadbeef', 'A'*36, '00000000-0000-0000-0000-000000000000-extra']:
            with self.subTest(bad=bad):
                with self.assertRaises(C.P.ProtectionError): C.session_path(self.repo,self.state,bad)

class BuildPhaseTests(unittest.TestCase):
    def setUp(self): self.td=test_tmpdir(); self.repo=init_repo(self.td/'repo')
    def tearDown(self): shutil.rmtree(self.td,ignore_errors=True)
    def test_F07_no_build_phase_not_safe(self):
        p=self.repo/'App.xcodeproj/project.pbxproj'; p.parent.mkdir(); p.write_text('// !$*UTF8*$!\nPBXProject\nobjects = {\n};\n'); git(self.repo,'add','.'); git(self.repo,'commit','-m','project')
        r=P.scan_build_phases(self.repo); self.assertFalse(r['safe_to_assume_read_only']); self.assertTrue(r['review_required']); self.assertEqual(r['status'],'complete')
    def test_F07_malformed_project(self):
        p=self.repo/'Bad.xcodeproj/project.pbxproj'; p.parent.mkdir(); p.write_text('malformed'); git(self.repo,'add','.'); git(self.repo,'commit','-m','bad')
        r=P.scan_build_phases(self.repo); self.assertFalse(r['safe_to_assume_read_only']); self.assertTrue(r['review_required']); self.assertEqual(r['status'],'partial'); self.assertTrue(r['errors'])

    def test_F07_known_executable_surfaces_reported(self):
        td=test_tmpdir()
        try:
            repo=init_repo(td/'repo')
            pbx=repo/'App.xcodeproj/project.pbxproj'; pbx.parent.mkdir(); pbx.write_text('PBXProject\nobjects = {\nPBXShellScriptBuildPhase\n};\n')
            scheme=repo/'App.xcodeproj/xcshareddata/xcschemes/App.xcscheme'; scheme.parent.mkdir(parents=True); scheme.write_text('<Scheme><BuildAction><PreActions><ExecutionAction/></PreActions></BuildAction></Scheme>')
            (repo/'Package.swift').write_text('// swift-tools-version: 6.0\n.plugin(name: "Synthetic", capability: .buildTool())\n.macro(name: "SyntheticMacro")\n')
            r=P.scan_build_phases(repo)
            surfaces={x['surface'] for x in r['findings']}
            self.assertIn('PBXShellScriptBuildPhase',surfaces); self.assertIn('PreActions',surfaces); self.assertIn('ExecutionAction',surfaces); self.assertIn('SwiftPM plugin declaration',surfaces); self.assertIn('Swift macro declaration',surfaces)
            self.assertTrue(r['review_required']); self.assertFalse(r['safe_to_assume_read_only'])
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F07_symlink_project_input_is_partial_and_not_followed(self):
        repo=self.repo
        outside=self.td/'outside.pbxproj'; marker='SYNTHETIC_OUTSIDE_BUILD_SECRET'; outside.write_text(marker)
        proj=repo/'App.xcodeproj'; proj.mkdir(); (proj/'project.pbxproj').symlink_to(outside)
        r=P.scan_build_phases(repo)
        self.assertEqual(r['status'],'partial')
        self.assertTrue(r['review_required']); self.assertFalse(r['safe_to_assume_read_only'])
        self.assertTrue(any(x.get('path')=='App.xcodeproj/project.pbxproj' for x in r['errors']))
        self.assertNotIn(marker,json.dumps(r))

class AdapterTests(unittest.TestCase):
    def setUp(self): self.td=test_tmpdir(); self.repo=self.td/'repo'; self.repo.mkdir()
    def tearDown(self): shutil.rmtree(self.td,ignore_errors=True)
    def test_F08_quoted_assignment_nonretention(self):
        secret='synthetic-short-value-XYZ'; (self.repo/'README.md').write_text(f'xcodebuild API_KEY="{secret}" -scheme App\n')
        m=A.model(self.repo); blob=json.dumps(m); self.assertNotIn(secret,blob); self.assertNotIn('API_KEY=',blob); self.assertTrue(m['command_candidates'][0]['secret_hint_present'])
    def test_F08_leading_assignment_nonretention(self):
        secret='synthetic-leading-secret-XYZ'; (self.repo/'README.md').write_text(f'API_KEY="{secret}" xcodebuild -scheme App\n')
        m=A.model(self.repo); blob=json.dumps(m); self.assertNotIn(secret,blob); self.assertEqual(m['command_candidates'][0]['executable'],'xcodebuild'); self.assertTrue(m['command_candidates'][0]['secret_hint_present'])
    def test_F08_arbitrary_prefix_token_not_retained_as_executable(self):
        secret='SYNTHETIC_PREFIX_SECRET_98765'; (self.repo/'README.md').write_text(f'{secret} xcodebuild -scheme App build\n')
        m=A.model(self.repo); blob=json.dumps(m); self.assertNotIn(secret,blob); self.assertEqual(m['command_candidates'][0]['executable'],'unknown')
    def test_F08_header_and_url_credentials_not_retained(self):
        secret='SYNTHETIC_URL_SECRET_987654321'
        data=(f'curl -H "Authorization: Bearer {secret}" https://user:{secret}@example.invalid/path\n').encode()
        out=A.command_metadata(Path('/repo'),Path('/repo/README.md'),data)
        encoded=json.dumps(out)
        self.assertNotIn(secret,encoded); self.assertNotIn('Authorization',encoded); self.assertNotIn('user:',encoded)
        self.assertTrue(out); self.assertEqual(out[0]['authority'],'data_only'); self.assertTrue(out[0]['secret_hint_present'])
    def test_F09_readme_command_invalidates_context(self):
        p=self.repo/'README.md'; p.write_text('Run: xcodebuild -scheme A build\n'); a=A.model(self.repo); p.write_text('Run: xcodebuild -scheme B build\n'); b=A.model(self.repo); self.assertNotEqual(a['meta']['source_fingerprint'],b['meta']['source_fingerprint'])
    def test_F09_generator_version_invalidates_context(self):
        (self.repo/'README.md').write_text('hello\n'); a=A.model(self.repo,{'adapter_version':'synthetic-v1'}); b=A.model(self.repo,{'adapter_version':'synthetic-v2'}); self.assertNotEqual(a['meta']['source_fingerprint'],b['meta']['source_fingerprint'])
    def test_K02_budget_exhaustion_is_partial(self):
        for i in range(6): (self.repo/f'F{i}.swift').write_text('let x = 1\n')
        m=A.model(self.repo,{'max_files_visited':2,'max_files':100,'max_bytes':1024*1024,'max_file_bytes':1024,'max_depth':10,'deadline_seconds':5})
        self.assertTrue(m['meta']['partial']); self.assertFalse(m['freshness']['complete']); self.assertLessEqual(m['meta']['budget']['files_visited'],3)
    def test_K02_symlink_source_escape_is_partial_and_not_read(self):
        outside=self.td/'outside.swift'; secret='SYNTHETIC_SOURCE_BODY_SECRET'; outside.write_text(secret); (self.repo/'Link.swift').symlink_to(outside)
        m=A.model(self.repo); self.assertTrue(m['meta']['partial']); self.assertNotIn(secret,json.dumps(m)); self.assertTrue(any(x['kind']=='symlink_file_skipped' for x in m['meta']['limitations']))

    def test_K02_nested_repo_is_independent_boundary(self):
        init_repo(self.repo/'Nested',{'Secret.swift':'SYNTHETIC_NESTED_BODY\n'})
        m=A.model(self.repo); blob=json.dumps(m)
        self.assertTrue(m['meta']['partial']); self.assertTrue(any(x['kind']=='nested_repository_boundary_skipped' for x in m['meta']['limitations'])); self.assertNotIn('Nested/Secret.swift',blob)

class RiskAndDocsTests(unittest.TestCase):
    def test_F12_task_lifetime_pattern_semantics_documentation(self):
        t=(ROOT/'33_CODE_PATTERNS/CP-03_TASK_LIFETIME.md').read_text()
        before_await=t.split('let result = try await',1)[0]
        self.assertNotIn('guard let self',before_await); self.assertIn('let service = service',t); self.assertIn('Task.checkCancellation()',t); self.assertIn('generation == requestGeneration',t); self.assertIn('!Task.isCancelled',t); self.assertIn('conceptual',t.lower())
    def test_F13_unknown_language_risk(self):
        r=C.build_plan('変更してください',None,None,{'available':True,'partial':False}); self.assertEqual(r['risk'],'UNKNOWN'); self.assertFalse(r['delegation']['admitted'])
    def test_F13_russian_destructive_migration_not_downgraded(self):
        r=C.build_plan('миграция базы данных с удалением старой схемы',None,None,{'available':True,'partial':False}); self.assertEqual(r['risk'],'R4')
    def test_F13_explicit_risk(self):
        r=C.build_plan('обычная задача','R3',['persistence'],{'available':True,'partial':False}); self.assertEqual(r['risk'],'R3'); self.assertEqual(r['risk_basis'],'explicit')
    def test_F13_partial_repository_evidence_denies_delegation(self):
        r=C.build_plan('security migration','R4',['security','persistence'],{'available':True,'partial':True}); self.assertFalse(r['delegation']['admitted']); self.assertIn('incomplete',r['delegation']['reason'])
    def test_K04_swift_risk_scan_no_source_body(self):
        td=test_tmpdir()
        try:
            repo=init_repo(td/'repo',{'A.swift':'func f() {}\n'}); (repo/'A.swift').write_text('func f() { try! dangerousSyntheticCall() }\n')
            p=run([sys.executable,RISK_SCAN,repo]); self.assertEqual(p.returncode,0,p.stderr); data=json.loads(p.stdout); self.assertTrue(any((x.get('rule') or x.get('kind'))=='force_try' for x in data['leads'])); self.assertNotIn('dangerousSyntheticCall',p.stdout); self.assertFalse(data['source_bodies_emitted'])
        finally: shutil.rmtree(td,ignore_errors=True)

class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.td=test_tmpdir(); self.home=self.td/'home'; self.skills=self.td/'skills'; self.home.mkdir(); self.original=b'# user rules\n\ncustom = true\n'; (self.home/'AGENTS.md').write_bytes(self.original)
        self._git_root_patch=mock.patch.object(I,'_git_root_for_destination',side_effect=_external_test_git_root)
        self._git_root_patch.start(); self.addCleanup(self._git_root_patch.stop)
    def tearDown(self): shutil.rmtree(self.td,ignore_errors=True)
    def test_F14_namespace_collision(self):
        generic=self.skills/'ios-security-privacy'; generic.mkdir(parents=True); (generic/'USER.txt').write_text('keep')
        a=install_args(self.home,self.skills,'full'); pre=I.build_preflight(a,False); self.assertFalse(any('ios-security-privacy' in x for x in pre['collisions'])); self.assertTrue(all(n.startswith('ioslib-') for n in pre['skills_to_install']))
        a.preflight_id=pre['preflight_id']; I.apply_fresh(pre,a); self.assertEqual((generic/'USER.txt').read_text(),'keep')
    def test_F14_dry_run_no_mutation(self):
        if not external_fixture_available():
            self.skipTest('NOT_RUN: no permitted fixture root outside every detected Git repository')
        before={p.relative_to(self.td).as_posix():p.read_bytes() for p in self.td.rglob('*') if p.is_file()}
        p=run([sys.executable,ROOT/'install_global.py','--codex-home',self.home,'--skills-root',self.skills,'--mode','full','--use-source-in-place','--dry-run'])
        self.assertEqual(p.returncode,0,p.stderr); data=json.loads(p.stdout); self.assertFalse(data['would_mutate']); after={p.relative_to(self.td).as_posix():p.read_bytes() for p in self.td.rglob('*') if p.is_file()}; self.assertEqual(before,after)
    def test_F14_portable_area_profile_is_explicit_and_local(self):
        if not external_fixture_available():
            self.skipTest('NOT_RUN: no permitted fixture root outside every detected Git repository')
        area=self.td/'portable-area'; area.mkdir()
        p=run([sys.executable,ROOT/'install_global.py','--portable-area',area,'--mode','full','--use-source-in-place','--dry-run'])
        self.assertEqual(p.returncode,0,p.stderr)
        data=json.loads(p.stdout)
        self.assertEqual(data['deployment_profile'],'portable_area')
        self.assertEqual(Path(data['codex_home']),area)
        self.assertEqual(Path(data['skills_root']),area/'skills')
        self.assertEqual(Path(data['agents_file']),area/'AGENTS.md')
        self.assertTrue(all(str(Path(x)).startswith(str(area)) for x in (data['codex_home'],data['skills_root'],data['shim_root'],data['state_root'])))
        self.assertTrue(str(area / I.REGISTRY_NAME).startswith(str(area)))
        self.assertFalse((area/'ios-engineering-global.json').exists())
        install=run([sys.executable,ROOT/'install_global.py','--portable-area',area,'--mode','reference','--use-source-in-place'])
        self.assertEqual(install.returncode,0,install.stdout+install.stderr)
        installed=json.loads(install.stdout)
        self.assertEqual(installed['deployment_profile'],'portable_area')
        self.assertEqual(json.loads((area/I.REGISTRY_NAME).read_text())['deployment_profile'],'portable_area')
        validated=run([sys.executable,ROOT/'validate_global_install.py','--codex-home',area])
        self.assertEqual(validated.returncode,0,validated.stdout+validated.stderr)
        synced=run([sys.executable,ROOT/'sync_global.py','--codex-home',area])
        self.assertEqual(synced.returncode,0,synced.stdout+synced.stderr)
        self.assertEqual(json.loads((area/I.REGISTRY_NAME).read_text())['deployment_profile'],'portable_area')
    def test_F14_portable_area_rejects_ambiguous_codex_home(self):
        p=run([sys.executable,ROOT/'install_global.py','--portable-area',self.home,'--codex-home',self.td/'other','--dry-run'])
        self.assertEqual(p.returncode,3)
        self.assertIn('cannot be combined',p.stdout)
    def test_F14_portable_area_rejects_path_escape_overrides(self):
        area=self.td/'portable-area'; area.mkdir()
        outside=self.td/'outside'
        for option in ('--skills-root','--agents-file','--runtime-root'):
            with self.subTest(option=option):
                p=run([sys.executable,ROOT/'install_global.py','--portable-area',area,option,outside,'--dry-run'])
                self.assertEqual(p.returncode,3,p.stdout+p.stderr)
                self.assertIn('must remain inside',p.stdout)

    def test_F14_split_host_entry_roundtrip_preserves_empty_file_and_mode(self):
        runtime_home=self.td/'runtime-home'; runtime_skills=self.td/'runtime-skills'
        fresh_install(runtime_home,runtime_skills,'reference')
        host_home=self.td/'host-home'; host_home.mkdir(); agents=host_home/'AGENTS.md'; agents.write_bytes(b''); os.chmod(agents,0o640)
        base=[sys.executable,ROOT/'host_entry.py','connect','--runtime-home',runtime_home,'--host-codex-home',host_home]
        dry=run([*base,'--dry-run']); self.assertEqual(dry.returncode,0,dry.stdout+dry.stderr); pre=json.loads(dry.stdout)
        connected=run([*base,'--preflight-id',pre['preflight_id']]); self.assertEqual(connected.returncode,0,connected.stdout+connected.stderr)
        self.assertEqual(sorted(p.name for p in host_home.iterdir()),['AGENTS.md'])
        text=agents.read_text(); self.assertIn(str(runtime_home/'ios-engineering-shim/bin/ios_ai.py'),text); self.assertNotIn('${CODEX_HOME',text)
        self.assertEqual(stat.S_IMODE(os.lstat(agents).st_mode),0o640)
        status=run([sys.executable,ROOT/'host_entry.py','status','--runtime-home',runtime_home]); self.assertEqual(status.returncode,0,status.stdout+status.stderr)
        disconnected=run([sys.executable,ROOT/'host_entry.py','disconnect','--runtime-home',runtime_home,'--yes']); self.assertEqual(disconnected.returncode,0,disconnected.stdout+disconnected.stderr)
        self.assertEqual(agents.read_bytes(),b''); self.assertEqual(stat.S_IMODE(os.lstat(agents).st_mode),0o640); self.assertFalse((runtime_home/H.RECEIPT_NAME).exists())

    def test_F14_split_host_entry_uses_active_override_and_restores_exact_bytes(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        host_home=self.td/'host-home'; host_home.mkdir(); base=host_home/'AGENTS.md'; base.write_bytes(b'# base untouched\n')
        override=host_home/'AGENTS.override.md'; original=b'# active override\n\ncustom = true\n'; override.write_bytes(original); os.chmod(override,0o644)
        command=[sys.executable,ROOT/'host_entry.py','connect','--runtime-home',runtime_home,'--host-codex-home',host_home]
        pre=json.loads(run([*command,'--dry-run'],check=True).stdout); connected=run([*command,'--preflight-id',pre['preflight_id']]); self.assertEqual(connected.returncode,0,connected.stdout+connected.stderr)
        receipt=json.loads((runtime_home/H.RECEIPT_NAME).read_text()); self.assertEqual(Path(receipt['agents_file']),override); self.assertEqual(base.read_bytes(),b'# base untouched\n')
        disconnected=run([sys.executable,ROOT/'host_entry.py','disconnect','--runtime-home',runtime_home,'--yes']); self.assertEqual(disconnected.returncode,0,disconnected.stdout+disconnected.stderr)
        self.assertEqual(override.read_bytes(),original); self.assertEqual(stat.S_IMODE(os.lstat(override).st_mode),0o644); self.assertEqual(base.read_bytes(),b'# base untouched\n')

    def test_F14_split_host_entry_tamper_blocks_status_and_disconnect(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        host_home=self.td/'host-home'; host_home.mkdir(); agents=host_home/'AGENTS.md'; agents.write_text('# user\n')
        command=[sys.executable,ROOT/'host_entry.py','connect','--runtime-home',runtime_home,'--host-codex-home',host_home]
        pre=json.loads(run([*command,'--dry-run'],check=True).stdout); self.assertEqual(run([*command,'--preflight-id',pre['preflight_id']]).returncode,0)
        agents.write_text(agents.read_text().replace('Global iOS Engineering Library','Locally modified library'))
        status=run([sys.executable,ROOT/'host_entry.py','status','--runtime-home',runtime_home]); self.assertEqual(status.returncode,1); self.assertIn('modified',status.stdout)
        disconnected=run([sys.executable,ROOT/'host_entry.py','disconnect','--runtime-home',runtime_home,'--yes']); self.assertEqual(disconnected.returncode,2); self.assertTrue((runtime_home/H.RECEIPT_NAME).exists()); self.assertIn('Locally modified',agents.read_text())

    def test_F14_split_host_entry_receipt_failure_restores_host_agents(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        host_home=self.td/'host-home'; host_home.mkdir(); agents=host_home/'AGENTS.md'; original=b'# user\n'; agents.write_bytes(original)
        pre,_,_,_=H._connect_preflight(runtime_home,host_home); args=types.SimpleNamespace(runtime_home=str(runtime_home),host_codex_home=str(host_home),dry_run=False,preflight_id=pre['preflight_id'])
        real=H.I.write_new_atomic
        def fail_receipt(path,data,mode=0o600):
            if Path(path)==runtime_home/H.RECEIPT_NAME: raise OSError('synthetic receipt failure')
            return real(path,data,mode)
        H.I.write_new_atomic=fail_receipt
        try:
            with self.assertRaises(OSError): H.connect(args)
        finally: H.I.write_new_atomic=real
        self.assertEqual(agents.read_bytes(),original); self.assertFalse((runtime_home/H.RECEIPT_NAME).exists())

    def test_F14_split_host_entry_new_file_durability_failure_removes_published_agents(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        host_home=self.td/'host-home'; host_home.mkdir(); agents=host_home/'AGENTS.md'
        pre,_,_,_=H._connect_preflight(runtime_home,host_home); args=types.SimpleNamespace(runtime_home=str(runtime_home),host_codex_home=str(host_home),dry_run=False,preflight_id=pre['preflight_id'])
        real=H.I.write_new_atomic; fired={'value':False}
        def fail_after_publish(path,data,mode=0o600,publication_observer=None):
            result=real(path,data,mode,publication_observer=publication_observer)
            if Path(path)==agents and not fired['value']:
                fired['value']=True
                raise OSError('synthetic post-publication durability failure')
            return result
        H.I.write_new_atomic=fail_after_publish
        try:
            with self.assertRaisesRegex(OSError,'synthetic post-publication durability failure'):
                H.connect(args)
        finally: H.I.write_new_atomic=real
        self.assertTrue(fired['value']); self.assertFalse(agents.exists()); self.assertFalse((runtime_home/H.RECEIPT_NAME).exists())
        self.assertEqual(list(host_home.iterdir()),[])

    def test_F14_split_host_entry_post_removal_fsync_failure_restores_connected_state(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        host_home=self.td/'host-home'; host_home.mkdir(); agents=host_home/'AGENTS.md'
        command=[sys.executable,ROOT/'host_entry.py','connect','--runtime-home',runtime_home,'--host-codex-home',host_home]
        pre=json.loads(run([*command,'--dry-run'],check=True).stdout); self.assertEqual(run([*command,'--preflight-id',pre['preflight_id']]).returncode,0)
        connected=agents.read_bytes(); receipt=runtime_home/H.RECEIPT_NAME; real=H.I.unlink_nofollow_file; fired={'value':False}
        def fail_after_removal(path,*,missing_ok=False,removal_observer=None):
            result=real(path,missing_ok=missing_ok,removal_observer=removal_observer)
            if '.ioslib-host-entry-remove.' in Path(path).name and not fired['value']:
                fired['value']=True
                raise OSError('synthetic post-removal fsync failure')
            return result
        args=types.SimpleNamespace(runtime_home=str(runtime_home),dry_run=False,yes=True)
        with mock.patch.object(H.I,'unlink_nofollow_file',side_effect=fail_after_removal):
            with self.assertRaisesRegex(OSError,'synthetic post-removal fsync failure'):
                H.disconnect(args)
        self.assertTrue(fired['value']); self.assertEqual(agents.read_bytes(),connected); self.assertTrue(receipt.exists())
        self.assertEqual(sorted(p.name for p in host_home.iterdir()),['AGENTS.md'])

    def test_F14_split_host_entry_post_exchange_cleanup_failure_restores_original(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        host_home=self.td/'host-home'; host_home.mkdir(); agents=host_home/'AGENTS.md'; original=b'# original user rules\n'; agents.write_bytes(original); os.chmod(agents,0o640)
        pre,_,_,_=H._connect_preflight(runtime_home,host_home); receipt=runtime_home/H.RECEIPT_NAME; real=H.I.unlink_nofollow_file; fired={'value':False}
        def fail_after_cleanup(path,*,missing_ok=False,removal_observer=None):
            result=real(path,missing_ok=missing_ok,removal_observer=removal_observer)
            if '.ioslib-host-entry-exchange.' in Path(path).name and not fired['value']:
                fired['value']=True
                raise OSError('synthetic post-exchange cleanup fsync failure')
            return result
        args=types.SimpleNamespace(runtime_home=str(runtime_home),host_codex_home=str(host_home),dry_run=False,preflight_id=pre['preflight_id'])
        with mock.patch.object(H.I,'unlink_nofollow_file',side_effect=fail_after_cleanup):
            with self.assertRaisesRegex(OSError,'synthetic post-exchange cleanup fsync failure'):
                H.connect(args)
        self.assertTrue(fired['value']); self.assertEqual(agents.read_bytes(),original); self.assertEqual(stat.S_IMODE(os.lstat(agents).st_mode),0o640)
        self.assertFalse(receipt.exists()); self.assertEqual(sorted(p.name for p in host_home.iterdir()),['AGENTS.md'])

    def test_F14_split_host_entry_recovery_snapshot_failure_is_explicit_and_preserved(self):
        for fail_after_publication in (False,True):
            with self.subTest(fail_after_publication=fail_after_publication):
                runtime_home=self.td/f'runtime-{fail_after_publication}'; fresh_install(runtime_home,self.td/f'skills-{fail_after_publication}','reference')
                host_home=self.td/f'host-{fail_after_publication}'; host_home.mkdir(); agents=host_home/'AGENTS.md'; original=b'# original user rules\n'; agents.write_bytes(original); os.chmod(agents,0o640)
                pre,_,_,_=H._connect_preflight(runtime_home,host_home); real_unlink=H.I.unlink_nofollow_file; real_write=H.I.write_new_atomic
                def fail_cleanup(path,*,missing_ok=False,removal_observer=None):
                    result=real_unlink(path,missing_ok=missing_ok,removal_observer=removal_observer)
                    if '.ioslib-host-entry-exchange.' in Path(path).name: raise OSError('synthetic exchange cleanup failure')
                    return result
                def fail_recovery(path,data,mode=0o600,publication_observer=None):
                    if '.ioslib-host-entry-restore.' not in Path(path).name:
                        return real_write(path,data,mode,publication_observer=publication_observer)
                    if fail_after_publication:
                        real_write(path,data,mode,publication_observer=publication_observer)
                    raise OSError('synthetic recovery snapshot failure')
                args=types.SimpleNamespace(runtime_home=str(runtime_home),host_codex_home=str(host_home),dry_run=False,preflight_id=pre['preflight_id'])
                with mock.patch.object(H.I,'unlink_nofollow_file',side_effect=fail_cleanup), mock.patch.object(H.I,'write_new_atomic',side_effect=fail_recovery):
                    with self.assertRaisesRegex(H.HostEntryRollbackIncomplete,'snapshot recreation could not start'):
                        H.connect(args)
                recovery=[p for p in host_home.iterdir() if '.ioslib-host-entry-restore.' in p.name]
                self.assertIn(I.BEGIN,agents.read_text()); self.assertFalse((runtime_home/H.RECEIPT_NAME).exists())
                self.assertEqual(len(recovery),1 if fail_after_publication else 0)
                if recovery: self.assertEqual(recovery[0].read_bytes(),original)

    def test_F14_split_host_entry_refuses_modified_runtime(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        launcher=runtime_home/'ios-engineering-shim/bin/ios_ai.py'; launcher.write_text(launcher.read_text()+'\n# tamper\n')
        host_home=self.td/'host-home'; host_home.mkdir(); (host_home/'AGENTS.md').write_bytes(b'')
        result=run([sys.executable,ROOT/'host_entry.py','connect','--runtime-home',runtime_home,'--host-codex-home',host_home,'--dry-run'])
        self.assertEqual(result.returncode,3); self.assertIn('shim mismatch',result.stdout); self.assertEqual((host_home/'AGENTS.md').read_bytes(),b''); self.assertFalse((runtime_home/H.RECEIPT_NAME).exists())

    def test_F14_split_host_entry_disconnect_recovers_from_damaged_runtime(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        host_home=self.td/'host-home'; host_home.mkdir(); agents=host_home/'AGENTS.md'; original=b'# user rules\n'; agents.write_bytes(original)
        command=[sys.executable,ROOT/'host_entry.py','connect','--runtime-home',runtime_home,'--host-codex-home',host_home]
        pre=json.loads(run([*command,'--dry-run'],check=True).stdout); self.assertEqual(run([*command,'--preflight-id',pre['preflight_id']]).returncode,0)
        launcher=runtime_home/'ios-engineering-shim/bin/ios_ai.py'; launcher.write_text(launcher.read_text()+'\n# tamper\n')
        status=run([sys.executable,ROOT/'host_entry.py','status','--runtime-home',runtime_home]); self.assertEqual(status.returncode,1); self.assertIn('runtime validation failed',status.stdout)
        disconnected=run([sys.executable,ROOT/'host_entry.py','disconnect','--runtime-home',runtime_home,'--yes']); self.assertEqual(disconnected.returncode,0,disconnected.stdout+disconnected.stderr)
        self.assertIn('safe host-only disconnect remains available',disconnected.stdout); self.assertEqual(agents.read_bytes(),original); self.assertFalse((runtime_home/H.RECEIPT_NAME).exists())

    def test_F14_runtime_uninstall_refuses_active_split_host_entry(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        host_home=self.td/'host-home'; host_home.mkdir(); agents=host_home/'AGENTS.md'; agents.write_bytes(b'# user rules\n')
        command=[sys.executable,ROOT/'host_entry.py','connect','--runtime-home',runtime_home,'--host-codex-home',host_home]
        pre=json.loads(run([*command,'--dry-run'],check=True).stdout); self.assertEqual(run([*command,'--preflight-id',pre['preflight_id']]).returncode,0)
        uninstall=run([sys.executable,ROOT/'uninstall_global.py','--codex-home',runtime_home,'--yes']); self.assertEqual(uninstall.returncode,2,uninstall.stdout+uninstall.stderr)
        self.assertIn('disconnect the host entry',uninstall.stdout); self.assertTrue((runtime_home/I.REGISTRY_NAME).exists()); self.assertTrue((runtime_home/H.RECEIPT_NAME).exists()); self.assertIn(I.BEGIN,agents.read_text())
        self.assertEqual(run([sys.executable,ROOT/'host_entry.py','disconnect','--runtime-home',runtime_home,'--yes']).returncode,0)

    def test_F14_split_host_entry_template_refresh_does_not_block_disconnect(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        host_home=self.td/'host-home'; host_home.mkdir(); agents=host_home/'AGENTS.md'; original=b'# user rules\n'; agents.write_bytes(original)
        pre,_,_,_=H._connect_preflight(runtime_home,host_home); H.connect(types.SimpleNamespace(runtime_home=str(runtime_home),host_codex_home=str(host_home),dry_run=False,preflight_id=pre['preflight_id']))
        with mock.patch.object(H,'_render_block',return_value='updated template'):
            _,_,errors,warnings=H._status(runtime_home)
        self.assertEqual(errors,[]); self.assertTrue(any('reconnect host entry' in item for item in warnings))
        self.assertEqual(H.disconnect(types.SimpleNamespace(runtime_home=str(runtime_home),dry_run=False,yes=True)),0)
        self.assertEqual(agents.read_bytes(),original)

    def test_F14_split_host_entry_preserves_edit_racing_publication(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        host_home=self.td/'host-home'; host_home.mkdir(); agents=host_home/'AGENTS.md'; agents.write_bytes(b'# original\n')
        pre,_,_,_=H._connect_preflight(runtime_home,host_home)
        concurrent=b'# concurrent user edit\n'; real=H._rename_sibling; fired={'value':False}
        def race_once(src,dst,flags):
            if not fired['value'] and flags==H._RENAME_SWAP and Path(dst)==agents:
                fired['value']=True; agents.write_bytes(concurrent)
            return real(src,dst,flags)
        args=types.SimpleNamespace(runtime_home=str(runtime_home),host_codex_home=str(host_home),dry_run=False,preflight_id=pre['preflight_id'])
        with mock.patch.object(H,'_rename_sibling',side_effect=race_once):
            with self.assertRaisesRegex(H.HostEntryError,'changed concurrently'):
                H.connect(args)
        self.assertTrue(fired['value']); self.assertEqual(agents.read_bytes(),concurrent); self.assertFalse((runtime_home/H.RECEIPT_NAME).exists())
        self.assertEqual(sorted(p.name for p in host_home.iterdir()),['AGENTS.md'])

    def test_F14_split_host_entry_post_exchange_fsync_failure_restores_original(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        host_home=self.td/'host-home'; host_home.mkdir(); agents=host_home/'AGENTS.md'; original=b'# original\n'; agents.write_bytes(original); os.chmod(agents,0o640)
        pre,_,_,_=H._connect_preflight(runtime_home,host_home); real=H._fsync_parent; calls={'value':0}
        def fail_once(path):
            calls['value']+=1
            if calls['value']==1: raise OSError('synthetic post-exchange fsync failure')
            return real(path)
        args=types.SimpleNamespace(runtime_home=str(runtime_home),host_codex_home=str(host_home),dry_run=False,preflight_id=pre['preflight_id'])
        with mock.patch.object(H,'_fsync_parent',side_effect=fail_once):
            with self.assertRaisesRegex(OSError,'synthetic post-exchange fsync failure'):
                H.connect(args)
        self.assertEqual(agents.read_bytes(),original); self.assertEqual(stat.S_IMODE(os.lstat(agents).st_mode),0o640)
        self.assertFalse((runtime_home/H.RECEIPT_NAME).exists()); self.assertEqual(sorted(p.name for p in host_home.iterdir()),['AGENTS.md'])

    def test_F14_split_host_entry_preserves_second_edit_during_exchange_rollback(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        host_home=self.td/'host-home'; host_home.mkdir(); agents=host_home/'AGENTS.md'; agents.write_bytes(b'# original\n')
        pre,_,_,_=H._connect_preflight(runtime_home,host_home)
        first=b'# first concurrent edit\n'; second=b'# second concurrent edit\n'; real=H._rename_sibling; calls={'value':0}
        def race_twice(src,dst,flags):
            if flags==H._RENAME_SWAP and Path(dst)==agents:
                calls['value']+=1; agents.write_bytes(first if calls['value']==1 else second)
            return real(src,dst,flags)
        args=types.SimpleNamespace(runtime_home=str(runtime_home),host_codex_home=str(host_home),dry_run=False,preflight_id=pre['preflight_id'])
        with mock.patch.object(H,'_rename_sibling',side_effect=race_twice):
            with self.assertRaises(H.HostEntryRollbackIncomplete):
                H.connect(args)
        recovery=[p for p in host_home.iterdir() if p.name.startswith('.AGENTS.md.ioslib-host-entry-exchange.')]
        self.assertEqual(calls['value'],2); self.assertEqual(agents.read_bytes(),first); self.assertEqual(len(recovery),1); self.assertEqual(recovery[0].read_bytes(),second)
        self.assertFalse((runtime_home/H.RECEIPT_NAME).exists())

    def test_F14_split_host_entry_status_detects_new_active_override(self):
        runtime_home=self.td/'runtime-home'; fresh_install(runtime_home,self.td/'runtime-skills','reference')
        host_home=self.td/'host-home'; host_home.mkdir(); agents=host_home/'AGENTS.md'; original=b'# base rules\n'; agents.write_bytes(original)
        command=[sys.executable,ROOT/'host_entry.py','connect','--runtime-home',runtime_home,'--host-codex-home',host_home]
        pre=json.loads(run([*command,'--dry-run'],check=True).stdout); self.assertEqual(run([*command,'--preflight-id',pre['preflight_id']]).returncode,0)
        override=host_home/'AGENTS.override.md'; override.write_bytes(b'# newer active override\n')
        status=run([sys.executable,ROOT/'host_entry.py','status','--runtime-home',runtime_home]); self.assertEqual(status.returncode,1); self.assertIn('no longer the active',status.stdout)
        disconnected=run([sys.executable,ROOT/'host_entry.py','disconnect','--runtime-home',runtime_home,'--yes']); self.assertEqual(disconnected.returncode,0,disconnected.stdout+disconnected.stderr)
        self.assertEqual(agents.read_bytes(),original); self.assertEqual(override.read_bytes(),b'# newer active override\n')
    def test_F14_reference_mode_installs_no_bundled_skills(self):
        home=self.td/'reference-home'; skills=self.td/'reference-skills'; home.mkdir(); (home/'AGENTS.md').write_text('# user rules\n')
        generic=skills/'ios-security-privacy'; generic.mkdir(parents=True); (generic/'USER.txt').write_text('keep')
        reg=fresh_install(home,skills,'reference')
        self.assertEqual(reg['mode'],'reference'); self.assertEqual(reg['ownership']['skills'],{})
        self.assertEqual((generic/'USER.txt').read_text(),'keep')
        self.assertEqual([p.name for p in skills.iterdir() if p.name.startswith('ioslib-')],[])
    def test_F14_reference_mode_publishes_knowledge_descriptor(self):
        home=self.td/'reference-descriptor-home'; skills=self.td/'reference-descriptor-skills'; home.mkdir(); (home/'AGENTS.md').write_text('# user rules\n')
        reg=fresh_install(home,skills,'reference')
        descriptor=home/'ios-engineering-shim'/'INSTALLATION.md'
        text=descriptor.read_text()
        self.assertIn(f'Knowledge root: `{ROOT}`',text)
        self.assertIn(f'External state root: `{Path(reg["state_root"])}`',text)
        self.assertIn(str(home/'ios-engineering-shim'/'bin'/'ios_ai.py'),text)
        selected=json.loads((home/'ios-engineering-shim'/'INSTALLATION.json').read_text())
        self.assertEqual(selected['release_id'],I.VERSION)
        self.assertEqual(selected['mode'],'reference')
        self.assertEqual(Path(selected['knowledge_root']),ROOT)
        self.assertEqual(Path(selected['state_root']),Path(reg['state_root']))
        vr=run([sys.executable,ROOT/'validate_global_install.py','--codex-home',home])
        self.assertEqual(vr.returncode,0,vr.stdout+vr.stderr)
    def test_F10_fresh_install_raced_empty_target_is_not_replaced(self):
        a=install_args(self.home,self.skills,'reference'); pre=I.build_preflight(a,False); a.preflight_id=pre['preflight_id']
        target=Path(pre['shim_root']); original_prepare=I.prepare_local_tree; fired={'v':False}
        def raced_prepare(source,dst,token):
            out=original_prepare(source,dst,token)
            if Path(dst)==target and not fired['v']:
                fired['v']=True; target.mkdir(parents=True)
            return out
        I.prepare_local_tree=raced_prepare
        try:
            with self.assertRaises(I.InstallError): I.apply_fresh(pre,a)
        finally:
            I.prepare_local_tree=original_prepare
        self.assertTrue(fired['v']); self.assertTrue(target.is_dir()); self.assertEqual(list(target.iterdir()),[])
        self.assertFalse((self.home/I.REGISTRY_NAME).exists()); self.assertEqual((self.home/'AGENTS.md').read_bytes(),self.original)

    def test_F10_late_collision_no_partial_install(self):
        first=I.skill_names()[0]; dst=self.skills/first; dst.mkdir(parents=True); (dst/'user.txt').write_text('keep')
        a=install_args(self.home,self.skills,'full'); pre=I.build_preflight(a,False); self.assertTrue(pre['collisions'])
        a.preflight_id=pre['preflight_id']
        with self.assertRaises(I.InstallError): I.apply_fresh(pre,a)
        self.assertFalse((self.home/'ios-engineering-shim').exists()); self.assertFalse((self.home/I.REGISTRY_NAME).exists()); self.assertEqual((dst/'user.txt').read_text(),'keep'); self.assertEqual((self.home/'AGENTS.md').read_bytes(),self.original)
    def test_F10_state_marker_collision_is_preflight(self):
        state=self.home/'ios-engineering-state'; state.mkdir(); (state/'.ioslib-state-owned.json').write_text('foreign')
        a=install_args(self.home,self.skills,'reference'); pre=I.build_preflight(a,False); self.assertTrue(any('state ownership marker collision' in x for x in pre['collisions'])); self.assertFalse((self.home/'ios-engineering-shim').exists())
    def test_F10_local_skill_edit_preserved(self):
        reg=fresh_install(self.home,self.skills,'full'); name=next(iter(reg['ownership']['skills'])); target=self.skills/name/'SKILL.md'; target.write_text(target.read_text()+'\nUSER EDIT\n')
        old,pre=S.preflight(self.home); self.assertTrue(any('modified/missing managed file' in x for x in pre['collisions'])); self.assertIn('USER EDIT',target.read_text())
    def test_F10_mid_install_failure_rollback(self):
        a=install_args(self.home,self.skills,'reference'); pre=I.build_preflight(a,False); a.preflight_id=pre['preflight_id']; original_write=I.write_atomic; fired={'v':False}; agents=Path(pre['agents_file'])
        def flaky(path,data,mode=0o600):
            if Path(path)==agents and not fired['v']: fired['v']=True; raise OSError('synthetic install failure')
            return original_write(path,data,mode)
        I.write_atomic=flaky
        try:
            with self.assertRaises(OSError): I.apply_fresh(pre,a)
        finally: I.write_atomic=original_write
        self.assertTrue(fired['v']); self.assertEqual((self.home/'AGENTS.md').read_bytes(),self.original); self.assertFalse((self.home/'ios-engineering-shim').exists()); self.assertFalse((self.home/I.REGISTRY_NAME).exists())

    def test_F10_fresh_post_rename_failure_rolls_back_published_target(self):
        a=install_args(self.home,self.skills,'reference'); pre=I.build_preflight(a,False); a.preflight_id=pre['preflight_id']
        target=Path(pre['shim_root']); original_replace=I._replace_path; fired={'v':False}
        def fail_after_publish(source,destination):
            result=original_replace(source,destination)
            if Path(destination)==target and not fired['v']:
                fired['v']=True
                raise OSError('synthetic post-rename fsync failure')
            return result
        I._replace_path=fail_after_publish
        try:
            with self.assertRaises(OSError): I.apply_fresh(pre,a)
        finally:
            I._replace_path=original_replace
        self.assertTrue(fired['v']); self.assertFalse(target.exists()); self.assertFalse((self.home/I.REGISTRY_NAME).exists()); self.assertEqual((self.home/'AGENTS.md').read_bytes(),self.original)

    def test_F10_fresh_post_metadata_publish_failure_rolls_back_file(self):
        a=install_args(self.home,self.skills,'reference'); pre=I.build_preflight(a,False); a.preflight_id=pre['preflight_id']; agents=Path(pre['agents_file']); original_write=I.write_atomic; fired={'v':False}
        def fail_after_publish(path,data,mode=0o600):
            result=original_write(path,data,mode)
            if Path(path)==agents and not fired['v']:
                fired['v']=True
                raise OSError('synthetic post-metadata fsync failure')
            return result
        I.write_atomic=fail_after_publish
        try:
            with self.assertRaises(OSError): I.apply_fresh(pre,a)
        finally:
            I.write_atomic=original_write
        self.assertTrue(fired['v']); self.assertEqual((self.home/'AGENTS.md').read_bytes(),self.original); self.assertFalse((self.home/'ios-engineering-shim').exists()); self.assertFalse((self.home/I.REGISTRY_NAME).exists())
    def test_F10_rollback_preserves_concurrent_tree_edit(self):
        a=install_args(self.home,self.skills,'reference'); pre=I.build_preflight(a,False); a.preflight_id=pre['preflight_id']
        original_new=I.write_new_atomic; registry=self.home/I.REGISTRY_NAME; shim=self.home/'ios-engineering-shim/bin/ios_ai.py'; fired={'v':False}
        def fail_registry(path,data,mode=0o600):
            if Path(path)==registry and not fired['v']:
                fired['v']=True; shim.write_text(shim.read_text()+'\n# USER CONCURRENT EDIT\n'); raise OSError('synthetic late install failure')
            return original_new(path,data,mode)
        I.write_new_atomic=fail_registry
        try:
            with self.assertRaises(I.RollbackIncomplete): I.apply_fresh(pre,a)
        finally: I.write_new_atomic=original_new
        self.assertTrue(fired['v']); self.assertTrue(shim.exists()); self.assertIn('USER CONCURRENT EDIT',shim.read_text()); self.assertEqual((self.home/'AGENTS.md').read_bytes(),self.original)

    def test_F10_raced_registry_is_not_overwritten(self):
        a=install_args(self.home,self.skills,'reference'); pre=I.build_preflight(a,False); a.preflight_id=pre['preflight_id']
        original_new=I.write_new_atomic; registry=self.home/I.REGISTRY_NAME; foreign=b'{"foreign":true}\n'; fired={'v':False}
        def race_registry(path,data,mode=0o600):
            if Path(path)==registry and not fired['v']:
                fired['v']=True; registry.write_bytes(foreign)
            return original_new(path,data,mode)
        I.write_new_atomic=race_registry
        try:
            with self.assertRaises(I.InstallError): I.apply_fresh(pre,a)
        finally: I.write_new_atomic=original_new
        self.assertTrue(fired['v']); self.assertEqual(registry.read_bytes(),foreign); self.assertEqual((self.home/'AGENTS.md').read_bytes(),self.original); self.assertFalse((self.home/'ios-engineering-shim').exists())
    def test_F10_sync_raced_managed_edit_is_preserved(self):
        fresh_install(self.home,self.skills,'reference')
        raced_file=self.home/'ios-engineering-shim'/'RACED_USER.txt'
        original_prepare=S.I.prepare_local_tree; fired={'v':False}
        def raced_prepare(source,target,token):
            out=original_prepare(source,target,token)
            if not fired['v']:
                fired['v']=True
                raced_file.write_text('user concurrent edit\n')
            return out
        S.I.prepare_local_tree=raced_prepare
        old_argv=sys.argv[:]
        try:
            sys.argv=['sync_global.py','--codex-home',str(self.home)]
            with contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaises(S.SyncError): S.main()
        finally:
            sys.argv=old_argv; S.I.prepare_local_tree=original_prepare
        self.assertTrue(fired['v']); self.assertEqual(raced_file.read_text(),'user concurrent edit\n')
        self.assertTrue((self.home/I.REGISTRY_NAME).exists())

    def test_F10_sync_raced_unmanaged_target_is_preserved(self):
        fresh_install(self.home,self.skills,'reference')
        old, pre = S.preflight(self.home, 'full')
        new_name = sorted(set(I.skill_names()) - set(old['ownership']['skills']))[0]
        raced_target = Path(pre['skills_root']) / new_name
        original_prepare = S.I.prepare_local_tree
        fired = {'v': False}

        def raced_prepare(source, target, token):
            out = original_prepare(source, target, token)
            if not fired['v']:
                fired['v'] = True
                raced_target.mkdir(parents=True)
                (raced_target / 'USER_UNKNOWN.txt').write_text('preserve unmanaged race\n')
            return out

        S.I.prepare_local_tree = raced_prepare
        old_argv = sys.argv[:]
        try:
            sys.argv = ['sync_global.py', '--codex-home', str(self.home), '--mode', 'full', '--preflight-id', pre['preflight_id']]
            with contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaises(S.SyncError): S.main()
        finally:
            sys.argv = old_argv
            S.I.prepare_local_tree = original_prepare
        self.assertTrue(fired['v'])
        self.assertEqual((raced_target / 'USER_UNKNOWN.txt').read_text(), 'preserve unmanaged race\n')
        self.assertTrue((self.home / I.REGISTRY_NAME).exists())
        self.assertTrue((self.home / 'ios-engineering-shim').exists())
        self.assertFalse(any('.ioslib-backup.' in p.name for p in self.home.rglob('*')))

    def test_F10_failed_update_rollback(self):
        fresh_install(self.home,self.skills,'reference'); agents=self.home/'AGENTS.md'; registry=self.home/I.REGISTRY_NAME; shim=self.home/'ios-engineering-shim/bin/ios_ai.py'; before=(agents.read_bytes(),registry.read_bytes(),hashlib.sha256(shim.read_bytes()).hexdigest())
        original_write=I.write_atomic; fired={'v':False}
        def flaky(path,data,mode=0o600):
            if Path(path)==registry and not fired['v']: fired['v']=True; raise OSError('synthetic update failure')
            return original_write(path,data,mode)
        I.write_atomic=flaky; old_argv=sys.argv[:]
        try:
            sys.argv=['sync_global.py','--codex-home',str(self.home)]
            with contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaises(OSError): S.main()
        finally: sys.argv=old_argv; I.write_atomic=original_write
        after=(agents.read_bytes(),registry.read_bytes(),hashlib.sha256(shim.read_bytes()).hexdigest()); self.assertEqual(before,after)

    def test_F10_failed_full_upgrade_removes_new_targets(self):
        fresh_install(self.home,self.skills,'reference')
        old, pre = S.preflight(self.home, 'full')
        new_targets = sorted(set(I.skill_names()) - set(old['ownership']['skills']))
        first_new = new_targets[0]
        registry = self.home / I.REGISTRY_NAME
        original_write = I.write_atomic
        fired = {'v': False}

        def fail_registry(path, data, mode=0o600):
            if Path(path) == registry and not fired['v']:
                fired['v'] = True
                raise OSError('synthetic full-upgrade metadata failure')
            return original_write(path, data, mode)

        I.write_atomic = fail_registry
        old_argv = sys.argv[:]
        try:
            sys.argv = ['sync_global.py', '--codex-home', str(self.home), '--mode', 'full', '--preflight-id', pre['preflight_id']]
            with contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaises(OSError):
                    S.main()
        finally:
            sys.argv = old_argv
            I.write_atomic = original_write

        self.assertTrue(fired['v'])
        self.assertTrue(new_targets)
        self.assertFalse(any((Path(pre['skills_root']) / name).exists() for name in new_targets))
        self.assertEqual(json.loads(registry.read_text())['mode'], 'reference')

    def test_F10_full_upgrade_post_rename_failure_removes_new_target(self):
        fresh_install(self.home,self.skills,'reference')
        old, pre = S.preflight(self.home, 'full')
        first_new = sorted(set(I.skill_names()) - set(old['ownership']['skills']))[0]
        new_target = Path(pre['skills_root']) / first_new
        original_replace = I._replace_path; fired = {'v':False}
        def fail_after_publish(source,destination):
            result=original_replace(source,destination)
            if Path(destination)==new_target and not fired['v']:
                fired['v']=True
                raise OSError('synthetic full-upgrade post-rename fsync failure')
            return result
        I._replace_path=fail_after_publish
        old_argv=sys.argv[:]
        try:
            sys.argv=['sync_global.py','--codex-home',str(self.home),'--mode','full','--preflight-id',pre['preflight_id']]
            with contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaises(OSError): S.main()
        finally:
            sys.argv=old_argv; I._replace_path=original_replace
        self.assertTrue(fired['v']); self.assertFalse(new_target.exists()); self.assertEqual(json.loads((self.home/I.REGISTRY_NAME).read_text())['mode'],'reference')
        self.assertFalse(any('.ioslib-backup.' in p.name for p in self.home.rglob('*')))

    def test_F10_late_backup_cleanup_failure_preserves_published_state(self):
        self.home.mkdir(parents=True,exist_ok=True); self.home.joinpath('AGENTS.md').write_bytes(b'# synthetic user rules\n')
        a=install_args(self.home,self.skills,'reference',source_in_place=False); pre=I.build_preflight(a,False); a.preflight_id=pre['preflight_id']; I.apply_fresh(pre,a)
        agents=self.home/'AGENTS.md'; registry=self.home/I.REGISTRY_NAME; shim=self.home/'ios-engineering-shim/bin/ios_ai.py'; old_registry=registry.read_bytes()
        original_remove=I.remove_created; fired={'v':0}
        def fail_second_backup(path):
            if '.ioslib-backup.' in Path(path).name:
                fired['v']+=1
                if fired['v']==2: raise OSError('synthetic second backup cleanup failure')
            return original_remove(path)
        I.remove_created=fail_second_backup; old_argv=sys.argv[:]
        try:
            sys.argv=['sync_global.py','--codex-home',str(self.home)]
            with self.assertRaises(S.SyncCleanupIncomplete) as ctx:
                with contextlib.redirect_stdout(io.StringIO()): S.main()
        finally:
            sys.argv=old_argv; I.remove_created=original_remove
        self.assertIn('cleanup incomplete',str(ctx.exception)); self.assertEqual(fired['v'],2)
        published=json.loads(registry.read_text()); self.assertTrue(published['installed']); self.assertNotEqual(registry.read_bytes(),old_registry)
        self.assertTrue(Path(published['content_root']).is_dir()); self.assertTrue(Path(published['shim_root']).is_dir())
        leftovers=[p for p in self.home.rglob('*') if '.ioslib-backup.' in p.name]; self.assertEqual(len(leftovers),1)

    def test_F10_uninstall_post_rename_failure_restores_target(self):
        fresh_install(self.home,self.skills,'reference')
        registry=self.home/I.REGISTRY_NAME; shim=self.home/'ios-engineering-shim'; before_agents=(self.home/'AGENTS.md').read_bytes(); original_replace=I._replace_path; fired={'v':False}
        def fail_after_publish(source,destination):
            result=original_replace(source,destination)
            if '.ioslib-uninstall.' in Path(destination).name and not fired['v']:
                fired['v']=True
                raise OSError('synthetic uninstall post-rename fsync failure')
            return result
        I._replace_path=fail_after_publish; old_argv=sys.argv[:]
        try:
            sys.argv=['uninstall_global.py','--codex-home',str(self.home),'--yes']
            with contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaises(OSError): U.main()
        finally:
            sys.argv=old_argv; I._replace_path=original_replace
        self.assertTrue(fired['v']); self.assertTrue(shim.exists()); self.assertTrue(registry.exists()); self.assertEqual((self.home/'AGENTS.md').read_bytes(),before_agents)
        self.assertFalse(any('.ioslib-uninstall.' in p.name for p in self.home.rglob('*')))

    def test_F10_uninstall_post_metadata_unlink_failure_restores_state(self):
        fresh_install(self.home,self.skills,'reference')
        registry=self.home/I.REGISTRY_NAME; before_registry=registry.read_bytes(); before_agents=(self.home/'AGENTS.md').read_bytes(); original_unlink=I.unlink_nofollow_file; fired={'v':False}
        def fail_after_unlink(path,missing_ok=False):
            result=original_unlink(path,missing_ok=missing_ok)
            if Path(path)==registry and not fired['v']:
                fired['v']=True
                raise OSError('synthetic uninstall post-unlink fsync failure')
            return result
        I.unlink_nofollow_file=fail_after_unlink; old_argv=sys.argv[:]
        try:
            sys.argv=['uninstall_global.py','--codex-home',str(self.home),'--yes']
            with contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaises(OSError): U.main()
        finally:
            sys.argv=old_argv; I.unlink_nofollow_file=original_unlink
        self.assertTrue(fired['v']); self.assertEqual(registry.read_bytes(),before_registry); self.assertTrue((self.home/'ios-engineering-shim').exists()); self.assertEqual((self.home/'AGENTS.md').read_bytes(),before_agents)

    def test_F10_uninstall_late_cleanup_reports_applied_state(self):
        self.home.mkdir(parents=True,exist_ok=True); self.home.joinpath('AGENTS.md').write_bytes(self.original)
        a=install_args(self.home,self.skills,'reference',source_in_place=False); pre=I.build_preflight(a,False); a.preflight_id=pre['preflight_id']; I.apply_fresh(pre,a)
        original_remove=I.remove_created; fired={'v':False}
        def fail_first_backup(path):
            if '.ioslib-uninstall.' in Path(path).name and not fired['v']:
                fired['v']=True
                raise OSError('synthetic uninstall cleanup failure')
            return original_remove(path)
        I.remove_created=fail_first_backup; old_argv=sys.argv[:]
        try:
            sys.argv=['uninstall_global.py','--codex-home',str(self.home),'--yes']
            with contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaises(U.UninstallCleanupIncomplete): U.main()
        finally:
            sys.argv=old_argv; I.remove_created=original_remove
        self.assertTrue(fired['v']); self.assertFalse((self.home/I.REGISTRY_NAME).exists()); self.assertFalse((self.home/'ios-engineering-shim').exists()); self.assertTrue(any('.ioslib-uninstall.' in p.name for p in self.home.rglob('*')))

    def test_F10_metadata_unlink_does_not_follow_symlink(self):
        td=test_tmpdir()
        try:
            parent=td/'state'; parent.mkdir(); outside=td/'outside.txt'; outside.write_text('preserve')
            link=parent/'marker.json'; link.symlink_to(outside)
            I.unlink_nofollow_file(link)
            self.assertFalse(link.exists()); self.assertFalse(link.is_symlink()); self.assertEqual(outside.read_text(),'preserve')
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F10_uninstall_unknown_file_preserved(self):
        reg=fresh_install(self.home,self.skills,'full'); name=next(iter(reg['ownership']['skills'])); unknown=self.skills/name/'USER_UNKNOWN.txt'; unknown.write_text('keep')
        old_argv=sys.argv[:]
        try:
            sys.argv=['uninstall_global.py','--codex-home',str(self.home),'--yes']
            with contextlib.redirect_stdout(io.StringIO()): rc=U.main()
        finally: sys.argv=old_argv
        self.assertEqual(rc,2); self.assertTrue(unknown.exists()); self.assertTrue((self.home/I.REGISTRY_NAME).exists())
    def test_F10_safe_uninstall_preserves_agents_exactly(self):
        fresh_install(self.home,self.skills,'reference'); old_argv=sys.argv[:]
        try:
            sys.argv=['uninstall_global.py','--codex-home',str(self.home),'--yes']
            with contextlib.redirect_stdout(io.StringIO()): rc=U.main()
        finally: sys.argv=old_argv
        self.assertEqual(rc,0); self.assertEqual((self.home/'AGENTS.md').read_bytes(),self.original); self.assertFalse((self.home/I.REGISTRY_NAME).exists())
    def test_F10_agents_permissions_preserved_across_install_sync_uninstall(self):
        agents=self.home/'AGENTS.md'; os.chmod(agents,0o644)
        fresh_install(self.home,self.skills,'reference')
        self.assertEqual(stat.S_IMODE(os.lstat(agents).st_mode),0o644)
        old_argv=sys.argv[:]
        try:
            sys.argv=['sync_global.py','--codex-home',str(self.home)]
            with contextlib.redirect_stdout(io.StringIO()): self.assertEqual(S.main(),0)
            self.assertEqual(stat.S_IMODE(os.lstat(agents).st_mode),0o644)
            sys.argv=['uninstall_global.py','--codex-home',str(self.home),'--yes']
            with contextlib.redirect_stdout(io.StringIO()): self.assertEqual(U.main(),0)
        finally: sys.argv=old_argv
        self.assertEqual(stat.S_IMODE(os.lstat(agents).st_mode),0o644)
        self.assertEqual(agents.read_bytes(),self.original)

    def test_F10_reference_install_validates(self):
        fresh_install(self.home,self.skills,'reference')
        p=run([sys.executable,ROOT/'validate_global_install.py','--codex-home',self.home])
        self.assertEqual(p.returncode,0,p.stdout+p.stderr)

    def test_F10_source_in_place_registry_points_to_source(self):
        reg=fresh_install(self.home,self.skills,'reference')
        self.assertTrue(reg['source_in_place'])
        self.assertEqual(Path(reg['content_root']).resolve(),ROOT.resolve())
        self.assertEqual(Path(reg['source']).resolve(),ROOT.resolve())

    def test_F10_copied_runtime_install_validates(self):
        a=install_args(self.home,self.skills,'reference',source_in_place=False)
        pre=I.build_preflight(a,False); a.preflight_id=pre['preflight_id']; reg=I.apply_fresh(pre,a)
        self.assertFalse(reg['source_in_place']); self.assertNotEqual(Path(reg['content_root']).resolve(),ROOT.resolve())
        self.assertTrue((Path(reg['content_root'])/'GLOBAL_CODEX/runtime/bin/ios_ai.py').is_file())
        descriptor=(self.home/'ios-engineering-shim'/'INSTALLATION.md').read_text()
        self.assertIn(f'Knowledge root: `{Path(reg["content_root"])}`',descriptor)
        self.assertNotIn(f'Knowledge root: `{ROOT}`',descriptor)
        p=run([sys.executable,ROOT/'validate_global_install.py','--codex-home',self.home])
        self.assertEqual(p.returncode,0,p.stdout+p.stderr)

    def test_symlink_source_escape_rejected(self):
        package=self.td/'package'; package.mkdir(); outside=self.td/'outside'; outside.write_text('secret'); (package/'link').symlink_to(outside)
        with self.assertRaises(I.InstallError): I.package_tree_identity(package)

class PackagePolicyTests(unittest.TestCase):
    def test_F14_all_bundled_skills_namespaced(self):
        names=I.skill_names(); self.assertEqual(len(names),60); self.assertTrue(all(n.startswith('ioslib-') for n in names))
    def test_F14_internal_skill_references_namespaced(self):
        offenders=[]
        for p in (ROOT/'GLOBAL_CODEX'/'skills').rglob('*'):
            if p.is_file() and p.suffix in {'.md','.yaml','.yml'}:
                text=p.read_text(encoding='utf-8',errors='strict')
                if '$ios-' in text: offenders.append(str(p.relative_to(ROOT)))
        self.assertEqual(offenders,[])
    def test_F14_runtime_component_versions_match_release_manifest(self):
        manifest=json.loads((ROOT/'GLOBAL_MANIFEST.json').read_text())
        runtime=manifest['runtime']; self.assertEqual(I.VERSION,manifest['version'])
        self.assertEqual(C.CLI_VERSION,runtime['cli_version'])
        self.assertEqual(A.ADAPTER_VERSION,runtime['adapter_version'])
        self.assertEqual(P.PROTECTION_VERSION,runtime['protection_version'])

    def test_F14_router_and_capability_matrix_are_shipped_entrypoints(self):
        router=(ROOT/'GLOBAL_CODEX/KNOWLEDGE_ROUTER.md').read_text()
        matrix=(ROOT/'CAPABILITY_MATRIX.md').read_text()
        self.assertIn('ordinary implementation or bug fix',router); self.assertIn('cross-domain task',router); self.assertIn('disabled_exact_duplicates',router)
        self.assertIn('Reference mode',matrix); self.assertIn('Automatic subagent fan-out',matrix); self.assertIn('grants build',matrix)
    def test_F14_manual_deployment_is_explicit_and_installer_independent(self):
        text=(ROOT/'MANUAL_DEPLOYMENT.md').read_text(encoding='utf-8')
        self.assertIn('Clean-host profile',text)
        self.assertIn('Current-host canonical profile',text)
        first_block=text.split('```bash\n',2)[1].split('```',1)[0]
        self.assertNotIn('--canonical-repository-root',first_block)
        self.assertNotIn('AIZenflowDocumentation',first_block)
        self.assertIn('not run `install_global.py`',text)
        self.assertIn('same active payload layout',text)
        self.assertIn('by\nitself make Codex load it',text)
        self.assertIn('doctor',text)
        self.assertIn('AGENTS.global.block.md',text)
        self.assertIn('no hidden rollback agent',text)
        self.assertIn('cp -n',text)
        self.assertIn('DESCRIPTOR_TMP',text)
        self.assertIn('STATE_MARKER_TMP',text)

    def test_F14_fresh_full_and_reference_full_migration_docs_are_distinct(self):
        readme=(ROOT/'README.md').read_text(encoding='utf-8')
        quick=(ROOT/'QUICKSTART.md').read_text(encoding='utf-8')
        self.assertIn('Existing reference installation: explicit reference → full migration',readme)
        self.assertIn('--preflight-id <PREFLIGHT_ID_FROM_SYNC_DRY_RUN>',readme)
        self.assertIn('migration producer is `sync_global.py`',quick)
        self.assertIn('--preflight-id <ID_FROM_SYNC_DRY_RUN>',quick)
        self.assertIn('--release-root',readme)
        self.assertIn("pre-fix sync as the rollback coordinator",quick)
    def test_F14_manual_shim_resolves_relocated_payload(self):
        td=test_tmpdir()
        try:
            home=td/'manual-home'; content=home/'ios-engineering'; shim=home/'ios-engineering-shim'/'bin'
            shutil.copytree(ROOT,content,symlinks=True,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
            shim.mkdir(parents=True); shutil.copy2(ROOT/'MANUAL_SHIM/bin/ios_ai.py',shim/'ios_ai.py')
            os.chmod(shim/'ios_ai.py',0o755)
            selected=I.deployment_descriptor(mode='reference',library_root=content,
                runtime_cli=content/'GLOBAL_CODEX/runtime/bin/ios_ai.py',state_root=home/'external-state',
                source_tree_sha256=I.package_tree_identity(),generated_by='synthetic-test')
            (shim.parent/'INSTALLATION.json').write_text(json.dumps(selected)+'\n')
            env=dict(os.environ); env['CODEX_HOME']=str(home)
            p=run([sys.executable,shim/'ios_ai.py','doctor'],env=env)
            self.assertEqual(p.returncode,0,p.stdout+p.stderr)
            data=json.loads(p.stdout); self.assertEqual(data['cli_version'],'5.4-review-ready.7'); self.assertTrue(data['identity_verified']); self.assertEqual(Path(data['library']),content); self.assertEqual(Path(data['state_root']),home/'external-state')
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_installed_package_identity_mismatch_is_not_pass(self):
        td=test_tmpdir(); home=td/'identity-home'; skills=td/'identity-skills'; home.mkdir()
        (home/'AGENTS.md').write_text('# user rules\n')
        source=ROOT/'README.md'; original=source.read_bytes()
        try:
            I.package_tree_identity.cache_clear()
            fresh_install(home,skills,'reference')
            source.write_bytes(original+b'\nidentity mismatch regression fixture\n')
            I.package_tree_identity.cache_clear()
            validated=run([sys.executable,ROOT/'validate_global_install.py','--codex-home',home])
            self.assertNotEqual(validated.returncode,0,validated.stdout+validated.stderr)
            self.assertIn('package identity mismatch',validated.stdout)
            doctor=run([sys.executable,home/'ios-engineering-shim/bin/ios_ai.py','doctor'],env=dict(os.environ,CODEX_HOME=str(home)))
            self.assertNotEqual(doctor.returncode,0,doctor.stdout+doctor.stderr)
            self.assertIn('identity',doctor.stdout+doctor.stderr)
        finally:
            source.write_bytes(original)
            I.package_tree_identity.cache_clear()
            shutil.rmtree(td,ignore_errors=True)

    def test_F14_source_in_place_update_switches_release_root_and_can_return(self):
        td=test_tmpdir(); home=td/'selector-home'; skills=td/'selector-skills'; home.mkdir()
        (home/'AGENTS.md').write_text('# user rules\n')
        release_b=td/'release-b'
        try:
            I.package_tree_identity.cache_clear()
            first=fresh_install(home,skills,'reference')
            old_root=Path(first['content_root']); old_readme=(old_root/'README.md').read_bytes()
            sentinel=Path(first['state_root'])/'history-sentinel'; sentinel.write_text('preserve\n')
            shutil.copytree(ROOT,release_b,symlinks=True,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
            (release_b/'README.md').write_bytes((release_b/'README.md').read_bytes()+b'\nrelease B\n')
            original_identity=I.package_tree_identity
            release_b_identity=original_identity.__wrapped__(release_b)
            with mock.patch.object(I,'_git_root_for_destination',side_effect=_external_test_git_root), \
                    mock.patch.object(I,'HERE',release_b), mock.patch.object(I,'G',release_b/'GLOBAL_CODEX'), \
                    mock.patch.object(I,'package_tree_identity',side_effect=lambda root=release_b: release_b_identity):
                old,pre=S.preflight(home)
                self.assertNotIn('source-in-place update must run from the registered source root',pre['collisions'])
                self.assertEqual(Path(pre['content_root']),release_b)
                with mock.patch.object(sys,'argv',['sync_global.py','--codex-home',str(home)]), contextlib.redirect_stdout(io.StringIO()):
                    self.assertEqual(S.main(),0)
            updated=json.loads((home/I.REGISTRY_NAME).read_text())
            self.assertEqual(Path(updated['content_root']),release_b)
            self.assertEqual(Path(updated['source']),release_b)
            self.assertEqual(updated['source_tree_sha256'],release_b_identity)
            descriptor=json.loads((home/'ios-engineering-shim/INSTALLATION.json').read_text())
            self.assertEqual(Path(descriptor['knowledge_root']),release_b)
            self.assertEqual((old_root/'README.md').read_bytes(),old_readme)
            self.assertEqual(sentinel.read_text(),'preserve\n')
            validated=run([sys.executable,ROOT/'validate_global_install.py','--codex-home',home])
            self.assertEqual(validated.returncode,0,validated.stdout+validated.stderr)
            with mock.patch.object(I,'_git_root_for_destination',side_effect=_external_test_git_root), \
                    mock.patch.object(I,'HERE',old_root), mock.patch.object(I,'G',old_root/'GLOBAL_CODEX'), \
                    mock.patch.object(I,'package_tree_identity',side_effect=lambda root=old_root: original_identity.__wrapped__(old_root)):
                with mock.patch.object(sys,'argv',['sync_global.py','--codex-home',str(home)]), contextlib.redirect_stdout(io.StringIO()):
                    self.assertEqual(S.main(),0)
            rolled_back=json.loads((home/I.REGISTRY_NAME).read_text())
            self.assertEqual(Path(rolled_back['content_root']),old_root)
            self.assertEqual(sentinel.read_text(),'preserve\n')
        finally:
            I.package_tree_identity.cache_clear()
            shutil.rmtree(td,ignore_errors=True)

    def test_F14_real_v6_round_trip_uses_fixed_coordinator(self):
        # This is the real release exercise: the historical archive is verified before
        # extraction, the old release performs the fresh install, the current release
        # performs the upgrade, and only the fixed current coordinator performs rollback.
        archive_input=os.environ.get('IOSLIB_LEGACY_ARCHIVE')
        if not archive_input:
            self.skipTest('NOT_RUN: set IOSLIB_LEGACY_ARCHIVE to the hash-pinned historical .6 ZIP')
        archive=Path(archive_input)
        self.assertTrue(archive.is_absolute(),'IOSLIB_LEGACY_ARCHIVE must be absolute')
        expected_archive_sha='57e34f454b5247a43864f89354cdb02a742e5a26d1e6a343d287c9b05bd76e27'
        self.assertTrue(archive.is_file())
        digest=hashlib.sha256()
        with archive.open('rb') as stream:
            for chunk in iter(lambda: stream.read(1024*1024),b''):
                digest.update(chunk)
        self.assertEqual(digest.hexdigest(),expected_archive_sha)
        if M.git_root_for_destination(TEST_TMP_ROOT)[0] is not None:
            self.skipTest('NOT_RUN: historical ZIP verified; real legacy-release acceptance needs an authorized external-to-Git fixture root')
        td=test_tmpdir(); home=td/'area'; home.mkdir(); (home/'AGENTS.md').write_text('# user rules\n'); (home/'AGENTS.md').chmod(0o640)
        old_root=td/'v5.4'; old_root.mkdir()
        try:
            with zipfile.ZipFile(archive) as zf:
                entries=zf.infolist()
                for info in entries:
                    rel=PurePosixPath(info.filename)
                    if rel.is_absolute() or '..' in rel.parts or not rel.parts or rel.parts[0] != 'v5.4':
                        raise AssertionError(f'unsafe historical archive entry: {info.filename}')
                    target=td.joinpath(*rel.parts)
                    if info.is_dir():
                        target.mkdir(parents=True,exist_ok=True)
                        continue
                    target.parent.mkdir(parents=True,exist_ok=True)
                    with zf.open(info) as source, target.open('wb') as sink:
                        shutil.copyfileobj(source,sink)
            self.assertIn('5.4-review-ready.6',(old_root/'GLOBAL_MANIFEST.json').read_text())
            legacy=load('legacy_install_v6_acceptance',old_root/'install_global.py')
            legacy_identity=legacy.package_tree_identity(old_root)
            old_install=run([sys.executable,old_root/'install_global.py','--portable-area',home,
                             '--use-source-in-place','--mode','reference','--dry-run'])
            self.assertEqual(old_install.returncode,0,old_install.stdout+old_install.stderr)
            old_install=run([sys.executable,old_root/'install_global.py','--portable-area',home,
                             '--use-source-in-place','--mode','reference'])
            self.assertEqual(old_install.returncode,0,old_install.stdout+old_install.stderr)
            state=home/'ios-engineering-state'; history=state/'history-sentinel'; history.write_bytes(b'v6 history\n')
            old_payload=(old_root/'README.md').read_bytes(); agents=home/'AGENTS.md'; agents_mode=stat.S_IMODE(agents.stat().st_mode)
            old_descriptor=json.loads((home/'ios-engineering-shim/INSTALLATION.json').read_text())
            self.assertEqual(old_descriptor['release_id'],'5.4-review-ready.6')
            self.assertEqual(Path(old_descriptor['knowledge_root']),old_root)
            old_validation=run([sys.executable,old_root/'validate_global_install.py','--codex-home',home])
            self.assertEqual(old_validation.returncode,0,old_validation.stdout+old_validation.stderr)
            old_doctor=run([sys.executable,home/'ios-engineering-shim/bin/ios_ai.py','doctor'],env=dict(os.environ,CODEX_HOME=str(home)))
            self.assertEqual(old_doctor.returncode,0,old_doctor.stdout+old_doctor.stderr)

            upgraded_dry=run([sys.executable,ROOT/'sync_global.py','--codex-home',home,'--dry-run'])
            self.assertEqual(upgraded_dry.returncode,0,upgraded_dry.stdout+upgraded_dry.stderr)
            upgrade_pre=json.loads(upgraded_dry.stdout)
            self.assertEqual(upgrade_pre['version'],'5.4-review-ready.7')
            upgraded=run([sys.executable,ROOT/'sync_global.py','--codex-home',home])
            self.assertEqual(upgraded.returncode,0,upgraded.stdout+upgraded.stderr)
            current_descriptor=json.loads((home/'ios-engineering-shim/INSTALLATION.json').read_text())
            self.assertEqual(current_descriptor['release_id'],'5.4-review-ready.7')
            self.assertEqual(Path(current_descriptor['knowledge_root']),ROOT)
            current_validation=run([sys.executable,ROOT/'validate_global_install.py','--codex-home',home])
            self.assertEqual(current_validation.returncode,0,current_validation.stdout+current_validation.stderr)
            current_doctor=run([sys.executable,home/'ios-engineering-shim/bin/ios_ai.py','doctor'],env=dict(os.environ,CODEX_HOME=str(home)))
            self.assertEqual(current_doctor.returncode,0,current_doctor.stdout+current_doctor.stderr)

            legacy_baseline=run([sys.executable,old_root/'sync_global.py','--codex-home',home,'--dry-run'])
            self.assertNotEqual(legacy_baseline.returncode,0)
            self.assertIn('source-in-place',legacy_baseline.stdout+legacy_baseline.stderr)
            still_current=json.loads((home/'ios-engineering-shim/INSTALLATION.json').read_text())
            self.assertEqual(still_current['release_id'],'5.4-review-ready.7')

            rollback_dry=run([sys.executable,ROOT/'sync_global.py','--release-root',old_root,
                              '--codex-home',home,'--dry-run'])
            self.assertEqual(rollback_dry.returncode,0,rollback_dry.stdout+rollback_dry.stderr)
            rollback_pre=json.loads(rollback_dry.stdout)
            self.assertEqual(rollback_pre['version'],'5.4-review-ready.6')
            self.assertEqual(Path(rollback_pre['source']),old_root)
            rollback=run([sys.executable,ROOT/'sync_global.py','--release-root',old_root,'--codex-home',home])
            self.assertEqual(rollback.returncode,0,rollback.stdout+rollback.stderr)
            rolled_descriptor=json.loads((home/'ios-engineering-shim/INSTALLATION.json').read_text())
            self.assertEqual(rolled_descriptor['release_id'],'5.4-review-ready.6')
            self.assertEqual(Path(rolled_descriptor['knowledge_root']),old_root)
            self.assertEqual(rolled_descriptor['source_tree_sha256'],legacy_identity)
            rolled_validation=run([sys.executable,old_root/'validate_global_install.py','--codex-home',home])
            self.assertEqual(rolled_validation.returncode,0,rolled_validation.stdout+rolled_validation.stderr)
            rolled_doctor=run([sys.executable,home/'ios-engineering-shim/bin/ios_ai.py','doctor'],env=dict(os.environ,CODEX_HOME=str(home)))
            self.assertEqual(rolled_doctor.returncode,0,rolled_doctor.stdout+rolled_doctor.stderr)
            self.assertEqual(history.read_bytes(),b'v6 history\n')
            self.assertEqual(agents.stat().st_mode & 0o777,agents_mode)
            self.assertTrue(agents.read_bytes().startswith(b'# user rules\n'))
            self.assertEqual((old_root/'README.md').read_bytes(),old_payload)
        finally:
            shutil.rmtree(td,ignore_errors=True)

    def test_F14_manual_shim_switches_external_release_from_descriptor(self):
        td=test_tmpdir()
        try:
            home=td/'manual-home'; release_a=td/'release-a'; release_b=td/'release-b'; shim=home/'ios-engineering-shim'/'bin'
            home.mkdir(); shutil.copytree(ROOT,release_a,symlinks=True,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
            shutil.copytree(ROOT,release_b,symlinks=True,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
            (release_a/'REVIEW_READY_VALIDATION_REPORT.md').write_text('selector-payload-A\n')
            (release_b/'REVIEW_READY_VALIDATION_REPORT.md').write_text('selector-payload-B\n')
            shim.mkdir(parents=True); shutil.copy2(ROOT/'MANUAL_SHIM/bin/ios_ai.py',shim/'ios_ai.py'); os.chmod(shim/'ios_ai.py',0o755)
            descriptor_path=shim.parent/'INSTALLATION.json'; state=home/'external-state'
            for release,marker in ((release_a,'selector-payload-A'),(release_b,'selector-payload-B'),(release_a,'selector-payload-A')):
                selected=I.deployment_descriptor(mode='reference',library_root=release,
                    runtime_cli=release/'GLOBAL_CODEX/runtime/bin/ios_ai.py',state_root=state,
                    source_tree_sha256=I.package_tree_identity(),generated_by='synthetic-test')
                descriptor_path.write_text(json.dumps(selected)+'\n')
                p=run([sys.executable,shim/'ios_ai.py','doctor'],env=dict(os.environ, CODEX_HOME=str(home)))
                self.assertEqual(p.returncode,0,p.stdout+p.stderr)
                self.assertEqual(Path(json.loads(p.stdout)['library']),release)
                self.assertIn(marker,(release/'REVIEW_READY_VALIDATION_REPORT.md').read_text())
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_manual_shim_missing_descriptor_fails_before_runtime(self):
        td=test_tmpdir()
        try:
            home=td/'manual-home'; content=home/'release'; shim=home/'ios-engineering-shim'/'bin'
            home.mkdir(); shutil.copytree(ROOT,content,symlinks=True,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
            shim.mkdir(parents=True); shutil.copy2(ROOT/'MANUAL_SHIM/bin/ios_ai.py',shim/'ios_ai.py'); os.chmod(shim/'ios_ai.py',0o755)
            p=run([sys.executable,shim/'ios_ai.py','doctor'],env=dict(os.environ, CODEX_HOME=str(home)))
            self.assertNotEqual(p.returncode,0); self.assertIn('INSTALLATION.json',p.stdout+p.stderr)
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_manual_preflight_rejects_occupied_unknown_shim(self):
        td=test_tmpdir()
        try:
            home=td/'manual-home'; home.mkdir(); (home/'AGENTS.md').write_text('# rules\n')
            shim=home/'ios-engineering-shim'/'bin'; shim.mkdir(parents=True); (shim/'user-owned').write_text('keep')
            pre=run([sys.executable,ROOT/'MANUAL_SHIM/bin/manual_preflight.py','--release-root',ROOT,'--codex-home',home])
            self.assertEqual(pre.returncode,2,pre.stdout+pre.stderr); data=json.loads(pre.stdout)
            self.assertFalse(data['ok']); self.assertTrue(any('unknown files' in x for x in data['collisions']))
            self.assertEqual((shim/'user-owned').read_text(),'keep')
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_manual_preflight_clean_is_read_only_and_emits_selector(self):
        if not external_fixture_available():
            self.skipTest('NOT_RUN: no permitted fixture root outside every detected Git repository')
        td=test_tmpdir()
        try:
            home=td/'manual-home'; home.mkdir(); state=home/'state'
            p=run([sys.executable,ROOT/'MANUAL_SHIM/bin/manual_preflight.py','--release-root',ROOT,'--codex-home',home,'--state-root',state,'--skills-root',home/'skills'])
            self.assertEqual(p.returncode,0,p.stdout+p.stderr); data=json.loads(p.stdout); self.assertTrue(data['ok']); self.assertTrue(data['read_only'])
            self.assertFalse(home.joinpath('ios-engineering-shim').exists()); self.assertFalse(state.exists())
            selector=run([sys.executable,ROOT/'MANUAL_SHIM/bin/manual_preflight.py','--release-root',ROOT,'--codex-home',home,'--state-root',state,'--skills-root',home/'skills','--emit-descriptor'])
            self.assertEqual(selector.returncode,0,selector.stdout+selector.stderr); self.assertEqual(json.loads(selector.stdout)['runtime_cli'],str(ROOT/'GLOBAL_CODEX/runtime/bin/ios_ai.py'))
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_manual_preflight_accepts_verified_transitional_shim_for_descriptor(self):
        if not external_fixture_available():
            self.skipTest('NOT_RUN: no permitted fixture root outside every detected Git repository')
        td=test_tmpdir()
        try:
            home=td/'manual-home'; home.mkdir(); state=home/'state'
            shim_bin=home/'ios-engineering-shim'/'bin'; shim_bin.mkdir(parents=True)
            shutil.copy2(ROOT/'MANUAL_SHIM/bin/ios_ai.py',shim_bin/'ios_ai.py'); os.chmod(shim_bin/'ios_ai.py',0o755)
            selector=run([sys.executable,ROOT/'MANUAL_SHIM/bin/manual_preflight.py','--release-root',ROOT,'--codex-home',home,'--state-root',state,'--skills-root',home/'skills','--emit-descriptor'])
            self.assertEqual(selector.returncode,0,selector.stdout+selector.stderr)
            data=json.loads(selector.stdout)
            self.assertEqual(data['runtime_cli'],str(ROOT/'GLOBAL_CODEX/runtime/bin/ios_ai.py'))
            self.assertFalse((home/'ios-engineering-shim'/'INSTALLATION.json').exists())
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_manual_preflight_rejects_unmarked_nonempty_state(self):
        td=test_tmpdir()
        try:
            home=td/'manual-home'; home.mkdir(); state=home/'state'; state.mkdir(mode=0o700); os.chmod(state,0o700); (state/'user-data').write_text('keep')
            p=run([sys.executable,ROOT/'MANUAL_SHIM/bin/manual_preflight.py','--release-root',ROOT,'--codex-home',home,'--state-root',state])
            self.assertEqual(p.returncode,2,p.stdout+p.stderr); self.assertIn('no library ownership marker',p.stdout); self.assertEqual((state/'user-data').read_text(),'keep')
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_manual_observer_bounds_empty_dirs_pending_work_and_walk_errors(self):
        td=test_tmpdir()
        try:
            root=td/'root'; root.mkdir(); (root/'empty-a').mkdir(); (root/'empty-b').mkdir()
            with self.assertRaises(M.PreflightError):
                M.tree_entries(root,max_entries=10,max_pending=1)
            with mock.patch.object(M.os,'scandir',side_effect=OSError('synthetic walk failure')):
                with self.assertRaises(M.PreflightError): M.tree_entries(root)
            with self.assertRaises(M.PreflightError): M.tree_entries(root,deadline_seconds=0)
            outside=td/'outside'; outside.mkdir(); (outside/'data').write_text('x')
            escaped=td/'escaped'; escaped.symlink_to(outside, target_is_directory=True)
            with self.assertRaises(M.PreflightError): M.tree_entries(escaped)
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_manual_receipt_rejects_changed_descriptor_and_skill(self):
        td=test_tmpdir()
        try:
            home=td/'home'; shim=home/'ios-engineering-shim'; state=home/'state'; skills=home/'skills'; agents=home/'AGENTS.md'
            (shim/'bin').mkdir(parents=True); state.mkdir(); skills.mkdir()
            descriptor=shim/'INSTALLATION.json'; launcher=shim/'bin/ios_ai.py'; marker=state/'.ioslib-state-owned.json'
            descriptor.write_text('{"release_id":"old"}\n'); launcher.write_text('#!/usr/bin/env python3\n')
            marker.write_text('{"managed_by":"ios-engineering-library"}\n')
            block=f'{M.BEGIN}\nmanaged\n{M.END}\n'; agents.write_text('user\n'+block)
            skill=skills/'ioslib-demo'; skill.mkdir(); skill_file=skill/'SKILL.md'; skill_file.write_text('stable\n')
            managed=[M.file_record(p) for p in (descriptor,launcher,marker,agents,skill_file)]
            receipt={'schema_version':1,'managed_by':'ios-engineering-library','release_id':'old',
                     'protection_version':'p','mode':'full','managed_paths':managed,
                     'agents':{'path':str(agents),'original_sha256':M.sha_bytes(b'user\n'),
                               'original_mode':0o644,'managed_block_sha256':M.sha_bytes(block.rstrip().encode())}}
            owned=M.validate_receipt(receipt,shim=shim,state=state,skills=skills,agents=agents)
            self.assertTrue(M.tree_matches_receipt(skill,owned))
            descriptor.write_text('{"release_id":"tampered"}\n')
            with self.assertRaises(M.PreflightError):
                M.validate_receipt(receipt,shim=shim,state=state,skills=skills,agents=agents)
            descriptor.write_text('{"release_id":"old"}\n'); skill_file.write_text('changed\n')
            with self.assertRaises(M.PreflightError):
                M.validate_receipt(receipt,shim=shim,state=state,skills=skills,agents=agents)
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_manual_receipt_emitter_accepts_published_reference_fixture(self):
        td=test_tmpdir()
        try:
            home=td/'home'; shim=home/'ios-engineering-shim'; state=home/'state'; skills=home/'skills'; agents=home/'AGENTS.md'
            (shim/'bin').mkdir(parents=True); state.mkdir(mode=0o700); os.chmod(state,0o700); skills.mkdir()
            launcher=shim/'bin/ios_ai.py'; shutil.copy2(ROOT/'MANUAL_SHIM/bin/ios_ai.py',launcher); os.chmod(launcher,0o755)
            manifest=json.loads((ROOT/'GLOBAL_MANIFEST.json').read_text())
            descriptor={'schema_version':1,'managed_by':'ios-engineering-library',
                        'release_id':manifest['version'],'protection_version':manifest['runtime']['protection_version'],
                        'mode':'reference','knowledge_root':str(ROOT),
                        'runtime_cli':str(ROOT/'GLOBAL_CODEX/runtime/bin/ios_ai.py'),'state_root':str(state),
                        'source_tree_sha256':M.package_identity(ROOT),'generated_by':'manual_preflight.py'}
            (shim/'INSTALLATION.json').write_text(json.dumps(descriptor)+'\n')
            (state/'.ioslib-state-owned.json').write_text(json.dumps({'managed_by':'ios-engineering-library',
                'version':manifest['version'],'protection_version':manifest['runtime']['protection_version'],
                'deployment':'manual'})+'\n')
            block=(ROOT/'GLOBAL_CODEX/AGENTS.global.block.md').read_text().rstrip()
            original=b'# user rules\n'; agents.write_bytes(original+b'\n'+block.encode()+b'\n')
            snapshot=td/'original-agents-snapshot'; snapshot.write_bytes(original); snapshot.chmod(0o644)
            args=types.SimpleNamespace(release_root=str(ROOT),codex_home=str(home),state_root=str(state),
                skills_root=str(skills),agents_file=None,mode='reference',emit_receipt=True,
                original_agents_sha256=M.sha_bytes(original),original_agents_mode=0o644,original_agents_absent=False,
                original_agents_snapshot=str(snapshot))
            with mock.patch.object(M,'git_root_for_destination',return_value=(None,None)):
                result=M.build(args)
            self.assertTrue(result['ok'],result['collisions']); self.assertIsNotNone(result['receipt'])
            owned=M.validate_receipt(result['receipt'],shim=shim,state=state,skills=skills,agents=agents)
            self.assertIn(shim/'INSTALLATION.json',owned)
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_manual_reconnect_requires_owned_disabled_state_and_preserves_agents_prefix(self):
        td=test_tmpdir()
        try:
            home=td/'home'; shim=home/'ios-engineering-shim'; state=home/'state'; skills=home/'skills'; agents=home/'AGENTS.md'
            (shim/'bin').mkdir(parents=True); state.mkdir(mode=0o700); os.chmod(state,0o700); skills.mkdir()
            old_marker={'managed_by':'ios-engineering-library','version':'old','protection_version':'old-p','deployment':'manual'}
            (state/'.ioslib-state-owned.json').write_text(json.dumps(old_marker)+'\n')
            original='# пользовательские правила\n\n'.encode('utf-8'); agents.write_bytes(original)
            args=types.SimpleNamespace(release_root=str(ROOT),codex_home=str(home),state_root=str(state),
                skills_root=str(skills),agents_file=None,mode='reference',emit_receipt=False,
                original_agents_sha256=None,original_agents_mode=None,original_agents_absent=False,
                original_agents_snapshot=None)
            with mock.patch.object(M,'git_root_for_destination',return_value=(None,None)):
                pre=M.build(args)
            self.assertTrue(pre['ok'],pre['collisions'])
            self.assertTrue(any(row['op']=='reuse_verified_empty_disabled_shim' for row in pre['operations']))
            launcher=shim/'bin/ios_ai.py'; shutil.copy2(ROOT/'MANUAL_SHIM/bin/ios_ai.py',launcher); os.chmod(launcher,0o755)
            (shim/'INSTALLATION.json').write_text(json.dumps(pre['descriptor'])+'\n')
            (state/'.ioslib-state-owned.json').write_text(json.dumps(pre['state_marker'])+'\n')
            block=(ROOT/'GLOBAL_CODEX/AGENTS.global.block.md').read_text().rstrip()
            agents.write_bytes(original+b'\n'+block.encode()+b'\n')
            snapshot=td/'agents-original'; snapshot.write_bytes(original); snapshot.chmod(0o644)
            args.emit_receipt=True; args.original_agents_sha256=M.sha_bytes(original); args.original_agents_mode=0o644
            args.original_agents_snapshot=str(snapshot)
            with mock.patch.object(M,'git_root_for_destination',return_value=(None,None)):
                emitted=M.build(args)
            self.assertTrue(emitted['ok'],emitted['collisions'])
            agents.write_bytes(b'# user rules changed\n\n'+block.encode()+b'\n')
            with mock.patch.object(M,'git_root_for_destination',return_value=(None,None)):
                denied=M.build(args)
            self.assertFalse(denied['ok'])
            self.assertTrue(any('user-owned AGENTS text changed' in item for item in denied['collisions']))
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_manual_update_accepts_only_release_matching_skill_tree(self):
        td=test_tmpdir()
        try:
            source=td/'source'; target=td/'target'; source.mkdir(); target.mkdir()
            (source/'SKILL.md').write_text('release skill\n'); (source/'references').mkdir()
            (source/'references/domain.md').write_text('domain guidance\n')
            shutil.copytree(source,target,dirs_exist_ok=True)
            extra=td/'INSTALLATION.md'; extra.write_text('selected release\n')
            (target/'references/INSTALLATION.md').write_bytes(extra.read_bytes())
            self.assertTrue(M.tree_matches_release(target,source,{'references/INSTALLATION.md':extra}))
            (target/'SKILL.md').write_text('locally changed\n')
            self.assertFalse(M.tree_matches_release(target,source,{'references/INSTALLATION.md':extra}))
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_manual_package_budget_and_short_reads(self):
        td=test_tmpdir()
        try:
            payload=b'bounded bytes'
            (td/'data').write_bytes(payload)
            manifest={'files':[{'path':'data','size':len(payload),'sha256':M.sha_bytes(payload)}]}
            raw=json.dumps(manifest).encode()
            (td/'PACKAGE_FILE_MANIFEST.json').write_bytes(raw)
            total=len(raw)+len(payload)
            with mock.patch.object(M,'MAX_PACKAGE_BYTES',total):
                self.assertTrue(M.package_identity(td))
            with mock.patch.object(M,'MAX_PACKAGE_BYTES',total-1):
                with self.assertRaises(M.PreflightError): M.package_identity(td)
            with mock.patch.object(M,'PACKAGE_DEADLINE_SECONDS',0):
                with self.assertRaises(M.PreflightError): M.package_identity(td)
            with mock.patch.object(M,'MAX_TREE_ENTRIES',0):
                with self.assertRaises(M.PreflightError): M.package_identity(td)
            real_read=M.os.read
            with mock.patch.object(M.os,'read',side_effect=lambda fd,n: real_read(fd,min(n,3))):
                self.assertEqual(M.read_regular(td/'data',len(payload)),payload)
            with mock.patch.object(M.os,'read',return_value=b''):
                with self.assertRaises(M.PreflightError): M.read_regular(td/'data',len(payload))
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_manual_receipt_encoded_and_aggregate_bounds(self):
        td=test_tmpdir()
        try:
            shim=td/'shim'; state=td/'state'; skills=td/'skills'; agents=td/'AGENTS.md'
            (shim/'bin').mkdir(parents=True); state.mkdir(); (skills/'ioslib-demo').mkdir(parents=True)
            for path in (shim/'INSTALLATION.json',shim/'bin/ios_ai.py',state/'.ioslib-state-owned.json',agents):
                path.write_text('x')
            for index in range(400):
                (skills/'ioslib-demo'/('document-'+str(index)+'x'*80)).write_text('x')
            kw=dict(release_id='r',protection_version='p',mode='full',shim=shim,state=state,
                    skills=skills,agents=agents,incoming_skill_names=['ioslib-demo'],
                    original_agents_sha256=None,original_agents_mode=None,managed_block_sha256='a'*64)
            receipt=M.build_receipt(**kw)
            encoded=json.dumps(receipt,indent=2,sort_keys=True)+'\n'
            self.assertGreater(len(encoded.encode()),M.MAX_DESCRIPTOR_BYTES)
            receipt_path=shim/M.RECEIPT_NAME; receipt_path.write_text(encoded)
            decoded=M.safe_json(receipt_path,M.MAX_RECEIPT_BYTES)
            self.assertEqual(decoded,receipt)
            roots=dict(shim=shim,state=state,skills=skills,agents=agents)
            with mock.patch.object(M,'MAX_TREE_BYTES',404):
                self.assertEqual(len(M.validate_receipt(decoded,**roots)),404)
            with mock.patch.object(M,'MAX_TREE_BYTES',403):
                with self.assertRaises(M.PreflightError): M.validate_receipt(decoded,**roots)
            with mock.patch.object(M,'MAX_RECEIPT_BYTES',len(encoded.encode())-1):
                with self.assertRaises(M.PreflightError): M.build_receipt(**kw)
        finally: shutil.rmtree(td,ignore_errors=True)

    def manual_activation_script(self, home, mode):
        import re, shlex
        doc=(ROOT/'MANUAL_DEPLOYMENT.md').read_text()
        blocks=re.findall(r'```bash\n(.*?)```',doc,re.S)
        def unique(marker):
            matches=[block for block in blocks if marker in block]
            self.assertEqual(len(matches),1,f'ambiguous or missing manual block: {marker}')
            return matches[0]
        bootstrap=unique('PREFLIGHT_TMP=')
        skills_script=unique('SKILL_STAGE=')
        receipt_script=unique('RECEIPT_TMP=')
        self.assertIn('LIB_ROOT=/ABSOLUTE/PATH/TO/HASH-VERIFIED-VERSIONED-RELEASE',bootstrap)
        self.assertIn('ACTIVE_CODEX_HOME=/ABSOLUTE/PATH/TO/DEDICATED-CODEX-HOME',bootstrap)
        script=bootstrap.replace(
            'LIB_ROOT=/ABSOLUTE/PATH/TO/HASH-VERIFIED-VERSIONED-RELEASE',
            'LIB_ROOT='+shlex.quote(str(ROOT))).replace(
            'ACTIVE_CODEX_HOME=/ABSOLUTE/PATH/TO/DEDICATED-CODEX-HOME',
            'ACTIVE_CODEX_HOME='+shlex.quote(str(home))).replace(
            'MODE=reference # set full explicitly when namespaced skill discovery is wanted',
            'MODE='+mode)
        script+='\n'+skills_script+'\n'+receipt_script
        self.assertNotIn('--canonical-repository-root',script)
        self.assertIn('--emit-receipt',script)
        self.assertNotIn('/ABSOLUTE/PATH/',script)
        return script

    def test_F14_manual_commands_compile_without_deployment(self):
        # The same command builder used by activation/reconnect is checked without
        # installing anything or overriding production Git admission.
        for mode in ('reference','full'):
            with self.subTest(mode=mode):
                script=self.manual_activation_script(TEST_TMP_ROOT/"area with spaces 'quoted'",mode)
                syntax=subprocess.run(['bash','-n'],input=script,text=True,capture_output=True)
                self.assertEqual(syntax.returncode,0,syntax.stderr)
                self.assertEqual(script.count('--emit-receipt'),1)

    def test_F14_manual_documented_fresh_reference_and_full(self):
        # Run the published shell blocks, not a hand-built already-installed fixture.
        import re, shlex
        td=test_tmpdir()
        try:
            doc=(ROOT/'MANUAL_DEPLOYMENT.md').read_text()
            blocks=re.findall(r'```bash\n(.*?)```',doc,re.S)
            self.assertGreaterEqual(len(blocks),3)
            bootstrap=next((block for block in blocks if
                            'LIB_ROOT=/ABSOLUTE/PATH/TO/HASH-VERIFIED-VERSIONED-RELEASE' in block and
                            'PREFLIGHT_TMP=' in block),None)
            skills_script=next((block for block in blocks if 'SKILL_STAGE=' in block),None)
            receipt_script=next((block for block in blocks if 'RECEIPT_TMP=' in block),None)
            self.assertIsNotNone(bootstrap)
            self.assertIsNotNone(skills_script)
            self.assertIsNotNone(receipt_script)
            self.assertIn('ACTIVE_CODEX_HOME=/ABSOLUTE/PATH/TO/DEDICATED-CODEX-HOME',bootstrap)
            self.assertNotIn('--canonical-repository-root',bootstrap)
            self.assertIn('--canonical-repository-root',doc)
            # Never bypass production Git detection to turn host-ineligible tests green.
            if M.git_root_for_destination(TEST_TMP_ROOT)[0] is not None:
                self.skipTest('NOT_RUN: documented deployment needs an authorized external-to-Git root')
            for mode in ('reference','full'):
                for existing in (False,True):
                    with self.subTest(mode=mode,existing=existing):
                        home=td/(mode+str(existing)); home.mkdir()
                        skills=home/'skills'
                        original=b'# user rules stay intact\n' if existing else b''
                        agents=home/'AGENTS.md'
                        if existing:
                            agents.write_bytes(original); agents.chmod(0o640)
                        activation_script=self.manual_activation_script(home,mode)
                        # This is the documented operator append between shell blocks;
                        # it preserves existing content and modes instead of repairing a fixture.
                        env=dict(os.environ,CODEX_HOME=str(home))
                        result=run(['bash','-c',activation_script],env=env)
                        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
                        self.assertTrue(agents.read_bytes().startswith(original))
                        if existing: self.assertEqual(stat.S_IMODE(agents.stat().st_mode),0o640)
                        shim=home/'ios-engineering-shim'
                        receipt=M.safe_json(shim/M.RECEIPT_NAME,M.MAX_RECEIPT_BYTES)
                        self.assertEqual(receipt['mode'],mode)
                        self.assertEqual(receipt['agents']['original_sha256'],M.sha_bytes(original) if existing else None)
                        self.assertEqual(json.loads((shim/'INSTALLATION.json').read_text())['mode'],mode)
                        if mode=='full':
                            self.assertEqual(len(list(skills.glob('ioslib-*/SKILL.md'))),60)
                        def preflight(release, selected_mode, *extra):
                            p=run([sys.executable,release/'MANUAL_SHIM/bin/manual_preflight.py',
                                '--release-root',release,'--codex-home',home,
                                '--state-root',home/'ios-engineering-state','--skills-root',skills,
                                '--mode',selected_mode,*extra])
                            self.assertEqual(p.returncode,0,p.stdout+p.stderr)
                            return json.loads(p.stdout)

                        def update(release, index):
                            # The documented update: check OLD ownership, prepare BOTH outputs,
                            # preserve backups, publish new content, move stale receipt, emit last.
                            prepared=preflight(release,'full')
                            old=M.safe_json(shim/M.RECEIPT_NAME,M.MAX_RECEIPT_BYTES)
                            backup=td/('backup-'+home.name+'-'+str(index)); backup.mkdir()
                            for path in (shim/'INSTALLATION.json',shim/M.RECEIPT_NAME,
                                         home/'ios-engineering-state/.ioslib-state-owned.json',agents):
                                shutil.copy2(path,backup/path.name)
                            (shim/'INSTALLATION.json').write_text(json.dumps(prepared['descriptor'])+'\n')
                            shutil.copy2(release/'MANUAL_SHIM/bin/ios_ai.py',shim/'bin/ios_ai.py')
                            old_text=agents.read_text()
                            start=old_text.index(M.BEGIN); end=old_text.index(M.END,start)+len(M.END)
                            new_block=(release/'GLOBAL_CODEX/AGENTS.global.block.md').read_text().rstrip()
                            agents.write_text(old_text[:start]+new_block+old_text[end:])
                            skills.mkdir(exist_ok=True)
                            for source in (release/'GLOBAL_CODEX/skills').iterdir():
                                staged=backup/('incoming-'+source.name)
                                shutil.copytree(source,staged)
                                shutil.copy2(release/'MANUAL_SHIM/INSTALLATION.md',staged/'references/INSTALLATION.md')
                                target=skills/source.name
                                if target.exists(): target.rename(backup/source.name)
                                staged.rename(target)
                            (home/'ios-engineering-state/.ioslib-state-owned.json').write_text(json.dumps(prepared['state_marker'])+'\n')
                            (shim/M.RECEIPT_NAME).rename(backup/'stale-receipt.json')
                            seed=old['agents']
                            if seed['original_sha256'] is None:
                                extra=['--original-agents-absent']
                            else:
                                snapshot=backup/'original-agents-snapshot'
                                snapshot.write_bytes(original)
                                snapshot.chmod(seed['original_mode'])
                                extra=['--original-agents-sha256',seed['original_sha256'],
                                    '--original-agents-mode',str(seed['original_mode']),
                                    '--original-agents-snapshot',str(snapshot)]
                            fresh=preflight(release,'full','--emit-receipt',*extra)
                            (shim/M.RECEIPT_NAME).write_text(json.dumps(fresh,indent=2)+'\n')
                            preflight(release,'full')
                            self.assertEqual(agents.read_bytes()[:len(original)],original)
                            if existing: self.assertEqual(stat.S_IMODE(agents.stat().st_mode),0o640)
                            return fresh

                        update(ROOT,0) # explicit reference -> full, or unchanged full control
                        release_b=td/('release-b-'+home.name)
                        shutil.copytree(ROOT,release_b)
                        router=release_b/'GLOBAL_CODEX/KNOWLEDGE_ROUTER.md'
                        router.write_text(router.read_text()+'\nPilot B: include cancellation ownership in the selected review.\n')
                        manifest_path=release_b/'PACKAGE_FILE_MANIFEST.json'
                        manifest=json.loads(manifest_path.read_text())
                        for row in manifest['files']:
                            data=(release_b/row['path']).read_bytes()
                            row.update(size=len(data),sha256=hashlib.sha256(data).hexdigest())
                        manifest_path.write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n')
                        history=home/'ios-engineering-state/history-sentinel'
                        history.write_text('preserve session history')
                        update(release_b,1)
                        selected=json.loads((shim/'INSTALLATION.json').read_text())
                        self.assertIn('Pilot B:',(Path(selected['knowledge_root'])/'GLOBAL_CODEX/KNOWLEDGE_ROUTER.md').read_text())
                        latest=update(ROOT,2)
                        selected=json.loads((shim/'INSTALLATION.json').read_text())
                        self.assertNotIn('Pilot B:',(Path(selected['knowledge_root'])/'GLOBAL_CODEX/KNOWLEDGE_ROUTER.md').read_text())
                        # Ordinary preflight must reject a changed user file before any update.
                        before=agents.read_bytes(); agents.write_bytes(before+b'# new user edit\n')
                        denied=run([sys.executable,ROOT/'MANUAL_SHIM/bin/manual_preflight.py',
                            '--release-root',ROOT,'--codex-home',home,'--skills-root',skills,'--mode','full'])
                        self.assertNotEqual(denied.returncode,0)
                        self.assertEqual(agents.read_bytes(),before+b'# new user edit\n')
                        agents.write_bytes(before) # end the explicit tamper test, not lifecycle repair
                        preflight(ROOT,'full')
                        # Disable removes only unchanged owned files, preserving state and user text.
                        owned=M.validate_receipt(latest,shim=shim,state=home/'ios-engineering-state',skills=skills,agents=agents)
                        skill_dirs=set()
                        for path in owned:
                            for parent in path.parents:
                                if parent==skills: break
                                if M.path_contains(skills,parent): skill_dirs.add(parent)
                        for path in owned:
                            if path==agents or M.path_contains(home/'ios-engineering-state',path): continue
                            path.unlink()
                        # Remove only now-empty directories derived from owned skill paths.
                        # rmdir refuses residual/unknown content; never recursively delete it.
                        for directory in sorted(skill_dirs,key=lambda p:len(p.parts),reverse=True):
                            directory.rmdir()
                        # The activation-owned separator and block newline are removed too;
                        # preserve the exact pre-activation bytes, not additional whitespace.
                        managed_block=(ROOT/'GLOBAL_CODEX/AGENTS.global.block.md').read_bytes()
                        self.assertEqual(agents.read_bytes(),original+b'\n'+managed_block)
                        agents.write_bytes(original)
                        (shim/M.RECEIPT_NAME).unlink()
                        self.assertNotIn(M.BEGIN,agents.read_text())
                        self.assertEqual(agents.read_bytes(),original)
                        self.assertEqual(history.read_text(),'preserve session history')
                        reconnect=run(['bash','-c',activation_script],env=env)
                        self.assertEqual(reconnect.returncode,0,reconnect.stdout+reconnect.stderr)
                        self.assertTrue((shim/M.RECEIPT_NAME).is_file())
                        self.assertIn(M.BEGIN,agents.read_text())
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_knowledge_profile_requires_exact_active_source_and_invalidates_change(self):
        td=test_tmpdir()
        try:
            source=td/'external-knowledge'; state=td/'state'; source.mkdir()
            (source/'exact.md').write_text('same\n'); (source/'overlap.md').write_text('external\n')
            # A source need not mirror the whole candidate; only exact matching paths can be
            # excluded, while same-path differences remain explicit conflicts.
            candidate_probe=ROOT/'exact.md'; candidate_probe.write_text('same\n')
            try:
                built=run([sys.executable,CLI,'--state-root',state,'profile','build','--source-root',source,'--activate','--write'])
                self.assertEqual(built.returncode,0,built.stdout+built.stderr)
                profile=json.loads((state/'knowledge-profile.json').read_text())
                self.assertIn('exact.md',profile['exact_duplicates']); self.assertIn('exact.md',profile['disabled_exact_duplicates'])
                (source/'exact.md').write_text('changed\n')
                status=run([sys.executable,CLI,'--state-root',state,'profile','status','--source-root',source])
                self.assertEqual(status.returncode,0,status.stdout+status.stderr)
                data=json.loads(status.stdout); self.assertEqual(data['status'],'invalid'); self.assertEqual(data['disabled_exact_duplicates'],[])
            finally:
                candidate_probe.unlink(missing_ok=True)
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_knowledge_profile_without_source_is_not_active(self):
        td=test_tmpdir()
        try:
            candidate=td/'candidate'; source=td/'source'; candidate.mkdir(); source.mkdir()
            (candidate/'same.md').write_text('same\n'); (source/'same.md').write_text('same\n')
            profile=C.K.build_profile(candidate,source,'test-release','test-protection',True)
            data=C.K.current_status(profile)
            self.assertEqual(data['status'],'inactive'); self.assertEqual(data['disabled_exact_duplicates'],[])
            selected=C.K.current_status(profile,source)
            self.assertEqual(selected['status'],'active_exact_only'); self.assertEqual(selected['disabled_exact_duplicates'],['same.md'])
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_knowledge_profile_revalidates_candidate_and_duplicate_evidence(self):
        td=test_tmpdir()
        try:
            candidate=td/'candidate'; source=td/'source'; candidate.mkdir(); source.mkdir()
            (candidate/'same.md').write_text('same\n'); (source/'same.md').write_text('same\n')
            profile=C.K.build_profile(candidate,source,'test-release','test-protection',True)
            self.assertEqual(C.K.current_status(profile,source)['status'],'active_exact_only')
            (candidate/'same.md').write_text('changed\n')
            status=C.K.current_status(profile,source)
            self.assertEqual(status['status'],'invalid'); self.assertIn('candidate release changed',status['reason'])
            self.assertEqual(status['disabled_exact_duplicates'],[])
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_knowledge_profile_supports_explicit_layout_mapping(self):
        td=test_tmpdir()
        try:
            candidate=td/'candidate'; source=td/'source'; candidate.mkdir(); source.mkdir()
            (candidate/'candidate.md').write_text('same\n'); (source/'renamed.md').write_text('same\n')
            profile=C.K.build_profile(candidate,source,'test-release','test-protection',True,{'candidate.md':'renamed.md'})
            self.assertEqual(profile['exact_duplicates'],['candidate.md'])
            self.assertEqual(C.K.current_status(profile,source)['disabled_exact_duplicates'],['candidate.md'])
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_knowledge_profile_requires_boolean_active_and_never_trusts_string_false(self):
        td=test_tmpdir()
        try:
            candidate=td/'candidate'; source=td/'source'; candidate.mkdir(); source.mkdir()
            (candidate/'same.md').write_text('same\n'); (source/'same.md').write_text('same\n')
            profile=C.K.build_profile(candidate,source,'test-release','test-protection',True)
            profile['source']['active']='false'
            status=C.K.current_status(profile,source)
            self.assertEqual(status['status'],'invalid'); self.assertEqual(status['disabled_exact_duplicates'],[])
            with self.assertRaises(C.K.ProfileError):
                C.K.build_profile(candidate,source,'test-release','test-protection','false')
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_knowledge_profile_bounds_empty_directories_and_pending_work(self):
        td=test_tmpdir()
        try:
            root=td/'root'; root.mkdir()
            (root/'empty-a').mkdir(); (root/'empty-b').mkdir(); (root/'empty-c').mkdir()
            with mock.patch.object(C.K,'MAX_ENTRIES',2):
                with self.assertRaises(C.K.ProfileError): C.K.scan(root)
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_knowledge_profile_rejects_aggregate_overflow_before_read(self):
        td=test_tmpdir()
        try:
            root=td/'root'; root.mkdir(); (root/'a.md').write_text('ab'); (root/'b.md').write_text('cd')
            with mock.patch.object(C.K,'MAX_BYTES',4):
                rows,_=C.K.scan(root); self.assertEqual(set(rows),{'a.md','b.md'})
                (root/'c.md').write_text('e')
                with self.assertRaises(C.K.ProfileError): C.K.scan(root)
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_knowledge_profile_walk_error_and_deadline_are_nonpass(self):
        td=test_tmpdir()
        try:
            root=td/'root'; root.mkdir(); (root/'a.md').write_text('a')
            with mock.patch.object(C.K.os,'scandir',side_effect=OSError('synthetic walk failure')):
                with self.assertRaises(C.K.ProfileError): C.K.scan(root)
            with self.assertRaises(C.K.ProfileError): C.K.scan(root,deadline_seconds=0)
        finally: shutil.rmtree(td,ignore_errors=True)
    def test_F14_knowledge_profile_rejects_ambiguous_normalized_mapping(self):
        td=test_tmpdir()
        try:
            candidate=td/'candidate'; source=td/'source'; candidate.mkdir(); source.mkdir()
            (candidate/'candidate.md').write_text('same\n'); (source/'renamed.md').write_text('same\n')
            with self.assertRaises(C.K.ProfileError):
                C.K.build_profile(candidate,source,'test-release','test-protection',True,
                                  {'candidate.md':'renamed.md', './candidate.md':'renamed.md'})
        finally: shutil.rmtree(td,ignore_errors=True)
    def test_K03_guarantee_terminology_present(self):
        t=(ROOT/'GLOBAL_CODEX/AGENTS.global.block.md').read_text(); self.assertIn('before/after **detection**',t); self.assertIn('not a backup',t); self.assertIn('advisory classifier',t); self.assertIn('ignored',t.lower())
    def test_K01_repeated_deep_playbook_placeholder_removed(self):
        old='Enumerate domain-specific edge cases from the existing implementation and acceptance criteria'
        matches=[p for p in (ROOT/'31_DEEP_PLAYBOOKS').glob('OP-*.md') if old in p.read_text()]
        self.assertEqual(matches,[]); self.assertTrue((ROOT/'31_DEEP_PLAYBOOKS/COMMON_EXECUTION_CONTRACT.md').is_file())
    def test_K01_priority_knowledge_has_domain_depth_and_primary_sources(self):
        rels=['03_CONCURRENCY/IOS-03-06_TASK_LIFETIME.md','03_CONCURRENCY/IOS-03-07_CANCELLATION.md','08_NETWORKING/IOS-08-03_RETRY_BACKOFF.md','08_NETWORKING/IOS-08-02_AUTH_REFRESH.md','05_SWIFTUI/IOS-05-02_STATE_OWNERSHIP.md','05_SWIFTUI/IOS-05-03_VIEW_IDENTITY.md','12_SECURITY_PRIVACY/IOS-12-03_AUTHENTICATION.md','12_SECURITY_PRIVACY/IOS-12-12_SECURITY_REVIEW.md','11_PERFORMANCE_MEMORY/IOS-11-11_PERF_BUDGET.md','11_PERFORMANCE_MEMORY/IOS-11-05_MEMORY_LEAK.md','09_PERSISTENCE_DATA/IOS-09-05_MIGRATIONS.md','13_ACCESSIBILITY_LOCALIZATION/IOS-13-01_VOICEOVER.md']
        for rel in rels:
            with self.subTest(rel=rel):
                t=(ROOT/rel).read_text().lower(); self.assertIn('scenario',t); self.assertIn('common wrong approach',t); self.assertIn('preferred approach',t); self.assertIn('verification',t); self.assertIn('compatibility',t); self.assertTrue('trap' in t or 'edge case' in t); self.assertIn('checked',t); self.assertIn('https://',t)


class AdditionalAcceptanceTests(unittest.TestCase):
    def setUp(self):
        self.td=test_tmpdir()
        self.repo=init_repo(self.td/'repo')
        self.state=self.td/'external-state'
    def tearDown(self):
        shutil.rmtree(self.td,ignore_errors=True)

    def test_F10_incompatible_active_session_blocks_installer_and_manual_update(self):
        reg=fresh_install(self.td/'installed-home',self.td/'installed-skills','reference')
        state=Path(reg['state_root'])
        session_dir=state/'repositories'/'synthetic-repository'/'protection'/'sessions'
        session_dir.mkdir(parents=True)
        (session_dir/'legacy.json').write_text(json.dumps({
            'session_id':'legacy', 'lifecycle':'active',
            'baseline':{'protection_version':'5.2-legacy'},
        })+'\n')
        old, pre=S.preflight(self.td/'installed-home')
        self.assertTrue(any('incompatible active protection session' in x for x in pre['collisions']))
        manual=run([sys.executable,ROOT/'MANUAL_SHIM/bin/manual_preflight.py',
            '--release-root',ROOT,'--codex-home',self.td/'installed-home',
            '--state-root',state,'--mode','reference'])
        self.assertEqual(manual.returncode,2,manual.stdout+manual.stderr)
        self.assertIn('incompatible active protection session',manual.stdout)

    def test_regression_state_inside_client_repo_rejected(self):
        with self.assertRaises(P.ProtectionError):
            P.ensure_external_state(self.repo,self.repo/'.ioslib-state')

    def test_F02_state_json_requires_private_permissions(self):
        state=self.td/'private-state'; P.secure_dir(state)
        f=state/'session.json'; P.secure_write(f, json.dumps({'ok': True}))
        os.chmod(f,0o644)
        with self.assertRaises(P.ProtectionError): P.secure_read_json(f)

    def test_F02_state_root_symlink_component_rejected_end_to_end(self):
        real=self.td/'real-state'; real.mkdir(); link=self.td/'state-link'; link.symlink_to(real,target_is_directory=True)
        pr=run([sys.executable,CLI,'--state-root',link,'context','--repo',self.repo,'--ensure'])
        self.assertNotEqual(pr.returncode,0); self.assertIn('symlink state path component',pr.stderr)
        self.assertEqual(list(real.iterdir()),[])

    def test_F14_installer_rejects_client_repository_destinations(self):
        client=init_repo(self.td/'client')
        args=install_args(client,self.td/'skills','reference')
        pre=I.build_preflight(args,False)
        self.assertTrue(any('inside client Git repository' in item for item in pre['collisions']))

    def test_F14_installer_env_codex_home_cannot_bypass_client_repository_rejection(self):
        client=init_repo(self.td/'env-client')
        args=types.SimpleNamespace(codex_home=None,runtime_root=None,skills_root='auto',agents_file=None,
            use_source_in_place=True,mode='reference',preflight_id=None,dry_run=True)
        with contextlib.ExitStack() as stack:
            stack.enter_context(mock.patch.dict(os.environ,{'CODEX_HOME':str(client)}))
            pre=I.build_preflight(args,False)
        self.assertTrue(any('inside client Git repository' in item for item in pre['collisions']))
        self.assertFalse((client/'ios-engineering-shim').exists())

    def test_F14_source_repository_is_not_an_installation_exception(self):
        client=init_repo(self.td/'source-client')
        release=client/'library-release'; release.mkdir()
        targets={'codex_home':client,'shim_root':client/'ios-engineering-shim',
                 'state_root':client/'ios-engineering-state','agents_file':client/'AGENTS.md'}
        installer_collisions=I.destination_layout_collisions(targets,source_root=release,source_in_place=False)
        manual_collisions=load('review_manual_a',ROOT/'MANUAL_SHIM/bin/manual_preflight.py').destination_layout_collisions(targets,release)
        self.assertTrue(any('inside client Git repository' in item for item in installer_collisions))
        self.assertTrue(any('inside client Git repository' in item for item in manual_collisions))

    def test_F14_canonical_repository_runtime_is_exact_and_lifecycle_safe(self):
        canonical=init_repo(self.td/'canonical-docs')
        git(canonical,'remote','add','origin','https://github.com/MArtem/AIZenflowDocumentation.git')
        area=canonical/'.codex-runtime'/'ios-engineering'
        args=install_args(area,area/'skills','reference',source_in_place=True)
        args.codex_home=None
        args.portable_area=str(area)
        args.canonical_repository_root=str(canonical)
        args.allow_canonical_repository_runtime=True
        I.apply_deployment_profile(args)
        pre=I.build_preflight(args,False)
        self.assertEqual(pre['collisions'],[],pre['collisions'])
        self.assertEqual(pre['deployment_profile'],I.CANONICAL_REPOSITORY_RUNTIME_PROFILE)
        manual=load('review_manual_canonical_runtime',ROOT/'MANUAL_SHIM/bin/manual_preflight.py')
        manual_collisions=manual.destination_layout_collisions(
            {'codex_home':area,'shim_root':area/'ios-engineering-shim',
             'state_root':area/'ios-engineering-state','skills_root':area/'skills',
             'agents_file':area/'AGENTS.md'}, ROOT,
            canonical_repository_root=canonical,
            allow_canonical_repository_runtime=True)
        self.assertEqual(manual_collisions,[],manual_collisions)
        args.preflight_id=pre['preflight_id']
        reg=I.apply_fresh(pre,args)
        self.assertEqual(reg['deployment_profile'],I.CANONICAL_REPOSITORY_RUNTIME_PROFILE)
        self.assertEqual(Path(reg['canonical_repository_root']),canonical)
        self.assertEqual(U.preflight(area)[1],[])
        old, sync_pre=S.preflight(area)
        self.assertEqual(sync_pre['collisions'],[],sync_pre['collisions'])
        self.assertEqual((canonical/'AGENTS.md').exists(),False)
        self.assertTrue((area/I.REGISTRY_NAME).exists())

    def test_F14_canonical_repository_runtime_rejects_wrong_origin_or_subtree(self):
        canonical=init_repo(self.td/'canonical-docs-reject')
        git(canonical,'remote','add','origin','https://github.com/example/not-the-canonical-repo.git')
        area=canonical/'.codex-runtime'/'ios-engineering'
        targets={'codex_home':area,'shim_root':area/'ios-engineering-shim',
                 'state_root':area/'ios-engineering-state','agents_file':area/'AGENTS.md'}
        wrong_origin=I.destination_layout_collisions(
            targets,source_root=ROOT,source_in_place=True,
            canonical_repository_root=canonical,
            allow_canonical_repository_runtime=True)
        self.assertTrue(any('origin is not MArtem/AIZenflowDocumentation' in x for x in wrong_origin))
        git(canonical,'remote','set-url','origin','https://github.com/MArtem/AIZenflowDocumentation.git')
        bad_targets=dict(targets); bad_targets['codex_home']=canonical/'.codex-runtime'/'other'
        wrong_subtree=I.destination_layout_collisions(
            bad_targets,source_root=ROOT,source_in_place=True,
            canonical_repository_root=canonical,
            allow_canonical_repository_runtime=True)
        self.assertTrue(any('exact CODEX_HOME' in x for x in wrong_subtree))
        self.assertTrue(any('escapes managed runtime root' in x for x in wrong_subtree))

    def test_F14_manual_env_codex_home_cannot_bypass_client_repository_rejection(self):
        client=init_repo(self.td/'manual-env-client')
        manual=run([sys.executable,ROOT/'MANUAL_SHIM/bin/manual_preflight.py','--release-root',ROOT],
            env=dict(os.environ,CODEX_HOME=str(client)))
        self.assertEqual(manual.returncode,2,manual.stdout+manual.stderr)
        self.assertIn('inside client Git repository',manual.stdout)
        self.assertFalse((client/'ios-engineering-shim').exists())

    def test_F14_manual_preflight_rejects_independent_target_overlap(self):
        home=self.td/'manual-home'; home.mkdir(); (home/'AGENTS.md').write_text('# rules\n')
        state=home/'ios-engineering-shim'/'state'
        p=run([sys.executable,ROOT/'MANUAL_SHIM/bin/manual_preflight.py','--release-root',ROOT,
               '--codex-home',home,'--state-root',state])
        self.assertEqual(p.returncode,2,p.stdout+p.stderr)
        self.assertIn('destination overlap',p.stdout)

    def test_F14_active_agents_override_wins_over_conventional_explicit_path(self):
        override=self.td/'override-home'/'AGENTS.override.md'; override.parent.mkdir()
        override.write_text('# temporary override\n')
        agents=override.parent/'AGENTS.md'; agents.write_text('# base\n')
        args=install_args(override.parent,self.td/'override-skills','reference')
        args.agents_file=str(agents)
        pre=I.build_preflight(args,False)
        self.assertEqual(Path(pre['agents_file']),override)

    def test_F14_unsafe_active_override_does_not_fallback_to_agents(self):
        home=self.td/'unsafe-override-home'; home.mkdir()
        agents=home/'AGENTS.md'; agents.write_text('# base\n')
        override=home/'AGENTS.override.md'; override.write_bytes(b'x'*(I.TEXT_LIMIT+1))
        args=install_args(home,self.td/'unsafe-override-skills','reference')
        args.agents_file=str(agents)
        pre=I.build_preflight(args,False)
        self.assertEqual(Path(pre['agents_file']),override)
        self.assertFalse(pre['agents_file']==str(agents))
        self.assertTrue(any('AGENTS file unreadable' in item for item in pre['collisions']))
        self.assertFalse((home/'ios-engineering-shim').exists())

    def test_F14_manual_unsafe_active_override_does_not_fallback_to_agents(self):
        home=self.td/'manual-unsafe-override-home'; home.mkdir()
        (home/'AGENTS.md').write_text('# base\n')
        override=home/'AGENTS.override.md'; override.write_bytes(b'x'*(2*1024*1024+1))
        p=run([sys.executable,ROOT/'MANUAL_SHIM/bin/manual_preflight.py','--release-root',ROOT,
               '--codex-home',home,'--agents-file',home/'AGENTS.md'])
        self.assertEqual(p.returncode,2,p.stdout+p.stderr)
        data=json.loads(p.stdout)
        self.assertEqual(data['paths']['agents_file'],str(override))
        self.assertTrue(any('AGENTS cannot be read safely' in item for item in data['collisions']))

    def test_F14_installer_fifo_override_is_bounded_and_never_falls_back(self):
        home=self.td/'fifo-installer-home'; home.mkdir(); skills=self.td/'fifo-installer-skills'
        (home/'AGENTS.md').write_text('# conventional fallback must not be selected\n')
        override=home/'AGENTS.override.md'; os.mkfifo(override)
        try:
            p=run_bounded([sys.executable,ROOT/'install_global.py','--codex-home',home,
                           '--skills-root',skills,'--mode','reference','--use-source-in-place','--dry-run'])
            self.assertEqual(p.returncode,3,p.stdout+p.stderr)
            self.assertIn(str(override),p.stdout+p.stderr)
            self.assertFalse((home/'ios-engineering-shim').exists())
            self.assertFalse((home/I.REGISTRY_NAME).exists())
        finally:
            override.unlink(missing_ok=True)

    def test_F14_manual_fifo_override_is_bounded_and_never_falls_back(self):
        home=self.td/'fifo-manual-home'; home.mkdir(); state=self.td/'fifo-manual-state'
        (home/'AGENTS.md').write_text('# conventional fallback must not be selected\n')
        override=home/'AGENTS.override.md'; os.mkfifo(override)
        try:
            p=run_bounded([sys.executable,ROOT/'MANUAL_SHIM/bin/manual_preflight.py',
                           '--release-root',ROOT,'--codex-home',home,'--state-root',state])
            self.assertEqual(p.returncode,2,p.stdout+p.stderr)
            data=json.loads(p.stdout)
            self.assertEqual(Path(data['paths']['agents_file']),override)
            self.assertTrue(any('AGENTS cannot be read safely' in item for item in data['collisions']))
            self.assertFalse((home/'ios-engineering-shim').exists())
            self.assertFalse(state.exists())
        finally:
            override.unlink(missing_ok=True)

    def test_F14_installer_admission_unknown_lifecycle_fails_closed(self):
        session_dir=self.state/'repositories'/'synthetic'/'protection'/'sessions'; session_dir.mkdir(parents=True)
        (session_dir/'unknown.json').write_text(json.dumps({'lifecycle':'mystery'})+'\n')
        with self.assertRaises(I.InstallError) as ctx:
            I.incompatible_active_sessions(self.state,I.PROTECTION_VERSION)
        self.assertIn('unknown protection session lifecycle',str(ctx.exception))

    def test_regression_private_cache_permissions(self):
        dest=self.state/'a'/'value.json'
        P.secure_write(dest,'{}\n')
        self.assertEqual(stat.S_IMODE(os.stat(dest).st_mode),0o600)
        self.assertEqual(stat.S_IMODE(os.stat(dest.parent).st_mode),0o700)
        self.assertEqual(stat.S_IMODE(os.stat(self.state).st_mode),0o700)

    def test_F06_subprocess_timeout_is_nonpass_observation(self):
        b=P.Budget(subprocess_timeout=0.05,total_deadline_seconds=1,max_output_bytes=4096)
        with self.assertRaises(P.ObservationError):
            P._run_bounded(self.repo,[sys.executable,'-c','import time; time.sleep(1)'],b)

    def test_F06_malformed_git_output_is_error(self):
        original=P.git
        P.git=lambda repo,args,budget: b'x'
        try:
            with self.assertRaises(P.ObservationError): P.changed_paths(self.repo,P.Budget())
        finally:
            P.git=original

    def test_regression_preexisting_dirty_user_file_preserved(self):
        (self.repo/'A.swift').write_text('let a = 9\n')
        baseline=P.capture(self.repo)
        (self.repo/'A.swift').write_text('let a = 10\n')
        r=P.compare(self.repo,baseline,{'allow':['A.swift']})
        self.assertFalse(r['ok'])
        self.assertTrue(any('pre-existing dirty path changed' in v for v in r['violations']))

    def test_regression_package_mutation_requires_protected_scope(self):
        (self.repo/'Package.resolved').write_text('{"pins":[]}\n')
        git(self.repo,'add','Package.resolved'); git(self.repo,'commit','-m','package baseline')
        baseline=P.capture(self.repo)
        (self.repo/'Package.resolved').write_text('{"pins":[{"identity":"synthetic"}]}\n')
        r=P.compare(self.repo,baseline,{'allow':['Package.resolved']})
        self.assertFalse(r['ok'])
        self.assertIn('protected path changed without protected scope: Package.resolved',r['violations'])

    def test_regression_project_pbxproj_requires_protected_scope(self):
        pbx=self.repo/'App.xcodeproj/project.pbxproj'; pbx.parent.mkdir(); pbx.write_text('// baseline\n')
        git(self.repo,'add','App.xcodeproj/project.pbxproj'); git(self.repo,'commit','-m','project baseline')
        baseline=P.capture(self.repo)
        pbx.write_text('// changed\n')
        r=P.compare(self.repo,baseline,{'allow':['App.xcodeproj/project.pbxproj']})
        self.assertFalse(r['ok'])
        self.assertIn('protected path changed without protected scope: App.xcodeproj/project.pbxproj',r['violations'])

    def test_regression_context_generation_leaves_client_repo_unchanged(self):
        before_head=git(self.repo,'rev-parse','HEAD').stdout.strip()
        before_status=git(self.repo,'status','--porcelain=v1','--untracked-files=all').stdout
        before={q.relative_to(self.repo).as_posix():hashlib.sha256(q.read_bytes()).hexdigest() for q in self.repo.rglob('*') if q.is_file() and '.git' not in q.parts}
        pr=run([sys.executable,CLI,'--state-root',self.state,'context','--repo',self.repo,'--ensure'])
        self.assertEqual(pr.returncode,0,pr.stderr)
        after_head=git(self.repo,'rev-parse','HEAD').stdout.strip()
        after_status=git(self.repo,'status','--porcelain=v1','--untracked-files=all').stdout
        after={q.relative_to(self.repo).as_posix():hashlib.sha256(q.read_bytes()).hexdigest() for q in self.repo.rglob('*') if q.is_file() and '.git' not in q.parts}
        self.assertEqual((before_head,before_status,before),(after_head,after_status,after))
        self.assertTrue(self.state.exists())

    def test_regression_full_install_validates(self):
        home=self.td/'home'; skills=self.td/'skills'; home.mkdir(); (home/'AGENTS.md').write_text('# synthetic\n')
        fresh_install(home,skills,'full')
        pr=run([sys.executable,ROOT/'validate_global_install.py','--codex-home',home])
        self.assertEqual(pr.returncode,0,pr.stdout+pr.stderr)

    def test_regression_modified_managed_skill_blocks_uninstall(self):
        home=self.td/'home2'; skills=self.td/'skills2'; home.mkdir(); (home/'AGENTS.md').write_text('# synthetic\n')
        reg=fresh_install(home,skills,'full'); name=next(iter(reg['ownership']['skills']))
        target=skills/name/'SKILL.md'; target.write_text(target.read_text()+'\nUSER EDIT\n')
        old_argv=sys.argv[:]
        try:
            sys.argv=['uninstall_global.py','--codex-home',str(home),'--yes']
            with contextlib.redirect_stdout(io.StringIO()): rc=U.main()
        finally: sys.argv=old_argv
        self.assertEqual(rc,2); self.assertIn('USER EDIT',target.read_text()); self.assertTrue((home/I.REGISTRY_NAME).exists())


class FinalCoverageTests(unittest.TestCase):
    def test_F02_permission_failure_is_fail_closed(self):
        td=test_tmpdir()
        try:
            dest=td/'state'/'x.json'; original=P.os.fchmod
            def denied(fd,mode): raise PermissionError('synthetic chmod denial')
            P.os.fchmod=denied
            try:
                with self.assertRaises(P.ProtectionError): P.secure_write(dest,'x')
            finally: P.os.fchmod=original
            self.assertFalse(dest.exists())
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F03_foreign_repository_session_rejected(self):
        td=test_tmpdir()
        try:
            r1=init_repo(td/'r1'); r2=init_repo(td/'r2'); state=td/'state'
            args=types.SimpleNamespace(allow=['A.swift'],allow_dirty=[],allow_protected=[],allow_nested=[],git_transition=[],parallel=False,task='')
            sid=C.begin_session(r1,state,args)['session_id']; data=C.load_session(r1,state,sid)
            with self.assertRaises(C.P.ProtectionError): C.validate_session(data,r2)
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F07_known_executable_surfaces_are_reported_but_never_safe(self):
        td=test_tmpdir()
        try:
            repo=init_repo(td/'repo')
            sch=repo/'App.xcodeproj/xcshareddata/xcschemes/App.xcscheme'; sch.parent.mkdir(parents=True); sch.write_text('<Scheme><BuildAction><PreActions><ExecutionAction/></PreActions></BuildAction></Scheme>')
            (repo/'Package.swift').write_text('// swift-tools-version: 6.0\nlet package = Package(name: "X", targets: [.plugin(name: "BuildPlugin", capability: .buildTool())])\n')
            r=P.scan_build_phases(repo)
            surfaces={x['surface'] for x in r['findings']}
            self.assertIn('PreActions',surfaces); self.assertIn('ExecutionAction',surfaces); self.assertIn('SwiftPM plugin declaration',surfaces)
            self.assertTrue(r['review_required']); self.assertFalse(r['safe_to_assume_read_only'])
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F08_header_and_url_credentials_are_not_retained(self):
        td=test_tmpdir()
        try:
            repo=init_repo(td/'repo',{'README.md':'# commands\n'})
            secret='SYNTHETIC_SECRET_abc123xyz'
            (repo/'README.md').write_text('curl -H "Authorization: Bearer '+secret+'" https://user:'+secret+'@example.invalid/path?token='+secret+'\n')
            m=A.model(repo); blob=json.dumps(m)
            self.assertNotIn(secret,blob); self.assertNotIn('Authorization: Bearer',blob); self.assertIn('authority',blob)
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_F14_reference_mode_does_not_install_bundled_skills(self):
        td=test_tmpdir()
        try:
            home=td/'home'; skills=td/'skills'; home.mkdir(); (home/'AGENTS.md').write_text('# synthetic\n')
            reg=fresh_install(home,skills,'reference')
            self.assertEqual(reg['mode'],'reference'); self.assertEqual(reg['ownership']['skills'],{})
            self.assertFalse(skills.exists() and any(skills.iterdir()))
        finally: shutil.rmtree(td,ignore_errors=True)

    def test_K05_provenance_and_authority_manifest(self):
        m=json.loads((ROOT/'GLOBAL_MANIFEST.json').read_text())
        self.assertEqual(m['reviewed_baseline']['sha256'],'6d02d35f7cdcc1566250ba0960619b2e681e7a967ce9dea3eae0e3a8df864e16')
        self.assertEqual(m['origin_baseline']['sha256'],'6f9e747403475f7be180d4fce6af2334a1b31445e90efa596f72f4701aa89be2')
        self.assertEqual(m['independent_review']['finding_ids'],['A53-01'])
        self.assertEqual(m['runtime']['session_schema'],3)
        self.assertFalse(m['authority_model']['knowledge_is_permission_authority'])
        self.assertTrue(m['authority_model']['repository_derived_commands_are_data_only'])
        self.assertEqual(m['final_archive_sha256'],'external_delivery_value')

class V51AcceptanceTests(unittest.TestCase):
    def setUp(self):
        self.td=test_tmpdir()
        self.repo=init_repo(self.td/'repo')
        self.state=self.td/'state'
    def tearDown(self):
        shutil.rmtree(self.td,ignore_errors=True)
    def args(self,allow=None,allow_dirty=None,allow_protected=None,allow_nested=None,transitions=None,parallel=False,task=''):
        return types.SimpleNamespace(allow=allow or [],allow_dirty=allow_dirty or [],allow_protected=allow_protected or [],allow_nested=allow_nested or [],git_transition=transitions or [],parallel=parallel,task=task)
    def begin(self,**kwargs): return C.begin_session(self.repo,self.state,self.args(**kwargs))['session_id']

    def _make_mm(self,path='B.swift'):
        target=self.repo/path
        target.write_text('let value = 2\n'); git(self.repo,'add',path)
        target.write_text('let value = 3\n')
        self.assertIn('MM',git(self.repo,'status','--porcelain=v1',path).stdout)

    def _replace_index_blob(self,path='B.swift',content='let value = 4\n',mode='100644'):
        blob=self.td/'replacement.blob'; blob.write_text(content)
        oid=git(self.repo,'hash-object','-w',str(blob)).stdout.strip()
        git(self.repo,'update-index','--cacheinfo',mode,oid,path)

    def test_V51_01_stage_does_not_waive_dirty_scope_for_existing_mm_blob(self):
        self._make_mm('B.swift')
        baseline=P.capture(self.repo)
        self._replace_index_blob('B.swift')
        r=P.compare(self.repo,baseline,{'allow':['A.swift'],'git_transitions':['stage']})
        self.assertFalse(r['ok'])
        self.assertIn('semantic Git index path outside declared dirty scope: B.swift',r['violations'])

    def test_V51_01_existing_mm_blob_allowed_only_with_explicit_dirty_scope(self):
        self._make_mm('B.swift')
        baseline=P.capture(self.repo)
        self._replace_index_blob('B.swift')
        r=P.compare(self.repo,baseline,{'allow_dirty':['B.swift'],'git_transitions':['stage']})
        self.assertTrue(r['ok'],r)

    def test_V51_01_staged_removal_requires_dirty_scope(self):
        (self.repo/'B.swift').write_text('let value = 2\n'); git(self.repo,'add','B.swift')
        baseline=P.capture(self.repo)
        git(self.repo,'reset','HEAD','--','B.swift')
        r=P.compare(self.repo,baseline,{'git_transitions':['stage']})
        self.assertFalse(r['ok'])
        self.assertIn('semantic Git index path outside declared dirty scope: B.swift',r['violations'])

    def test_V51_01_staged_mode_change_requires_dirty_scope(self):
        (self.repo/'B.swift').write_text('let value = 2\n'); git(self.repo,'add','B.swift')
        baseline=P.capture(self.repo)
        git(self.repo,'update-index','--chmod=+x','B.swift')
        r=P.compare(self.repo,baseline,{'git_transitions':['stage']})
        self.assertFalse(r['ok'])
        self.assertIn('semantic Git index path outside declared dirty scope: B.swift',r['violations'])

    def test_V51_01_stage_and_commit_inside_scope_remain_valid(self):
        baseline=P.capture(self.repo)
        (self.repo/'A.swift').write_text('let a = 42\n'); git(self.repo,'add','A.swift'); git(self.repo,'commit','-m','allowed stage+commit')
        r=P.compare(self.repo,baseline,{'allow':['A.swift'],'git_transitions':['stage','commit']})
        self.assertTrue(r['ok'],r)

    def test_V51_02_repeated_partial_ensure_never_becomes_fresh(self):
        (self.repo/'Deep').mkdir(); (self.repo/'Deep'/'X.swift').write_text('let x = 1\n')
        base=[sys.executable,CLI,'--state-root',str(self.state),'context','--repo',str(self.repo),'--ensure','--max-depth','0']
        p1=run(base); p2=run(base)
        self.assertNotEqual(p1.returncode,0,p1.stdout+p1.stderr)
        self.assertNotEqual(p2.returncode,0,p2.stdout+p2.stderr)
        d1=json.loads(p1.stdout); d2=json.loads(p2.stdout)
        self.assertTrue(d1['partial']); self.assertFalse(d1['fresh'])
        self.assertTrue(d2['partial']); self.assertFalse(d2['fresh'])
        self.assertTrue(d2.get('stable_partial')); self.assertFalse(d2.get('refresh_required'))
        p3=run([sys.executable,CLI,'--state-root',str(self.state),'context','--repo',str(self.repo),'--ensure','--max-depth','40'])
        self.assertEqual(p3.returncode,0,p3.stdout+p3.stderr)
        self.assertTrue(json.loads(p3.stdout)['fresh'])

    def test_V51_03_nested_protected_basenames_and_mixed_separators(self):
        positives=['Info.plist','App/Info.plist','Modules/Core/Package.swift','App/PrivacyInfo.xcprivacy','Config/Debug.xcconfig','Config\\Prod.entitlements']
        for value in positives:
            with self.subTest(value=value): self.assertTrue(P.protected(value))
        for value in ['App/NotInfo.plist','Modules/Core/Package.swift.bak','Docs/scripts.md','PrivacyInfo.xcprivacy.txt']:
            with self.subTest(value=value): self.assertFalse(P.protected(value))

    def test_V51_03_nested_protected_file_requires_protected_scope(self):
        target=self.repo/'App'/'Info.plist'; target.parent.mkdir(); target.write_text('<plist/>\n')
        git(self.repo,'add','App/Info.plist'); git(self.repo,'commit','-m','nested config')
        baseline=P.capture(self.repo); target.write_text('<plist><dict/></plist>\n')
        r=P.compare(self.repo,baseline,{'allow':['App/Info.plist']})
        self.assertFalse(r['ok']); self.assertIn('protected path changed without protected scope: App/Info.plist',r['violations'])

    def test_V51_04_relative_fake_git_and_pwd_are_never_green(self):
        for cmd in ['./untrusted/git status','./untrusted/pwd']:
            with self.subTest(cmd=cmd): self.assertNotEqual(P.command_guard(cmd)['classification'],'ALLOW_READ_ONLY')

    def test_V51_04_path_spoof_is_never_green(self):
        bindir=self.td/'bin'; bindir.mkdir()
        fake=bindir/'git'; fake.write_text('#!/bin/sh\nexit 0\n'); fake.chmod(0o755)
        old=os.environ.get('PATH','')
        try:
            os.environ['PATH']=str(bindir)+os.pathsep+old
            r=P.command_guard('git status')
        finally: os.environ['PATH']=old
        self.assertNotEqual(r['classification'],'ALLOW_READ_ONLY'); self.assertEqual(r['reason_code'],'EXECUTABLE_IDENTITY_UNTRUSTED')

    def test_V51_04_explicit_trusted_system_git_is_green_when_available(self):
        system=Path('/usr/bin/git')
        if not system.exists(): self.skipTest('/usr/bin/git unavailable on this platform')
        r=P.command_guard('/usr/bin/git status')
        self.assertEqual(r['classification'],'ALLOW_READ_ONLY',r)

    def test_V51_05_reason_never_retains_unknown_tokens(self):
        secrets=['SYNTHETIC_OPTION_SECRET_DEMO','SYNTHETIC_SUBCOMMAND_SECRET_DEMO','SYNTHETIC_EXECUTABLE_SECRET_DEMO','SYNTHETIC_PARSE_SECRET_DEMO']
        commands=[
            'git --'+secrets[0]+'=demo status',
            'git '+secrets[1],
            secrets[2],
            "git '"+secrets[3],
        ]
        for cmd,secret in zip(commands,secrets):
            with self.subTest(cmd=cmd):
                blob=json.dumps(P.command_guard(cmd),sort_keys=True)
                self.assertNotIn(secret,blob)

    def test_V51_06_same_worktree_parallel_writer_is_rejected(self):
        C.begin_session(self.repo,self.state,self.args(allow=['A.swift']))
        with self.assertRaises(C.P.ProtectionError): C.begin_session(self.repo,self.state,self.args(allow=['B.swift'],parallel=True))

    def test_V51_06_parallel_flag_is_rejected_even_for_first_writer(self):
        with self.assertRaises(C.P.ProtectionError):
            C.begin_session(self.repo,self.state,self.args(allow=['A.swift'],parallel=True))
        self.assertEqual(C.active_sessions(self.repo,self.state),[])

    def test_V51_06_concurrent_begin_has_single_winner(self):
        cmd=[sys.executable,CLI,'--state-root',str(self.state),'protect','begin','--repo',str(self.repo),'--allow','A.swift']
        p1=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
        p2=subprocess.Popen(cmd[:-1]+['B.swift'],stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
        o1,e1=p1.communicate(timeout=20); o2,e2=p2.communicate(timeout=20)
        codes=[p1.returncode,p2.returncode]
        self.assertEqual(codes.count(0),1,(codes,o1,e1,o2,e2))
        self.assertEqual(len(C.active_sessions(self.repo,self.state)),1)

    def test_V51_06_close_releases_writer_slot(self):
        first=C.begin_session(self.repo,self.state,self.args(allow=['A.swift']))['session_id']
        closed=C.close_session(self.repo,self.state,first); self.assertTrue(closed['ok'],closed)
        second=C.begin_session(self.repo,self.state,self.args(allow=['B.swift']))['session_id']
        self.assertNotEqual(first,second)

    def test_V51_06_independent_repositories_have_independent_writer_slots(self):
        other=init_repo(self.td/'repo2')
        s1=C.begin_session(self.repo,self.state,self.args(allow=['A.swift']))
        s2=C.begin_session(other,self.state,self.args(allow=['A.swift']))
        self.assertNotEqual(s1['session_id'],s2['session_id'])
        (self.repo/'A.swift').write_text('let a = 10\n'); (other/'A.swift').write_text('let a = 11\n')
        self.assertTrue(C.verify_session(self.repo,self.state,s1['session_id'])['ok'])
        self.assertTrue(C.verify_session(other,self.state,s2['session_id'])['ok'])

    def test_V51_06_policy_docs_match_one_writer_contract(self):
        global_block=(ROOT/'GLOBAL_CODEX/AGENTS.global.block.md').read_text()
        quick=(ROOT/'QUICKSTART.md').read_text()
        self.assertIn('one writer session per Git common directory',global_block)
        self.assertIn('linked worktrees share that writer slot',global_block)
        self.assertNotIn('parallel sessions require explicit `--parallel`',global_block)
        self.assertIn('declared-policy --repo .',quick)
        self.assertNotIn('effective-policy --repo .',quick)

    def test_V51_06_parallel_cli_flag_is_not_exposed(self):
        parser=C.make_parser()
        with contextlib.redirect_stderr(io.StringIO()):
            with self.assertRaises(SystemExit):
                parser.parse_args(['protect','begin','--parallel'])

    def test_V51_declared_policy_does_not_claim_effective_resolution(self):
        pr=run([sys.executable,CLI,'--state-root',str(self.state),'declared-policy','--repo',str(self.repo)])
        self.assertEqual(pr.returncode,0,pr.stdout+pr.stderr)
        data=json.loads(pr.stdout); self.assertEqual(data['report_kind'],'declared_policy_not_effective_resolution')

    def test_V51_no_install_project_reference_workflow_is_explicit(self):
        text=(ROOT/'PROJECT_REFERENCE_OPT_IN.md').read_text()
        self.assertIn('without installing runtime, skills, or a global AGENTS block',text)
        self.assertIn('Do not run `install_global.py`',text)
        self.assertIn('advisory knowledge',text)

    def test_V51_07_total_deadline_cleans_owned_child(self):
        captured={}
        original=P.subprocess.Popen
        def recording_popen(*args,**kwargs):
            proc=original(*args,**kwargs)
            captured['pid']=proc.pid
            return proc
        P.subprocess.Popen=recording_popen
        try:
            b=P.Budget(subprocess_timeout=5,total_deadline_seconds=0.35,max_output_bytes=4096)
            with self.assertRaises(P.ObservationError):
                P._run_bounded(self.repo,[sys.executable,'-c','import time; time.sleep(5)'],b)
        finally:
            P.subprocess.Popen=original
        self.assertIn('pid',captured)
        with self.assertRaises(ProcessLookupError):
            os.kill(captured['pid'],0)

    def _pid_alive(self,pid):
        try:
            os.kill(pid,0); return True
        except ProcessLookupError:
            return False

    def _wait_pid_gone(self,pid,timeout=2.0):
        end=time.monotonic()+timeout
        while time.monotonic()<end:
            if not self._pid_alive(pid): return True
            time.sleep(0.02)
        return not self._pid_alive(pid)

    @unittest.skipUnless(os.name=='posix','POSIX process-group contract')
    def test_A52_01_silent_grandchild_inherited_pipes_is_bounded_and_killed(self):
        pidfile=self.td/'grandchild.pid'
        shell=f"sleep 5 & echo $! > {str(pidfile)!r}; exit 0"
        b=P.Budget(subprocess_timeout=1.5,total_deadline_seconds=2.5,max_output_bytes=4096)
        started=time.monotonic()
        try:
            with self.assertRaises(P.ObservationError):
                P._run_bounded(self.repo,['/bin/sh','-c',shell],b)
        finally:
            elapsed=time.monotonic()-started
        self.assertLess(elapsed,3.0,elapsed)
        self.assertTrue(pidfile.exists())
        pid=int(pidfile.read_text())
        try:
            self.assertTrue(self._wait_pid_gone(pid),f'grandchild still alive: {pid}')
        finally:
            if self._pid_alive(pid):
                try: os.kill(pid,9)
                except ProcessLookupError: pass

    @unittest.skipUnless(os.name=='posix','POSIX process-group contract')
    def test_A52_01_closed_pipes_do_not_allow_background_grandchild_to_escape(self):
        pidfile=self.td/'grandchild-closed.pid'
        shell=f"sleep 5 >/dev/null 2>&1 & echo $! > {str(pidfile)!r}; exit 0"
        rc,_,_=P._run_bounded(self.repo,['/bin/sh','-c',shell],P.Budget(subprocess_timeout=1.5,total_deadline_seconds=2.5,max_output_bytes=4096))
        self.assertEqual(rc,0)
        self.assertTrue(pidfile.exists())
        pid=int(pidfile.read_text())
        try:
            self.assertTrue(self._wait_pid_gone(pid),f'background grandchild still alive: {pid}')
        finally:
            if self._pid_alive(pid):
                try: os.kill(pid,9)
                except ProcessLookupError: pass

    @unittest.skipUnless(os.name=='posix','POSIX process-group contract')
    def test_A52_01_pipe_read_error_still_cleans_owned_child(self):
        captured={}; original_popen=P.subprocess.Popen; original_read=P.os.read
        def recording_popen(*args,**kwargs):
            proc=original_popen(*args,**kwargs); captured['pid']=proc.pid; captured['pipe_fds']=tuple(x.fileno() for x in (proc.stdout,proc.stderr) if x is not None); return proc
        def broken_read(fd,n):
            if fd in captured.get('pipe_fds',()): raise OSError('synthetic pipe read failure')
            return original_read(fd,n)
        P.subprocess.Popen=recording_popen; P.os.read=broken_read
        try:
            with self.assertRaises(P.ObservationError):
                P._run_bounded(self.repo,[sys.executable,'-c',"import sys,time; print('x',flush=True); time.sleep(3)"],P.Budget(subprocess_timeout=1,total_deadline_seconds=2))
        finally:
            P.subprocess.Popen=original_popen; P.os.read=original_read
        self.assertIn('pid',captured)
        self.assertTrue(self._wait_pid_gone(captured['pid']))

    def test_A52_02_verify_close_interleaving_cannot_resurrect_closed_session(self):
        sid=self.begin(allow=['A.swift'])
        original=C.P.compare; entered=threading.Event(); release=threading.Event(); count={'n':0}; count_lock=threading.Lock()
        def controlled(*args,**kwargs):
            with count_lock:
                count['n']+=1; n=count['n']
            if n==1:
                entered.set(); self.assertTrue(release.wait(5),'verify barrier timed out')
            return original(*args,**kwargs)
        C.P.compare=controlled; results={}
        try:
            tv=threading.Thread(target=lambda: results.setdefault('verify',C.verify_session(self.repo,self.state,sid,True)),daemon=True)
            tc=threading.Thread(target=lambda: results.setdefault('close',C.close_session(self.repo,self.state,sid)),daemon=True)
            tv.start(); self.assertTrue(entered.wait(5)); tc.start(); time.sleep(0.15)
            self.assertTrue(tc.is_alive(),'close should wait for the serialized verify lifecycle transition')
            release.set(); tv.join(5); tc.join(5)
            self.assertFalse(tv.is_alive()); self.assertFalse(tc.is_alive())
        finally:
            release.set(); C.P.compare=original
        session=C.load_session(self.repo,self.state,sid)
        self.assertEqual(session['lifecycle'],'closed')
        events=[x['event'] for x in session['audit']]
        self.assertIn('close',events); self.assertGreaterEqual(events.count('verify'),2)
        replacement=C.begin_session(self.repo,self.state,self.args(allow=['B.swift']))
        self.assertNotEqual(replacement['session_id'],sid)
        self.assertEqual(C.load_session(self.repo,self.state,sid)['lifecycle'],'closed')

    def test_A52_02_two_concurrent_verifies_preserve_both_audit_records(self):
        sid=self.begin(allow=['A.swift'])
        original=C.P.compare; entered=threading.Event(); release=threading.Event(); calls={'n':0}; guard=threading.Lock()
        def controlled(*args,**kwargs):
            with guard:
                calls['n']+=1; n=calls['n']
            if n==1:
                entered.set(); self.assertTrue(release.wait(5))
            return original(*args,**kwargs)
        C.P.compare=controlled; results=[]
        try:
            t1=threading.Thread(target=lambda: results.append(C.verify_session(self.repo,self.state,sid,True)),daemon=True)
            t2=threading.Thread(target=lambda: results.append(C.verify_session(self.repo,self.state,sid,True)),daemon=True)
            t1.start(); self.assertTrue(entered.wait(5)); t2.start(); time.sleep(0.15)
            self.assertEqual(calls['n'],1,'second verify entered compare before lifecycle lock released')
            release.set(); t1.join(5); t2.join(5)
        finally:
            release.set(); C.P.compare=original
        self.assertEqual(len(results),2); self.assertTrue(all(r['ok'] for r in results))
        session=C.load_session(self.repo,self.state,sid)
        self.assertEqual(sum(1 for x in session['audit'] if x.get('event')=='verify'),2)

    def test_A52_03_real_linked_worktree_shares_writer_slot(self):
        git(self.repo,'branch','linked-b')
        linked=self.td/'linked-b'; git(self.repo,'worktree','add','-q',str(linked),'linked-b')
        id_main=P.repository_identity(self.repo,P.Budget()); id_link=P.repository_identity(linked,P.Budget())
        self.assertEqual(id_main['git_common_dir'],id_link['git_common_dir'])
        sid=C.begin_session(self.repo,self.state,self.args(allow=['A.swift']))['session_id']
        with self.assertRaises(C.P.ProtectionError):
            C.begin_session(linked,self.state,self.args(allow=['B.swift']))
        self.assertTrue(C.close_session(self.repo,self.state,sid)['ok'])
        linked_sid=C.begin_session(linked,self.state,self.args(allow=['B.swift']))['session_id']
        self.assertTrue(C.close_session(linked,self.state,linked_sid)['ok'])

    def test_A52_03_shared_third_party_ref_mutation_is_still_detected(self):
        git(self.repo,'branch','linked-c')
        linked=self.td/'linked-c'; git(self.repo,'worktree','add','-q',str(linked),'linked-c')
        sid=C.begin_session(linked,self.state,self.args(allow=['A.swift'],transitions=['commit']))['session_id']
        git(self.repo,'branch','third-party-ref')
        r=C.verify_session(linked,self.state,sid,True)
        self.assertFalse(r['ok']); self.assertTrue(any('Git ref changed' in x for x in r['violations']),r)

    def test_V51_08_protection_walk_error_is_nonpass(self):
        blocked=self.repo/'Blocked'; blocked.mkdir()
        real=P.os.scandir
        def denied(path):
            if not isinstance(path,int) and Path(path).name=='Blocked': raise PermissionError('synthetic')
            return real(path)
        P.os.scandir=denied
        try:
            with self.assertRaises(P.ObservationError): P.capture(self.repo)
        finally: P.os.scandir=real

    def test_V51_08_build_scan_walk_error_is_incomplete(self):
        blocked=self.repo/'Blocked'; blocked.mkdir()
        real=P.os.scandir
        def denied(path):
            if not isinstance(path,int) and Path(path).name=='Blocked': raise PermissionError('synthetic')
            return real(path)
        P.os.scandir=denied
        try: result=P.scan_build_phases(self.repo)
        finally: P.os.scandir=real
        self.assertEqual(result['status'],'incomplete'); self.assertTrue(result['errors'])

    def test_V51_08_adapter_walk_error_is_partial(self):
        blocked=self.repo/'Blocked'; blocked.mkdir(); (blocked/'Secret.swift').write_text('let hidden = 1\n')
        real=A.os.scandir
        def denied(path):
            if not isinstance(path,int) and Path(path).name=='Blocked': raise PermissionError('synthetic')
            return real(path)
        A.os.scandir=denied
        try: model=A.model(self.repo)
        finally: A.os.scandir=real
        self.assertTrue(model['meta']['partial']); self.assertFalse(model['freshness']['complete'])
        self.assertTrue(any(x['kind']=='walk_error' for x in model['meta']['limitations']))
        self.assertNotIn('Blocked/Secret.swift',json.dumps(model))

    def test_V51_08_installer_package_walk_error_fails_closed(self):
        real=I.os.scandir
        def denied(path):
            if not isinstance(path,int) and Path(path).name=='31_DEEP_PLAYBOOKS': raise PermissionError('synthetic')
            return real(path)
        I.os.scandir=denied
        try:
            with self.assertRaises(I.InstallError): I._package_rows(ROOT)
        finally: I.os.scandir=real

    def test_V51_08_installer_managed_tree_walk_error_fails_closed(self):
        managed=self.td/'managed'; blocked=managed/'Blocked'; blocked.mkdir(parents=True); (blocked/'x.txt').write_text('x')
        real=I.os.scandir
        def denied(path):
            if not isinstance(path,int) and Path(path).name=='Blocked': raise PermissionError('synthetic')
            return real(path)
        I.os.scandir=denied
        try:
            with self.assertRaises(I.InstallError): I.managed_hashes(managed)
        finally: I.os.scandir=real

    def test_V51_08_global_install_validator_walk_error_is_error(self):
        managed=self.td/'validator-managed'; blocked=managed/'Blocked'; blocked.mkdir(parents=True); (blocked/'x.txt').write_text('x')
        errs=[]; real=V.os.scandir
        def denied(path):
            if not isinstance(path,int) and Path(path).name=='Blocked': raise PermissionError('synthetic')
            return real(path)
        V.os.scandir=denied
        try: V.check_tree(managed,{},'synthetic',errs)
        finally: V.os.scandir=real
        self.assertTrue(any('directory walk failed' in e for e in errs),errs)

if __name__=='__main__': unittest.main(verbosity=2)
