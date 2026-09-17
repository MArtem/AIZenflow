from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path


BASE = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/fixtures/pilots-macos')
TMP = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/tmp/pilots')
ROOT = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY')
CLI = ROOT / 'GLOBAL_CODEX/runtime/bin/ios_ai.py'


def env():
    value = os.environ.copy()
    value.update({'TMPDIR': str(TMP), 'TMP': str(TMP), 'TEMP': str(TMP),
                  'PYTHONDONTWRITEBYTECODE': '1',
                  'GIT_CONFIG_GLOBAL': str(TMP / 'gitconfig'), 'GIT_CONFIG_NOSYSTEM': '1'})
    return value


def git(repo, *args):
    return subprocess.run(['git', *args], cwd=repo, env=env(), check=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def ai(state, *args):
    return subprocess.run([sys.executable, '-B', str(CLI), '--state-root', str(state), *map(str, args)],
                          cwd=CLI.parent, env=env(), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def json_output(proc):
    raw = proc.stdout.strip() or proc.stderr.strip()
    return json.loads(raw) if raw else {}


def expect(label, proc, code, predicate):
    value = json_output(proc)
    if proc.returncode != code or not predicate(value):
        raise AssertionError(f'{label}: rc={proc.returncode}, payload={value}, stderr={proc.stderr[-500:]}')
    return {'status': 'PASS', 'exit': proc.returncode}


def knowledge_pilot():
    cases = {
        'swiftui_replacement': {
            'path': '03_CONCURRENCY/IOS-03-07_CANCELLATION.md',
            'checks': ['generation', 'old success', 'old generic failure', 'cooperative cancellation'],
        },
        'auth_refresh_retry': {
            'path': '08_NETWORKING/IOS-08-02_AUTH_REFRESH.md',
            'checks': ['single-flight', 'bounded replay', 'logout race', 'refresh-token rotation'],
        },
        'migration_and_accessibility': {
            'path': '09_PERSISTENCE_DATA/IOS-09-05_MIGRATIONS.md',
            'checks': ['pre-upgrade stores', 'row/object counts', 'rollback'],
        },
        'voiceover_semantics': {
            'path': '13_ACCESSIBILITY_LOCALIZATION/IOS-13-01_VOICEOVER.md',
            'checks': ['focus order', 'dynamic content insertion', 'actual VoiceOver traversal'],
        },
    }
    baseline = (ROOT / 'GLOBAL_CODEX/AGENTS.global.block.md').read_text().lower() + '\n' + (ROOT / 'GLOBAL_CODEX/runtime/core/QUALITY_STANDARD.md').read_text().lower()
    result = {}
    additional = []
    for name, case in cases.items():
        text = (ROOT / case['path']).read_text().lower()
        missing = [term for term in case['checks'] if term.lower() not in text]
        if missing:
            raise AssertionError(f'knowledge case {name} missing checks: {missing}')
        delta = [term for term in case['checks'] if term.lower() not in baseline]
        additional.extend(delta)
        result[name] = {'status': 'PASS', 'checks': len(case['checks']), 'specific_delta_checks': delta}
    if len(set(additional)) < 8:
        raise AssertionError(f'knowledge pilot did not show enough domain-specific delta: {additional}')
    return {'status': 'PASS', 'cases': result, 'additional_domain_checks': sorted(set(additional)),
            'method': 'deterministic document-to-rubric coverage, not blind model evaluation'}


def runtime_pilot():
    root = BASE / 'consumer'
    repo = root / 'repo'; repo.mkdir(parents=True)
    git(repo, 'init', '-q')
    git(repo, 'config', 'user.email', 'pilot@example.invalid')
    git(repo, 'config', 'user.name', 'Runtime Pilot')
    (repo / 'A.swift').write_text('let a = 1\n')
    (repo / 'B.swift').write_text('let b = 1\n')
    git(repo, 'add', 'A.swift', 'B.swift'); git(repo, 'commit', '-q', '-m', 'pilot baseline')
    user_control = repo / 'USER_CONTROL.md'; user_control.write_bytes(b'user-owned dirty control\n')
    original_control = user_control.read_bytes()
    state = BASE / 'state'

    sid = json_output(ai(state, 'protect', 'begin', '--repo', repo, '--allow', 'A.swift'))['session_id']
    (repo / 'A.swift').write_text('let a = 2\n')
    expect('allowed write', ai(state, 'protect', 'verify', '--repo', repo, '--session', sid), 0, lambda x: x.get('ok') is True)
    expect('allowed close', ai(state, 'protect', 'close', '--repo', repo, '--session', sid), 0, lambda x: x.get('ok') is True)

    sid = json_output(ai(state, 'protect', 'begin', '--repo', repo, '--allow', 'A.swift'))['session_id']
    original_b = (repo / 'B.swift').read_bytes()
    (repo / 'B.swift').write_text('let b = 2\n')
    rejected = expect('forbidden write', ai(state, 'protect', 'verify', '--repo', repo, '--session', sid), 3,
                      lambda x: x.get('ok') is False and x.get('violations'))
    (repo / 'B.swift').write_bytes(original_b)
    expect('rollback after forbidden write', ai(state, 'protect', 'verify', '--repo', repo, '--session', sid), 0,
           lambda x: x.get('ok') is True)
    expect('close after rollback', ai(state, 'protect', 'close', '--repo', repo, '--session', sid), 0,
           lambda x: x.get('ok') is True)
    assert user_control.read_bytes() == original_control

    sid = json_output(ai(state, 'protect', 'begin', '--repo', repo, '--allow', 'A.swift'))['session_id']
    git(repo, 'branch', 'pilot-forbidden-ref')
    ref_rejected = expect('forbidden ref write', ai(state, 'protect', 'verify', '--repo', repo, '--session', sid), 3,
                          lambda x: x.get('ok') is False and x.get('violations'))
    git(repo, 'branch', '-D', 'pilot-forbidden-ref')
    expect('rollback after ref write', ai(state, 'protect', 'verify', '--repo', repo, '--session', sid), 0,
           lambda x: x.get('ok') is True)
    expect('close after ref rollback', ai(state, 'protect', 'close', '--repo', repo, '--session', sid), 0,
           lambda x: x.get('ok') is True)
    assert user_control.read_bytes() == original_control
    return {'status': 'PASS', 'tasks': {'allowed_write': 'PASS', 'forbidden_write_detected': rejected,
                                        'forbidden_write_rollback': 'PASS', 'forbidden_ref_detected': ref_rejected,
                                        'forbidden_ref_rollback': 'PASS'}, 'dirty_user_control_preserved': True}


def main():
    if BASE.exists():
        shutil.rmtree(BASE)
    TMP.mkdir(parents=True, exist_ok=True)
    result = {'knowledge': knowledge_pilot(), 'runtime': runtime_pilot()}
    print(json.dumps({'environment': {'platform': 'macOS', 'python': sys.version.split()[0]},
                      'result': result, 'fixture_root': str(BASE)}, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
