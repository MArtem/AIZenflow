#!/usr/bin/env python3
"""Read-only safety gate for connecting an unpacked release to a CODEX_HOME.

This helper never creates directories, writes a descriptor, edits AGENTS, copies skills, or
removes anything. A non-zero result means the operator must not execute the displayed plan.
"""
from __future__ import annotations

import argparse
import configparser
import hashlib
import json
import os
from pathlib import Path
import stat
import sys
import time

MAX_DESCRIPTOR_BYTES = 64 * 1024
MAX_RECEIPT_BYTES = 4 * 1024 * 1024
MAX_PACKAGE_BYTES = 512 * 1024 * 1024
PACKAGE_DEADLINE_SECONDS = 30.0
MAX_TEXT_BYTES = 2 * 1024 * 1024
MAX_TREE_ENTRIES = 10000
MAX_TREE_PENDING_DIRECTORIES = 1000
MAX_TREE_DEPTH = 64
MAX_TREE_BYTES = 64 * 1024 * 1024
TREE_SCAN_DEADLINE_SECONDS = 10.0
CANONICAL_REPOSITORY_RUNTIME_PROFILE = 'canonical_repository_runtime'
CANONICAL_REPOSITORY_RUNTIME_RELATIVE = Path('.codex-runtime') / 'ios-engineering'
CANONICAL_REPOSITORY_REMOTE = 'https://github.com/MArtem/AIZenflowDocumentation'
MAX_GIT_CONFIG_BYTES = 256 * 1024
RECEIPT_NAME = '.ioslib-managed.json'
RECEIPT_SCHEMA_VERSION = 1
BEGIN = '<!-- IOS_ENGINEERING_GLOBAL:BEGIN -->'
END = '<!-- IOS_ENGINEERING_GLOBAL:END -->'


class PreflightError(RuntimeError):
    pass


def absolute(value):
    path = Path(value).expanduser()
    if not path.is_absolute():
        raise PreflightError(f'path must be absolute: {path}')
    return Path(os.path.abspath(os.path.normpath(str(path))))


def lexists(path):
    return os.path.lexists(str(path))


def reject_symlink_components(path):
    path = absolute(path)
    current = Path(path.anchor)
    for part in path.parts[1:]:
        current /= part
        if lexists(current) and stat.S_ISLNK(os.lstat(current).st_mode):
            raise PreflightError(f'symlink path component: {current}')


def read_regular(path, max_bytes, *, deadline=None):
    path = absolute(path)
    parent_fd = open_directory_chain(path.parent)
    fd = None
    try:
        st = os.lstat(path)
        if stat.S_ISLNK(st.st_mode) or not stat.S_ISREG(st.st_mode):
            raise PreflightError(f'not a regular file: {path}')
        if st.st_size > max_bytes:
            raise PreflightError(f'file exceeds read budget: {path}')
        if not hasattr(os, 'O_NONBLOCK'):
            raise PreflightError('safe manual observation requires O_NONBLOCK')
        flags = os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0) | os.O_NONBLOCK
        fd = os.open(path.name, flags, dir_fd=parent_fd)
        opened = os.fstat(fd)
        if not stat.S_ISREG(opened.st_mode):
            raise PreflightError(f'file changed to a non-regular entry: {path}')
        if (opened.st_dev, opened.st_ino, opened.st_size, opened.st_mtime_ns) != (st.st_dev, st.st_ino, st.st_size, st.st_mtime_ns):
            raise PreflightError(f'file changed during read: {path}')
        chunks = []
        size = 0
        while True:
            if deadline is not None and time.monotonic() >= deadline:
                raise PreflightError('manual read deadline exceeded')
            chunk = os.read(fd, min(1024 * 1024, max_bytes - size + 1))
            if not chunk:
                break
            size += len(chunk)
            if size > max_bytes:
                raise PreflightError(f'file exceeds read budget: {path}')
            chunks.append(chunk)
        data = b''.join(chunks)
        if size != opened.st_size:
            raise PreflightError(f'incomplete file read: {path}')
        closed = os.fstat(fd)
        if (closed.st_dev, closed.st_ino, closed.st_size, closed.st_mtime_ns) != (opened.st_dev, opened.st_ino, opened.st_size, opened.st_mtime_ns):
            raise PreflightError(f'file changed during read: {path}')
        return data
    finally:
        if fd is not None:
            os.close(fd)
        os.close(parent_fd)


def open_directory_chain(path):
    """Open every parent component without following a symlink or path replacement."""
    if not all(hasattr(os, flag) for flag in ('O_DIRECTORY', 'O_NOFOLLOW')):
        raise PreflightError('manual observation requires O_DIRECTORY and O_NOFOLLOW')
    path = absolute(path)
    flags = os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW
    fd = os.open(path.anchor, flags)
    try:
        for part in path.parts[1:]:
            next_fd = os.open(part, flags, dir_fd=fd)
            os.close(fd)
            fd = next_fd
        return fd
    except OSError as error:
        os.close(fd)
        raise PreflightError(f'directory open failed: {path}: {type(error).__name__}') from error


def sha_bytes(data):
    return hashlib.sha256(data).hexdigest()


def sha_file(path):
    return sha_bytes(read_regular(path, 512 * 1024 * 1024))


def package_identity(release):
    """Recompute the release identity from the shipped file manifest, without trust by path."""
    manifest_path = release / 'PACKAGE_FILE_MANIFEST.json'
    deadline = time.monotonic() + PACKAGE_DEADLINE_SECONDS
    manifest_raw = read_regular(manifest_path, min(MAX_TEXT_BYTES, MAX_PACKAGE_BYTES), deadline=deadline)
    data = json.loads(manifest_raw)
    entries = data.get('files')
    if not isinstance(entries, list) or len(entries) > MAX_TREE_ENTRIES:
        raise PreflightError('PACKAGE_FILE_MANIFEST.files is not a list')
    rows = []
    seen = set()
    remaining = MAX_PACKAGE_BYTES - len(manifest_raw)
    for item in entries:
        if not isinstance(item, dict) or not isinstance(item.get('path'), str):
            raise PreflightError('PACKAGE_FILE_MANIFEST contains an invalid entry')
        rel = item['path']
        if rel in seen or rel == 'PACKAGE_FILE_MANIFEST.json' or rel.startswith('/') or '..' in Path(rel).parts:
            raise PreflightError(f'PACKAGE_FILE_MANIFEST contains an unsafe/duplicate path: {rel}')
        seen.add(rel)
        path = release / rel
        raw = read_regular(path, min(MAX_TREE_BYTES, remaining), deadline=deadline)
        remaining -= len(raw)
        if len(raw) != item.get('size') or sha_bytes(raw) != item.get('sha256'):
            raise PreflightError(f'package manifest hash mismatch: {rel}')
        if path.name == 'REVIEW_READY_VALIDATION_REPORT.md':
            continue
        rows.append([rel, item['sha256']])
    rows.append(['PACKAGE_FILE_MANIFEST.json', sha_bytes(manifest_raw)])
    rows.sort(key=lambda row: row[0])
    return sha_bytes(json.dumps(rows, sort_keys=True, separators=(',', ':')).encode('utf-8'))


def active_agents(ch, explicit):
    override = ch / 'AGENTS.override.md'
    override_is_active = False
    if lexists(override):
        try:
            if read_regular(override, MAX_TEXT_BYTES).decode('utf-8').strip():
                override_is_active = True
        except Exception:
            override_is_active = True
    # Passing the conventional AGENTS.md path must not bypass an active override. A deliberately
    # different explicit path remains an intentional selection for custom host layouts.
    if explicit:
        selected = absolute(explicit)
        if selected != absolute(ch / 'AGENTS.md') or not override_is_active:
            return selected
    if override_is_active:
        return override
    return ch / 'AGENTS.md'


def path_contains(parent, child):
    try:
        absolute(child).relative_to(absolute(parent))
        return True
    except ValueError:
        return False


def existing_ancestor(path):
    current = absolute(path)
    while not lexists(current) and current != current.parent:
        current = current.parent
    return current


def git_root_for_destination(path):
    """Find a lexical Git root without invoking Git or following a destination symlink."""
    current = existing_ancestor(path)
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


def normalize_canonical_remote(value):
    value = value.strip()
    if value.startswith('git@github.com:'):
        value = 'https://github.com/' + value[len('git@github.com:'):]
    elif value.startswith('ssh://git@github.com/'):
        value = 'https://github.com/' + value[len('ssh://git@github.com/'):]
    value = value.rstrip('/')
    if value.endswith('.git'):
        value = value[:-4]
    return value.rstrip('/')


def canonical_repository_identity(root):
    root = absolute(root)
    detected, issue = git_root_for_destination(root)
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
        config.read_string(read_regular(marker / 'config', MAX_GIT_CONFIG_BYTES).decode('utf-8'))
        remote = config.get('remote "origin"', 'url', fallback=None)
    except Exception as error:
        return None, f'canonical repository origin is unreadable: {type(error).__name__}'
    if normalize_canonical_remote(remote or '') != CANONICAL_REPOSITORY_REMOTE:
        return None, 'canonical repository origin is not MArtem/AIZenflowDocumentation'
    return root, None


def canonical_runtime_admission(targets, *, canonical_repository_root=None,
                                allow_canonical_repository_runtime=False):
    if not allow_canonical_repository_runtime:
        return None, []
    if canonical_repository_root is None:
        return None, ['canonical repository runtime requires --canonical-repository-root']
    root, issue = canonical_repository_identity(canonical_repository_root)
    if issue:
        return None, [issue]
    runtime = root / CANONICAL_REPOSITORY_RUNTIME_RELATIVE
    home = absolute(targets.get('codex_home'))
    collisions = []
    if home != runtime:
        collisions.append(f'canonical repository runtime must use exact CODEX_HOME: {runtime}')
    for label, path in targets.items():
        path = absolute(path)
        if label in {'release_root', 'content_root'}:
            continue
        if not path_contains(runtime, path):
            collisions.append(f'{label}: canonical runtime target escapes managed runtime root: {path}')
    return root, collisions


def destination_layout_collisions(targets, release, *, canonical_repository_root=None,
                                  allow_canonical_repository_runtime=False):
    """Reject mutable destinations inside client repositories or overlapping each other."""
    rows = [(label, absolute(path)) for label, path in targets.items()]
    collisions = []
    release = absolute(release)
    canonical_root, canonical_collisions = canonical_runtime_admission(
        dict(rows), canonical_repository_root=canonical_repository_root,
        allow_canonical_repository_runtime=allow_canonical_repository_runtime)
    collisions.extend(canonical_collisions)
    canonical_runtime = (canonical_root / CANONICAL_REPOSITORY_RUNTIME_RELATIVE
                         if canonical_root is not None else None)
    for label, path in rows:
        git_root, issue = git_root_for_destination(path)
        if issue:
            collisions.append(f'{label}: {issue}: {git_root}')
        elif git_root is not None and not (
                canonical_runtime is not None and git_root == canonical_root and
                path_contains(canonical_runtime, path)):
            collisions.append(f'{label}: installation destination is inside client Git repository: {git_root}')
        if label == 'codex_home' and path_contains(path, release):
            continue
        if path_contains(release, path) or path_contains(path, release):
            collisions.append(f'{label}: destination overlaps immutable release root: {path}')
    for index, (left_label, left) in enumerate(rows):
        for right_label, right in rows[index + 1:]:
            # The Codex home intentionally contains its managed children.
            if left_label == 'codex_home' or right_label == 'codex_home':
                continue
            if path_contains(left, right) or path_contains(right, left):
                collisions.append(f'destination overlap: {left_label}={left} and {right_label}={right}')
    return sorted(set(collisions))


def safe_json(path, max_bytes=MAX_DESCRIPTOR_BYTES):
    try:
        return json.loads(read_regular(path, max_bytes).decode('utf-8'))
    except Exception as error:
        raise PreflightError(f'invalid JSON at {path}: {type(error).__name__}') from error


def tree_entries(root, *, max_entries=MAX_TREE_ENTRIES, max_bytes=MAX_TREE_BYTES,
                 max_depth=MAX_TREE_DEPTH, max_pending=MAX_TREE_PENDING_DIRECTORIES,
                 deadline_seconds=TREE_SCAN_DEADLINE_SECONDS):
    root = absolute(root)
    if not lexists(root):
        return []
    reject_symlink_components(root)
    if not root.is_dir():
        raise PreflightError(f'expected directory: {root}')
    deadline = time.monotonic() + deadline_seconds
    pending = [(root, open_directory_chain(root), 0)]
    result = []
    visited = 0
    total_bytes = 0
    try:
        while pending:
            if time.monotonic() > deadline:
                raise PreflightError('bounded directory observation deadline exceeded')
            directory, directory_fd, depth = pending.pop()
            try:
                try:
                    entries = os.scandir(directory_fd)
                except OSError as error:
                    raise PreflightError(f'directory iteration failed: {directory}: {type(error).__name__}') from error
                try:
                    for entry in entries:
                        if time.monotonic() > deadline:
                            raise PreflightError('bounded directory observation deadline exceeded')
                        visited += 1
                        if visited > max_entries:
                            raise PreflightError('directory-entry observation budget exceeded')
                        path = directory / entry.name
                        try:
                            st = entry.stat(follow_symlinks=False)
                        except OSError as error:
                            raise PreflightError(f'entry stat failed: {path}: {type(error).__name__}') from error
                        if stat.S_ISLNK(st.st_mode):
                            raise PreflightError(f'unsafe directory entry: {path}')
                        if stat.S_ISDIR(st.st_mode):
                            if depth + 1 > max_depth:
                                raise PreflightError(f'directory-depth observation budget exceeded: {path}')
                            if len(pending) >= max_pending:
                                raise PreflightError('pending-directory observation budget exceeded')
                            child_fd = None
                            try:
                                child_fd = os.open(entry.name, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW,
                                                   dir_fd=directory_fd)
                                child_stat = os.fstat(child_fd)
                            except OSError as error:
                                if child_fd is not None:
                                    os.close(child_fd)
                                raise PreflightError(f'directory changed before read: {path}: {type(error).__name__}') from error
                            if (child_stat.st_dev, child_stat.st_ino) != (st.st_dev, st.st_ino):
                                os.close(child_fd)
                                raise PreflightError(f'directory changed before read: {path}')
                            pending.append((path, child_fd, depth + 1))
                            continue
                        if not stat.S_ISREG(st.st_mode):
                            raise PreflightError(f'unsafe file entry: {path}')
                        total_bytes += st.st_size
                        if total_bytes > max_bytes:
                            raise PreflightError('aggregate directory observation byte budget exceeded')
                        result.append(path.relative_to(root).as_posix())
                finally:
                    entries.close()
            finally:
                os.close(directory_fd)
    finally:
        for _, pending_fd, _ in pending:
            os.close(pending_fd)
    return result


def _hash_is_valid(value):
    return isinstance(value, str) and len(value) == 64 and all(c in '0123456789abcdef' for c in value)


def _file_identity(st):
    return (st.st_dev, st.st_ino, st.st_size, st.st_mtime_ns, stat.S_IMODE(st.st_mode))


def file_record(path, *, max_bytes=MAX_TREE_BYTES, deadline=None, byte_budget=None):
    """Return a bounded, race-checked ownership record for one regular file."""
    path = absolute(path)
    before = os.lstat(path)
    if stat.S_ISLNK(before.st_mode) or not stat.S_ISREG(before.st_mode):
        raise PreflightError(f'owned path is not a regular file: {path}')
    raw = read_regular(path, min(max_bytes, byte_budget[0]) if byte_budget is not None else max_bytes,
                       deadline=deadline)
    if byte_budget is not None:
        byte_budget[0] -= len(raw)
    digest = sha_bytes(raw)
    after = os.lstat(path)
    if _file_identity(before) != _file_identity(after):
        raise PreflightError(f'owned file changed during receipt observation: {path}')
    return {'path': str(path), 'sha256': digest, 'mode': stat.S_IMODE(after.st_mode)}


def _receipt_roots(shim, state, skills, agents):
    return [absolute(shim), absolute(state), absolute(skills), absolute(agents)]


def validate_receipt(receipt, *, shim, state, skills, agents):
    """Validate and re-hash a previously recorded manual ownership receipt."""
    if not isinstance(receipt, dict) or receipt.get('schema_version') != RECEIPT_SCHEMA_VERSION:
        raise PreflightError('manual ownership receipt schema is unsupported')
    if receipt.get('managed_by') != 'ios-engineering-library':
        raise PreflightError('manual ownership receipt has a different owner')
    if not isinstance(receipt.get('release_id'), str) or not receipt['release_id']:
        raise PreflightError('manual ownership receipt release_id is invalid')
    if not isinstance(receipt.get('protection_version'), str) or not receipt['protection_version']:
        raise PreflightError('manual ownership receipt protection_version is invalid')
    if receipt.get('mode') not in {'reference', 'full'}:
        raise PreflightError('manual ownership receipt mode is invalid')
    rows = receipt.get('managed_paths')
    if not isinstance(rows, list) or not rows or len(rows) > MAX_TREE_ENTRIES:
        raise PreflightError('manual ownership receipt managed_paths is invalid')
    roots = _receipt_roots(shim, state, skills, agents)
    receipt_path = absolute(shim) / RECEIPT_NAME
    owned = {}
    remaining = [MAX_TREE_BYTES]
    deadline = time.monotonic() + TREE_SCAN_DEADLINE_SECONDS
    for row in rows:
        if not isinstance(row, dict) or not isinstance(row.get('path'), str):
            raise PreflightError('manual ownership receipt contains an invalid path record')
        path = absolute(row['path'])
        if path == receipt_path or path in owned or not _hash_is_valid(row.get('sha256')):
            raise PreflightError(f'manual ownership receipt contains an unsafe/duplicate path: {path}')
        mode = row.get('mode')
        if type(mode) is not int or mode < 0 or mode > 0o7777:
            raise PreflightError(f'manual ownership receipt contains an invalid mode: {path}')
        allowed = any(path_contains(root, path) and path != root for root in roots[:-1]) or path == roots[-1]
        if not allowed:
            raise PreflightError(f'manual ownership receipt path is outside declared targets: {path}')
        current = file_record(path, byte_budget=remaining, deadline=deadline)
        if current['sha256'] != row['sha256'] or current['mode'] != mode:
            raise PreflightError(f'manual ownership receipt does not match current bytes/mode: {path}')
        owned[path] = row
    for required in (absolute(shim) / 'INSTALLATION.json', absolute(shim) / 'bin' / 'ios_ai.py',
                     absolute(state) / '.ioslib-state-owned.json'):
        if required not in owned:
            raise PreflightError(f'manual ownership receipt omits required managed path: {required}')
    metadata = receipt.get('agents')
    if not isinstance(metadata, dict) or absolute(metadata.get('path', '')) != absolute(agents):
        raise PreflightError('manual ownership receipt AGENTS metadata is invalid')
    if not _hash_is_valid(metadata.get('managed_block_sha256')):
        raise PreflightError('manual ownership receipt managed AGENTS hash is invalid')
    original = metadata.get('original_sha256')
    if original is not None and not _hash_is_valid(original):
        raise PreflightError('manual ownership receipt original AGENTS hash is invalid')
    original_mode = metadata.get('original_mode')
    if original_mode is not None and (type(original_mode) is not int or original_mode < 0 or original_mode > 0o7777):
        raise PreflightError('manual ownership receipt original AGENTS mode is invalid')
    if lexists(agents) and absolute(agents) not in owned:
        raise PreflightError('manual ownership receipt omits the managed AGENTS file')
    return owned


def receipt_tree_paths(owned, root):
    root = absolute(root)
    return {path.relative_to(root).as_posix() for path in owned if path_contains(root, path) and path != root}


def tree_matches_receipt(root, owned):
    root = absolute(root)
    if not lexists(root) or not root.is_dir():
        return False
    return set(tree_entries(root)) == receipt_tree_paths(owned, root)


def tree_matches_release(target, source, extra_files=None):
    """Compare a staged manual skill with its immutable release tree."""
    target = absolute(target)
    source = absolute(source)
    if not target.is_dir() or not source.is_dir():
        return False
    extra_files = extra_files or {}
    source_paths = set(tree_entries(source))
    expected = set(source_paths) | set(extra_files)
    if set(tree_entries(target)) != expected:
        return False
    for relative in sorted(source_paths):
        if file_record(target / relative)['sha256'] != file_record(source / relative)['sha256']:
            return False
        if file_record(target / relative)['mode'] != file_record(source / relative)['mode']:
            return False
    for relative, source_file in extra_files.items():
        target_file = target / relative
        if file_record(target_file)['sha256'] != file_record(source_file)['sha256']:
            return False
        if file_record(target_file)['mode'] != file_record(source_file)['mode']:
            return False
    return True


def build_receipt(*, release_id, protection_version, mode, shim, state, skills, agents,
                  incoming_skill_names, original_agents_sha256, original_agents_mode,
                  managed_block_sha256):
    """Build data for the operator to publish after all manual writes have succeeded."""
    paths = set()
    for relative in tree_entries(shim):
        path = absolute(shim) / relative
        if path != absolute(shim) / RECEIPT_NAME:
            paths.add(path)
    marker = absolute(state) / '.ioslib-state-owned.json'
    if not lexists(marker):
        raise PreflightError('cannot emit receipt without the state ownership marker')
    paths.add(marker)
    if lexists(agents):
        paths.add(absolute(agents))
    for name in incoming_skill_names:
        target = absolute(skills) / name
        if not target.is_dir():
            raise PreflightError(f'cannot emit receipt without full-mode skill: {target}')
        for relative in tree_entries(target):
            paths.add(target / relative)
    required = {absolute(shim) / 'INSTALLATION.json', absolute(shim) / 'bin' / 'ios_ai.py', marker}
    if not required.issubset(paths):
        raise PreflightError('cannot emit receipt before the managed shim is complete')
    if len(paths) > MAX_TREE_ENTRIES:
        raise PreflightError('receipt path count exceeds budget')
    rows = []
    remaining = [MAX_TREE_BYTES]
    deadline = time.monotonic() + TREE_SCAN_DEADLINE_SECONDS
    for path in sorted(paths):
        rows.append(file_record(path, byte_budget=remaining, deadline=deadline))
    receipt = {
        'schema_version': RECEIPT_SCHEMA_VERSION,
        'managed_by': 'ios-engineering-library',
        'release_id': release_id,
        'protection_version': protection_version,
        'mode': mode,
        'managed_paths': rows,
        'agents': {
            'path': str(absolute(agents)),
            'original_sha256': original_agents_sha256,
            'original_mode': original_agents_mode,
            'managed_block_sha256': managed_block_sha256,
        },
    }
    if len(json.dumps(receipt, indent=2, sort_keys=True).encode('utf-8')) + 1 > MAX_RECEIPT_BYTES:
        raise PreflightError('encoded receipt exceeds read budget')
    return receipt


def build(args):
    release = absolute(args.release_root)
    ch = absolute(args.codex_home or os.environ.get('CODEX_HOME', str(Path.home() / '.codex')))
    state = absolute(args.state_root or ch / 'ios-engineering-state')
    shim = ch / 'ios-engineering-shim'
    skills = absolute(args.skills_root or Path.home() / '.agents' / 'skills')
    agents = active_agents(ch, args.agents_file)
    collisions = []
    operations = []

    for label, path in [('release_root', release), ('codex_home', ch), ('shim_root', shim),
                        ('state_root', state), ('skills_root', skills), ('agents_file', agents)]:
        try:
            reject_symlink_components(path)
        except Exception as error:
            collisions.append(f'{label}: {error}')
    collisions.extend(destination_layout_collisions({
        'codex_home': ch,
        'shim_root': shim,
        'state_root': state,
        'skills_root': skills,
        'agents_file': agents,
    }, release,
        canonical_repository_root=getattr(args, 'canonical_repository_root', None),
        allow_canonical_repository_runtime=bool(getattr(args, 'allow_canonical_repository_runtime', False))))

    if not release.is_dir():
        collisions.append(f'release_root is missing or not a directory: {release}')
    manifest = {}
    try:
        manifest = safe_json(release / 'GLOBAL_MANIFEST.json', MAX_TEXT_BYTES)
        if manifest.get('status') not in {'review_candidate_independent_review_required', 'accepted_internal_pilot'}:
            collisions.append('release manifest status is not an installable candidate')
        runtime = release / 'GLOBAL_CODEX' / 'runtime' / 'bin' / 'ios_ai.py'
        manual_shim = release / 'MANUAL_SHIM' / 'bin' / 'ios_ai.py'
        read_regular(runtime, MAX_TEXT_BYTES)
        read_regular(manual_shim, MAX_TEXT_BYTES)
    except Exception as error:
        collisions.append(f'release validation failed: {error}')

    try:
        release_identity = package_identity(release)
    except Exception as error:
        release_identity = None
        collisions.append(f'release package identity failed: {error}')

    version = manifest.get('version')
    # The descriptor's release_id is the runtime release identity shared with the installer;
    # the manifest's artifact name remains a separate packaging label.
    release_id = version
    protection_version = manifest.get('runtime', {}).get('protection_version')
    descriptor = {
        'schema_version': 1,
        'managed_by': 'ios-engineering-library',
        'release_id': release_id,
        'protection_version': protection_version,
        'mode': args.mode,
        'knowledge_root': str(release),
        'runtime_cli': str(release / 'GLOBAL_CODEX' / 'runtime' / 'bin' / 'ios_ai.py'),
        'state_root': str(state),
        'source_tree_sha256': release_identity,
        'generated_by': 'manual_preflight.py',
    }
    if getattr(args, 'allow_canonical_repository_runtime', False):
        descriptor['deployment_profile'] = CANONICAL_REPOSITORY_RUNTIME_PROFILE
        descriptor['canonical_repository_root'] = str(absolute(args.canonical_repository_root))
        descriptor['canonical_runtime_root'] = str(absolute(args.canonical_repository_root) / CANONICAL_REPOSITORY_RUNTIME_RELATIVE)
    state_marker = {
        'managed_by': 'ios-engineering-library',
        'version': version,
        'protection_version': protection_version,
        'deployment': 'manual',
    }
    receipt_path = shim / RECEIPT_NAME
    marker = state / '.ioslib-state-owned.json'
    old_receipt = None
    receipt_map = {}
    fresh_receipt_candidate = False
    reconnect_from_disabled = False
    receipt_seed = {'original_agents_sha256': None, 'original_agents_mode': None}
    expected_block = None
    try:
        expected_block = read_regular(release / 'GLOBAL_CODEX' / 'AGENTS.global.block.md', MAX_TEXT_BYTES).decode('utf-8').rstrip()
    except Exception as error:
        collisions.append(f'global AGENTS block validation failed: {error}')
    if lexists(agents):
        try:
            initial_agents = read_regular(agents, MAX_TEXT_BYTES)
            initial_stat = os.lstat(agents)
            receipt_seed = {
                'original_agents_sha256': sha_bytes(initial_agents),
                'original_agents_mode': stat.S_IMODE(initial_stat.st_mode),
            }
        except Exception as error:
            collisions.append(f'AGENTS receipt seed failed: {error}')

    try:
        # Reuse the release's bounded, read-only admission check. Importing the package helper
        # does not mutate the target; all actual manual writes remain outside this process.
        if str(release) not in sys.path:
            sys.path.insert(0, str(release))
        import install_global as installer
        blockers = installer.incompatible_active_sessions(state, protection_version)
        collisions.extend(
            'incompatible active protection session: {session_id} ({protection_version}); '
            'close/recover it with the old runtime before manual activation'.format(**row)
            for row in blockers
        )
    except Exception as error:
        collisions.append(f'active-session admission check failed: {type(error).__name__}: {error}')

    if lexists(shim):
        try:
            entries = tree_entries(shim)
            expected = {'INSTALLATION.json', 'INSTALLATION.md', '.ioslib-managed.json', 'bin/ios_ai.py'}
            unknown = sorted(set(entries) - expected)
            if unknown:
                collisions.append('shim contains unknown files: ' + ', '.join(unknown))
            launcher_hash_matches = bool(lexists(shim / 'bin' / 'ios_ai.py')) and sha_file(shim / 'bin' / 'ios_ai.py') == sha_file(release / 'MANUAL_SHIM' / 'bin' / 'ios_ai.py')
            if not entries:
                if not lexists(marker):
                    collisions.append('existing empty manual shim has no managed state marker')
                else:
                    disabled_marker = safe_json(marker)
                    if (disabled_marker.get('managed_by') != 'ios-engineering-library' or
                            disabled_marker.get('deployment') != 'manual'):
                        collisions.append('existing empty manual shim has an invalid state marker')
                    else:
                        reconnect_from_disabled = True
                        operations.append({'op': 'reuse_verified_empty_disabled_shim', 'target': str(shim)})
            elif set(entries) == {'bin/ios_ai.py'} and launcher_hash_matches:
                # This is the only safe transitional state after the operator has copied the
                # verified launcher and before INSTALLATION.json is published.
                operations.append({'op': 'complete_selector_for_verified_transitional_shim', 'target': str(shim)})
            else:
                old_descriptor = safe_json(shim / 'INSTALLATION.json')
                if old_descriptor.get('managed_by') != 'ios-engineering-library':
                    collisions.append('existing shim descriptor has a different owner')
                if lexists(receipt_path):
                    old_receipt = safe_json(receipt_path, MAX_RECEIPT_BYTES)
                    receipt_map = validate_receipt(old_receipt, shim=shim, state=state, skills=skills, agents=agents)
                    if old_descriptor.get('release_id') != old_receipt.get('release_id'):
                        collisions.append('existing descriptor release does not match the ownership receipt')
                    if old_descriptor.get('protection_version') != old_receipt.get('protection_version'):
                        collisions.append('existing descriptor protection identity does not match the ownership receipt')
                    if old_descriptor.get('mode') != old_receipt.get('mode'):
                        collisions.append('existing descriptor mode does not match the ownership receipt')
                elif args.emit_receipt:
                    required_descriptor = {
                        'managed_by': 'ios-engineering-library',
                        'release_id': release_id,
                        'protection_version': protection_version,
                        'mode': args.mode,
                        'knowledge_root': str(release),
                        'runtime_cli': str(release / 'GLOBAL_CODEX' / 'runtime' / 'bin' / 'ios_ai.py'),
                        'state_root': str(state),
                        'source_tree_sha256': release_identity,
                    }
                    if any(old_descriptor.get(key) != value for key, value in required_descriptor.items()):
                        collisions.append('fresh receipt requires a descriptor for the current verified release')
                    else:
                        fresh_receipt_candidate = True
                else:
                    collisions.append('existing manual shim has no ownership receipt; refusing update')
                old_mode = old_descriptor.get('mode')
                if old_mode != args.mode and not (old_mode == 'reference' and args.mode == 'full'):
                    collisions.append('existing shim mode differs; only reference-to-full migration is supported')
                elif old_mode == 'reference' and args.mode == 'full':
                    operations.append({'op': 'migrate_verified_reference_shim_to_full_mode', 'target': str(shim)})
                if not launcher_hash_matches and not old_receipt:
                    collisions.append('existing shim launcher is modified or from a pre-descriptor release')
                if old_receipt or fresh_receipt_candidate:
                    operations.append({'op': 'replace_only_verified_managed_shim_files', 'target': str(shim)})
        except Exception as error:
            collisions.append(f'existing shim is not safely updatable: {error}')
    else:
        operations.append({'op': 'create_managed_shim_after_all_checks', 'target': str(shim)})

    if lexists(agents):
        try:
            text = read_regular(agents, MAX_TEXT_BYTES).decode('utf-8')
            matches = text.count(BEGIN), text.count(END)
            if matches != (0, 0):
                if matches != (1, 1) or BEGIN not in text or END not in text:
                    collisions.append('AGENTS has an incomplete managed block')
                else:
                    start = text.index(BEGIN); end = text.index(END, start) + len(END)
                    current_block_hash = sha_bytes(text[start:end].rstrip().encode('utf-8'))
                    if old_receipt:
                        recorded = old_receipt.get('agents', {}).get('managed_block_sha256')
                        if current_block_hash != recorded:
                            collisions.append('AGENTS managed block is modified since the ownership receipt')
                        else:
                            operations.append({'op': 'replace_only_exact_managed_AGENTS_block', 'target': str(agents)})
                    elif fresh_receipt_candidate:
                        if text[start:end].rstrip() != expected_block:
                            collisions.append('AGENTS managed block is modified or from another release')
                        else:
                            operations.append({'op': 'replace_only_exact_managed_AGENTS_block', 'target': str(agents)})
                    else:
                        collisions.append('managed AGENTS block has no ownership receipt; refusing update')
            elif old_receipt or fresh_receipt_candidate:
                collisions.append('managed AGENTS block is missing; refusing receipt/update')
        except Exception as error:
            collisions.append(f'AGENTS cannot be read safely: {error}')
    elif args.emit_receipt:
        collisions.append('cannot emit manual ownership receipt without an AGENTS file')
    operations.append({'op': 'append_managed_block_after_exact_text_review', 'target': str(agents)})

    if args.mode == 'full':
        try:
            incoming = sorted(p.name for p in (release / 'GLOBAL_CODEX' / 'skills').iterdir()
                              if p.is_dir() and not p.is_symlink())
            for name in incoming:
                target = skills / name
                if lexists(target):
                    owned_target = bool(old_receipt and tree_matches_receipt(target, receipt_map))
                    fresh_target = bool(fresh_receipt_candidate and tree_matches_release(
                        target, release / 'GLOBAL_CODEX' / 'skills' / name,
                        {'references/INSTALLATION.md': release / 'MANUAL_SHIM' / 'INSTALLATION.md'}))
                    if owned_target or fresh_target:
                        operations.append({'op': 'replace_only_verified_managed_skill', 'target': str(target)})
                    else:
                        collisions.append(f'full-mode skill target is unknown or modified: {target}')
                else:
                    operations.append({'op': 'copy_namespaced_skill_after_all_checks', 'target': str(target)})
        except Exception as error:
            collisions.append(f'full-mode skill preflight failed: {error}')

    if lexists(state):
        try:
            if not state.is_dir() or stat.S_IMODE(os.lstat(state).st_mode) & 0o077:
                collisions.append('state root must be a private directory')
            elif lexists(marker):
                owned = safe_json(marker)
                if owned.get('managed_by') != 'ios-engineering-library':
                    collisions.append('existing state marker has a different owner')
                elif old_receipt or reconnect_from_disabled:
                    operations.append({'op': 'replace_only_verified_state_marker', 'target': str(marker)})
            elif tree_entries(state):
                collisions.append('existing state root has no library ownership marker; explicit migration is required')
        except Exception as error:
            collisions.append(f'state root is not safely inspectable: {error}')
    operations.append({'op': 'create_private_state_root_and_marker_if_absent', 'target': str(state)})

    if args.emit_receipt and lexists(marker):
        try:
            current_marker = safe_json(marker)
            if not reconnect_from_disabled and current_marker != state_marker:
                collisions.append('state ownership marker is not published for the current release')
        except Exception as error:
            collisions.append(f'state ownership marker cannot be validated for receipt: {error}')

    # An old receipt authorizes replacing unchanged files; it does not certify new-release
    # publication. Receipt emission always checks the actual incoming descriptor and content.
    if args.emit_receipt:
        try:
            if safe_json(shim / 'INSTALLATION.json') != descriptor:
                raise PreflightError('descriptor is not the current requested deployment')
            actual = read_regular(agents, MAX_TEXT_BYTES).decode('utf-8')
            start = actual.index(BEGIN)
            end = actual.index(END, start) + len(END)
            if actual[start:end].rstrip() != expected_block:
                raise PreflightError('managed AGENTS block is not the current release')
            if old_receipt:
                original_sha256 = old_receipt.get('agents', {}).get('original_sha256')
                original_mode = old_receipt.get('agents', {}).get('original_mode')
            elif getattr(args, 'original_agents_absent', False):
                original_sha256 = None
                original_mode = None
            else:
                original_sha256 = getattr(args, 'original_agents_sha256', None)
                original_mode = getattr(args, 'original_agents_mode', None)
            if original_sha256 is not None:
                snapshot_path = getattr(args, 'original_agents_snapshot', None)
                if not snapshot_path:
                    raise PreflightError('fresh receipt requires the original AGENTS snapshot')
                snapshot = read_regular(snapshot_path, MAX_TEXT_BYTES)
                snapshot_stat = os.lstat(absolute(snapshot_path))
                if sha_bytes(snapshot) != original_sha256 or stat.S_IMODE(snapshot_stat.st_mode) != original_mode:
                    raise PreflightError('original AGENTS snapshot does not match the recorded seed')
                expected_prefix = snapshot + b'\n'
            else:
                expected_prefix = b'\n'
            if actual[:start].encode('utf-8') != expected_prefix:
                raise PreflightError('user-owned AGENTS text changed before the managed block')
            if sha_file(shim / 'bin' / 'ios_ai.py') != sha_file(manual_shim):
                raise PreflightError('launcher is not the current release')
            if args.mode == 'full':
                for name in incoming:
                    if not tree_matches_release(skills / name, release / 'GLOBAL_CODEX' / 'skills' / name,
                            {'references/INSTALLATION.md': release / 'MANUAL_SHIM/INSTALLATION.md'}):
                        raise PreflightError(f'skill is not the current release: {name}')
        except Exception as error:
            collisions.append(f'publication verification failed: {error}')

    receipt = None
    if args.emit_receipt and not collisions:
        try:
            if not lexists(agents):
                raise PreflightError('cannot emit receipt without an AGENTS file')
            agents_text = read_regular(agents, MAX_TEXT_BYTES).decode('utf-8')
            if agents_text.count(BEGIN) != 1 or agents_text.count(END) != 1:
                raise PreflightError('cannot emit receipt without exactly one managed AGENTS block')
            block_start = agents_text.index(BEGIN)
            block_end = agents_text.index(END, block_start) + len(END)
            block_hash = sha_bytes(agents_text[block_start:block_end].rstrip().encode('utf-8'))
            if old_receipt:
                original_sha256 = old_receipt['agents'].get('original_sha256')
                original_mode = old_receipt['agents'].get('original_mode')
            else:
                original_sha256 = getattr(args, 'original_agents_sha256', None)
                original_mode = getattr(args, 'original_agents_mode', None)
                if getattr(args, 'original_agents_absent', False):
                    original_sha256 = None
                    original_mode = None
                elif not _hash_is_valid(original_sha256) or type(original_mode) is not int:
                    raise PreflightError('fresh receipt requires the first preflight AGENTS hash and mode, or --original-agents-absent')
            if original_sha256 is not None and not _hash_is_valid(original_sha256):
                raise PreflightError('receipt original AGENTS hash is invalid')
            if original_mode is not None and (type(original_mode) is not int or original_mode < 0 or original_mode > 0o7777):
                raise PreflightError('receipt original AGENTS mode is invalid')
            receipt = build_receipt(
                release_id=release_id,
                protection_version=protection_version,
                mode=args.mode,
                shim=shim,
                state=state,
                skills=skills,
                agents=agents,
                incoming_skill_names=incoming if args.mode == 'full' else [],
                original_agents_sha256=original_sha256,
                original_agents_mode=original_mode,
                managed_block_sha256=block_hash,
            )
        except Exception as error:
            collisions.append(f'manual ownership receipt cannot be emitted: {error}')

    operations.append({'op': 'write_descriptor_last', 'target': str(shim / 'INSTALLATION.json')})
    operations.append({'op': 'activation_is_last_and_old_release_remains_untouched', 'target': str(shim / 'bin' / 'ios_ai.py')})
    return {
        'ok': not collisions,
        'release': {'release_id': release_id, 'version': version, 'protection_version': protection_version, 'root': str(release)},
        'paths': {'codex_home': str(ch), 'shim_root': str(shim), 'state_root': str(state), 'skills_root': str(skills), 'agents_file': str(agents)},
        'descriptor': descriptor,
        'state_marker': state_marker,
        'collisions': sorted(set(collisions)),
        'operations': operations,
        'receipt_seed': receipt_seed,
        'receipt': receipt,
        'read_only': True,
    }


def main():
    ap = argparse.ArgumentParser(description='Read-only manual deployment preflight')
    ap.add_argument('--release-root', required=True)
    ap.add_argument('--codex-home')
    ap.add_argument('--state-root')
    ap.add_argument('--skills-root')
    ap.add_argument('--agents-file')
    ap.add_argument('--mode', choices=['reference', 'full'], default='reference')
    ap.add_argument('--emit-descriptor', action='store_true', help='print only the descriptor JSON when preflight passes')
    ap.add_argument('--emit-state-marker', action='store_true', help='print only the state marker JSON when preflight passes')
    ap.add_argument('--emit-receipt', action='store_true', help='print only the ownership receipt JSON when preflight passes')
    ap.add_argument('--original-agents-sha256')
    ap.add_argument('--original-agents-mode', type=int)
    ap.add_argument('--original-agents-absent', action='store_true')
    ap.add_argument('--original-agents-snapshot')
    ap.add_argument('--allow-canonical-repository-runtime', action='store_true',
                    help='Explicitly allow only the managed runtime subtree of AIZenflowDocumentation.')
    ap.add_argument('--canonical-repository-root',
                    help='Git root whose origin must be MArtem/AIZenflowDocumentation for the explicit runtime exception.')
    args = ap.parse_args()
    try:
        result = build(args)
    except Exception as error:
        result = {'ok': False, 'read_only': True, 'collisions': [f'preflight failed: {type(error).__name__}: {error}'], 'operations': []}
    if args.emit_receipt and result.get('ok'):
        print(json.dumps(result['receipt'], indent=2, sort_keys=True))
    elif args.emit_descriptor and result.get('ok'):
        print(json.dumps(result['descriptor'], indent=2, sort_keys=True))
    elif args.emit_state_marker and result.get('ok'):
        print(json.dumps(result['state_marker'], indent=2, sort_keys=True))
    else:
        print(json.dumps(result, indent=2, sort_keys=True))
    return 0 if result.get('ok') else 2


if __name__ == '__main__':
    raise SystemExit(main())
