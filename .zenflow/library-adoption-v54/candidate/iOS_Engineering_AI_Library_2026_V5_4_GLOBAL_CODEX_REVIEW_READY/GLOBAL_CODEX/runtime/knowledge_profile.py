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

MAX_FILES = 100000
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


def _iter_files(root, deadline):
    """Stream directory entries and keep symlink/nonsensical entries fail-closed."""
    pending = [root]
    while pending:
        _check_deadline(deadline)
        directory = pending.pop()
        try:
            entries = os.scandir(directory)
        except OSError as error:
            raise ProfileError(f'profile directory scan failed: {directory}: {type(error).__name__}') from error
        try:
            for entry in entries:
                _check_deadline(deadline)
                try:
                    observed = entry.stat(follow_symlinks=False)
                except OSError as error:
                    raise ProfileError(f'profile entry stat failed: {entry.path}: {type(error).__name__}') from error
                mode = observed.st_mode
                if stat.S_ISLNK(mode):
                    raise ProfileError(f'unsafe profile entry: {entry.path}')
                if stat.S_ISDIR(mode):
                    if entry.name not in EXCLUDED_DIRS:
                        pending.append(Path(entry.path))
                    continue
                if not stat.S_ISREG(mode):
                    raise ProfileError(f'unsafe profile entry: {entry.path}')
                yield Path(entry.path), observed
        finally:
            entries.close()


def _hash_file(path, observed, deadline):
    if observed.st_size > MAX_FILE_BYTES:
        raise ProfileError(f'profile file exceeds per-file budget: {path}')
    _reject_symlink_components(path.parent)
    flags = os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0)
    try:
        fd = os.open(str(path), flags)
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
    for path, observed in _iter_files(root, deadline):
        _check_deadline(deadline)
        if len(rows) >= MAX_FILES:
            raise ProfileError('profile file-count budget exceeded')
        digest, consumed = _hash_file(path, observed, deadline)
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
    if not isinstance(profile, dict) or profile.get('schema_version') != 1:
        raise ProfileError('profile schema is unsupported')
    candidate = profile.get('candidate')
    source = profile.get('source')
    if not isinstance(candidate, dict) or not isinstance(source, dict):
        raise ProfileError('profile candidate/source metadata is invalid')
    for section, keys in ((candidate, ('release_id', 'protection_version', 'root', 'tree_sha256')),
                          (source, ('root', 'tree_sha256', 'active'))):
        if any(key not in section for key in keys):
            raise ProfileError('profile metadata is incomplete')
    exact = profile.get('exact_duplicates')
    overlap = profile.get('candidate_overlap')
    disabled = profile.get('disabled_exact_duplicates')
    if not all(isinstance(value, list) for value in (exact, overlap, disabled)):
        raise ProfileError('profile duplicate lists are invalid')
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
