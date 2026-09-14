#!/usr/bin/env python3
"""Bounded, explicit compatibility profile for an external knowledge source.

The profile may disable only content proved identical by bytes. Both the candidate and the
external source are re-observed before every exclusion decision; an incomplete observation is
an error and therefore disables nothing.
"""
from __future__ import annotations

import errno
import hashlib
import json
import os
from pathlib import Path
import stat
import time
import re

MAX_FILES = 100000
MAX_ENTRIES = 200000
MAX_PENDING_DIRECTORIES = 10000
MAX_DEPTH = 64
MAX_BYTES = 512 * 1024 * 1024
MAX_FILE_BYTES = 64 * 1024 * 1024
SCAN_DEADLINE_SECONDS = 30.0
CHUNK_BYTES = 65536
EXCLUDED_DIRS = {'.git', '__pycache__'}


class ProfileError(RuntimeError):
    pass


def absolute(value):
    path = Path(value).expanduser()
    if not path.is_absolute():
        raise ProfileError(f'profile root must be absolute: {path}')
    return Path(os.path.abspath(os.path.normpath(str(path))))


def _check_deadline(deadline):
    if time.monotonic() > deadline:
        raise ProfileError('profile observation deadline exceeded')


def _reject_symlink_components(path):
    path = absolute(path)
    current = Path(path.anchor)
    for part in path.parts[1:]:
        current /= part
        if os.path.lexists(current) and stat.S_ISLNK(os.lstat(current).st_mode):
            raise ProfileError(f'profile path contains a symlink component: {current}')


def _open_directory_chain(path):
    """Open every directory component without following a symlink or path replacement."""
    if not all(hasattr(os, flag) for flag in ('O_DIRECTORY', 'O_NOFOLLOW')):
        raise ProfileError('profile observation requires O_DIRECTORY and O_NOFOLLOW')
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
        raise ProfileError(f'profile directory open failed: {path}: {type(error).__name__}') from error


def _iter_files(root, deadline):
    """Stream from stable directory handles with explicit entry/depth/pending limits."""
    pending = [(root, _open_directory_chain(root), 0)]
    visited_entries = 0
    try:
        while pending:
            _check_deadline(deadline)
            directory, directory_fd, depth = pending.pop()
            try:
                try:
                    entries = os.scandir(directory_fd)
                except OSError as error:
                    raise ProfileError(f'profile directory scan failed: {directory}: {type(error).__name__}') from error
                try:
                    for entry in entries:
                        _check_deadline(deadline)
                        visited_entries += 1
                        if visited_entries > MAX_ENTRIES:
                            raise ProfileError('profile directory-entry budget exceeded')
                        entry_path = directory / entry.name
                        try:
                            observed = entry.stat(follow_symlinks=False)
                        except OSError as error:
                            raise ProfileError(f'profile entry stat failed: {entry_path}: {type(error).__name__}') from error
                        mode = observed.st_mode
                        if stat.S_ISLNK(mode):
                            raise ProfileError(f'unsafe profile entry: {entry_path}')
                        if stat.S_ISDIR(mode):
                            if entry.name in EXCLUDED_DIRS:
                                continue
                            if depth + 1 > MAX_DEPTH:
                                raise ProfileError(f'profile directory-depth budget exceeded: {entry_path}')
                            if len(pending) >= MAX_PENDING_DIRECTORIES:
                                raise ProfileError('profile pending-directory budget exceeded')
                            child_fd = None
                            try:
                                child_fd = os.open(entry.name, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW,
                                                   dir_fd=directory_fd)
                                child_stat = os.fstat(child_fd)
                            except OSError as error:
                                if child_fd is not None:
                                    os.close(child_fd)
                                raise ProfileError(f'profile directory open failed: {entry_path}: {type(error).__name__}') from error
                            expected = (observed.st_dev, observed.st_ino)
                            actual = (child_stat.st_dev, child_stat.st_ino)
                            if not stat.S_ISDIR(child_stat.st_mode) or actual != expected:
                                os.close(child_fd)
                                raise ProfileError(f'profile directory changed before read: {entry_path}')
                            pending.append((entry_path, child_fd, depth + 1))
                            continue
                        if not stat.S_ISREG(mode):
                            raise ProfileError(f'unsafe profile entry: {entry_path}')
                        yield entry_path, observed, directory_fd, entry.name
                finally:
                    entries.close()
            finally:
                os.close(directory_fd)
    finally:
        for _, pending_fd, _ in pending:
            os.close(pending_fd)


def _hash_file(path, observed, deadline, *, parent_fd=None, name=None):
    if observed.st_size > MAX_FILE_BYTES:
        raise ProfileError(f'profile file exceeds per-file budget: {path}')
    if parent_fd is None:
        _reject_symlink_components(path.parent)
    if not hasattr(os, 'O_NONBLOCK'):
        raise ProfileError('profile observation requires O_NONBLOCK')
    flags = os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0) | os.O_NONBLOCK
    try:
        fd = os.open(name if parent_fd is not None else str(path), flags,
                     dir_fd=parent_fd) if parent_fd is not None else os.open(str(path), flags)
    except OSError as error:
        if error.errno in (errno.ELOOP, errno.ENOTDIR):
            raise ProfileError(f'refusing symlink/non-regular profile read target: {path}') from error
        raise ProfileError(f'profile file open failed: {path}: {type(error).__name__}') from error
    consumed = 0
    digest = hashlib.sha256()
    try:
        opened = os.fstat(fd)
        expected = (observed.st_dev, observed.st_ino, observed.st_size, observed.st_mtime_ns)
        actual = (opened.st_dev, opened.st_ino, opened.st_size, opened.st_mtime_ns)
        if not stat.S_ISREG(opened.st_mode) or actual != expected:
            raise ProfileError(f'profile file changed before read: {path}')
        if opened.st_size > MAX_FILE_BYTES:
            raise ProfileError(f'profile file exceeds per-file budget: {path}')
        while consumed < opened.st_size:
            _check_deadline(deadline)
            chunk = os.read(fd, min(CHUNK_BYTES, opened.st_size - consumed))
            if not chunk:
                raise ProfileError(f'profile file ended during read: {path}')
            consumed += len(chunk)
            if consumed > MAX_FILE_BYTES:
                raise ProfileError(f'profile file exceeds per-file budget: {path}')
            digest.update(chunk)
        _check_deadline(deadline)
        closed = os.fstat(fd)
        final = (closed.st_dev, closed.st_ino, closed.st_size, closed.st_mtime_ns)
        if final != actual or consumed != closed.st_size:
            raise ProfileError(f'profile file changed during read: {path}')
        return digest.hexdigest(), consumed
    except OSError as error:
        raise ProfileError(f'profile file read failed: {path}: {type(error).__name__}') from error
    finally:
        os.close(fd)


def scan(root, *, deadline_seconds=SCAN_DEADLINE_SECONDS):
    root = absolute(root)
    _reject_symlink_components(root)
    if not root.is_dir():
        raise ProfileError(f'profile root is not a directory: {root}')
    deadline = time.monotonic() + deadline_seconds
    rows = {}
    total = 0
    for path, observed, parent_fd, name in _iter_files(root, deadline):
        _check_deadline(deadline)
        if len(rows) >= MAX_FILES:
            raise ProfileError('profile file-count budget exceeded')
        if total + observed.st_size > MAX_BYTES:
            raise ProfileError('profile aggregate byte budget exceeded')
        digest, consumed = _hash_file(path, observed, deadline, parent_fd=parent_fd, name=name)
        total += consumed
        if total > MAX_BYTES:
            raise ProfileError('profile aggregate byte budget exceeded')
        rows[path.relative_to(root).as_posix()] = digest
    _check_deadline(deadline)
    identity_rows = [[rel, rows[rel]] for rel in sorted(rows)]
    identity = hashlib.sha256(json.dumps(identity_rows, separators=(',', ':')).encode('utf-8')).hexdigest()
    return rows, identity


def _relative_path(value, label):
    if not isinstance(value, str) or not value or Path(value).is_absolute() or '..' in Path(value).parts:
        raise ProfileError(f'{label} must be a safe relative path: {value!r}')
    return Path(value).as_posix()


def _required_text(value, label):
    if not isinstance(value, str) or not value.strip():
        raise ProfileError(f'{label} must be a non-empty string')
    return value


def _identity(value, label):
    value = _required_text(value, label)
    if re.fullmatch(r'[0-9a-f]{64}', value) is None:
        raise ProfileError(f'{label} must be a lowercase SHA-256 hex string')
    return value


def _absolute_root(value, label):
    value = _required_text(value, label)
    return absolute(value)


def _normalize_mappings(source_mappings):
    if source_mappings is None:
        return {}
    if not isinstance(source_mappings, dict):
        raise ProfileError('source mappings must be an object')
    result = {}
    for candidate_path, source_path in source_mappings.items():
        candidate_rel = _relative_path(candidate_path, 'candidate mapping path')
        if candidate_rel in result:
            raise ProfileError(f'duplicate normalized candidate mapping path: {candidate_rel}')
        result[candidate_rel] = _relative_path(source_path, 'source mapping path')
    return dict(sorted(result.items()))


def _validate_profile_shape(profile):
    if not isinstance(profile, dict) or type(profile.get('schema_version')) is not int or profile.get('schema_version') != 1:
        raise ProfileError('profile schema is unsupported')
    if profile.get('profile_kind') != 'external-knowledge-compatibility':
        raise ProfileError('profile kind is unsupported')
    candidate = profile.get('candidate')
    source = profile.get('source')
    if not isinstance(candidate, dict) or not isinstance(source, dict):
        raise ProfileError('profile candidate/source metadata is invalid')
    for key in ('release_id', 'protection_version', 'root', 'tree_sha256'):
        if key not in candidate:
            raise ProfileError('profile candidate metadata is incomplete')
    for key in ('root', 'tree_sha256', 'active'):
        if key not in source:
            raise ProfileError('profile source metadata is incomplete')
    _required_text(candidate['release_id'], 'candidate release_id')
    _required_text(candidate['protection_version'], 'candidate protection_version')
    _absolute_root(candidate['root'], 'candidate root')
    _identity(candidate['tree_sha256'], 'candidate tree_sha256')
    _absolute_root(source['root'], 'source root')
    _identity(source['tree_sha256'], 'source tree_sha256')
    if type(source['active']) is not bool:
        raise ProfileError('source active must be a boolean')
    exact = profile.get('exact_duplicates')
    overlap = profile.get('candidate_overlap')
    disabled = profile.get('disabled_exact_duplicates')
    if not all(isinstance(value, list) for value in (exact, overlap, disabled)):
        raise ProfileError('profile duplicate lists are invalid')
    if not isinstance(profile.get('conflicts'), list):
        raise ProfileError('profile conflicts must be a list')
    if not isinstance(profile.get('safety'), dict):
        raise ProfileError('profile safety metadata is invalid')
    safe_lists = {}
    for label, values in (('exact_duplicates', exact), ('candidate_overlap', overlap),
                          ('disabled_exact_duplicates', disabled)):
        normalized = [_relative_path(value, label) for value in values]
        if normalized != sorted(set(normalized)):
            raise ProfileError(f'{label} is not sorted and unique')
        safe_lists[label] = normalized
    mappings = _normalize_mappings(profile.get('source_mappings', {}))
    return candidate, source, safe_lists, mappings


def build_profile(candidate_root, source_root, release_id, protection_version, active=False, source_mappings=None):
    if type(active) is not bool:
        raise ProfileError('source active must be a boolean')
    _required_text(release_id, 'candidate release_id')
    _required_text(protection_version, 'candidate protection_version')
    candidate_root = absolute(candidate_root)
    source_root = absolute(source_root)
    mappings = _normalize_mappings(source_mappings)
    candidate, candidate_identity = scan(candidate_root)
    source, source_identity = scan(source_root)
    exact = []
    overlap = []
    conflicts = []
    for rel in sorted(candidate):
        source_rel = mappings.get(rel, rel)
        if source.get(source_rel) == candidate[rel]:
            exact.append(rel)
        elif source_rel in source:
            overlap.append(rel)
            conflicts.append({'path': rel, 'source_path': source_rel,
                              'reason': 'same mapped path has different content'})
    return {
        'schema_version': 1,
        'profile_kind': 'external-knowledge-compatibility',
        'candidate': {'release_id': release_id, 'protection_version': protection_version,
                      'root': str(candidate_root), 'tree_sha256': candidate_identity},
        'source': {'root': str(source_root), 'tree_sha256': source_identity, 'active': bool(active)},
        'source_mappings': mappings,
        'exact_duplicates': exact,
        'candidate_overlap': overlap,
        'conflicts': conflicts,
        'disabled_exact_duplicates': exact if active else [],
        'safety': {
            'disable_requires_exact_path_and_hash': True,
            'partial_overlap_disables_nothing': True,
            'changed_or_missing_candidate_invalidates_profile': True,
            'changed_or_missing_source_invalidates_profile': True,
            'source_is_explicitly_confirmed': bool(active),
            'semantic_similarity_is_not_deduplication': True,
        },
    }


def current_status(profile, source_root=None, candidate_root=None, *, expected_release_id=None,
                   expected_protection_version=None):
    try:
        candidate_meta, source_meta, lists, mappings = _validate_profile_shape(profile)
    except ProfileError as error:
        return {'status': 'invalid', 'reason': str(error), 'disabled_exact_duplicates': []}
    if expected_release_id is not None and candidate_meta.get('release_id') != expected_release_id:
        return {'status': 'invalid', 'reason': 'profile release identity is stale', 'disabled_exact_duplicates': []}
    if (expected_protection_version is not None and
            candidate_meta.get('protection_version') != expected_protection_version):
        return {'status': 'invalid', 'reason': 'profile protection identity is stale', 'disabled_exact_duplicates': []}
    if source_root is None:
        return {'status': 'inactive',
                'reason': 'external source must be explicitly selected for this task',
                'disabled_exact_duplicates': []}
    try:
        current_candidate_root = absolute(candidate_root or candidate_meta['root'])
        current_candidate, candidate_identity = scan(current_candidate_root)
    except Exception as error:
        return {'status': 'invalid', 'reason': f'candidate observation failed: {type(error).__name__}',
                'disabled_exact_duplicates': []}
    if candidate_identity != candidate_meta.get('tree_sha256'):
        return {'status': 'invalid', 'reason': 'candidate release changed', 'disabled_exact_duplicates': []}
    try:
        current_source_root = absolute(source_root or source_meta['root'])
        current_source, source_identity = scan(current_source_root)
    except Exception as error:
        return {'status': 'invalid', 'reason': f'source observation failed: {type(error).__name__}',
                'disabled_exact_duplicates': []}
    if source_identity != source_meta.get('tree_sha256'):
        return {'status': 'invalid', 'reason': 'confirmed source changed', 'disabled_exact_duplicates': []}
    if not source_meta.get('active'):
        return {'status': 'inactive', 'reason': 'source is not explicitly confirmed active',
                'disabled_exact_duplicates': []}
    current_exact = sorted(rel for rel, digest in current_candidate.items()
                           if current_source.get(mappings.get(rel, rel)) == digest)
    if current_exact != lists['exact_duplicates'] or lists['disabled_exact_duplicates'] != current_exact:
        return {'status': 'invalid', 'reason': 'profile duplicate evidence is stale or inconsistent',
                'disabled_exact_duplicates': []}
    current_overlap = sorted(rel for rel in current_candidate
                             if mappings.get(rel, rel) in current_source and rel not in current_exact)
    if current_overlap != lists['candidate_overlap']:
        return {'status': 'invalid', 'reason': 'profile overlap evidence is stale or inconsistent',
                'disabled_exact_duplicates': []}
    return {'status': 'active_exact_only', 'reason': 'candidate and confirmed source identities match',
            'disabled_exact_duplicates': current_exact}
