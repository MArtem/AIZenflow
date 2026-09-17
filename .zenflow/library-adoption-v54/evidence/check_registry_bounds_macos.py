from __future__ import annotations

import importlib.util
import json
import shutil
import subprocess
import sys
import uuid
from pathlib import Path


BASE = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/fixtures/registry-bounds-macos')
CLI = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py')
spec = importlib.util.spec_from_file_location('ios_ai_registry_bounds', CLI)
C = importlib.util.module_from_spec(spec)
assert spec and spec.loader
spec.loader.exec_module(C)


def git(repo, *args):
    return subprocess.run(['git', *args], cwd=repo, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def write_record(path, worktree, common, sid=None):
    sid = sid or str(uuid.uuid4())
    baseline = {'repository_identity': {'worktree': str(worktree.resolve()), 'git_common_dir': str(common)}}
    scope = {'allow': [], 'allow_dirty': [], 'allow_protected': [], 'allow_nested': [], 'git_transitions': [], 'task': None}
    data = {'schema_version': 2, 'session_id': sid, 'lifecycle': 'closed', 'created_at': '2026-09-11T00:00:00+00:00',
            'baseline': baseline, 'baseline_sha256': C.jhash(baseline), 'scope': scope, 'audit': []}
    C.P.secure_write(path, json.dumps(data, separators=(',', ':')))
    return sid


def fixture(count):
    state = BASE / f'state-{count}'
    repos = state / 'repositories'
    C.P.secure_dir(repos)
    repo = BASE / 'repo'
    common = Path(C.P.repository_identity(repo, C.P.Budget())['git_common_dir']).resolve()
    for index in range(count):
        worktree = BASE / 'fake-worktrees' / str(index)
        sessions = repos / C.state_key(worktree) / 'protection' / 'sessions'
        C.P.secure_dir(sessions)
        sid = str(uuid.uuid4())
        write_record(sessions / f'{sid}.json', worktree, common, sid=sid)
    return repo, state


def expect_protection(label, action, expected):
    try:
        action()
    except C.P.ProtectionError as error:
        message = str(error)
        if expected not in message:
            raise AssertionError(f'{label}: unexpected ProtectionError: {message}')
        return {'status': 'PASS', 'error': message}
    raise AssertionError(f'{label}: unexpected success')


def main():
    if BASE.exists():
        shutil.rmtree(BASE)
    repo = BASE / 'repo'
    repo.mkdir(parents=True)
    git(repo, 'init', '-q')
    git(repo, 'config', 'user.email', 'fixture@example.invalid')
    git(repo, 'config', 'user.name', 'Registry Bounds Fixture')
    (repo / 'A.swift').write_text('let a = 1\n')
    git(repo, 'add', 'A.swift')
    git(repo, 'commit', '-q', '-m', 'fixture')

    original = (C.LEGACY_SCAN_MAX_REPOSITORIES, C.LEGACY_SCAN_MAX_SESSION_RECORDS, C.LEGACY_SCAN_MAX_BYTES)
    try:
        _, state = fixture(2)
        C.LEGACY_SCAN_MAX_REPOSITORIES = 1
        repository_bound = expect_protection('repository bound', lambda: C._scan_legacy_v52_shared_writer_blockers(repo, state), 'repository-entry budget exceeded')

        _, state = fixture(1)
        C.LEGACY_SCAN_MAX_REPOSITORIES = 10_000
        C.LEGACY_SCAN_MAX_SESSION_RECORDS = 10_000
        C.LEGACY_SCAN_MAX_BYTES = 1
        byte_bound = expect_protection('byte bound', lambda: C._scan_legacy_v52_shared_writer_blockers(repo, state), 'byte budget exceeded')

        _, state = fixture(2)
        C.LEGACY_SCAN_MAX_BYTES = 32 * 1024 * 1024
        C.LEGACY_SCAN_MAX_SESSION_RECORDS = 1
        record_bound = expect_protection('record bound', lambda: C._scan_legacy_v52_shared_writer_blockers(repo, state), 'record budget exceeded')

        _, state = fixture(1)
        malformed = next((state / 'repositories').glob('*/protection/sessions/*.json'))
        C.P.secure_write(malformed, '{')
        malformed_result = expect_protection('malformed private record', lambda: C._scan_legacy_v52_shared_writer_blockers(repo, state), 'malformed')
    finally:
        C.LEGACY_SCAN_MAX_REPOSITORIES, C.LEGACY_SCAN_MAX_SESSION_RECORDS, C.LEGACY_SCAN_MAX_BYTES = original

    print(json.dumps({'environment': {'platform': 'macOS', 'python': sys.version.split()[0]},
                      'repository_bound': repository_bound, 'byte_bound': byte_bound,
                      'record_bound': record_bound, 'malformed_private_record': malformed_result,
                      'fixture_root': str(BASE)}, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
