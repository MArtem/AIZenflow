from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import uuid
from pathlib import Path


BASE = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/fixtures/runtime-matrix-macos')
TMP = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/tmp/runtime-matrix')
CLI = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py')


def env():
    result = os.environ.copy()
    result.update({'TMPDIR': str(TMP), 'TMP': str(TMP), 'TEMP': str(TMP),
                   'PYTHONDONTWRITEBYTECODE': '1',
                   'GIT_CONFIG_GLOBAL': str(TMP / 'gitconfig'), 'GIT_CONFIG_NOSYSTEM': '1'})
    return result


def git(repo, *args):
    return subprocess.run(['git', *args], cwd=repo, env=env(), check=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def ai(state, *args):
    return subprocess.run([sys.executable, '-B', str(CLI), '--state-root', str(state), *map(str, args)],
                          cwd=CLI.parent, env=env(), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def data(proc):
    raw = proc.stdout.strip() or proc.stderr.strip()
    if not raw:
        return {}
    try:
        return json.loads(raw)
    except json.JSONDecodeError as error:
        raise AssertionError(f'non-JSON CLI output: {raw[-1000:]}') from error


def repo_for(name, nested=False):
    repo = BASE / name / 'repo'
    repo.mkdir(parents=True)
    git(repo, 'init', '-q')
    git(repo, 'config', 'user.email', 'matrix@example.invalid')
    git(repo, 'config', 'user.name', 'Runtime Matrix')
    (repo / 'A.swift').write_text('let a = 1\n')
    (repo / 'B.swift').write_text('let b = 1\n')
    (repo / 'README.md').write_text('# Matrix\n')
    git(repo, 'add', 'A.swift', 'B.swift', 'README.md')
    git(repo, 'commit', '-q', '-m', 'matrix fixture')
    if nested:
        child = repo / 'Nested'
        child.mkdir()
        git(child, 'init', '-q')
        git(child, 'config', 'user.email', 'nested@example.invalid')
        git(child, 'config', 'user.name', 'Nested Matrix')
        (child / 'Nested.swift').write_text('let nested = 1\n')
        git(child, 'add', 'Nested.swift')
        git(child, 'commit', '-q', '-m', 'nested fixture')
    return repo


def check(label, proc, expected_code, predicate):
    observed = data(proc)
    if proc.returncode != expected_code:
        raise AssertionError(f'{label}: exit {proc.returncode}, expected {expected_code}: {proc.stdout[-600:]} {proc.stderr[-600:]}')
    if not predicate(observed):
        raise AssertionError(f'{label}: unexpected payload {observed}')
    return {'exit': proc.returncode, 'status': 'PASS'}


def protect_begin(repo, state, *scope):
    proc = ai(state, 'protect', 'begin', '--repo', repo, *scope)
    payload = data(proc)
    if proc.returncode != 0 or not payload.get('session_id'):
        raise AssertionError(f'begin failed: {proc.stdout} {proc.stderr}')
    return payload['session_id']


def allowed_matrix():
    rows = {}
    rows['A01_doctor'] = check('doctor', ai(BASE / 'state-doctor', 'doctor'), 0, lambda x: x.get('ok') is True and x.get('guard', '').startswith('advisory'))

    rows['A02_guard_read_only'] = check('guard safe', ai(BASE / 'state-guard', 'guard', '--command', 'git status --short'), 0, lambda x: x.get('classification') == 'ALLOW_READ_ONLY')
    rows['A03_guard_declared_policy'] = check('declared policy', ai(BASE / 'state-policy', 'declared-policy', '--repo', repo_for('policy')), 0, lambda x: x.get('knowledge_is_authority') is False and x.get('client_repository_infrastructure_written') is False)
    path_proc = ai(BASE / 'state-path', 'path', '--repo', repo_for('path'))
    path_value = path_proc.stdout.strip()
    if path_proc.returncode != 0 or not path_value.startswith(str(BASE)):
        raise AssertionError(f'path endpoint escaped synthetic state root: {path_proc.stdout} {path_proc.stderr}')
    rows['A04_path_external_state'] = {'exit': 0, 'status': 'PASS'}

    build_repo = repo_for('build')
    build = data(ai(BASE / 'state-build', 'build-phases', '--repo', build_repo))
    if build.get('status') not in {'complete', 'partial'} or build.get('safe_to_assume_read_only') is not False:
        raise AssertionError(f'build phase result not bounded/advisory: {build}')
    rows['A05_build_phase_advisory'] = {'exit': 0, 'status': 'PASS'}

    repo = repo_for('protect-unchanged'); state = BASE / 'state-protect-unchanged'
    sid = protect_begin(repo, state)
    rows['A06_protect_unchanged_begin'] = {'exit': 0, 'status': 'PASS'}
    rows['A07_protect_unchanged_verify'] = check('verify unchanged', ai(state, 'protect', 'verify', '--repo', repo, '--session', sid), 0, lambda x: x.get('ok') is True)
    rows['A08_protect_unchanged_close'] = check('close unchanged', ai(state, 'protect', 'close', '--repo', repo, '--session', sid), 0, lambda x: x.get('ok') is True and x.get('status') == 'CLOSED')

    repo = repo_for('protect-allowed'); state = BASE / 'state-protect-allowed'
    sid = protect_begin(repo, state, '--allow', 'A.swift')
    (repo / 'A.swift').write_text('let a = 2\n')
    check('verify allowed scope', ai(state, 'protect', 'verify', '--repo', repo, '--session', sid), 0, lambda x: x.get('ok') is True)
    rows['A09_protect_allowed_scope'] = check('close allowed scope', ai(state, 'protect', 'close', '--repo', repo, '--session', sid), 0, lambda x: x.get('ok') is True)
    return rows


def rejected_matrix():
    rows = {}
    rows['R01_guard_mutation_advisory'] = check('guard mutation', ai(BASE / 'state-guard-mutation', 'guard', '--command', 'rm -rf build'), 2, lambda x: x.get('classification') == 'REVIEW_UNSUPPORTED')
    rows['R02_guard_unknown_argv'] = check('guard unknown argv', ai(BASE / 'state-guard-unknown', 'guard', '--command', 'git --matrix-secret=do-not-run status'), 2, lambda x: x.get('classification') == 'REVIEW_UNSUPPORTED' and 'matrix-secret' not in json.dumps(x))

    repo = repo_for('outside-scope'); state = BASE / 'state-outside-scope'; sid = protect_begin(repo, state, '--allow', 'A.swift')
    (repo / 'B.swift').write_text('let b = 2\n')
    rows['R03_dirty_outside_scope'] = check('outside scope', ai(state, 'protect', 'verify', '--repo', repo, '--session', sid), 3, lambda x: x.get('ok') is False and x.get('status') != 'PASS' and x.get('violations'))

    repo = repo_for('git-config'); state = BASE / 'state-git-config'; sid = protect_begin(repo, state)
    git(repo, 'config', 'matrix.changed', 'true')
    rows['R04_git_config_mutation'] = check('git config mutation', ai(state, 'protect', 'verify', '--repo', repo, '--session', sid), 3, lambda x: x.get('ok') is False and x.get('status') != 'PASS' and x.get('violations'))

    repo = repo_for('index'); state = BASE / 'state-index'; sid = protect_begin(repo, state, '--allow', 'A.swift')
    (repo / 'A.swift').write_text('let a = 3\n'); git(repo, 'add', 'A.swift')
    rows['R05_index_without_transition'] = check('index mutation', ai(state, 'protect', 'verify', '--repo', repo, '--session', sid), 3, lambda x: x.get('ok') is False and x.get('status') != 'PASS' and x.get('violations'))

    repo = repo_for('refs'); state = BASE / 'state-refs'; sid = protect_begin(repo, state)
    git(repo, 'branch', 'unexpected-branch')
    rows['R06_ref_mutation'] = check('ref mutation', ai(state, 'protect', 'verify', '--repo', repo, '--session', sid), 3, lambda x: x.get('ok') is False and x.get('status') != 'PASS' and x.get('violations'))

    repo = repo_for('nested', nested=True); state = BASE / 'state-nested'; sid = protect_begin(repo, state)
    (repo / 'Nested' / 'Nested.swift').write_text('let nested = 2\n')
    rows['R07_nested_mutation'] = check('nested mutation', ai(state, 'protect', 'verify', '--repo', repo, '--session', sid), 3, lambda x: x.get('ok') is False and x.get('status') != 'PASS' and x.get('violations'))

    repo = repo_for('freshness'); state = BASE / 'state-freshness'
    rows['R08_missing_context_is_incomplete'] = check('missing context', ai(state, 'context', '--repo', repo, '--status'), 2, lambda x: x.get('fresh') is False and x.get('refresh_required') is True)
    return rows


def main():
    if BASE.exists():
        shutil.rmtree(BASE)
    TMP.mkdir(parents=True, exist_ok=True)
    rows = {'allowed': allowed_matrix(), 'reject_or_incomplete': rejected_matrix()}
    print(json.dumps({'environment': {'platform': 'macOS', 'python': sys.version.split()[0]},
                      'counts': {'allowed': len(rows['allowed']), 'reject_or_incomplete': len(rows['reject_or_incomplete'])},
                      'matrix': rows, 'fixture_root': str(BASE)}, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
