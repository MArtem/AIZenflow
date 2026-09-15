#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import argparse, configparser, errno, functools, hashlib, json, os, re, secrets, shutil, stat, tempfile, time

HERE = Path(__file__).resolve().parent
G = HERE / 'GLOBAL_CODEX'
VERSION = '5.4-review-ready.7'
PROTECTION_VERSION = '5.4-review-ready.5'
REGISTRY_NAME = 'ios-engineering-global.json'
BEGIN = '<!-- IOS_ENGINEERING_GLOBAL:BEGIN -->'
END = '<!-- IOS_ENGINEERING_GLOBAL:END -->'
TEXT_LIMIT = 2 * 1024 * 1024
MANAGED_MAX_ENTRIES = 100000
MANAGED_MAX_BYTES = 512 * 1024 * 1024
SESSION_SCAN_MAX_REPOSITORIES = 10000
SESSION_SCAN_MAX_RECORDS = 10000
SESSION_SCAN_MAX_FILE_BYTES = 4 * 1024 * 1024
SESSION_SCAN_MAX_BYTES = 32 * 1024 * 1024
SESSION_SCAN_DEADLINE_SECONDS = 10.0
CANONICAL_REPOSITORY_RUNTIME_PROFILE = 'canonical_repository_runtime'
CANONICAL_REPOSITORY_RUNTIME_RELATIVE = Path('.codex-runtime') / 'ios-engineering'
CANONICAL_REPOSITORY_REMOTE = 'https://github.com/MArtem/AIZenflowDocumentation'
MAX_GIT_CONFIG_BYTES = 256 * 1024

class InstallError(RuntimeError):
    pass

class RollbackIncomplete(InstallError):
    """A mutation failed and safe rollback could not fully restore the pre-state without risking user data."""
    pass


def _walk_fail(label):
    def onerror(error):
        raise InstallError(f'{label} directory walk failed: {type(error).__name__}')
    return onerror


def abs_lex(value) -> Path:
    """Absolute lexical path; intentionally does not resolve symlinks."""
    return Path(os.path.abspath(os.path.expanduser(str(value))))


def read_regular_snapshot(p: Path, max_bytes=TEXT_LIMIT, *, expected_identity=None, deadline=None):
    """Bounded no-follow read plus stable permission snapshot for one regular file."""
    p = abs_lex(p)
    pfd = _open_dir_chain(p.parent, create=False)
    fd = None
    try:
        # O_NONBLOCK is required before fstat: opening a FIFO read-only otherwise waits for
        # a writer and defeats the fail-closed non-regular-file check below.
        if not hasattr(os, 'O_NONBLOCK'):
            raise InstallError('safe installer I/O requires O_NONBLOCK')
        fd = os.open(p.name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=pfd)
        st = os.fstat(fd)
        if not stat.S_ISREG(st.st_mode):
            raise InstallError(f'not a regular file: {p}')
        current_identity = (st.st_dev, st.st_ino, st.st_size, st.st_mtime_ns)
        if expected_identity is not None and current_identity != expected_identity:
            raise InstallError(f'file changed before read: {p}')
        if st.st_size > max_bytes:
            raise InstallError(f'file exceeds safe read budget: {p}')
        data = bytearray()
        while len(data) < st.st_size:
            if deadline is not None and time.monotonic() > deadline:
                raise InstallError(f'bounded read deadline exceeded: {p}')
            chunk = os.read(fd, min(65536, st.st_size - len(data)))
            if not chunk:
                break
            data.extend(chunk)
        if deadline is not None and time.monotonic() > deadline:
            raise InstallError(f'bounded read deadline exceeded: {p}')
        end = os.fstat(fd)
        if len(data) != st.st_size or (end.st_dev, end.st_ino, end.st_size, end.st_mtime_ns) != (st.st_dev, st.st_ino, st.st_size, st.st_mtime_ns):
            raise InstallError(f'file changed or was incompletely read: {p}')
        return bytes(data), stat.S_IMODE(st.st_mode)
    except OSError as e:
        if e.errno in (errno.ELOOP, errno.ENOTDIR):
            raise InstallError(f'refusing symlink/non-regular read target: {p}') from e
        raise
    finally:
        if fd is not None:
            os.close(fd)
        os.close(pfd)


def read_regular_bytes(p: Path, max_bytes=TEXT_LIMIT):
    return read_regular_snapshot(p, max_bytes)[0]


def sha_file(p: Path):
    """Streaming no-follow hash; never buffers a managed/package file in full."""
    p = abs_lex(p)
    pfd = _open_dir_chain(p.parent, create=False)
    fd = None
    try:
        fd = os.open(p.name, os.O_RDONLY | os.O_NOFOLLOW, dir_fd=pfd)
        st = os.fstat(fd)
        if not stat.S_ISREG(st.st_mode):
            raise InstallError(f'not a regular file: {p}')
        if st.st_size > MANAGED_MAX_BYTES:
            raise InstallError(f'file exceeds managed hash budget: {p}')
        h = hashlib.sha256(); total = 0
        while total < st.st_size:
            chunk = os.read(fd, min(65536, st.st_size-total))
            if not chunk:
                break
            total += len(chunk); h.update(chunk)
        end = os.fstat(fd)
        if total != st.st_size or (end.st_dev, end.st_ino, end.st_size, end.st_mtime_ns) != (st.st_dev, st.st_ino, st.st_size, st.st_mtime_ns):
            raise InstallError(f'file changed or was incompletely hashed: {p}')
        return h.hexdigest()
    except OSError as e:
        if e.errno in (errno.ELOOP, errno.ENOTDIR):
            raise InstallError(f'refusing symlink/non-regular hash target: {p}') from e
        raise
    finally:
        if fd is not None: os.close(fd)
        os.close(pfd)


def sha_bytes(b: bytes):
    return hashlib.sha256(b).hexdigest()


def canonical_hash(obj):
    return hashlib.sha256(json.dumps(obj, sort_keys=True, separators=(',', ':')).encode()).hexdigest()


def _package_rows(root: Path = HERE):
    root = abs_lex(root)
    rows = []
    visited = 0
    total = 0
    for base, dirs, files in os.walk(root, topdown=True, followlinks=False, onerror=_walk_fail('package')):
        bp = Path(base)
        kept = []
        for d in sorted(dirs):
            visited += 1
            q = bp / d
            if visited > MANAGED_MAX_ENTRIES:
                raise InstallError('package entry budget exceeded')
            st = os.lstat(q)
            if stat.S_ISLNK(st.st_mode):
                raise InstallError(f'package contains symlink directory: {q.relative_to(root)}')
            if not stat.S_ISDIR(st.st_mode):
                raise InstallError(f'package contains non-directory entry: {q.relative_to(root)}')
            kept.append(d)
        dirs[:] = kept
        for fn in sorted(files):
            visited += 1
            q = bp / fn
            if visited > MANAGED_MAX_ENTRIES:
                raise InstallError('package entry budget exceeded')
            st = os.lstat(q)
            if stat.S_ISLNK(st.st_mode):
                raise InstallError(f'package contains symlink file: {q.relative_to(root)}')
            if not stat.S_ISREG(st.st_mode):
                raise InstallError(f'package contains non-regular file: {q.relative_to(root)}')
            if '__pycache__' in q.parts or q.suffix == '.pyc':
                continue
            # The generated validation report includes the package identity, so excluding
            # it avoids a circular hash while keeping all executable/source inputs covered.
            if q.name == 'REVIEW_READY_VALIDATION_REPORT.md':
                continue
            total += st.st_size
            if total > MANAGED_MAX_BYTES:
                raise InstallError('package byte budget exceeded')
            rows.append([q.relative_to(root).as_posix(), sha_file(q)])
    rows.sort(key=lambda row: row[0])
    return rows


@functools.lru_cache(maxsize=8)
def package_tree_identity(root: Path = HERE):
    return canonical_hash(_package_rows(root))


def codex_home(v=None):
    return abs_lex(v or os.environ.get('CODEX_HOME', str(Path.home() / '.codex')))


def choose_skills_root(v, ch):
    if v in (None, 'auto'):
        return abs_lex(Path.home() / '.agents' / 'skills')
    if v == 'codex-home':
        return abs_lex(ch / 'skills')
    if v == 'agents':
        return abs_lex(Path.home() / '.agents' / 'skills')
    return abs_lex(v)


def lexists(p: Path):
    return os.path.lexists(str(p))


def active_agents_file(ch, explicit=None):
    over = ch / 'AGENTS.override.md'
    override_is_active = False
    if lexists(over):
        st = os.lstat(over)
        if stat.S_ISLNK(st.st_mode):
            override_is_active = True  # preflight reports it as an unsafe target instead of following it
        elif not stat.S_ISREG(st.st_mode) or st.st_size > TEXT_LIMIT:
            # An uninspectable override is still the effective target.  Falling back to
            # AGENTS.md could silently write a different instruction file.
            override_is_active = True
        else:
            try:
                if read_regular_bytes(over, TEXT_LIMIT).decode('utf-8').strip():
                    override_is_active = True
            except (OSError, UnicodeDecodeError, InstallError):
                override_is_active = True
    # The conventional AGENTS.md argument must not bypass a non-empty override. A deliberately
    # different explicit path remains an intentional caller selection.
    if explicit:
        selected = abs_lex(explicit)
        if selected != abs_lex(ch / 'AGENTS.md') or not override_is_active:
            return selected
    if override_is_active:
        return over
    return ch / 'AGENTS.md'


def _path_contains(parent: Path, child: Path) -> bool:
    try:
        child.relative_to(parent)
        return True
    except ValueError:
        return False


def _existing_ancestor(path: Path) -> Path:
    current = abs_lex(path)
    while not lexists(current) and current != current.parent:
        current = current.parent
    return current


def _git_root_for_destination(path: Path):
    """Find a lexical Git root without invoking Git or following a target symlink."""
    current = _existing_ancestor(path)
    while True:
        marker = current / '.git'
        if lexists(marker):
            try:
                marker_stat = os.lstat(marker)
                if stat.S_ISLNK(marker_stat.st_mode):
                    return current, 'symlink .git marker'
                if stat.S_ISDIR(marker_stat.st_mode) or stat.S_ISREG(marker_stat.st_mode):
                    return current, None
            except OSError as error:
                return current, f'unreadable .git marker: {type(error).__name__}'
        if current == current.parent:
            return None, None
        current = current.parent


def _normalize_canonical_remote(value: str):
    value = value.strip()
    if value.startswith('git@github.com:'):
        value = 'https://github.com/' + value[len('git@github.com:'):]
    elif value.startswith('ssh://git@github.com/'):
        value = 'https://github.com/' + value[len('ssh://git@github.com/'):]
    value = value.rstrip('/')
    if value.endswith('.git'):
        value = value[:-4]
    return value.rstrip('/')


def _canonical_repository_identity(root: Path):
    """Verify the explicitly selected canonical documentation repository by root and origin."""
    root = abs_lex(root)
    detected, issue = _git_root_for_destination(root)
    if issue:
        return None, f'canonical repository Git marker is unsafe: {issue}: {detected}'
    if detected != root:
        return None, f'canonical repository root mismatch: detected {detected}, requested {root}'
    marker = root / '.git'
    try:
        marker_stat = os.lstat(marker)
        if not stat.S_ISDIR(marker_stat.st_mode):
            return None, f'canonical repository .git marker is not a directory: {marker}'
        config = configparser.ConfigParser(interpolation=None, strict=False)
        config.read_string(read_regular_bytes(marker / 'config', MAX_GIT_CONFIG_BYTES).decode('utf-8'))
        remote = config.get('remote "origin"', 'url', fallback=None)
    except Exception as error:
        return None, f'canonical repository origin is unreadable: {type(error).__name__}'
    if _normalize_canonical_remote(remote or '') != CANONICAL_REPOSITORY_REMOTE:
        return None, 'canonical repository origin is not MArtem/AIZenflowDocumentation'
    return root, None


def _canonical_runtime_admission(targets, *, canonical_repository_root=None,
                                 allow_canonical_repository_runtime=False):
    """Return the narrow, explicit exception for the canonical repository runtime subtree."""
    if not allow_canonical_repository_runtime:
        return None, []
    if canonical_repository_root is None:
        return None, ['canonical repository runtime requires --canonical-repository-root']
    root, issue = _canonical_repository_identity(Path(canonical_repository_root))
    if issue:
        return None, [issue]
    runtime = root / CANONICAL_REPOSITORY_RUNTIME_RELATIVE
    home = abs_lex(targets.get('codex_home'))
    collisions = []
    if home != runtime:
        collisions.append(f'canonical repository runtime must use exact CODEX_HOME: {runtime}')
    for label, path in targets.items():
        path = abs_lex(path)
        if label in {'release_root', 'content_root'}:
            continue
        if not _path_contains(runtime, path):
            collisions.append(f'{label}: canonical runtime target escapes managed runtime root: {path}')
    return root, collisions


def destination_layout_collisions(targets, *, source_root=None, source_in_place=False,
                                  canonical_repository_root=None,
                                  allow_canonical_repository_runtime=False):
    """Reject client-repository destinations and unintended target overlap.

    The Codex home is the only intended container: its managed children may overlap it. The
    immutable source release may live in its own library repository, but no mutable destination
    may be inside that release tree or any client Git repository.
    """
    rows = [(label, abs_lex(path)) for label, path in targets.items()]
    collisions = []
    source = abs_lex(source_root) if source_root is not None else None
    canonical_root, canonical_collisions = _canonical_runtime_admission(
        dict(rows), canonical_repository_root=canonical_repository_root,
        allow_canonical_repository_runtime=allow_canonical_repository_runtime)
    collisions.extend(canonical_collisions)
    canonical_runtime = (canonical_root / CANONICAL_REPOSITORY_RUNTIME_RELATIVE
                         if canonical_root is not None else None)
    for label, path in rows:
        if label == 'release_root' or (source_in_place and label == 'content_root'):
            continue
        git_root, issue = _git_root_for_destination(path)
        if issue:
            collisions.append(f'{label}: {issue}: {git_root}')
        elif git_root is not None and not (
                canonical_runtime is not None and git_root == canonical_root and
                _path_contains(canonical_runtime, path)):
            collisions.append(f'{label}: installation destination is inside client Git repository: {git_root}')
    if source is not None:
        for label, path in rows:
            if label in {'release_root', 'content_root'} and source_in_place:
                continue
            if label == 'codex_home' and _path_contains(path, source):
                # A versioned payload may be stored below the active Codex home; the managed
                # children remain separate destinations and are checked independently below.
                continue
            if _path_contains(source, path) or _path_contains(path, source):
                collisions.append(f'{label}: destination overlaps immutable release root: {path}')
    for index, (left_label, left) in enumerate(rows):
        for right_label, right in rows[index + 1:]:
            if left_label == 'codex_home' or right_label == 'codex_home':
                continue
            if _path_contains(left, right) or _path_contains(right, left):
                collisions.append(f'destination overlap: {left_label}={left} and {right_label}={right}')
    return sorted(set(collisions))


def reject_symlink_path(p: Path, allow_missing_final=True):
    p = abs_lex(p)
    cur = Path(p.anchor)
    parts = p.parts[1:] if p.anchor else p.parts
    for part in parts:
        cur = cur / part
        if not lexists(cur):
            if allow_missing_final:
                continue
            raise InstallError(f'missing required path component: {cur}')
        st = os.lstat(cur)
        if stat.S_ISLNK(st.st_mode):
            raise InstallError(f'refusing symlink installation path component: {cur}')


def _open_dir_chain(path: Path, create=False, mode=0o700) -> int:
    path = abs_lex(path)
    if not hasattr(os, 'O_NOFOLLOW') or not hasattr(os, 'O_DIRECTORY'):
        raise InstallError('safe installer I/O requires O_NOFOLLOW and O_DIRECTORY')
    fd = os.open(path.anchor or '/', os.O_RDONLY | os.O_DIRECTORY)
    try:
        parts = path.parts[1:] if path.anchor else path.parts
        for part in parts:
            try:
                nfd = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            except FileNotFoundError:
                if not create:
                    raise
                os.mkdir(part, mode=mode, dir_fd=fd)
                nfd = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            except OSError as e:
                if e.errno in (errno.ELOOP, errno.ENOTDIR):
                    raise InstallError(f'refusing symlink/non-directory installer path component: {part}') from e
                raise
            os.close(fd)
            fd = nfd
        return fd
    except Exception:
        os.close(fd)
        raise


def ensure_dir(path: Path, mode=0o700) -> Path:
    fd = _open_dir_chain(path, create=True, mode=mode)
    os.close(fd)
    return abs_lex(path)


def enforce_dir_mode(path: Path, mode=0o700) -> Path:
    """Enforce mode on a library-owned directory through a stable no-follow fd."""
    path = abs_lex(path)
    fd = _open_dir_chain(path, create=True, mode=mode)
    try:
        os.fchmod(fd, mode)
        if stat.S_IMODE(os.fstat(fd).st_mode) != mode:
            raise InstallError(f'cannot enforce directory mode {oct(mode)}: {path}')
    finally:
        os.close(fd)
    return path


def write_atomic(path: Path, data: bytes, mode=0o600):
    """No-follow, same-directory atomic publication for installer-owned text/state files."""
    path = abs_lex(path)
    ensure_dir(path.parent)
    pfd = _open_dir_chain(path.parent, create=False)
    name = path.name
    tmp = f'.{name}.tmp.{os.getpid()}.{secrets.token_hex(8)}'
    fd = None
    try:
        try:
            st = os.stat(name, dir_fd=pfd, follow_symlinks=False)
            if stat.S_ISLNK(st.st_mode) or not stat.S_ISREG(st.st_mode):
                raise InstallError(f'refusing non-regular/symlink destination: {path}')
        except FileNotFoundError:
            pass
        fd = os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, mode, dir_fd=pfd)
        os.fchmod(fd, mode)
        off = 0
        while off < len(data):
            off += os.write(fd, data[off:])
        os.fsync(fd)
        os.close(fd)
        fd = None
        # If destination is raced to a symlink, replace renames the link itself and does
        # not follow its target. Stable parent dir-fd removes parent-component races.
        os.replace(tmp, name, src_dir_fd=pfd, dst_dir_fd=pfd)
        os.fsync(pfd)
        st = os.stat(name, dir_fd=pfd, follow_symlinks=False)
        if not stat.S_ISREG(st.st_mode) or stat.S_IMODE(st.st_mode) != mode:
            raise InstallError(f'atomic write publication verification failed: {path}')
    finally:
        if fd is not None:
            try:
                os.close(fd)
            except OSError:
                pass
        try:
            os.unlink(tmp, dir_fd=pfd)
        except FileNotFoundError:
            pass
        os.close(pfd)


def write_new_atomic(path: Path, data: bytes, mode=0o600):
    """Publish a fully written new file without replacing any raced-in destination."""
    path = abs_lex(path)
    ensure_dir(path.parent)
    pfd = _open_dir_chain(path.parent, create=False)
    name = path.name
    tmp = f'.{name}.tmp.{os.getpid()}.{secrets.token_hex(8)}'
    fd = None
    try:
        fd = os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, mode, dir_fd=pfd)
        os.fchmod(fd, mode)
        off = 0
        while off < len(data):
            off += os.write(fd, data[off:])
        os.fsync(fd); os.close(fd); fd = None
        try:
            os.link(tmp, name, src_dir_fd=pfd, dst_dir_fd=pfd, follow_symlinks=False)
        except FileExistsError as e:
            raise InstallError(f'destination appeared concurrently; refusing overwrite: {path}') from e
        os.unlink(tmp, dir_fd=pfd)
        os.fsync(pfd)
        st = os.stat(name, dir_fd=pfd, follow_symlinks=False)
        if not stat.S_ISREG(st.st_mode) or stat.S_IMODE(st.st_mode) != mode:
            raise InstallError(f'new-file publication verification failed: {path}')
    finally:
        if fd is not None:
            try: os.close(fd)
            except OSError: pass
        try: os.unlink(tmp, dir_fd=pfd)
        except FileNotFoundError: pass
        os.close(pfd)


def unlink_nofollow_file(path: Path, *, missing_ok: bool = False) -> None:
    """Unlink one regular file or symlink entry through a stable no-follow parent dir-fd.

    This never follows the final path. Directories/special files are rejected.
    """
    path = abs_lex(path)
    pfd = _open_dir_chain(path.parent, create=False)
    try:
        try:
            st = os.stat(path.name, dir_fd=pfd, follow_symlinks=False)
        except FileNotFoundError:
            if missing_ok:
                return
            raise
        if stat.S_ISDIR(st.st_mode) or not (stat.S_ISREG(st.st_mode) or stat.S_ISLNK(st.st_mode)):
            raise InstallError(f'refusing unlink of directory/special file: {path}')
        os.unlink(path.name, dir_fd=pfd)
        os.fsync(pfd)
    finally:
        os.close(pfd)


def read_registry(ch):
    p = abs_lex(ch / REGISTRY_NAME)
    if not lexists(p):
        return None
    try:
        raw = read_regular_bytes(p, TEXT_LIMIT)
        return json.loads(raw.decode('utf-8'))
    except (UnicodeDecodeError, json.JSONDecodeError, InstallError, OSError) as e:
        raise InstallError('malformed or unsafe installation registry') from e


def incompatible_active_sessions(state_root: Path, protection_version=PROTECTION_VERSION):
    """Read-only admission check for active sessions from older protection contracts."""
    state_root = abs_lex(state_root)
    if not lexists(state_root):
        return []
    reject_symlink_path(state_root)
    repositories = state_root / 'repositories'
    if not lexists(repositories):
        return []
    reject_symlink_path(repositories)
    if not repositories.is_dir():
        raise InstallError('protection repositories state root is not a directory')
    blockers = []
    repository_count = 0
    record_count = 0
    bytes_read = 0
    deadline = time.monotonic() + SESSION_SCAN_DEADLINE_SECONDS

    def check_deadline():
        if time.monotonic() > deadline:
            raise InstallError('active-session admission deadline exceeded')

    # Keep directory iteration streamed. The collision output is sorted by build_preflight, so
    # deterministic complete directory materialization is unnecessary and unsafe for large roots.
    with os.scandir(repositories) as repository_entries:
        for repo_entry in repository_entries:
            check_deadline()
            repository_count += 1
            if repository_count > SESSION_SCAN_MAX_REPOSITORIES:
                raise InstallError('active-session admission repository budget exceeded')
            if repo_entry.is_symlink():
                raise InstallError('symlink in protection repositories state root')
            if not repo_entry.is_dir(follow_symlinks=False):
                continue
            sessions = Path(repo_entry.path) / 'protection' / 'sessions'
            if not lexists(sessions):
                continue
            reject_symlink_path(sessions)
            if not sessions.is_dir():
                raise InstallError('protection sessions root is not a directory')
            with os.scandir(sessions) as session_entries:
                for session_entry in session_entries:
                    check_deadline()
                    if not session_entry.name.endswith('.json'):
                        continue
                    record_count += 1
                    if record_count > SESSION_SCAN_MAX_RECORDS:
                        raise InstallError('active-session admission record budget exceeded')
                    if session_entry.is_symlink() or not session_entry.is_file(follow_symlinks=False):
                        raise InstallError('unsafe protection session record')
                    observed = session_entry.stat(follow_symlinks=False)
                    identity = (observed.st_dev, observed.st_ino, observed.st_size, observed.st_mtime_ns)
                    if observed.st_size > SESSION_SCAN_MAX_FILE_BYTES:
                        raise InstallError('active-session admission per-file byte budget exceeded')
                    raw, _ = read_regular_snapshot(
                        Path(session_entry.path),
                        SESSION_SCAN_MAX_FILE_BYTES,
                        expected_identity=identity,
                        deadline=deadline,
                    )
                    bytes_read += len(raw)
                    if bytes_read > SESSION_SCAN_MAX_BYTES:
                        raise InstallError('active-session admission byte budget exceeded')
                    try:
                        data = json.loads(raw.decode('utf-8'))
                    except (UnicodeDecodeError, json.JSONDecodeError) as error:
                        raise InstallError('malformed protection session record') from error
                    check_deadline()
                    if not isinstance(data, dict):
                        raise InstallError('malformed protection session record')
                    lifecycle = data.get('lifecycle')
                    if lifecycle not in {'active', 'verified', 'closed'}:
                        raise InstallError(f'unknown protection session lifecycle: {lifecycle!r}')
                    if lifecycle == 'closed':
                        continue
                    baseline = data.get('baseline')
                    if not isinstance(baseline, dict) or not isinstance(baseline.get('protection_version'), str):
                        raise InstallError('active protection session has no valid protection version')
                    if baseline['protection_version'] != protection_version:
                        blockers.append({
                            'session_id': data.get('session_id', Path(session_entry.name).stem),
                            'lifecycle': lifecycle,
                            'protection_version': baseline['protection_version'],
                            'required_protection_version': protection_version,
                            'state_record': str(Path(session_entry.path)),
                        })
    check_deadline()
    return blockers


def _safe_rel(rel: str) -> Path:
    p = Path(rel)
    if p.is_absolute() or '..' in p.parts or not rel:
        raise InstallError(f'invalid managed relative path: {rel!r}')
    return p


def managed_hashes(root: Path):
    root = abs_lex(root)
    reject_symlink_path(root)
    rows = {}
    if not root.exists():
        return rows
    entries = 0
    total = 0
    for base, dirs, files in os.walk(root, topdown=True, followlinks=False, onerror=_walk_fail('managed tree')):
        bp = Path(base)
        kept = []
        for d in sorted(dirs):
            entries += 1
            if entries > MANAGED_MAX_ENTRIES:
                raise InstallError('managed tree entry budget exceeded')
            q = bp / d
            st = os.lstat(q)
            if stat.S_ISLNK(st.st_mode):
                raise InstallError(f'managed tree unexpectedly contains symlink: {q}')
            if not stat.S_ISDIR(st.st_mode):
                raise InstallError(f'managed tree contains non-directory entry: {q}')
            kept.append(d)
        dirs[:] = kept
        for fn in sorted(files):
            entries += 1
            if entries > MANAGED_MAX_ENTRIES:
                raise InstallError('managed tree entry budget exceeded')
            q = bp / fn
            st = os.lstat(q)
            if stat.S_ISLNK(st.st_mode):
                raise InstallError(f'managed tree unexpectedly contains symlink: {q}')
            if not stat.S_ISREG(st.st_mode):
                raise InstallError(f'managed tree contains non-regular file: {q}')
            total += st.st_size
            if total > MANAGED_MAX_BYTES:
                raise InstallError('managed tree byte budget exceeded')
            rows[q.relative_to(root).as_posix()] = sha_file(q)
    return rows


def check_existing_managed(root: Path, expected: dict):
    problems = []
    root = abs_lex(root)
    try:
        reject_symlink_path(root)
    except InstallError as e:
        return [str(e)]
    if not root.exists():
        return ['managed root missing']
    try:
        current = managed_hashes(root)
    except InstallError as e:
        return [str(e)]
    for rel, h in expected.items():
        try:
            _safe_rel(rel)
        except InstallError as e:
            problems.append(str(e))
            continue
        if current.get(rel) != h:
            problems.append(f'modified/missing managed file: {rel}')
    for rel in current:
        if rel not in expected:
            problems.append(f'unknown file inside managed root: {rel}')
    return problems


def deployment_descriptor(*, mode: str, library_root: Path, runtime_cli: Path,
                          state_root: Path, source_tree_sha256: str,
                          generated_by: str):
    """Return the single data-only contract consumed by both deployment paths.

    Paths are deliberately absolute and explicit. The runtime shim validates this record
    before executing anything, so it never falls back to a guessed CODEX_HOME payload.
    """
    return {
        'schema_version': 1,
        'managed_by': 'ios-engineering-library',
        'release_id': VERSION,
        'protection_version': PROTECTION_VERSION,
        'mode': mode,
        'knowledge_root': str(abs_lex(library_root)),
        'runtime_cli': str(abs_lex(runtime_cli)),
        'state_root': str(abs_lex(state_root)),
        'source_tree_sha256': source_tree_sha256,
        'generated_by': generated_by,
    }


def descriptor_bytes(**kwargs):
    return (json.dumps(deployment_descriptor(**kwargs), indent=2, sort_keys=True) + '\n').encode('utf-8')


def render_installation(runtime_cli: Path, library_root: Path, state_root: Path):
    return f'''# Installation paths — generated by installer\n\n- Runtime shim: `python3 "{runtime_cli}"`\n- Deployment descriptor: `{Path(runtime_cli).parent.parent / "INSTALLATION.json"}`\n- Knowledge root: `{library_root}`\n- External state root: `{state_root}`\n\nThe descriptor is the authoritative selected-release contract. The shim validates it before launch and fails closed if it is missing, malformed, or points outside the declared knowledge root.\n\nSafety contract: repository-local rules remain authoritative for project conventions. Library knowledge is advisory and never grants build/test/network/Git/release permission.\n'''


def agents_separator(old: bytes) -> bytes:
    if not old:
        return b''
    return b'' if old.endswith(b'\n\n') else (b'\n' if old.endswith(b'\n') else b'\n\n')


def merge_block_bytes(old: bytes, block: str):
    try:
        text = old.decode('utf-8')
    except UnicodeDecodeError as e:
        raise InstallError('AGENTS file is not UTF-8; refusing automatic merge') from e
    if len(old) > TEXT_LIMIT:
        raise InstallError('AGENTS file exceeds safe merge budget')
    pat = re.compile(re.escape(BEGIN) + r'.*?' + re.escape(END), re.S)
    if pat.search(text):
        raise InstallError('global iOS library block already exists without a trusted current transaction; use sync or uninstall first')
    block_bytes = block.rstrip().encode('utf-8') + b'\n'
    return old + agents_separator(old) + block_bytes


def build_preflight(args, for_update=False):
    ch = codex_home(args.codex_home)
    skills = choose_skills_root(args.skills_root, ch)
    agents = active_agents_file(ch, args.agents_file)
    content = HERE if args.use_source_in_place else abs_lex(args.runtime_root or ch / 'ios-engineering')
    shim = abs_lex(ch / 'ios-engineering-shim')
    state = abs_lex(ch / 'ios-engineering-state')
    registry = abs_lex(ch / REGISTRY_NAME)
    names = skill_names() if args.mode == 'full' else []
    collisions = []
    managed_modified = []

    path_targets = {
        'codex_home': ch,
        'skills_root': skills,
        'agents_file': agents,
        # In source-in-place mode this remains the immutable release root.  It is
        # included for the descriptor, but destination_layout_collisions explicitly
        # skips it; using CODEX_HOME here falsely makes every managed child overlap
        # the content root and blocks otherwise safe installs.
        'content_root': content,
        'shim_root': shim,
        'state_root': state,
        'registry': registry,
    }
    unsafe_path = False
    for label, target in path_targets.items():
        try:
            reject_symlink_path(target)
        except (OSError, InstallError) as e:
            collisions.append(f'{label}: {e}')
            unsafe_path = True
    collisions.extend(destination_layout_collisions(
        path_targets,
        source_root=HERE,
        source_in_place=bool(args.use_source_in_place),
        canonical_repository_root=getattr(args, 'canonical_repository_root', None),
        allow_canonical_repository_runtime=bool(getattr(args, 'allow_canonical_repository_runtime', False)),
    ))

    try:
        source_tree_sha256 = package_tree_identity()
    except (OSError, InstallError) as e:
        collisions.append(f'package source invalid: {e}')
        source_tree_sha256 = None

    existing = None
    if not unsafe_path:
        try:
            existing = read_registry(ch)
        except InstallError as e:
            collisions.append(f'registry: {e}')

        if agents.exists():
            try:
                raw_agents = read_regular_bytes(agents, TEXT_LIMIT)
                raw_agents.decode('utf-8')
            except UnicodeDecodeError:
                collisions.append(f'AGENTS file is not UTF-8: {agents}')
            except (OSError, InstallError) as e:
                collisions.append(f'AGENTS file unreadable: {agents}: {type(e).__name__}')

        marker = state / '.ioslib-state-owned.json'
        if lexists(marker) and not existing:
            collisions.append(f'pre-existing state ownership marker collision: {marker}')
        if not for_update and existing:
            collisions.append(f'existing managed installation registry: {registry}')
        if not args.use_source_in_place and content.exists() and not for_update:
            collisions.append(f'content root exists: {content}')
        if shim.exists() and not for_update:
            collisions.append(f'shim root exists: {shim}')
        for n in names:
            dst = skills / n
            if lexists(dst) and not for_update:
                collisions.append(f'unmanaged or pre-existing skill collision: {dst}')
        if not existing and agents.exists() and agents.stat().st_size <= TEXT_LIMIT:
            try:
                t = read_regular_bytes(agents, TEXT_LIMIT).decode('utf-8')
                if BEGIN in t or END in t:
                    collisions.append(f'orphan managed AGENTS marker exists: {agents}')
            except (OSError, UnicodeDecodeError):
                pass
        try:
            blockers = incompatible_active_sessions(state, PROTECTION_VERSION)
            collisions.extend(
                'incompatible active protection session: {session_id} ({protection_version}); '
                'close/recover it with the old runtime before deployment'.format(**row)
                for row in blockers
            )
        except Exception as e:
            collisions.append(f'active-session admission check failed: {type(e).__name__}: {e}')

    operations = []
    if not args.use_source_in_place:
        operations.append({'op': 'create_or_replace_managed_content', 'target': str(content)})
    else:
        operations.append({'op': 'use_source_in_place_read_only', 'target': str(HERE)})
    operations.append({'op': 'create_or_replace_managed_shim', 'target': str(shim)})
    if args.mode == 'full':
        operations += [{'op': 'install_namespaced_skill', 'target': str(skills / n)} for n in names]
    operations += [
        {'op': 'merge_managed_block_preserving_existing_text', 'target': str(agents)},
        {'op': 'create_external_state_marker', 'target': str(state)},
        {'op': 'write_ownership_registry', 'target': str(registry)},
    ]
    base = {
        'version': VERSION,
        'protection_version': PROTECTION_VERSION,
        'deployment_profile': (
            CANONICAL_REPOSITORY_RUNTIME_PROFILE
            if getattr(args, 'allow_canonical_repository_runtime', False)
            else ('portable_area' if getattr(args, 'portable_area', None) else 'user_global')
        ),
        'mode': args.mode,
        'source': str(HERE),
        'source_tree_sha256': source_tree_sha256,
        'codex_home': str(ch),
        'content_root': str(content),
        'source_in_place': bool(args.use_source_in_place),
        'shim_root': str(shim),
        'state_root': str(state),
        'skills_root': str(skills),
        'agents_file': str(agents),
        'skills_to_install': names,
        'collisions': collisions,
        'managed_modified': managed_modified,
        'policy_precedence': [
            'explicit user safety requirements',
            'repository/project-local rules for project conventions',
            'global runtime safety contract',
            'library knowledge/advice',
        ],
        'operations': operations,
    }
    if getattr(args, 'allow_canonical_repository_runtime', False):
        base['canonical_repository_root'] = str(abs_lex(args.canonical_repository_root))
        base['canonical_runtime_root'] = str(abs_lex(args.canonical_repository_root) / CANONICAL_REPOSITORY_RUNTIME_RELATIVE)
    base['preflight_id'] = canonical_hash(base)
    return base


def skill_names():
    names = []
    for p in sorted((G / 'skills').iterdir()):
        if p.is_dir() and (p / 'SKILL.md').exists():
            if not p.name.startswith('ioslib-'):
                raise InstallError(f'non-namespaced bundled skill: {p.name}')
            names.append(p.name)
    return names


def copy_package_content(stage: Path, expected_identity=None):
    def ignore(src, names):
        return {'__pycache__'} | {n for n in names if n.endswith('.pyc')}
    shutil.copytree(HERE, stage, ignore=ignore, symlinks=True)
    staged_identity = package_tree_identity.__wrapped__(stage)
    if expected_identity and staged_identity != expected_identity:
        raise InstallError('staged package identity differs from preflight source identity')


def build_stage(pre, args):
    ch = ensure_dir(Path(pre['codex_home']))
    txn = Path(tempfile.mkdtemp(prefix='.ioslib-txn-', dir=ch))
    os.chmod(txn, 0o700)
    try:
        if not args.use_source_in_place:
            copy_package_content(txn / 'content', pre.get('source_tree_sha256'))
        shim = txn / 'shim'
        (shim / 'bin').mkdir(parents=True)
        runtime_cli = Path(pre['content_root']) / 'GLOBAL_CODEX' / 'runtime' / 'bin' / 'ios_ai.py'
        library_root = Path(pre['content_root'])
        launcher = shim / 'bin' / 'ios_ai.py'
        shutil.copy2(HERE / 'MANUAL_SHIM' / 'bin' / 'ios_ai.py', launcher)
        os.chmod(launcher, 0o755)
        (shim / '.ioslib-managed.json').write_text(
            json.dumps({'managed_by': 'ios-engineering-library', 'version': VERSION,
                        'protection_version': PROTECTION_VERSION}) + '\n', encoding='utf-8')
        (shim / 'INSTALLATION.json').write_bytes(descriptor_bytes(
            mode=args.mode, library_root=library_root, runtime_cli=runtime_cli,
            state_root=Path(pre['state_root']), source_tree_sha256=pre['source_tree_sha256'],
            generated_by='install_global.py'))
        (shim / 'INSTALLATION.md').write_text(
            render_installation(Path(pre['shim_root']) / 'bin' / 'ios_ai.py', library_root, Path(pre['state_root'])),
            encoding='utf-8',
        )
        if args.mode == 'full':
            ss = txn / 'skills'
            ss.mkdir()
            for n in pre['skills_to_install']:
                shutil.copytree(G / 'skills' / n, ss / n, symlinks=True)
                managed_hashes(ss / n)  # rejects any raced-in symlink/non-regular entry
                refs = ss / n / 'references'
                refs.mkdir(exist_ok=True)
                (refs / 'INSTALLATION.md').write_text(
                    render_installation(Path(pre['shim_root']) / 'bin' / 'ios_ai.py', library_root, Path(pre['state_root'])),
                    encoding='utf-8',
                )
        return txn
    except Exception:
        shutil.rmtree(txn, ignore_errors=True)
        raise


def _replace_path(src: Path, dst: Path):
    """Rename using stable parent dir-fds. Cross-device moves fail closed and roll back."""
    ensure_dir(dst.parent)
    sfd = _open_dir_chain(src.parent, create=False)
    dfd = _open_dir_chain(dst.parent, create=False)
    try:
        os.replace(src.name, dst.name, src_dir_fd=sfd, dst_dir_fd=dfd)
        os.fsync(dfd)
    finally:
        os.close(sfd)
        os.close(dfd)



def prepare_local_tree(source: Path, target: Path, token: str) -> Path:
    """Copy an incoming tree to a hidden sibling of target for same-filesystem atomic rename."""
    target = abs_lex(target)
    ensure_dir(target.parent)
    staged = target.parent / f'.{target.name}.ioslib-incoming.{token}'
    if lexists(staged):
        raise InstallError(f'local staging collision: {staged}')
    try:
        shutil.copytree(source, staged, symlinks=True)
        managed_hashes(staged)
        return staged
    except Exception:
        shutil.rmtree(staged, ignore_errors=True)
        raise

def remove_created(path: Path):
    path = abs_lex(path)
    reject_symlink_path(path.parent)
    if not lexists(path):
        return
    st = os.lstat(path)
    if stat.S_ISLNK(st.st_mode):
        path.unlink()
    elif stat.S_ISDIR(st.st_mode):
        shutil.rmtree(path)
    elif stat.S_ISREG(st.st_mode):
        path.unlink()
    else:
        raise InstallError(f'refusing cleanup of special file: {path}')


def apply_fresh(pre, args):
    if pre['collisions']:
        raise InstallError('preflight has collisions; no mutation performed')
    if args.mode == 'full' and args.preflight_id != pre['preflight_id']:
        raise InstallError('full install requires --preflight-id from a matching current --dry-run')
    ch = Path(pre['codex_home'])
    ch_existed = lexists(ch)
    txn = None
    prepared = []
    created = []
    created_dirs = []
    incoming_expected = {}
    created_file_hashes = {}
    agents_written_sha = None
    token = secrets.token_hex(8)
    agents = Path(pre['agents_file'])
    agents_existed = lexists(agents)
    old_agents, agents_mode = read_regular_snapshot(agents, TEXT_LIMIT) if agents_existed else (b'', 0o600)
    registry = ch / REGISTRY_NAME
    try:
        txn = build_stage(pre, args)

        # Prepare every incoming tree on the target's own filesystem before the first
        # managed target is switched. A failure here leaves the installation untouched.
        incoming = []
        if not args.use_source_in_place:
            incoming.append((txn / 'content', Path(pre['content_root'])))
        incoming.append((txn / 'shim', Path(pre['shim_root'])))
        if args.mode == 'full':
            sr = Path(pre['skills_root'])
            sr_existed = sr.exists()
            ensure_dir(sr)
            if not sr_existed:
                created_dirs.append(sr)
            for n in pre['skills_to_install']:
                incoming.append((txn / 'skills' / n, sr / n))
        for src, target in incoming:
            local = prepare_local_tree(src, target, token)
            prepared.append((target, local))
            incoming_expected[str(target)] = managed_hashes(local)

        for target, local in prepared:
            # Fresh-install targets were required absent by preflight. Recheck at the
            # publication boundary so an empty raced-in directory is not silently replaced.
            # The same-dir rename then makes publication atomic after this userspace check.
            if lexists(target):
                raise InstallError(f'managed target appeared concurrently after preflight: {target}')
            # Journal the intended publication before rename. _replace_path also fsyncs
            # the parent directory; if rename succeeds but that fsync raises, the target
            # is already live and must still be eligible for safe rollback.
            created.append(target)
            _replace_path(local, target)

        block = read_regular_bytes(G / 'AGENTS.global.block.md', TEXT_LIMIT).decode('utf-8')
        new_agents = merge_block_bytes(old_agents, block)
        # Refuse obvious concurrent edits between preflight/snapshot and publication.
        if agents_existed:
            if not lexists(agents) or read_regular_bytes(agents, TEXT_LIMIT) != old_agents:
                raise InstallError('AGENTS changed concurrently before managed block publication')
            agents_written_sha = sha_bytes(new_agents)
            created.append(('agents', agents))
            write_atomic(agents, new_agents, agents_mode)
        else:
            if lexists(agents):
                raise InstallError('AGENTS appeared concurrently before managed block publication')
            agents_written_sha = sha_bytes(new_agents)
            created.append(('agents', agents))
            write_new_atomic(agents, new_agents, 0o600)

        state = Path(pre['state_root'])
        state_existed = state.exists()
        ensure_dir(state)
        if not state_existed:
            created_dirs.append(state)
        enforce_dir_mode(state, 0o700)
        marker_path = state / '.ioslib-state-owned.json'
        if lexists(marker_path):
            raise InstallError('state ownership marker collision')
        marker_bytes = json.dumps({'managed_by': 'ios-engineering-library', 'version': VERSION}).encode() + b'\n'
        created_file_hashes[str(marker_path)] = sha_bytes(marker_bytes)
        created.append(marker_path)
        write_new_atomic(marker_path, marker_bytes, 0o600)

        ownership = {
            'content': {} if args.use_source_in_place else managed_hashes(Path(pre['content_root'])),
            'shim': managed_hashes(Path(pre['shim_root'])),
            'skills': {n: managed_hashes(Path(pre['skills_root']) / n) for n in pre['skills_to_install']},
            'state_files': {'.ioslib-state-owned.json': sha_file(marker_path)},
        }
        manifest = {
            **pre,
            'installed': True,
            'ownership': ownership,
            'agents': {
                'existed_before': agents_existed,
                'original_sha256': sha_bytes(old_agents),
                'original_mode': agents_mode if agents_existed else None,
                'managed_mode': agents_mode,
                'managed_block_sha256': sha_bytes(block.rstrip().encode()),
                'separator_hex': agents_separator(old_agents).hex(),
            },
            'claims': {
                'prevention': 'only operations actually rejected before execution by a cooperating caller/installer',
                'detection': 'protection snapshots compare before/after state; transient writes are not observed',
                'advisory': 'command guard and knowledge are not OS enforcement boundaries',
                'knowledge_is_permission_authority': False,
                'client_repo_install_required': False,
                'project_local_rules_preserved': True,
            },
        }
        registry_bytes = (json.dumps(manifest, indent=2, sort_keys=True) + '\n').encode()
        created_file_hashes[str(registry)] = sha_bytes(registry_bytes)
        created.append(registry)
        write_new_atomic(registry, registry_bytes, 0o600)
        return manifest
    except Exception as original:
        rollback_errors = []
        if agents_written_sha is not None:
            try:
                current = read_regular_bytes(agents, TEXT_LIMIT) if lexists(agents) else None
                publication_absent = (agents_existed and current == old_agents) or (not agents_existed and current is None)
                if publication_absent:
                    pass
                elif current is None or sha_bytes(current) != agents_written_sha:
                    rollback_errors.append('AGENTS changed after installer publication; preserved instead of overwriting')
                elif agents_existed:
                    write_atomic(agents, old_agents, agents_mode)
                else:
                    unlink_nofollow_file(agents, missing_ok=True)
            except Exception as e:
                rollback_errors.append(f'AGENTS rollback: {type(e).__name__}')
        for item in reversed(created):
            if isinstance(item, tuple):
                continue
            try:
                if str(item) in incoming_expected:
                    if not lexists(item):
                        continue
                    problems = check_existing_managed(item, incoming_expected[str(item)])
                    if problems:
                        rollback_errors.append(f'{item}: changed after publication; preserved')
                        continue
                elif str(item) in created_file_hashes:
                    if not lexists(item):
                        continue
                    if sha_file(item) != created_file_hashes[str(item)]:
                        rollback_errors.append(f'{item}: changed after publication; preserved')
                        continue
                remove_created(item)
            except Exception as e:
                rollback_errors.append(f'{item}: {type(e).__name__}')
        for d in reversed(created_dirs):
            try:
                d.rmdir()
            except OSError:
                pass
        if rollback_errors:
            raise RollbackIncomplete('install failed and safe rollback was incomplete: ' + '; '.join(rollback_errors)) from original
        raise
    finally:
        for target, local in prepared:
            try:
                if not lexists(local):
                    continue
                expected=incoming_expected.get(str(target))
                if expected is not None and not check_existing_managed(local,expected):
                    remove_created(local)
            except Exception:
                pass
        if txn is not None:
            shutil.rmtree(txn, ignore_errors=True)
        if not ch_existed:
            try:
                ch.rmdir()
            except OSError:
                pass

def parser():
    ap = argparse.ArgumentParser(description='Transactional global installer; client repositories are never installation targets.')
    ap.add_argument('--mode', choices=['reference', 'full'], default='reference')
    ap.add_argument('--dry-run', action='store_true')
    ap.add_argument('--preflight-id', help='Required for full installation; copy from an immediately preceding matching --dry-run')
    ap.add_argument('--codex-home')
    ap.add_argument('--runtime-root')
    ap.add_argument('--skills-root', default='auto')
    ap.add_argument('--agents-file')
    ap.add_argument(
        '--portable-area',
        help='Use an explicit area as CODEX_HOME and keep full-mode skills under <area>/skills; this does not configure the host automatically.',
    )
    ap.add_argument('--allow-canonical-repository-runtime', action='store_true',
                    help='Explicitly allow only the managed runtime subtree of AIZenflowDocumentation.')
    ap.add_argument('--canonical-repository-root',
                    help='Git root whose origin must be MArtem/AIZenflowDocumentation for the explicit runtime exception.')
    ap.add_argument('--use-source-in-place', action='store_true')
    return ap


def apply_deployment_profile(args):
    """Resolve an explicit portable area without changing the default global profile."""
    if not args.portable_area:
        if getattr(args, 'allow_canonical_repository_runtime', False):
            raise InstallError('--allow-canonical-repository-runtime requires --portable-area')
        return
    area = abs_lex(args.portable_area)
    if args.codex_home:
        raise InstallError('--portable-area cannot be combined with --codex-home')
    for label, value in (
        ('--runtime-root', args.runtime_root),
        ('--skills-root', args.skills_root if args.skills_root != 'auto' else None),
        ('--agents-file', args.agents_file),
    ):
        if value is None:
            continue
        target = abs_lex(value)
        try:
            target.relative_to(area)
        except ValueError:
            raise InstallError(f'{label} must remain inside --portable-area: {target}')
    args.codex_home = area
    if args.skills_root == 'auto':
        args.skills_root = 'codex-home'
    if getattr(args, 'allow_canonical_repository_runtime', False):
        if not args.canonical_repository_root:
            raise InstallError('--allow-canonical-repository-runtime requires --canonical-repository-root')
        canonical_root = abs_lex(args.canonical_repository_root)
        expected = canonical_root / CANONICAL_REPOSITORY_RUNTIME_RELATIVE
        if area != expected:
            raise InstallError(f'--portable-area must equal canonical runtime root: {expected}')


def main():
    args = parser().parse_args()
    apply_deployment_profile(args)
    pre = build_preflight(args, False)
    if args.dry_run:
        print(json.dumps({'dry_run': True, 'would_mutate': False, **pre}, indent=2))
        return 0 if not pre['collisions'] else 2
    result = apply_fresh(pre, args)
    print(json.dumps(result, indent=2))
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except RollbackIncomplete as e:
        print(json.dumps({'ok': False, 'error': str(e), 'mutation_state': 'rollback_incomplete_user_data_preserved_where_detected'}, indent=2))
        raise SystemExit(4)
    except (InstallError, OSError) as e:
        print(json.dumps({'ok': False, 'error': str(e), 'mutation_state': 'none_or_rolled_back'}, indent=2))
        raise SystemExit(3)
