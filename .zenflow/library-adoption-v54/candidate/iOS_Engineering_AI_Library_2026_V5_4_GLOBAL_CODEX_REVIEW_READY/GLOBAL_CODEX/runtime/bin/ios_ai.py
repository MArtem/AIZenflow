#!/usr/bin/env python3
from __future__ import annotations
import argparse, contextlib, datetime as dt, hashlib, importlib.util, json, os, stat, sys, time, uuid
from pathlib import Path
sys.dont_write_bytecode=True

RUNTIME=Path(__file__).resolve().parents[1]
LIBRARY=Path(os.environ.get('IOS_ENGINEERING_LIBRARY_ROOT',str(RUNTIME.parent.parent))).expanduser().resolve()
DEFAULT_STATE=Path(os.environ.get('IOS_ENGINEERING_STATE_ROOT',str(Path(os.environ.get('CODEX_HOME',str(Path.home()/'.codex'))).expanduser()/'ios-engineering-state'))).expanduser()
CLI_VERSION='5.4-review-ready.6'
SESSION_SCHEMA=3
LEGACY_SCAN_MAX_REPOSITORIES=10_000
LEGACY_SCAN_MAX_SESSION_RECORDS=10_000
LEGACY_SCAN_MAX_FILE_BYTES=4*1024*1024
LEGACY_SCAN_MAX_BYTES=32*1024*1024
LEGACY_SCAN_DEADLINE_SECONDS=10.0
try:
    import fcntl
except ImportError:
    fcntl=None


def load_module(name,path):
    spec=importlib.util.spec_from_file_location(name,path); mod=importlib.util.module_from_spec(spec); assert spec and spec.loader; sys.modules[name]=mod; spec.loader.exec_module(mod); return mod
P=load_module('ioslib_protection',RUNTIME/'protection'/'protection.py')
A=load_module('ioslib_adapt',RUNTIME/'vendor'/'adapt_project.py')
K=load_module('ioslib_knowledge_profile',RUNTIME/'knowledge_profile.py')


def utcnow(): return dt.datetime.now(dt.timezone.utc).isoformat()
def jhash(obj): return hashlib.sha256(json.dumps(obj,sort_keys=True,separators=(',',':'),ensure_ascii=False).encode()).hexdigest()
def state_key(repo:Path): return hashlib.sha256(str(repo.resolve()).encode()).hexdigest()[:24]

def repo_state_dir(repo:Path,state_root:Path,create=True)->Path:
    root=state_root/'repositories'/state_key(repo)
    if create:
        P.secure_dir(root)
        marker=root/'REPOSITORY.json'
        expected={'schema_version':1,'state_key':state_key(repo),'repository_path_sha256':hashlib.sha256(str(repo.resolve()).encode()).hexdigest()}
        if marker.exists():
            current=P.load_json(marker)
            if current!=expected: raise P.ProtectionError('repository state marker mismatch')
        else: P.save_json(marker,expected)
    return root

def sessions_dir(repo,state_root):
    p=repo_state_dir(repo,state_root)/'protection'/'sessions'; P.secure_dir(p); return p

def _writer_group_identity(repo: Path) -> tuple[str,str]:
    identity=P.repository_identity(repo,P.Budget())
    common=str(Path(identity['git_common_dir']).resolve())
    return common, hashlib.sha256(common.encode()).hexdigest()

def writer_group_dir(repo,state_root):
    common, full_hash=_writer_group_identity(Path(repo))
    root=Path(state_root)/'writer-groups'/full_hash[:24]
    P.secure_dir(root)
    marker=root/'GIT_COMMON_DIR.json'
    expected={'schema_version':1,'git_common_dir_sha256':full_hash}
    if os.path.lexists(marker):
        if P.load_json(marker)!=expected: raise P.ProtectionError('writer-group marker mismatch')
    else:
        P.save_json(marker,expected)
    return root

def writer_lease_path(repo,state_root): return writer_group_dir(repo,state_root)/'ACTIVE_WRITER.json'

def _load_writer_lease_locked(repo,state_root):
    path=writer_lease_path(repo,state_root)
    if not os.path.lexists(path): return None
    lease=P.load_json(path)
    required={'schema_version','status','session_id','repository_state_key','git_common_dir_sha256'}
    if not isinstance(lease,dict) or not required.issubset(lease) or lease['schema_version']!=1 or lease['status'] not in {'active','released'}:
        raise P.ProtectionError('malformed writer-group lease')
    try: canonical=str(uuid.UUID(str(lease['session_id'])))
    except (ValueError, TypeError, AttributeError) as e: raise P.ProtectionError('writer lease contains invalid session id') from e
    if str(lease['session_id']).lower()!=canonical:
        raise P.ProtectionError('writer lease session id is not canonical')
    state_key_value=lease['repository_state_key']
    if not isinstance(state_key_value,str) or len(state_key_value)!=24 or any(c not in '0123456789abcdef' for c in state_key_value):
        raise P.ProtectionError('writer lease contains invalid repository state key')
    _, expected_hash=_writer_group_identity(Path(repo))
    if lease['git_common_dir_sha256']!=expected_hash:
        raise P.ProtectionError('foreign writer-group lease')
    return None if lease['status']=='released' else lease

def _write_writer_lease_locked(repo,state_root,sid,status):
    _, common_hash=_writer_group_identity(Path(repo))
    data={'schema_version':1,'status':status,'session_id':sid,'repository_state_key':state_key(Path(repo)),'git_common_dir_sha256':common_hash}
    if status=='active': data['acquired_at']=utcnow()
    else: data['released_at']=utcnow()
    P.save_json(writer_lease_path(repo,state_root),data)

def _assert_writer_lease_locked(repo,state_root,sid):
    lease=_load_writer_lease_locked(repo,state_root)
    if lease is None or lease.get('session_id')!=sid or lease.get('repository_state_key')!=state_key(Path(repo)):
        raise P.ProtectionError('session does not own the Git common-dir writer lease')
    return lease

@contextlib.contextmanager
def session_registry_lock(repo,state_root):
    if fcntl is None:
        raise P.ProtectionError('writer serialization requires POSIX flock support')
    d=writer_group_dir(Path(repo),state_root)
    path=d/'WRITER.lock'
    flags=os.O_RDWR | os.O_CREAT | getattr(os,'O_NOFOLLOW',0)
    fd=os.open(path,flags,0o600)
    try:
        os.fchmod(fd,0o600)
        st=os.fstat(fd)
        if not __import__('stat').S_ISREG(st.st_mode):
            raise P.ProtectionError('writer lock is not a regular file')
        fcntl.flock(fd,fcntl.LOCK_EX)
        try: yield
        finally: fcntl.flock(fd,fcntl.LOCK_UN)
    finally:
        os.close(fd)

def session_path(repo,state_root,sid):
    try:
        parsed=uuid.UUID(str(sid))
    except (ValueError, TypeError, AttributeError) as e:
        raise P.ProtectionError('invalid session id') from e
    canonical=str(parsed)
    if str(sid).lower() != canonical:
        raise P.ProtectionError('session id must use canonical UUID form')
    return sessions_dir(repo,state_root)/(canonical+'.json')

def _canonical_session_id(value):
    try:
        canonical=str(uuid.UUID(str(value)))
    except (ValueError, TypeError, AttributeError) as e:
        raise P.ProtectionError('invalid session id in protection session') from e
    if str(value).lower()!=canonical:
        raise P.ProtectionError('session id in protection session must use canonical UUID form')
    return canonical

def _validate_session_record(data,repo,*,allow_legacy_closed=True,allow_legacy_active=False):
    req={'schema_version','session_id','lifecycle','created_at','baseline','baseline_sha256','scope','audit'}
    if not isinstance(data,dict) or not req.issubset(data): raise P.ProtectionError('malformed/incomplete protection session')
    schema=data.get('schema_version')
    lifecycle=data.get('lifecycle')
    _canonical_session_id(data.get('session_id'))
    if lifecycle not in {'active','verified','closed'}: raise P.ProtectionError('invalid protection session lifecycle')
    if not isinstance(data.get('baseline'),dict) or not isinstance(data.get('scope'),dict) or not isinstance(data.get('audit'),list):
        raise P.ProtectionError('malformed protection session payload')
    if jhash(data['baseline'])!=data['baseline_sha256']: raise P.ProtectionError('immutable baseline hash mismatch')
    identity=data['baseline'].get('repository_identity')
    if not isinstance(identity,dict) or identity.get('worktree')!=str(repo.resolve()): raise P.ProtectionError('foreign repository session')
    if schema==SESSION_SCHEMA:
        return data
    if schema==2 and allow_legacy_closed:
        if lifecycle=='closed':
            result=dict(data)
            result['_compatibility']='legacy-v5.2-closed-archival'
            result['_historical_evidence_only']=True
            return result
        if lifecycle in {'active','verified'} and allow_legacy_active:
            result=dict(data)
            result['_compatibility']='legacy-v5.2-writer-blocker'
            return result
        raise P.ProtectionError('legacy V5.2 active/verified session requires explicit recovery before upgrade')
    raise P.ProtectionError('unsupported protection session schema')

def validate_session(data,repo):
    return _validate_session_record(data,repo,allow_legacy_closed=True)

def load_session(repo,state_root,sid):
    s=validate_session(P.load_json(session_path(repo,state_root,sid)),repo)
    if s['session_id']!=str(sid): raise P.ProtectionError('session id/path mismatch')
    return s

def save_session(repo,state_root,data): P.save_json(session_path(repo,state_root,data['session_id']),data)

def _session_summary(s):
    row={'session_id':s['session_id'],'schema_version':s['schema_version'],'lifecycle':s['lifecycle'],'created_at':s['created_at'],'scope':s['scope']}
    if s.get('_compatibility'):
        row.update({'compatibility':s['_compatibility'],'historical_evidence_only':True,'audit':s['audit']})
    return row

def list_sessions(repo,state_root):
    d=sessions_dir(repo,state_root); out=[]
    for p in sorted(d.glob('*.json')):
        try:
            s=validate_session(P.load_json(p),repo)
            if s['session_id']!=p.stem: raise P.ProtectionError('session id/path mismatch')
            out.append(_session_summary(s))
        except Exception as e:
            out.append({'session_id':p.stem,'lifecycle':'invalid','error':type(e).__name__})
    return out

def _scan_legacy_v52_shared_writer_blockers(repo,state_root):
    """Return valid V5.2 active/verified sessions sharing this Git common-dir.

    Closed schema-2 records are archival-only and never writer-admission evidence. Relevant
    malformed/unknown records fail closed. The scan is read-only and intentionally leaves
    historical JSON untouched, making upgrade/recovery idempotent.
    """
    target_common=str(Path(P.repository_identity(Path(repo),P.Budget())['git_common_dir']).resolve())
    repos_root=Path(state_root)/'repositories'
    if not os.path.lexists(repos_root): return []
    if repos_root.is_symlink() or not repos_root.is_dir(): raise P.ProtectionError('invalid repositories state root')
    blockers=[]; started=time.monotonic(); repository_count=0; session_count=0; bytes_read=0
    def check_budget():
        if time.monotonic()-started > LEGACY_SCAN_DEADLINE_SECONDS:
            raise P.ProtectionError('legacy session registry observation deadline exceeded')
        if repository_count > LEGACY_SCAN_MAX_REPOSITORIES:
            raise P.ProtectionError('legacy session registry repository-entry budget exceeded')
        if session_count > LEGACY_SCAN_MAX_SESSION_RECORDS:
            raise P.ProtectionError('legacy session registry record budget exceeded')
        if bytes_read > LEGACY_SCAN_MAX_BYTES:
            raise P.ProtectionError('legacy session registry byte budget exceeded')
    try:
        with os.scandir(repos_root) as repo_entries:
            for entry in repo_entries:
                repository_count += 1; check_budget()
                try:
                    if entry.is_symlink(): raise P.ProtectionError('symlink in repositories state root')
                    if not entry.is_dir(follow_symlinks=False): continue
                except OSError as e:
                    raise P.ProtectionError(f'legacy repository state inspection failed: {type(e).__name__}') from e
                state_name=entry.name
                protection_dir=Path(entry.path)/'protection'
                if os.path.lexists(protection_dir):
                    protection_stat=os.lstat(protection_dir)
                    if stat.S_ISLNK(protection_stat.st_mode) or not stat.S_ISDIR(protection_stat.st_mode):
                        raise P.ProtectionError('invalid legacy protection directory')
                sess=protection_dir/'sessions'
                if not os.path.lexists(sess): continue
                session_stat=os.lstat(sess)
                if stat.S_ISLNK(session_stat.st_mode) or not stat.S_ISDIR(session_stat.st_mode):
                    raise P.ProtectionError('invalid legacy sessions directory')
                try:
                    with os.scandir(sess) as session_entries:
                        for se in session_entries:
                            session_count += 1; check_budget()
                            try:
                                if se.is_symlink(): raise P.ProtectionError('symlink in legacy session registry')
                                if not se.is_file(follow_symlinks=False) or not se.name.endswith('.json'): continue
                            except OSError as e:
                                raise P.ProtectionError(f'legacy session file inspection failed: {type(e).__name__}') from e
                            try:
                                file_stat=se.stat(follow_symlinks=False)
                                size=file_stat.st_size
                            except OSError as e:
                                raise P.ProtectionError(f'legacy session file inspection failed: {type(e).__name__}') from e
                            remaining=LEGACY_SCAN_MAX_BYTES-bytes_read
                            if size > LEGACY_SCAN_MAX_FILE_BYTES:
                                raise P.ProtectionError('legacy session file byte budget exceeded')
                            if size > remaining:
                                raise P.ProtectionError('legacy session registry byte budget exceeded')
                            # The bounded no-follow loader rechecks the opened file's
                            # identity/size and enforces the remaining aggregate budget.
                            # The post-read accounting and deadline check prevent a slow
                            # final record from being returned as a successful observation.
                            expected_identity=(file_stat.st_dev,file_stat.st_ino,file_stat.st_size,file_stat.st_mtime_ns)
                            data=P.secure_read_json(Path(se.path), max_bytes=remaining, expected_identity=expected_identity)
                            bytes_read += size; check_budget()
                            if not isinstance(data,dict):
                                # Only the current worktree can safely attribute a record with no identity.
                                if state_name==state_key(Path(repo)): raise P.ProtectionError('malformed legacy/current session state')
                                continue
                            baseline=data.get('baseline') if isinstance(data.get('baseline'),dict) else {}
                            identity=baseline.get('repository_identity') if isinstance(baseline.get('repository_identity'),dict) else {}
                            common=identity.get('git_common_dir')
                            worktree=identity.get('worktree')
                            relevant=False
                            if isinstance(common,str):
                                try: relevant=str(Path(common).resolve())==target_common
                                except OSError: relevant=False
                            if not relevant:
                                if state_name==state_key(Path(repo)): raise P.ProtectionError('foreign or malformed session state in current repository state directory')
                                continue
                            if not isinstance(worktree,str) or state_key(Path(worktree))!=state_name:
                                raise P.ProtectionError('foreign legacy session repository-state identity')
                            schema=data.get('schema_version')
                            if schema==2:
                                validated=_validate_session_record(data,Path(worktree),allow_legacy_closed=True,allow_legacy_active=True)
                                check_budget()
                                if se.name[:-5]!=validated['session_id']:
                                    raise P.ProtectionError('legacy session id/path mismatch')
                                if validated['lifecycle'] in {'active','verified'}:
                                    blockers.append({'session_id':validated['session_id'],'lifecycle':validated['lifecycle'],'worktree':worktree})
                            elif schema!=SESSION_SCHEMA:
                                raise P.ProtectionError('unknown protection session schema for shared Git common directory')
                except OSError as e:
                    raise P.ProtectionError(f'legacy session registry iteration failed: {type(e).__name__}') from e
    except OSError as e:
        raise P.ProtectionError(f'legacy session registry iteration failed: {type(e).__name__}') from e
    check_budget()
    return blockers

def active_sessions(repo,state_root):
    rows=list_sessions(repo,state_root)
    invalid=[x for x in rows if x.get('lifecycle')=='invalid']
    if invalid: raise P.ProtectionError('invalid protection session state exists; refusing to continue until explicitly resolved')
    return [x for x in rows if x.get('lifecycle') in {'active','verified'}]

def resolve_session_id(repo,state_root,sid):
    if sid: return sid
    active=active_sessions(repo,state_root)
    if len(active)==1: return active[0]['session_id']
    if not active: raise P.ProtectionError('no active protection session')
    raise P.ProtectionError('multiple active sessions; --session is required')

def validate_scope(args):
    for label,vals in [('allow',args.allow),('allow-dirty',args.allow_dirty),('allow-protected',args.allow_protected),('allow-nested',args.allow_nested)]:
        for v in vals:
            try: P.validate_scope_item(v)
            except Exception as e: raise P.ProtectionError(f'invalid --{label}: {v}') from e
    transitions=[]
    for t in args.git_transition:
        if t not in {'stage','commit'}: raise P.ProtectionError(f'unsupported Git transition: {t}')
        if t not in transitions: transitions.append(t)
    return {'allow':args.allow,'allow_dirty':args.allow_dirty,'allow_protected':args.allow_protected,'allow_nested':args.allow_nested,'git_transitions':transitions,
            'task':{'sha256':hashlib.sha256(args.task.encode()).hexdigest(),'length':len(args.task)} if args.task else None}

def begin_session(repo,state_root,args):
    # Contract: at most one writer session per Git common directory. Independent clones/repos
    # can proceed concurrently; linked worktrees share refs/config and therefore share this slot.
    if getattr(args,'parallel',False):
        raise P.ProtectionError('legacy parallel writer request is unsupported; use an independent repository/clone with a different Git common directory')
    with session_registry_lock(repo,state_root):
        legacy_blockers=_scan_legacy_v52_shared_writer_blockers(repo,state_root)
        if legacy_blockers:
            raise P.ProtectionError('legacy V5.2 active/verified writer session shares this Git common directory; close/recover it under V5.2 before upgrade')
        group_lease=_load_writer_lease_locked(repo,state_root)
        if group_lease is not None:
            raise P.ProtectionError('an active/verified writer session already exists for this Git common directory; linked worktrees are serialized')
        current_active=active_sessions(repo,state_root)
        if current_active:
            raise P.ProtectionError('an active/verified writer session already exists in this worktree state')
        scope=validate_scope(args)
        baseline=P.capture(repo)
        sid=str(uuid.uuid4())
        data={'schema_version':SESSION_SCHEMA,'session_id':sid,'lifecycle':'active','created_at':utcnow(),'baseline':baseline,'baseline_sha256':jhash(baseline),'scope':scope,
              'writer_model':'one-writer-per-git-common-dir',
              'audit':[{'at':utcnow(),'event':'begin','scope_sha256':jhash(scope)}]}
        _write_writer_lease_locked(repo,state_root,sid,'active')
        try:
            save_session(repo,state_root,data)
        except Exception:
            try: _write_writer_lease_locked(repo,state_root,sid,'released')
            except Exception: pass
            raise
    return {'ok':True,'session_id':sid,'lifecycle':'active','writer_model':'one-writer-per-git-common-dir','scope':scope,'preexisting_dirty_paths':sorted(baseline['changed_paths']),'nested_repositories':sorted(baseline.get('nested_repositories',{}))}

def _verify_session_locked(repo,state_root,sid,mark=True):
    _assert_writer_lease_locked(repo,state_root,sid)
    s=load_session(repo,state_root,sid)
    if s['lifecycle']=='closed': raise P.ProtectionError('session is closed')
    result=P.compare(repo,s['baseline'],s['scope'])
    if mark:
        # Reloading is unnecessary while holding the common-dir lifecycle lock; no other library
        # lifecycle transition can update this session until this save completes.
        if result['ok']:
            s['lifecycle']='verified'; s['last_verified_at']=utcnow(); s['audit'].append({'at':utcnow(),'event':'verify','result':'PASS'})
        else:
            s['audit'].append({'at':utcnow(),'event':'verify','result':result['status'],'violations_sha256':jhash(result.get('violations',[]))})
        save_session(repo,state_root,s)
    return result

def verify_session(repo,state_root,sid,mark=True):
    # Lifecycle load/compare/audit/save is one serialized transition. This lock does not freeze
    # arbitrary external source mutations; compare remains a before/after observer.
    with session_registry_lock(repo,state_root):
        return _verify_session_locked(repo,state_root,sid,mark)

def close_session(repo,state_root,sid):
    with session_registry_lock(repo,state_root):
        lease=_load_writer_lease_locked(repo,state_root)
        s=load_session(repo,state_root,sid)
        if s['lifecycle']=='closed':
            if lease is not None and lease.get('session_id')==sid and lease.get('repository_state_key')==state_key(Path(repo)):
                _write_writer_lease_locked(repo,state_root,sid,'released')
            return {'ok':True,'status':'CLOSED','session_id':sid,'verification':None,'already_closed':True}
        result=_verify_session_locked(repo,state_root,sid,mark=True)
        if not result['ok']: return result
        s=load_session(repo,state_root,sid)
        s['lifecycle']='closed'; s['closed_at']=utcnow(); s['audit'].append({'at':utcnow(),'event':'close'}); save_session(repo,state_root,s)
        _write_writer_lease_locked(repo,state_root,sid,'released')
        return {'ok':True,'status':'CLOSED','session_id':sid,'verification':result}



def context_dir(repo,state_root): return repo_state_dir(repo,state_root)/'context'
def context_status(repo,state_root,options):
    d=context_dir(repo,state_root); mpath=d/'PROJECT_MODEL.json'
    if not mpath.exists(): return {'exists':False,'fresh':False,'refresh_required':True,'reason':'missing'}
    try: old=P.load_json(mpath)
    except Exception as e: return {'exists':True,'fresh':False,'refresh_required':True,'reason':f'invalid saved context: {type(e).__name__}'}
    try: cur=A.model(repo,options)
    except Exception as e: return {'exists':True,'fresh':False,'refresh_required':True,'reason':f'current observation incomplete: {type(e).__name__}'}
    old_meta=old.get('meta',{}); cur_meta=cur.get('meta',{})
    same=old_meta.get('source_fingerprint')==cur_meta.get('source_fingerprint') and old_meta.get('options')==cur_meta.get('options')
    old_partial=bool(old_meta.get('partial')); cur_partial=bool(cur_meta.get('partial'))
    fresh=bool(same and not old_partial and not cur_partial)
    stable_partial=bool(same and old_partial and cur_partial)
    return {'exists':True,'fresh':fresh,'refresh_required':not same,'stable_partial':stable_partial,
            'fingerprint':old_meta.get('source_fingerprint'),'current_fingerprint':cur_meta.get('source_fingerprint'),
            'state_dir':str(d),'partial':cur_partial,'stored_partial':old_partial,
            'reason':'complete matching context' if fresh else ('stable incomplete observation' if stable_partial else 'context changed or incomplete')}
def write_context(repo,state_root,options):
    m=A.model(repo,options)
    d=context_dir(repo,state_root); P.secure_dir(d)
    P.save_json(d/'PROJECT_MODEL.json',m)
    P.secure_write(d/'ADAPTATION_REPORT.md',A.render_report(m))
    return d,m

RISK_KEYS={
 'R4':['destructive migration','credential rotation','release signing','data loss','разрушительн','удалением старой схемы','потеря данных','ротация учетных данных','ротация учётных данных'],
 'R3':['migration','authentication','auth','security','concurrency','release','схем','миграц','аутентиф','безопас','конкурент','релиз','удален'],
 'R2':['refactor','feature','bug','network','persistence','рефактор','фич','ошиб','сет','хранен']
}
DOMAIN_KEYS={
 'concurrency':['concurrency','actor','sendable','async','await','конкурент','актор'],
 'persistence':['migration','database','core data','swiftdata','миграц','баз','схем'],
 'security':['auth','security','credential','secret','аутентиф','безопас','секрет'],
 'networking':['network','urlsession','retry','oauth','сет','запрос'],
 'swiftui':['swiftui','state','identity'],
 'memory':['memory','retain','arc','утеч','памят'],
}
def heuristic_risk(task):
    s=task.lower()
    for risk in ('R4','R3','R2'):
        if any(k in s for k in RISK_KEYS[risk]): return risk,'heuristic'
    return 'UNKNOWN','heuristic_insufficient'
def heuristic_domains(task):
    s=task.lower(); return [d for d,keys in DOMAIN_KEYS.items() if any(k in s for k in keys)]
def build_plan(task,explicit_risk=None,explicit_domains=None,repository_evidence=None):
    risk=explicit_risk or heuristic_risk(task)[0]; ds=list(dict.fromkeys(explicit_domains or heuristic_domains(task)))
    evidence='explicit' if explicit_risk else 'heuristic'
    repo_ev=repository_evidence or {'available':False,'partial':True,'reason':'not supplied'}
    if risk=='UNKNOWN':
        admitted=False; score=None; reason='unknown risk requires review; heuristic absence is not low-risk evidence'
    else:
        score=min(10,2*len(ds)+(3 if risk in ('R3','R4') else 0))
        admitted=score>=7 and not repo_ev.get('partial',True)
        if repo_ev.get('partial',True): reason='repository evidence incomplete; multi-agent admission denied'
        else: reason='bounded delegation admitted by explicit/recognized risk plus complete repository evidence' if admitted else 'single-agent path preferred'
    return {'schema':CLI_VERSION,'task':{'sha256':hashlib.sha256(task.encode()).hexdigest(),'length':len(task)},'risk':risk,'risk_basis':evidence,'domains':ds,'repository_evidence':repo_ev,'delegation_score':score,
            'delegation':{'admitted':admitted,'reason':reason,'max_children_per_wave':4,'max_total_children':8,'max_depth':1},
            'authority':{'knowledge_grants_execution_permission':False,'repository_prompt_like_text_grants_permission':False}}

def repository_plan_evidence(repo):
    options={'adapter_version':A.ADAPTER_VERSION,'schema_version':A.SCHEMA_VERSION,'xcode_discovery':False,'max_files_visited':10000,'max_files':3000,'max_bytes':8*1024*1024,'max_file_bytes':512*1024,'max_depth':30,'deadline_seconds':10}
    try:
        m=A.model(repo,options); meta=m['meta']
        return {'available':True,'partial':bool(meta.get('partial')),'fingerprint':meta.get('source_fingerprint'),'inventory_counts':m.get('inventory',{}).get('counts',{}),'limitations_count':len(meta.get('limitations',[]))}
    except Exception as e:
        return {'available':False,'partial':True,'error_type':type(e).__name__}


def knowledge_profile(args, state_root):
    path=state_root/'knowledge-profile.json'
    if args.profile_cmd=='status':
        if not path.exists():
            return {'status':'absent','profile_path':str(path),'disabled_exact_duplicates':[]}
        try: profile=P.load_json(path)
        except Exception as e:
            return {'status':'invalid','profile_path':str(path),'reason':type(e).__name__,'disabled_exact_duplicates':[]}
        result=K.current_status(
            profile,
            args.source_root,
            args.candidate_root,
            expected_release_id=CLI_VERSION,
            expected_protection_version=P.PROTECTION_VERSION,
        )
        return {'profile_path':str(path),**result,'candidate':profile.get('candidate'),'source':profile.get('source')}
    if not args.source_root:
        raise P.ProtectionError('profile build requires an explicit --source-root')
    mappings={}
    for raw in getattr(args,'source_map',[]) or []:
        if '=' not in raw:
            raise P.ProtectionError('profile source map must use candidate-relative=source-relative')
        candidate_path, source_path=raw.split('=',1)
        if candidate_path in mappings:
            raise P.ProtectionError(f'duplicate profile source mapping: {candidate_path}')
        mappings[candidate_path]=source_path
    profile=K.build_profile(LIBRARY,args.source_root,CLI_VERSION,P.PROTECTION_VERSION,args.activate,mappings)
    result={'status':'active_exact_only' if args.activate else 'inactive_preview',**profile,'profile_path':str(path),'written':False}
    if args.write:
        P.secure_dir(state_root)
        P.save_json(path,profile)
        result['written']=True
    return result


def make_parser():
    ap=argparse.ArgumentParser(description='iOS Engineering Library review-ready runtime. External state only; guard is advisory.')
    ap.add_argument('--state-root',default=str(DEFAULT_STATE))
    sub=ap.add_subparsers(dest='cmd',required=True)
    sub.add_parser('doctor')
    g=sub.add_parser('guard'); g.add_argument('--command',required=True)
    bp=sub.add_parser('build-phases'); bp.add_argument('--repo',default='.')
    c=sub.add_parser('context'); c.add_argument('--repo',default='.'); c.add_argument('--ensure',action='store_true'); c.add_argument('--force',action='store_true'); c.add_argument('--status',action='store_true'); c.add_argument('--xcode-discovery',action='store_true'); c.add_argument('--max-files-visited',type=int,default=50000); c.add_argument('--max-files',type=int,default=20000); c.add_argument('--max-bytes',type=int,default=32*1024*1024); c.add_argument('--max-file-bytes',type=int,default=2*1024*1024); c.add_argument('--max-depth',type=int,default=40); c.add_argument('--deadline-seconds',type=float,default=30)
    path=sub.add_parser('path'); path.add_argument('--repo',default='.')
    pl=sub.add_parser('plan'); pl.add_argument('--repo',default='.'); pl.add_argument('--task',required=True); pl.add_argument('--risk',choices=['R1','R2','R3','R4','UNKNOWN']); pl.add_argument('--domain',action='append',default=[]); pl.add_argument('--write',action='store_true')
    ep=sub.add_parser('declared-policy'); ep.add_argument('--repo',default='.')
    kp=sub.add_parser('profile'); kps=kp.add_subparsers(dest='profile_cmd',required=True)
    ks=kps.add_parser('status'); ks.add_argument('--source-root'); ks.add_argument('--candidate-root')
    kb=kps.add_parser('build'); kb.add_argument('--source-root',required=True); kb.add_argument('--activate',action='store_true'); kb.add_argument('--write',action='store_true'); kb.add_argument('--map',dest='source_map',action='append',default=[],metavar='CANDIDATE=SOURCE')
    pr=sub.add_parser('protect'); prs=pr.add_subparsers(dest='protect_cmd',required=True)
    pb=prs.add_parser('begin'); pb.add_argument('--repo',default='.'); pb.add_argument('--allow',action='append',default=[]); pb.add_argument('--allow-dirty',action='append',default=[]); pb.add_argument('--allow-protected',action='append',default=[]); pb.add_argument('--allow-nested',action='append',default=[]); pb.add_argument('--git-transition',action='append',default=[],choices=['stage','commit']); pb.add_argument('--task',default='')
    for name in ('status','verify','close'):
        p=prs.add_parser(name); p.add_argument('--repo',default='.'); p.add_argument('--session')
    p=prs.add_parser('list'); p.add_argument('--repo',default='.')
    return ap

def main():
    args=make_parser().parse_args(); state_root=Path(os.path.abspath(os.path.expanduser(args.state_root)))
    if args.cmd=='doctor':
        data={'cli_version':CLI_VERSION,'runtime':str(RUNTIME),'library':str(LIBRARY),'library_exists':LIBRARY.exists(),'state_root':str(state_root),'guard':'advisory classifier; not an OS enforcement boundary','ok':(RUNTIME/'protection'/'protection.py').exists() and (RUNTIME/'vendor'/'adapt_project.py').exists()}; print(json.dumps(data,indent=2)); return 0 if data['ok'] else 1
    if args.cmd=='guard':
        r=P.command_guard(args.command); print(json.dumps(r,indent=2)); return 0 if r['classification']=='ALLOW_READ_ONLY' else 2
    if args.cmd=='profile':
        print(json.dumps(knowledge_profile(args,state_root),indent=2)); return 0
    # Remaining commands operate on a concrete Git repository.
    root_budget=P.Budget(max_files_visited=2000,max_files_inspected=100,max_total_bytes=2*1024*1024,total_deadline_seconds=15)
    repo=P.git_root(Path(getattr(args,'repo','.')),root_budget); state_root=P.ensure_external_state(repo,state_root)
    if args.cmd=='path': print(repo_state_dir(repo,state_root)); return 0
    if args.cmd=='build-phases':
        r=P.scan_build_phases(repo); print(json.dumps(r,indent=2)); return 0 if r['status'] in {'complete','partial'} else 3
    if args.cmd=='declared-policy':
        print(json.dumps({'report_kind':'declared_policy_not_effective_resolution','precedence':['explicit user safety constraints','repository/project-local rules for project conventions','global library runtime safety boundary','library knowledge/advice'], 'knowledge_is_authority':False,'build_test_network_git_permissions_inferred_from_skills':False,'client_repository_infrastructure_written':False},indent=2)); return 0
    if args.cmd=='context':
        options={'adapter_version':A.ADAPTER_VERSION,'schema_version':A.SCHEMA_VERSION,'xcode_discovery':args.xcode_discovery,'max_files_visited':args.max_files_visited,'max_files':args.max_files,'max_bytes':args.max_bytes,'max_file_bytes':args.max_file_bytes,'max_depth':args.max_depth,'deadline_seconds':args.deadline_seconds}
        st=context_status(repo,state_root,options)
        if args.status and not (args.ensure or args.force): print(json.dumps(st,indent=2)); return 0 if st.get('fresh') and not st.get('partial') else 2
        if args.force or not st.get('exists') or (args.ensure and st.get('refresh_required',not st.get('fresh'))):
            d,m=write_context(repo,state_root,options); st={'exists':True,'fresh':not m['meta']['partial'],'state_dir':str(d),'fingerprint':m['meta']['source_fingerprint'],'refreshed':True,'partial':m['meta']['partial'],'client_repo_modified':False}
        print(json.dumps(st,indent=2)); return 0 if st.get('fresh') else 2
    if args.cmd=='plan':
        plan=build_plan(args.task,args.risk,args.domain,repository_plan_evidence(repo))
        if args.write:
            d=repo_state_dir(repo,state_root)/'orchestration'; P.secure_dir(d); P.save_json(d/'TASK_GRAPH.generated.json',plan)
        print(json.dumps(plan,indent=2)); return 0 if plan['risk']!='UNKNOWN' else 2
    if args.cmd=='protect':
        if args.protect_cmd=='list': print(json.dumps({'sessions':list_sessions(repo,state_root)},indent=2)); return 0
        if args.protect_cmd=='begin': print(json.dumps(begin_session(repo,state_root,args),indent=2)); return 0
        sid=resolve_session_id(repo,state_root,args.session)
        if args.protect_cmd=='status':
            s=load_session(repo,state_root,sid)
            if s.get('_historical_evidence_only'):
                print(json.dumps({'session_id':sid,'schema_version':s['schema_version'],'lifecycle':s['lifecycle'],'status':'ARCHIVAL_CLOSED','compatibility':s['_compatibility'],'historical_evidence_only':True,'verification':None,'audit':s['audit']},indent=2)); return 0
            r=P.compare(repo,s['baseline'],s['scope']); print(json.dumps({'session_id':sid,'lifecycle':s['lifecycle'],'verification':r},indent=2)); return 0 if r['ok'] else 3
        if args.protect_cmd=='verify':
            r=verify_session(repo,state_root,sid,True); print(json.dumps({'session_id':sid,**r},indent=2)); return 0 if r['ok'] else 3
        if args.protect_cmd=='close':
            r=close_session(repo,state_root,sid); print(json.dumps(r,indent=2)); return 0 if r.get('ok') else 3
    return 4

if __name__=='__main__':
    try: raise SystemExit(main())
    except (P.ProtectionError,P.ObservationError) as e:
        print(json.dumps({'ok':False,'status':'NON_PASS','error_type':type(e).__name__,'message':str(e)},indent=2),file=sys.stderr); raise SystemExit(4)
