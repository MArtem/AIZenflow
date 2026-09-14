#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import errno, fnmatch, hashlib, json, os, secrets, selectors, shlex, shutil, signal, stat, subprocess, time

SCHEMA_VERSION = 2
PROTECTION_VERSION = "5.4-review-ready.5"

PROTECTED_PATTERNS = [
    '*.xcodeproj/project.pbxproj','project.pbxproj','Package.swift','Package.resolved',
    'Podfile','Podfile.lock','Cartfile','Cartfile.resolved','Mintfile','Mintfile.lock',
    '*.entitlements','*.xcconfig','Info.plist','PrivacyInfo.xcprivacy',
    '.github/**','.gitlab-ci.yml','.circleci/**','Jenkinsfile','fastlane/**',
    'scripts/**','Scripts/**','*.xcscheme','*.xctestplan','*.xcdatamodeld/**','*.momd/**',
]
EXCLUDED_DIRS = {'.git','.build','DerivedData','Pods','Carthage','node_modules','.swiftpm'}
SHELL_META = ('|','&',';','>','<','`','$','\n','\r','\x00')
NETWORK_TOOLS = {'curl','wget','scp','sftp','ssh','rsync','nc','netcat','ftp'}
DEPENDENCY_TOOLS = {'pod','brew','npm','pnpm','yarn','bundle','gem','mint'}
INTERPRETERS = {'sh','bash','zsh','fish','python','python3','ruby','perl','node','osascript'}
RELEASE_TOOLS = {'fastlane','xcrun','codesign','notarytool','altool','security'}
SAFE_SIMPLE = {
    'pwd': lambda a: len(a) == 1,
    'git': None,
}
SAFE_GIT_SUBCOMMANDS = {'status','diff','log','show','rev-parse','branch','remote','ls-files','ls-tree','for-each-ref'}
MUTATING_GIT_SUBCOMMANDS = {
    'add','commit','checkout','switch','restore','reset','clean','merge','rebase','cherry-pick',
    'revert','stash','tag','fetch','pull','push','config','rm','mv','worktree','submodule','gc','reflog'
}

class ProtectionError(RuntimeError):
    pass

class ObservationError(ProtectionError):
    """Observation was incomplete; callers must not turn this into PASS."""

@dataclass
class Budget:
    max_files_visited: int = 50000
    max_files_inspected: int = 20000
    max_total_bytes: int = 64 * 1024 * 1024
    max_file_bytes: int = 8 * 1024 * 1024
    max_output_bytes: int = 4 * 1024 * 1024
    subprocess_timeout: float = 12.0
    total_deadline_seconds: float = 45.0
    files_visited: int = 0
    files_inspected: int = 0
    bytes_read: int = 0
    started: float = 0.0

    def __post_init__(self):
        if not self.started:
            self.started = time.monotonic()

    def check_deadline(self):
        if time.monotonic() - self.started > self.total_deadline_seconds:
            raise ObservationError('operation deadline exceeded')

    def visit(self, count: int = 1):
        self.check_deadline(); self.files_visited += count
        if self.files_visited > self.max_files_visited:
            raise ObservationError('file-visit budget exceeded')

    def inspect(self, size: int):
        self.check_deadline(); self.files_inspected += 1
        if self.files_inspected > self.max_files_inspected:
            raise ObservationError('file-inspection budget exceeded')
        if size > self.max_file_bytes:
            raise ObservationError(f'per-file byte budget exceeded: {size}')
        self.bytes_read += size
        if self.bytes_read > self.max_total_bytes:
            raise ObservationError('total byte budget exceeded')

    def summary(self):
        return {
            'files_visited': self.files_visited,
            'files_inspected': self.files_inspected,
            'bytes_read': self.bytes_read,
            'limits': {
                'max_files_visited': self.max_files_visited,
                'max_files_inspected': self.max_files_inspected,
                'max_total_bytes': self.max_total_bytes,
                'max_file_bytes': self.max_file_bytes,
                'max_output_bytes': self.max_output_bytes,
                'subprocess_timeout': self.subprocess_timeout,
                'total_deadline_seconds': self.total_deadline_seconds,
            }
        }


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def hash_text(text: str) -> str:
    return sha256_bytes(text.encode('utf-8'))


def _terminate_owned_process(p: subprocess.Popen) -> None:
    """Terminate the observer-owned process tree as far as the platform contract permits.

    POSIX children are created in a fresh session/process group, so cleanup targets the group even
    when its original leader has already exited. A dead leader is not evidence that descendants are
    gone: they may still hold inherited pipes or keep running in that group. Descendants that
    deliberately leave the owned process group remain outside this advisory observer boundary.
    """
    if os.name == 'posix':
        try:
            os.killpg(p.pid, signal.SIGKILL)
            return
        except ProcessLookupError:
            return
        except (PermissionError, OSError):
            # Fall back to the direct child only when it is still alive.
            pass
    if p.poll() is None:
        try:
            p.kill()
        except (ProcessLookupError, OSError):
            pass


def _run_bounded(cwd: Path, argv: list[str], budget: Budget, env=None) -> tuple[int, bytes, bytes]:
    budget.check_deadline()
    process_env = os.environ.copy()
    if env: process_env.update(env)
    if argv and argv[0] == 'git': process_env.setdefault('GIT_OPTIONAL_LOCKS', '0')
    p = subprocess.Popen(
        argv, cwd=str(cwd), stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=process_env,
        start_new_session=(os.name == 'posix')
    )
    sel = None
    chunks = {'out': bytearray(), 'err': bytearray()}
    timed_out = False
    overflow = False
    start = time.monotonic()
    try:
        if p.stdout is None or p.stderr is None:
            raise ObservationError('subprocess pipes unavailable')
        sel = selectors.DefaultSelector()
        for stream, label in ((p.stdout, 'out'), (p.stderr, 'err')):
            try:
                os.set_blocking(stream.fileno(), False)
            except (AttributeError, OSError) as e:
                raise ObservationError('subprocess pipe cannot be made nonblocking') from e
            sel.register(stream, selectors.EVENT_READ, label)

        # Read only descriptors reported ready by the selector. Direct-child exit is not EOF:
        # a descendant may still own the inherited write end. Waiting remains bounded by both the
        # subprocess timeout and the operation deadline.
        while sel.get_map():
            budget.check_deadline()
            remaining = budget.subprocess_timeout - (time.monotonic() - start)
            if remaining <= 0:
                timed_out = True
                break
            events = sel.select(min(0.02, remaining))
            for key, _ in events:
                try:
                    data = os.read(key.fileobj.fileno(), 65536)
                except BlockingIOError:
                    continue
                except OSError as e:
                    raise ObservationError('subprocess pipe read failed') from e
                if not data:
                    try: sel.unregister(key.fileobj)
                    except Exception: pass
                    continue
                chunks[key.data].extend(data)
                if len(chunks['out']) + len(chunks['err']) > budget.max_output_bytes:
                    overflow = True
                    break
            if overflow:
                break

        # Pipes may close before the process exits. Do not use an unbounded wait in that case.
        while not timed_out and not overflow and p.poll() is None:
            budget.check_deadline()
            remaining = budget.subprocess_timeout - (time.monotonic() - start)
            if remaining <= 0:
                timed_out = True
                break
            time.sleep(min(0.01, remaining))

        if timed_out or overflow:
            _terminate_owned_process(p)
        if p.poll() is None:
            try:
                p.wait(timeout=0.25)
            except subprocess.TimeoutExpired:
                _terminate_owned_process(p)
        if timed_out:
            raise ObservationError('subprocess timeout')
        if overflow:
            raise ObservationError('subprocess output budget exceeded')
        rc=p.poll()
        if rc is None:
            raise ObservationError('subprocess cleanup incomplete')
        return rc, bytes(chunks['out']), bytes(chunks['err'])
    finally:
        # Always target the POSIX process group, even if the immediate child already exited.
        _terminate_owned_process(p)
        try:
            p.wait(timeout=0.25)
        except (subprocess.TimeoutExpired, ChildProcessError):
            _terminate_owned_process(p)
            try: p.wait(timeout=0.25)
            except Exception: pass
        if sel is not None:
            try: sel.close()
            except Exception: pass
        for stream in (p.stdout, p.stderr):
            if stream is not None:
                try: stream.close()
                except Exception: pass


def git(repo: Path, args: list[str], budget: Budget, *, allow_returncodes=(0,)) -> bytes:
    rc, out, err = _run_bounded(repo, ['git'] + args, budget)
    if rc not in allow_returncodes:
        # Never retain/emit raw command output: it may contain repository-derived secrets.
        raise ObservationError(f'git observation failed: subcommand={args[0] if args else "?"} exit={rc} stderr_sha256={sha256_bytes(err)}')
    return out


def git_root(path: Path, budget=None) -> Path:
    budget = budget or Budget()
    p = path.expanduser().resolve()
    out = git(p, ['rev-parse','--show-toplevel'], budget)
    try: root = Path(out.decode('utf-8').strip()).resolve()
    except UnicodeDecodeError as e: raise ObservationError('git root output is not UTF-8') from e
    if not root.exists(): raise ObservationError('git reported missing worktree root')
    return root


def is_within(child: Path, parent: Path) -> bool:
    try: child.resolve().relative_to(parent.resolve()); return True
    except Exception: return False


def _open_dir_chain(path: Path, create: bool, mode: int = 0o700) -> int:
    """Open an absolute directory through no-follow dir fds. Caller owns returned fd."""
    p = path.expanduser()
    if not p.is_absolute(): p = p.resolve()
    if not hasattr(os, 'O_NOFOLLOW') or not hasattr(os, 'O_DIRECTORY'):
        raise ProtectionError('safe state I/O requires O_NOFOLLOW and O_DIRECTORY')
    fd = os.open('/', os.O_RDONLY | os.O_DIRECTORY)
    try:
        for part in p.parts[1:]:
            if part in ('', '.'): continue
            try:
                nextfd = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            except FileNotFoundError:
                if not create: raise
                os.mkdir(part, mode=mode, dir_fd=fd)
                nextfd = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            except OSError as e:
                if e.errno in (errno.ELOOP, errno.ENOTDIR):
                    raise ProtectionError(f'refusing symlink/non-directory state component: {part}') from e
                raise
            # Never chmod pre-existing ancestors (for example $HOME or /tmp). Newly created
            # components already received mode 0700; secure_dir enforces the final owned directory.
            os.close(fd); fd = nextfd
        return fd
    except Exception:
        os.close(fd); raise


def secure_dir(path: Path) -> Path:
    fd = _open_dir_chain(path, create=True)
    try: os.fchmod(fd, 0o700)
    except Exception as e:
        os.close(fd); raise ProtectionError(f'cannot enforce private directory permissions: {path}') from e
    os.close(fd)
    return path


def ensure_external_state(repo: Path, state_root: Path) -> Path:
    repo = repo.resolve()
    # Keep the caller's state path lexical. Resolving it here would erase symlink
    # components before the no-follow directory walk can reject them.
    state_root = Path(os.path.abspath(os.path.expanduser(str(state_root))))
    try:
        state_root.relative_to(repo); raise ProtectionError('external state must be outside client repository')
    except ValueError: pass
    try:
        repo.relative_to(state_root); raise ProtectionError('external state must not contain client repository')
    except ValueError: pass
    # Reject every pre-existing symlink component, regardless of where it points.
    # This keeps containment/no-follow behavior consistent from CLI input to file I/O.
    cur = Path(state_root.anchor or '/')
    for part in state_root.parts[1:] if state_root.anchor else state_root.parts:
        cur = cur / part
        if not os.path.lexists(cur):
            continue
        try:
            st = os.lstat(cur)
        except FileNotFoundError:
            continue
        if stat.S_ISLNK(st.st_mode):
            raise ProtectionError(f'refusing symlink state path component: {cur}')
    secure_dir(state_root)
    return state_root


def secure_write(path: Path, text: str) -> None:
    parent = path.parent
    secure_dir(parent)
    pfd = _open_dir_chain(parent, create=False)
    name = path.name
    tmp = f'.{name}.tmp.{os.getpid()}.{secrets.token_hex(8)}'
    tfd = None
    try:
        try:
            st = os.stat(name, dir_fd=pfd, follow_symlinks=False)
            if stat.S_ISLNK(st.st_mode):
                raise ProtectionError(f'refusing symlink destination: {path}')
            if stat.S_ISDIR(st.st_mode):
                raise ProtectionError(f'refusing directory destination: {path}')
        except FileNotFoundError:
            pass
        flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW
        tfd = os.open(tmp, flags, 0o600, dir_fd=pfd)
        os.fchmod(tfd, 0o600)
        data = text.encode('utf-8')
        offset = 0
        while offset < len(data):
            offset += os.write(tfd, data[offset:])
        os.fsync(tfd); os.close(tfd); tfd = None
        # replace renames the link itself if an attacker swaps destination to a symlink;
        # it does not follow the destination symlink target.
        os.replace(tmp, name, src_dir_fd=pfd, dst_dir_fd=pfd)
        os.fsync(pfd)
        st = os.stat(name, dir_fd=pfd, follow_symlinks=False)
        if stat.S_ISLNK(st.st_mode) or stat.S_IMODE(st.st_mode) != 0o600:
            raise ProtectionError(f'private file publication verification failed: {path}')
    finally:
        if tfd is not None:
            try: os.close(tfd)
            except Exception: pass
        try: os.unlink(tmp, dir_fd=pfd)
        except FileNotFoundError: pass
        os.close(pfd)


def secure_read_json(path: Path, max_bytes: int = 4 * 1024 * 1024, expected_identity=None) -> dict:
    pfd = _open_dir_chain(path.parent, create=False)
    fd = None
    try:
        fd = os.open(path.name, os.O_RDONLY | os.O_NOFOLLOW, dir_fd=pfd)
        st = os.fstat(fd)
        if not stat.S_ISREG(st.st_mode): raise ProtectionError('state file is not regular')
        if stat.S_IMODE(st.st_mode) & 0o077:
            raise ProtectionError('state file permissions are not private')
        identity=(st.st_dev, st.st_ino, st.st_size, st.st_mtime_ns)
        if expected_identity is not None and identity != tuple(expected_identity):
            raise ProtectionError('state file changed before read')
        if st.st_size > max_bytes: raise ProtectionError('state file exceeds read budget')
        raw = bytearray()
        while len(raw) < st.st_size:
            chunk = os.read(fd, min(65536, st.st_size-len(raw)))
            if not chunk: break
            raw.extend(chunk)
        end = os.fstat(fd)
        if len(raw) != st.st_size or (end.st_dev, end.st_ino, end.st_size, end.st_mtime_ns) != identity:
            raise ProtectionError('state file changed or was incompletely read')
        return json.loads(bytes(raw).decode('utf-8'))
    except (UnicodeDecodeError, json.JSONDecodeError) as e:
        raise ProtectionError(f'malformed state JSON: {path}') from e
    finally:
        if fd is not None: os.close(fd)
        os.close(pfd)


def hash_path(path: Path, repo: Path, budget: Budget) -> dict:
    budget.visit()
    try: st = os.lstat(path)
    except OSError as e: raise ObservationError(f'file lstat failed: {path.name}:{type(e).__name__}') from e
    if stat.S_ISLNK(st.st_mode):
        # Hash link text; never follow source escape.
        target = os.readlink(path)
        data = target.encode('utf-8', errors='surrogateescape')
        budget.inspect(len(data))
        return {'kind':'symlink','sha256':sha256_bytes(data),'size':len(data)}
    if stat.S_ISREG(st.st_mode):
        h = hashlib.sha256(); total = 0; fd = None
        try:
            fd = os.open(path, os.O_RDONLY | getattr(os,'O_NOFOLLOW',0))
            fst = os.fstat(fd)
            if not stat.S_ISREG(fst.st_mode): raise ObservationError(f'file type changed during observation: {path.name}')
            if (fst.st_dev,fst.st_ino) != (st.st_dev,st.st_ino): raise ObservationError(f'file identity changed during observation: {path.name}')
            budget.inspect(fst.st_size)
            while True:
                budget.check_deadline(); chunk = os.read(fd,min(65536,budget.max_file_bytes-total+1))
                if not chunk: break
                total += len(chunk)
                if total > budget.max_file_bytes: raise ObservationError(f'file too large: {path.name}')
                h.update(chunk)
            if total != fst.st_size: raise ObservationError(f'file changed/short read during observation: {path.name}')
        except ObservationError:
            raise
        except OSError as e: raise ObservationError(f'file read failed: {path.name}:{type(e).__name__}') from e
        finally:
            if fd is not None: os.close(fd)
        return {'kind':'file','sha256':h.hexdigest(),'size':total}
    if stat.S_ISDIR(st.st_mode):
        return {'kind':'directory','sha256':None,'size':0}
    return {'kind':'special','sha256':None,'size':0}


def _decode_utf8(data: bytes, label: str) -> str:
    try: return data.decode('utf-8')
    except UnicodeDecodeError as e: raise ObservationError(f'malformed UTF-8 from {label}') from e


def read_regular_nofollow(path: Path, budget: Budget, label: str) -> bytes:
    """Read one bounded regular file without following the final symlink and detect identity/size swaps."""
    budget.check_deadline()
    try:
        before=os.lstat(path)
    except OSError as e:
        raise ObservationError(f'{label} lstat failed: {type(e).__name__}') from e
    if stat.S_ISLNK(before.st_mode):
        raise ObservationError(f'{label} symlink is outside static scanner coverage')
    if not stat.S_ISREG(before.st_mode):
        raise ObservationError(f'{label} is not a regular file')
    budget.inspect(before.st_size)
    fd=None
    try:
        fd=os.open(path, os.O_RDONLY | getattr(os,'O_NOFOLLOW',0))
        opened=os.fstat(fd)
        if not stat.S_ISREG(opened.st_mode) or (opened.st_dev,opened.st_ino)!=(before.st_dev,before.st_ino):
            raise ObservationError(f'{label} identity changed before read')
        raw=bytearray()
        while True:
            budget.check_deadline()
            chunk=os.read(fd,min(65536,budget.max_file_bytes-len(raw)+1))
            if not chunk: break
            raw.extend(chunk)
            if len(raw)>budget.max_file_bytes:
                raise ObservationError(f'{label} exceeded per-file read budget')
        after=os.fstat(fd)
        if (after.st_dev,after.st_ino,after.st_size)!=(opened.st_dev,opened.st_ino,opened.st_size) or len(raw)!=opened.st_size:
            raise ObservationError(f'{label} changed or was incompletely read')
        return bytes(raw)
    except ObservationError:
        raise
    except OSError as e:
        raise ObservationError(f'{label} read failed: {type(e).__name__}') from e
    finally:
        if fd is not None: os.close(fd)


def changed_paths(repo: Path, budget: Budget) -> dict[str, str]:
    out = git(repo, ['status','--porcelain=v1','-z','--untracked-files=all'], budget)
    chunks = out.split(b'\0'); result = {}; i = 0
    while i < len(chunks):
        rec = chunks[i]; i += 1
        if not rec: continue
        if len(rec) < 4: raise ObservationError('malformed git status record')
        status_code = _decode_utf8(rec[:2], 'git status')
        path = _decode_utf8(rec[3:], 'git status path')
        result[path] = status_code
        if 'R' in status_code or 'C' in status_code:
            if i >= len(chunks) or not chunks[i]: raise ObservationError('malformed rename/copy status')
            old = _decode_utf8(chunks[i], 'git status old path'); i += 1
            result[old] = status_code
    return result


def staged_paths(repo: Path, budget: Budget) -> list[str]:
    out = git(repo, ['diff','--cached','--name-only','-z'], budget)
    return sorted(_decode_utf8(x,'staged path') for x in out.split(b'\0') if x)


def index_entries(repo: Path, budget: Budget) -> list[dict]:
    out = git(repo, ['ls-files','--stage','-z'], budget)
    entries=[]
    for rec in out.split(b'\0'):
        if not rec: continue
        try: head, raw_path = rec.split(b'\t',1); mode, oid, stage = head.split(b' ',2)
        except ValueError as e: raise ObservationError('malformed git index output') from e
        entries.append({'mode':mode.decode('ascii'),'oid':oid.decode('ascii'),'stage':stage.decode('ascii'),'path':_decode_utf8(raw_path,'index path')})
    entries.sort(key=lambda x:(x['path'],x['stage']))
    return entries


def refs_map(repo: Path, budget: Budget) -> dict[str,str]:
    out = git(repo, ['for-each-ref','--format=%(refname)%09%(objectname)'], budget)
    refs={}
    for line in _decode_utf8(out,'refs').splitlines():
        if not line: continue
        if '\t' not in line: raise ObservationError('malformed refs output')
        name, oid = line.split('\t',1); refs[name]=oid
    return refs


def local_config_hash(repo: Path, budget: Budget) -> str:
    out = git(repo, ['config','--local','--null','--list','--show-origin'], budget)
    return sha256_bytes(out)


def head_state(repo: Path, budget: Budget) -> dict:
    rc, out, _ = _run_bounded(repo, ['git','symbolic-ref','-q','HEAD'], budget, {'GIT_OPTIONAL_LOCKS':'0'})
    if rc not in (0,1): raise ObservationError(f'git symbolic-ref failed: exit={rc}')
    symbolic = _decode_utf8(out,'symbolic-ref').strip() if rc == 0 else None
    rc2, out2, _ = _run_bounded(repo, ['git','rev-parse','--verify','HEAD'], budget, {'GIT_OPTIONAL_LOCKS':'0'})
    if rc2 == 0:
        oid = _decode_utf8(out2,'HEAD').strip()
        tree = _decode_utf8(git(repo,['rev-parse','HEAD^{tree}'],budget),'HEAD tree').strip()
        return {'kind':'attached' if symbolic else 'detached','symbolic_ref':symbolic,'oid':oid,'tree_oid':tree}
    if rc2 == 128 and symbolic:
        return {'kind':'unborn','symbolic_ref':symbolic,'oid':None,'tree_oid':None}
    raise ObservationError(f'git HEAD observation failed: exit={rc2}')


def repository_identity(repo: Path, budget: Budget) -> dict:
    root = git_root(repo,budget)
    gd = _decode_utf8(git(root,['rev-parse','--git-dir'],budget),'git-dir').strip()
    cd = _decode_utf8(git(root,['rev-parse','--git-common-dir'],budget),'git-common-dir').strip()
    git_dir=(root/gd).resolve() if not Path(gd).is_absolute() else Path(gd).resolve()
    common=(root/cd).resolve() if not Path(cd).is_absolute() else Path(cd).resolve()
    st=os.stat(root)
    return {'worktree':str(root),'git_dir':str(git_dir),'git_common_dir':str(common),'device':st.st_dev,'inode':st.st_ino}


def nested_repo_roots(repo: Path, budget: Budget) -> list[Path]:
    result=[]
    for base, dirs, files in os.walk(repo, topdown=True, followlinks=False, onerror=lambda e: (_ for _ in ()).throw(ObservationError('directory walk failed'))):
        budget.check_deadline(); basep=Path(base)
        # Do not descend into symlinked dirs or heavy generated roots.
        clean=[]
        for d in dirs:
            budget.visit()
            p=basep/d
            if d in EXCLUDED_DIRS:
                continue
            try:
                if stat.S_ISLNK(os.lstat(p).st_mode): continue
            except OSError as e: raise ObservationError(f'directory observation failed: {d}:{type(e).__name__}') from e
            clean.append(d)
        dirs[:] = clean
        if basep == repo: continue
        dotgit=basep/'.git'
        if os.path.lexists(dotgit):
            try:
                gst=os.lstat(dotgit)
            except OSError as e:
                raise ObservationError(f'nested .git observation failed: {type(e).__name__}') from e
            if stat.S_ISLNK(gst.st_mode):
                raise ObservationError('nested repository .git symlink is unsupported; observation incomplete')
            if not (stat.S_ISDIR(gst.st_mode) or stat.S_ISREG(gst.st_mode)):
                raise ObservationError('nested repository .git entry is neither directory nor gitdir file')
            result.append(basep)
            dirs[:] = []
    return sorted(set(result))


def _capture_repo_core(repo: Path, budget: Budget, include_nested: bool, nested_depth: int = 0, max_nested_depth: int = 8) -> dict:
    identity=repository_identity(repo,budget)
    head=head_state(repo,budget)
    changed=changed_paths(repo,budget)
    staged=staged_paths(repo,budget)
    nested = nested_repo_roots(repo,budget) if include_nested else []
    nested_rel={str(p.relative_to(repo)):p for p in nested}
    dirty_hashes={}
    for rel in sorted(changed):
        # Nested repos are independent boundaries; parent status may expose only their directory.
        if any(rel == nr or rel.startswith(nr.rstrip('/')+'/') for nr in nested_rel): continue
        p=repo/rel
        if os.path.lexists(p): dirty_hashes[rel]=hash_path(p,repo,budget)
        else: dirty_hashes[rel]={'kind':'missing','sha256':None,'size':0}
    core={
        'repository_identity':identity,
        'head':head,
        'refs':refs_map(repo,budget),
        'local_config_sha256':local_config_hash(repo,budget),
        'index_entries':index_entries(repo,budget),
        'changed_paths':changed,
        'staged_paths':staged,
        'dirty_hashes':dirty_hashes,
    }
    if include_nested:
        if nested_rel and nested_depth >= max_nested_depth:
            raise ObservationError('nested repository depth budget exceeded')
        nested_states={}
        for rel,p in nested_rel.items():
            nested_states[rel]=_capture_repo_core(p,budget,True,nested_depth+1,max_nested_depth)
        core['nested_repositories']=nested_states
    return core


def capture(repo: Path, budget=None) -> dict:
    budget=budget or Budget(); repo=git_root(repo,budget)
    try:
        data=_capture_repo_core(repo,budget,True)
    except ObservationError:
        raise
    data.update({'schema_version':SCHEMA_VERSION,'protection_version':PROTECTION_VERSION,'observation_status':'complete','coverage':{
        'tracked_and_nonignored_untracked_worktree':'observed at snapshot time',
        'ignored_files':'not covered unless Git reports them through another observed surface',
        'transient_writes_between_snapshots':'not detectable',
        'backup_or_recovery':'not provided',
        'nested_repositories':'independent snapshot boundaries',
    },'budget':budget.summary()})
    return data


def protected(path: str) -> bool:
    p=path.replace('\\','/').strip('/')
    basename=p.rsplit('/',1)[-1]
    for raw_pattern in PROTECTED_PATTERNS:
        pattern=raw_pattern.replace('\\','/')
        # A slash-bearing pattern is repository-path scoped. A basename pattern applies
        # at every depth; this is required for Info.plist, Package.swift, xcconfig, etc.
        candidate=p if '/' in pattern else basename
        if fnmatch.fnmatchcase(candidate,pattern):
            return True
    return False


def validate_scope_item(value: str) -> None:
    if not value or value.startswith('/') or '..' in Path(value).parts or any(c in value for c in '*?['):
        raise ProtectionError(f'invalid repository-relative exact scope: {value!r}')


def path_allowed(path: str, scopes) -> bool:
    path=path.rstrip('/')
    for s in scopes or []:
        validate_scope_item(s)
        if s.endswith('/'):
            base=s.rstrip('/')
            if path == base or path.startswith(base+'/'): return True
        elif path == s:
            return True
    return False


def _committed_paths(repo: Path, before_head: dict, after_head: dict, budget: Budget) -> list[str]:
    if before_head['oid'] == after_head['oid']: return []
    if before_head['oid']:
        out=git(repo,['diff','--name-only','-z',before_head['oid'],after_head['oid']],budget)
    elif after_head['oid']:
        out=git(repo,['diff-tree','--root','--no-commit-id','--name-only','-r','-z',after_head['oid']],budget)
    else: return []
    return sorted(_decode_utf8(x,'commit diff path') for x in out.split(b'\0') if x)


def _index_map(entries: list[dict]) -> dict[tuple[str,str],tuple[str,str]]:
    return {(e['path'],e['stage']):(e['mode'],e['oid']) for e in entries}


def compare(repo: Path, baseline: dict, scope=None, budget=None) -> dict:
    scope=scope or {}; budget=budget or Budget(); violations=[]; notes=[]
    if baseline.get('schema_version') != SCHEMA_VERSION or baseline.get('protection_version') != PROTECTION_VERSION or baseline.get('observation_status') != 'complete':
        return {'ok':False,'status':'NON_PASS','violations':['invalid/incompatible/incomplete baseline'],'observation':'baseline rejected'}
    try: current=capture(repo,budget)
    except ObservationError as e:
        return {'ok':False,'status':'NON_PASS','violations':[f'observation incomplete: {e}'],'observation':'incomplete'}
    if current['repository_identity'] != baseline.get('repository_identity'):
        violations.append('repository identity changed or foreign baseline')
        return {'ok':False,'status':'NON_PASS','violations':violations,'observation':'complete'}
    allow=scope.get('allow',[]); allow_dirty=scope.get('allow_dirty',[]); allow_protected=scope.get('allow_protected',[]); allow_nested=scope.get('allow_nested',[])
    transitions=set(scope.get('git_transitions',[]))
    for seq in (allow,allow_dirty,allow_protected,allow_nested):
        for item in seq: validate_scope_item(item)

    before_changed=baseline.get('changed_paths',{}); after_changed=current['changed_paths']
    all_paths=set(before_changed)|set(after_changed)|set(baseline.get('dirty_hashes',{}))|set(current['dirty_hashes'])
    for p in sorted(all_paths):
        b_hash=baseline.get('dirty_hashes',{}).get(p); c_hash=current['dirty_hashes'].get(p)
        status_changed=before_changed.get(p)!=after_changed.get(p)
        content_changed=b_hash!=c_hash
        if p in before_changed:
            if (status_changed or content_changed) and not path_allowed(p,allow_dirty):
                violations.append(f'pre-existing dirty path changed without declared dirty scope: {p}')
        elif p in after_changed:
            if not path_allowed(p,allow): violations.append(f'worktree path outside declared write scope: {p}')
        if (status_changed or content_changed) and protected(p) and not path_allowed(p,allow_protected):
            violations.append(f'protected path changed without protected scope: {p}')

    bh=baseline['head']; ch=current['head']
    if bh.get('symbolic_ref') != ch.get('symbolic_ref') or bh.get('kind') != ch.get('kind') and bh.get('oid') == ch.get('oid'):
        violations.append('branch/HEAD attachment changed')
    committed=[]
    if bh.get('oid') != ch.get('oid'):
        if 'commit' not in transitions:
            violations.append('HEAD changed without declared commit transition')
        else:
            try: committed=_committed_paths(repo,bh,ch,budget)
            except ObservationError as e:
                return {'ok':False,'status':'NON_PASS','violations':[f'observation incomplete: {e}'],'observation':'incomplete'}
            for p in committed:
                if not path_allowed(p,allow): violations.append(f'committed path outside declared write scope: {p}')
                if protected(p) and not path_allowed(p,allow_protected): violations.append(f'committed protected path without protected scope: {p}')
                if p in before_changed: violations.append(f'pre-existing dirty path was incorporated into commit: {p}')

    # Local config/remotes are never authorized by stage/commit.
    if baseline.get('local_config_sha256') != current['local_config_sha256']:
        violations.append('local Git config/remotes changed')

    brefs=baseline.get('refs',{}); crefs=current['refs']; current_branch=ch.get('symbolic_ref')
    for ref in sorted(set(brefs)|set(crefs)):
        if brefs.get(ref)==crefs.get(ref): continue
        if 'commit' in transitions and ref == current_branch and crefs.get(ref)==ch.get('oid'):
            continue
        violations.append(f'Git ref changed outside allowed commit branch transition: {ref}')

    # Staging state is evaluated semantically. Declaring `stage` authorizes the
    # operation class; it never waives write/dirty/protected scope for an index delta.
    bstaged=set(baseline.get('staged_paths',[])); cstaged=set(current['staged_paths'])
    bindex=_index_map(baseline.get('index_entries',[])); cindex=_index_map(current['index_entries'])
    index_paths={k[0] for k in set(bindex)|set(cindex) if bindex.get(k) != cindex.get(k)}

    if 'stage' in transitions:
        # Additions, removals, mode changes and blob replacements all require scope.
        for p in sorted(index_paths | (bstaged ^ cstaged)):
            preexisting = p in before_changed or p in bstaged
            required = allow_dirty if preexisting else allow
            if not path_allowed(p,required):
                label='dirty' if preexisting else 'write'
                violations.append(f'semantic Git index path outside declared {label} scope: {p}')
            if protected(p) and not path_allowed(p,allow_protected):
                violations.append(f'staged protected path without protected scope: {p}')
    else:
        if cstaged != bstaged and 'commit' not in transitions:
            violations.append('staged paths changed without declared stage transition')
        if 'commit' not in transitions:
            if bindex != cindex:
                violations.append('semantic Git index changed without declared stage transition')
        else:
            # A commit may update index entries for paths actually committed. Any other
            # semantic delta, including a staged leftover that keeps the same path/status,
            # requires an explicit stage transition.
            for p in sorted(index_paths):
                before={k:v for k,v in bindex.items() if k[0]==p}
                after={k:v for k,v in cindex.items() if k[0]==p}
                explained_by_commit = p in committed and p not in cstaged
                if not explained_by_commit and before != after:
                    violations.append(f'semantic Git index changed without declared stage transition: {p}')

    bn=baseline.get('nested_repositories',{}); cn=current.get('nested_repositories',{})
    for rel in sorted(set(bn)|set(cn)):
        if rel not in bn or rel not in cn:
            if not path_allowed(rel,allow_nested): violations.append(f'nested repository boundary added/removed: {rel}')
            continue
        if bn[rel] != cn[rel] and not path_allowed(rel,allow_nested):
            violations.append(f'nested repository changed: {rel}')

    return {
        'ok':not violations,
        'status':'PASS' if not violations else 'DETECTED_AFTER_MUTATION',
        'violations':sorted(set(violations)),
        'observation':'complete',
        'committed_paths':committed,
        'limitations':current['coverage'],
        'budget':current['budget'],
        'terminology':{'guard':'advisory/rejected-before-execution only when caller honors result','verify':'before/after detection, not prevention'}
    }


def save_json(path: Path, data: dict) -> None:
    secure_write(path,json.dumps(data,ensure_ascii=False,indent=2,sort_keys=True)+'\n')


def load_json(path: Path) -> dict:
    return secure_read_json(path)


def _reason(code: str) -> tuple[str,str]:
    messages={
        'GIT_C_MISSING':'Git working-directory option is incomplete',
        'GIT_C_UNTRUSTED':'Git working-directory option requires review',
        'GIT_GLOBAL_OPTION_UNSUPPORTED':'Git global option is outside the allowlist',
        'GIT_SUBCOMMAND_MISSING':'Git subcommand is missing',
        'GIT_MUTATING':'Git mutating operation requires review',
        'GIT_SUBCOMMAND_UNSUPPORTED':'Git subcommand is outside the read-only allowlist',
        'GIT_EXTERNAL_BEHAVIOR':'Git option may invoke external behavior or write output',
        'GIT_REMOTE_QUERY':'Git remote operation may access network or mutate configuration',
        'GIT_BRANCH_MUTATION':'Git branch operation may mutate refs',
        'GIT_BRANCH_FORM_UNSUPPORTED':'Git branch argv form is outside the read-only allowlist',
        'READ_ONLY_GIT':'Explicit read-only Git argv allowlist',
        'READ_ONLY_PWD':'Explicit read-only pwd argv allowlist',
        'SHELL_META':'Shell syntax is outside the read-only classifier',
        'INVALID_SHELL':'Invalid shell quoting or syntax',
        'EMPTY_COMMAND':'Empty command',
        'ENV_ASSIGNMENT':'Leading environment assignment is outside the read-only allowlist',
        'EXECUTABLE_IDENTITY_UNTRUSTED':'Executable identity is not trusted for positive classification',
        'INTERPRETER':'Interpreter execution requires review',
        'NETWORK_TOOL':'Network-capable tool requires review',
        'DEPENDENCY_TOOL':'Dependency/tool manager requires review',
        'BUILD_RELEASE_TOOL':'Build/release/signing tool requires review',
        'EXECUTABLE_UNSUPPORTED':'Executable is outside the read-only allowlist',
    }
    return code,messages[code]


def _trusted_executable(raw: str) -> str | None:
    """Return a known executable name only when its filesystem identity is trusted.

    Positive classification is intentionally conservative: arbitrary relative paths are
    rejected, PATH is resolved in the classifier environment, and the resolved file must
    live under a root-owned system executable directory without group/other write bits.
    """
    known={'git','pwd'}
    has_component='/' in raw or '\\' in raw
    try:
        if has_component:
            candidate=Path(raw)
            if not candidate.is_absolute():
                return None
            resolved=candidate.resolve(strict=True)
        else:
            found=shutil.which(raw)
            if not found:
                return None
            resolved=Path(found).resolve(strict=True)
        name=resolved.name
        if name not in known:
            return None
        trusted_roots=[]
        for item in ('/usr/bin','/bin','/usr/sbin','/sbin'):
            try: trusted_roots.append(Path(item).resolve(strict=True))
            except OSError: pass
        if not any(resolved == root or root in resolved.parents for root in trusted_roots):
            return None
        st=os.stat(resolved,follow_symlinks=False)
        if not stat.S_ISREG(st.st_mode) or not os.access(resolved,os.X_OK):
            return None
        if os.name == 'posix' and st.st_uid != 0:
            return None
        if st.st_mode & (stat.S_IWGRP | stat.S_IWOTH):
            return None
        return name
    except (OSError,RuntimeError,ValueError):
        return None


def _git_command_classification(argv: list[str]) -> tuple[str,str,str]:
    i=1
    while i < len(argv) and argv[i].startswith('-'):
        tok=argv[i]
        if tok == '-C':
            if i+1 >= len(argv):
                code,msg=_reason('GIT_C_MISSING'); return 'REVIEW_UNSUPPORTED',code,msg
            target=argv[i+1]; pp=Path(target)
            if pp.is_absolute() or '..' in pp.parts or target.startswith('-') or '\x00' in target:
                code,msg=_reason('GIT_C_UNTRUSTED'); return 'REVIEW_UNSUPPORTED',code,msg
            i += 2; continue
        if tok.startswith('-C') and len(tok)>2:
            target=tok[2:]; pp=Path(target)
            if pp.is_absolute() or '..' in pp.parts:
                code,msg=_reason('GIT_C_UNTRUSTED'); return 'REVIEW_UNSUPPORTED',code,msg
            i += 1; continue
        code,msg=_reason('GIT_GLOBAL_OPTION_UNSUPPORTED'); return 'REVIEW_UNSUPPORTED',code,msg
    if i >= len(argv):
        code,msg=_reason('GIT_SUBCOMMAND_MISSING'); return 'REVIEW_UNSUPPORTED',code,msg
    sub=argv[i]; rest=argv[i+1:]
    if sub in MUTATING_GIT_SUBCOMMANDS:
        code,msg=_reason('GIT_MUTATING'); return 'REVIEW_UNSUPPORTED',code,msg
    if sub not in SAFE_GIT_SUBCOMMANDS:
        code,msg=_reason('GIT_SUBCOMMAND_UNSUPPORTED'); return 'REVIEW_UNSUPPORTED',code,msg
    dangerous={'--exec-path','--paginate','-p','--output','--ext-diff','--textconv'}
    if any(a in dangerous or a.startswith('--output=') for a in rest):
        code,msg=_reason('GIT_EXTERNAL_BEHAVIOR'); return 'REVIEW_UNSUPPORTED',code,msg
    if sub == 'remote':
        if not rest or rest == ['-v'] or rest == ['--verbose'] or (rest and rest[0] == 'get-url'):
            code,msg=_reason('READ_ONLY_GIT'); return 'ALLOW_READ_ONLY',code,msg
        code,msg=_reason('GIT_REMOTE_QUERY'); return 'REVIEW_UNSUPPORTED',code,msg
    if sub == 'branch':
        mutating_flags={'-d','-D','-m','-M','-c','-C','--delete','--move','--copy','--edit-description','--set-upstream-to','--unset-upstream'}
        if any(x in mutating_flags or any(x.startswith(f+'=') for f in mutating_flags if f.startswith('--')) for x in rest):
            code,msg=_reason('GIT_BRANCH_MUTATION'); return 'REVIEW_UNSUPPORTED',code,msg
        query_flags={'-a','--all','-r','--remotes','-l','--list','--show-current','--contains','--no-contains','--merged','--no-merged','-v','-vv','--verbose'}
        nonopts=[x for x in rest if not x.startswith('-')]
        if nonopts and not any(x in {'--contains','--no-contains','--merged','--no-merged'} for x in rest):
            code,msg=_reason('GIT_BRANCH_FORM_UNSUPPORTED'); return 'REVIEW_UNSUPPORTED',code,msg
        if rest and not any(x in query_flags or x.startswith('--contains=') or x.startswith('--merged=') or x.startswith('--no-merged=') for x in rest):
            code,msg=_reason('GIT_BRANCH_FORM_UNSUPPORTED'); return 'REVIEW_UNSUPPORTED',code,msg
    code,msg=_reason('READ_ONLY_GIT'); return 'ALLOW_READ_ONLY',code,msg


def command_guard(command: str) -> dict:
    digest=hash_text(command)
    code,msg=_reason('EXECUTABLE_UNSUPPORTED')
    result={'schema_version':2,'classifier':'advisory','command_sha256':digest,'classification':'REVIEW_UNSUPPORTED','executable':None,'reason_code':code,'reason':msg}
    def reject(reason_code: str, executable=None):
        c,m=_reason(reason_code); result.update({'reason_code':c,'reason':m})
        if executable is not None: result['executable']=executable
        return result
    if any(meta in command for meta in SHELL_META):
        return reject('SHELL_META')
    try: argv=shlex.split(command,posix=True)
    except ValueError:
        return reject('INVALID_SHELL')
    if not argv:
        return reject('EMPTY_COMMAND')
    assignment_count=0
    while assignment_count < len(argv) and '=' in argv[assignment_count]:
        key,_value=argv[assignment_count].split('=',1)
        if not key or not (key[0].isalpha() or key[0]=='_') or not all(c.isalnum() or c=='_' for c in key):
            break
        assignment_count += 1
    if assignment_count:
        return reject('ENV_ASSIGNMENT','unknown')

    raw_exe=argv[0]
    basename=Path(raw_exe).name
    # Tools that are never green can be categorized by a fixed allowlisted name without
    # trusting their executable identity; positive classifications require _trusted_executable.
    if basename in INTERPRETERS:
        return reject('INTERPRETER',basename)
    if basename in NETWORK_TOOLS:
        return reject('NETWORK_TOOL',basename)
    if basename in DEPENDENCY_TOOLS:
        return reject('DEPENDENCY_TOOL',basename)
    if basename in RELEASE_TOOLS or basename == 'xcodebuild':
        return reject('BUILD_RELEASE_TOOL',basename)

    trusted=_trusted_executable(raw_exe)
    if basename in {'git','pwd'} and trusted is None:
        return reject('EXECUTABLE_IDENTITY_UNTRUSTED','unknown')
    if trusted == 'git':
        normalized=['git']+argv[1:]
        classification,reason_code,reason=_git_command_classification(normalized)
        result.update({'classification':classification,'executable':'git','reason_code':reason_code,'reason':reason})
        return result
    if trusted == 'pwd' and len(argv)==1:
        c,m=_reason('READ_ONLY_PWD'); result.update({'classification':'ALLOW_READ_ONLY','executable':'pwd','reason_code':c,'reason':m}); return result
    return reject('EXECUTABLE_UNSUPPORTED','unknown')


def scan_build_phases(repo: Path, budget=None) -> dict:
    budget=budget or Budget(max_files_visited=20000,max_files_inspected=5000,max_total_bytes=32*1024*1024,max_file_bytes=4*1024*1024,total_deadline_seconds=30)
    findings=[]; errors=[]; coverage=[]
    try:
        repo=git_root(repo,budget)
        for base,dirs,files in os.walk(repo,topdown=True,followlinks=False,onerror=lambda e: (_ for _ in ()).throw(ObservationError('directory walk failed'))):
            budget.check_deadline(); bp=Path(base)
            nd=[]
            for d in dirs:
                budget.visit(); p=bp/d
                if d in EXCLUDED_DIRS: continue
                if stat.S_ISLNK(os.lstat(p).st_mode): continue
                nd.append(d)
            dirs[:]=nd
            for fn in files:
                budget.visit(); p=bp/fn
                rel=str(p.relative_to(repo))
                interesting = fn=='project.pbxproj' or fn.endswith('.xcscheme') or fn=='Package.swift'
                if not interesting: continue
                try:
                    raw=read_regular_nofollow(p,budget,f'build-surface file {rel}')
                    text=_decode_utf8(raw,f'build-surface file {rel}')
                except ObservationError as e:
                    errors.append({'path':rel,'kind':'unreadable_or_malformed','detail':type(e).__name__}); continue
                if fn=='project.pbxproj':
                    coverage.append({'path':rel,'surface':'PBXShellScriptBuildPhase','status':'parsed'})
                    if 'PBXProject' not in text or 'objects = {' not in text:
                        errors.append({'path':rel,'kind':'malformed_pbxproj'}); continue
                    count=text.count('PBXShellScriptBuildPhase')
                    if count: findings.append({'path':rel,'surface':'PBXShellScriptBuildPhase','occurrences':count})
                elif fn.endswith('.xcscheme'):
                    coverage.append({'path':rel,'surface':'scheme_pre_post_actions','status':'parsed'})
                    if '<Scheme' not in text:
                        errors.append({'path':rel,'kind':'malformed_xcscheme'}); continue
                    for tag in ('PreActions','PostActions','ExecutionAction'):
                        c=text.count('<'+tag)
                        if c: findings.append({'path':rel,'surface':tag,'occurrences':c})
                elif fn=='Package.swift':
                    coverage.append({'path':rel,'surface':'SwiftPM_plugins_macros_build_tools','status':'heuristic'})
                    for needle,label in [('.plugin(','SwiftPM plugin declaration'),('.macro(','Swift macro declaration'),('Plugins/','plugin path reference')]:
                        c=text.count(needle)
                        if c: findings.append({'path':rel,'surface':label,'occurrences':c})
        status='complete' if not errors else 'partial'
    except ObservationError as e:
        status='incomplete'; errors.append({'kind':'observation_incomplete','detail':str(e)})
    return {
        'status':status,
        'coverage':coverage,
        'findings':findings,
        'errors':errors,
        'limitations':['Static inspection cannot prove the complete Xcode/SwiftPM executable graph or runtime side effects.','Generated build tools and dependencies may add executable surfaces not visible in inspected files.'],
        'review_required':True,
        'safe_to_assume_read_only':False,
        'budget':budget.summary(),
    }
