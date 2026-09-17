from __future__ import annotations

import hashlib
import json
import os
import shutil
import stat
import subprocess
import sys
from pathlib import Path


BASE = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/fixtures/install-lifecycle-macos')
TMP = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/tmp/install-lifecycle')
V54 = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY')
V52 = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v52-aPK9Wh/iOS_Engineering_AI_Library_2026_V5_2_GLOBAL_CODEX_REVIEW_READY')


def run(script_root, script, *args):
    env = os.environ.copy()
    env.update({'TMPDIR': str(TMP), 'TMP': str(TMP), 'TEMP': str(TMP), 'PYTHONDONTWRITEBYTECODE': '1'})
    return subprocess.run([sys.executable, '-B', str(script_root / script), *map(str, args)],
                          cwd=script_root, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def payload(proc):
    if not proc.stdout.strip():
        return {}
    try:
        return json.loads(proc.stdout)
    except json.JSONDecodeError as error:
        raise AssertionError(f'non-JSON output from {proc.args}: {proc.stdout[-1000:]} / {proc.stderr[-1000:]}') from error


def require(proc, code=0):
    if proc.returncode != code:
        raise AssertionError(f'command {proc.args} returned {proc.returncode}, expected {code}: {proc.stdout[-1000:]} {proc.stderr[-1000:]}')
    return payload(proc)


def snapshot(root):
    root = root.resolve()
    result = {}
    if not root.exists():
        return result
    for base, dirs, files in os.walk(root, topdown=True, followlinks=False):
        base_path = Path(base)
        dirs[:] = sorted(dirs)
        for name in sorted(files):
            path = base_path / name
            st = os.lstat(path)
            if stat.S_ISLNK(st.st_mode):
                result[str(path.relative_to(root))] = ('symlink', os.readlink(path))
            else:
                result[str(path.relative_to(root))] = (stat.S_IMODE(st.st_mode), path.read_bytes())
    return result


def home_args(home, mode='reference'):
    return ('--mode', mode, '--codex-home', home, '--runtime-root', home / 'content',
            '--skills-root', home / 'skills', '--agents-file', home / 'AGENTS.md')


def init_git_repo(repo):
    repo.mkdir(parents=True)
    (repo / 'A.swift').write_text('let a = 1\n')
    git_env = os.environ.copy()
    git_env.update({'GIT_AUTHOR_NAME': 'Synthetic Test', 'GIT_AUTHOR_EMAIL': 'synthetic@example.invalid',
                    'GIT_COMMITTER_NAME': 'Synthetic Test', 'GIT_COMMITTER_EMAIL': 'synthetic@example.invalid'})
    for args in (('git', 'init', '-q'), ('git', 'add', 'A.swift'), ('git', 'commit', '-qm', 'baseline')):
        result = subprocess.run(args, cwd=repo, env=git_env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0:
            raise AssertionError(f'git fixture command failed: {args}: {result.stderr}')


def v52_session_path(repo, state_root, session_id):
    state_key = hashlib.sha256(str(repo.resolve()).encode()).hexdigest()[:24]
    return state_root / 'repositories' / state_key / 'protection' / 'sessions' / f'{session_id}.json'


def assert_valid(home):
    result = require(run(V54, 'validate_global_install.py', '--codex-home', home))
    assert result.get('ok') is True, result


def install_reference_lifecycle():
    home = BASE / 'reference-home'
    home.mkdir(parents=True)
    agents = home / 'AGENTS.md'
    original = b'# User-owned rules\nkeep this exact text\n'
    agents.write_bytes(original)
    before = snapshot(home)

    dry = require(run(V54, 'install_global.py', *home_args(home), '--dry-run'))
    assert dry['dry_run'] is True and dry['would_mutate'] is False
    assert snapshot(home) == before

    require(run(V54, 'install_global.py', *home_args(home)))
    assert_valid(home)
    registry = json.loads((home / 'ios-engineering-global.json').read_text())
    assert registry['mode'] == 'reference' and registry['ownership']['skills'] == {}
    assert not (home / 'skills').exists()

    state_history = home / 'ios-engineering-state' / 'protection' / 'sessions' / 'legacy.json'
    state_history.parent.mkdir(parents=True)
    state_history.write_bytes(b'legacy session evidence\n')
    os.chmod(state_history, 0o600)
    agents.write_bytes(agents.read_bytes() + b'\n# USER EDIT AFTER INSTALL\n')

    sync_dry = require(run(V54, 'sync_global.py', '--codex-home', home, '--dry-run'))
    assert sync_dry['dry_run'] is True and not sync_dry['collisions']
    require(run(V54, 'sync_global.py', '--codex-home', home))
    assert_valid(home)
    assert b'# USER EDIT AFTER INSTALL' in agents.read_bytes()

    uninstall_dry = require(run(V54, 'uninstall_global.py', '--codex-home', home, '--dry-run'))
    assert uninstall_dry['dry_run'] is True and uninstall_dry['would_mutate'] is False
    require(run(V54, 'uninstall_global.py', '--codex-home', home, '--yes'))
    assert not (home / 'ios-engineering-global.json').exists()
    assert not (home / 'ios-engineering-shim').exists()
    assert not (home / 'content').exists()
    restored_agents = agents.read_bytes()
    assert original in restored_agents and b'# USER EDIT AFTER INSTALL' in restored_agents
    assert b'IOS_ENGINEERING_GLOBAL:BEGIN' not in restored_agents
    assert b'IOS_ENGINEERING_GLOBAL:END' not in restored_agents
    assert state_history.read_bytes() == b'legacy session evidence\n'
    return {'status': 'PASS', 'home': str(home), 'reference_skills': 0, 'external_state_preserved': True}


def full_collision_and_update():
    collision = BASE / 'full-collision-home'
    collision.mkdir(parents=True)
    (collision / 'AGENTS.md').write_bytes(b'# collision fixture\n')
    first_dry = require(run(V54, 'install_global.py', *home_args(collision, 'full'), '--dry-run'))
    names = first_dry['skills_to_install']
    assert len(names) == 60 and all(name.startswith('ioslib-') for name in names)
    collision_skill = collision / 'skills' / names[0]
    collision_skill.mkdir(parents=True)
    (collision_skill / 'USER_OWNED.txt').write_bytes(b'preserve me\n')
    before = snapshot(collision)
    rejected = require(run(V54, 'install_global.py', *home_args(collision, 'full'), '--dry-run'), code=2)
    assert rejected['collisions'] and snapshot(collision) == before
    assert not (collision / 'ios-engineering-global.json').exists()

    home = BASE / 'reference-to-full-home'
    home.mkdir(parents=True)
    agents = home / 'AGENTS.md'
    original = b'# User-owned full update rules\n'
    agents.write_bytes(original)
    require(run(V54, 'install_global.py', *home_args(home, 'reference')))
    full_dry = require(run(V54, 'sync_global.py', '--codex-home', home, '--mode', 'full', '--dry-run'))
    assert len(full_dry['skills_to_install']) == 60
    require(run(V54, 'sync_global.py', '--codex-home', home, '--mode', 'full', '--preflight-id', full_dry['preflight_id']))
    assert_valid(home)
    registry = json.loads((home / 'ios-engineering-global.json').read_text())
    assert registry['mode'] == 'full' and len(registry['ownership']['skills']) == 60
    assert all(name.startswith('ioslib-') for name in registry['ownership']['skills'])
    return {'status': 'PASS', 'collision_preflight': 'PASS', 'reference_to_full_update': 'PASS', 'full_skills': 60}


def v52_to_v54_update():
    home = BASE / 'v52-to-v54-home'
    home.mkdir(parents=True)
    agents = home / 'AGENTS.md'
    original = b'# V5.2 user rules\n'
    agents.write_bytes(original)
    require(run(V52, 'install_global.py', *home_args(home, 'reference')))
    consumer = BASE / 'v52-consumer'
    init_git_repo(consumer)
    state_root = home / 'ios-engineering-state'
    began = require(run(V52, 'GLOBAL_CODEX/runtime/bin/ios_ai.py', '--state-root', state_root,
                        'protect', 'begin', '--repo', consumer, '--allow', 'A.swift'))
    session_id = began['session_id']
    require(run(V52, 'GLOBAL_CODEX/runtime/bin/ios_ai.py', '--state-root', state_root,
                 'protect', 'close', '--repo', consumer, '--session', session_id))
    state_history = v52_session_path(consumer, state_root, session_id)
    assert state_history.exists()
    history_before = state_history.read_bytes()
    assert b'"schema_version": 2' in history_before

    require(run(V54, 'sync_global.py', '--codex-home', home, '--dry-run'))
    require(run(V54, 'sync_global.py', '--codex-home', home))
    assert_valid(home)
    first_registry = json.loads((home / 'ios-engineering-global.json').read_text())
    assert first_registry['version'].startswith('5.4-review-ready.')
    assert state_history.read_bytes() == history_before
    archival = require(run(V54, 'GLOBAL_CODEX/runtime/bin/ios_ai.py', '--state-root', state_root,
                           'protect', 'status', '--repo', consumer, '--session', session_id))
    assert archival['status'] == 'ARCHIVAL_CLOSED' and archival['historical_evidence_only'] is True

    active_consumer = BASE / 'v52-active-consumer'
    init_git_repo(active_consumer)
    active = require(run(V52, 'GLOBAL_CODEX/runtime/bin/ios_ai.py', '--state-root', state_root,
                          'protect', 'begin', '--repo', active_consumer, '--allow', 'A.swift'))
    active_sid = active['session_id']
    blocked_active = run(V54, 'GLOBAL_CODEX/runtime/bin/ios_ai.py', '--state-root', state_root,
                         'protect', 'begin', '--repo', active_consumer, '--allow', 'A.swift')
    assert blocked_active.returncode == 4 and 'legacy V5.2 active/verified' in blocked_active.stderr
    require(run(V52, 'GLOBAL_CODEX/runtime/bin/ios_ai.py', '--state-root', state_root,
                 'protect', 'verify', '--repo', active_consumer, '--session', active_sid))
    blocked_verified = run(V54, 'GLOBAL_CODEX/runtime/bin/ios_ai.py', '--state-root', state_root,
                           'protect', 'begin', '--repo', active_consumer, '--allow', 'A.swift')
    assert blocked_verified.returncode == 4 and 'legacy V5.2 active/verified' in blocked_verified.stderr
    require(run(V52, 'GLOBAL_CODEX/runtime/bin/ios_ai.py', '--state-root', state_root,
                 'protect', 'close', '--repo', active_consumer, '--session', active_sid))
    recovered = require(run(V54, 'GLOBAL_CODEX/runtime/bin/ios_ai.py', '--state-root', state_root,
                            'protect', 'begin', '--repo', active_consumer, '--allow', 'A.swift'))
    require(run(V54, 'GLOBAL_CODEX/runtime/bin/ios_ai.py', '--state-root', state_root,
                 'protect', 'close', '--repo', active_consumer, '--session', recovered['session_id']))

    require(run(V54, 'sync_global.py', '--codex-home', home, '--dry-run'))
    require(run(V54, 'sync_global.py', '--codex-home', home))
    assert_valid(home)
    assert original in agents.read_bytes() and state_history.read_bytes() == history_before
    require(run(V54, 'uninstall_global.py', '--codex-home', home, '--yes'))
    assert agents.read_bytes() == original and state_history.read_bytes() == history_before
    return {'status': 'PASS', 'v52_installer': 'PASS', 'v52_valid_closed_session': True,
            'v54_update': 'PASS', 'repeat_update': 'PASS', 'archival_status': 'ARCHIVAL_CLOSED',
            'active_legacy_blocked': True, 'verified_legacy_blocked': True,
            'explicit_v52_recovery': 'PASS', 'post_recovery_begin': 'PASS',
            'session_history_preserved_byte_for_byte': True}


def main():
    if BASE.exists():
        shutil.rmtree(BASE)
    TMP.mkdir(parents=True, exist_ok=True)
    results = {'reference_lifecycle': install_reference_lifecycle(),
               'full_and_collision': full_collision_and_update(),
               'v52_to_v54': v52_to_v54_update()}
    print(json.dumps({'environment': {'platform': 'macOS', 'python': sys.version.split()[0]},
                      'results': results, 'fixture_root': str(BASE)}, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
