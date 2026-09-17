from __future__ import annotations

import json
import os
import signal
import shutil
import subprocess
import sys
import time
from pathlib import Path


BASE = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/fixtures/interruption-macos')
TMP = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/tmp/interruption')
V54 = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY')


def env():
    result = os.environ.copy()
    result.update({'TMPDIR': str(TMP), 'TMP': str(TMP), 'TEMP': str(TMP), 'PYTHONDONTWRITEBYTECODE': '1',
                   'GIT_AUTHOR_NAME': 'Synthetic Test', 'GIT_AUTHOR_EMAIL': 'synthetic@example.invalid',
                   'GIT_COMMITTER_NAME': 'Synthetic Test', 'GIT_COMMITTER_EMAIL': 'synthetic@example.invalid'})
    return result


def home_args(home):
    return ('--mode', 'reference', '--codex-home', home, '--runtime-root', home / 'content',
            '--skills-root', home / 'skills', '--agents-file', home / 'AGENTS.md')


def run(*args):
    return subprocess.run([sys.executable, *map(str, args)], cwd=V54, env=env(),
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def require(proc, code=0):
    if proc.returncode != code:
        raise AssertionError(f'command failed rc={proc.returncode}, expected {code}: {proc.stdout[-1000:]} {proc.stderr[-1000:]}')
    return json.loads(proc.stdout) if proc.stdout.strip() else {}


def child(home):
    sys.path.insert(0, str(V54))
    import install_global as installer
    import types

    args = types.SimpleNamespace(codex_home=str(home), runtime_root=str(home / 'content'),
                                skills_root=str(home / 'skills'), agents_file=str(home / 'AGENTS.md'),
                                use_source_in_place=False, mode='reference', preflight_id=None,
                                dry_run=False)
    original_replace = installer._replace_path

    def publish_then_pause(source, target):
        result = original_replace(source, target)
        print('PUBLISHED_ONCE', flush=True)
        time.sleep(60)
        return result

    installer._replace_path = publish_then_pause
    preflight = installer.build_preflight(args, False)
    installer.apply_fresh(preflight, args)


def main():
    if len(sys.argv) == 3 and sys.argv[1] == '--child':
        child(Path(sys.argv[2]))
        return

    if BASE.exists():
        shutil.rmtree(BASE)
    TMP.mkdir(parents=True, exist_ok=True)
    home = BASE / 'interrupted-home'
    home.mkdir(parents=True)
    agents = home / 'AGENTS.md'
    original_agents = b'# interruption fixture user rules\n'
    agents.write_bytes(original_agents)

    process = subprocess.Popen([sys.executable, str(Path(__file__)), '--child', str(home)],
                               cwd=V54, env=env(), stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                               text=True)
    marker = process.stdout.readline().strip()
    if marker != 'PUBLISHED_ONCE':
        process.kill()
        stdout, stderr = process.communicate(timeout=5)
        raise AssertionError(f'child did not reach publication boundary: {marker!r} {stdout[-1000:]} {stderr[-1000:]}')
    os.kill(process.pid, signal.SIGKILL)
    process.wait(timeout=5)
    assert process.returncode == -signal.SIGKILL

    content = home / 'content'
    leftovers = sorted(home.glob('.ioslib-txn-*'))
    assert content.is_dir() and leftovers
    assert not (home / 'ios-engineering-global.json').exists()
    assert agents.read_bytes() == original_agents

    blocked = require(run(V54 / 'install_global.py', *home_args(home), '--dry-run'), code=2)
    assert blocked['collisions'] and any('content root exists' in item for item in blocked['collisions'])
    assert agents.read_bytes() == original_agents

    sys.path.insert(0, str(V54))
    import install_global as installer
    installer.remove_created(content)
    for leftover in leftovers:
        installer.remove_created(leftover)
    assert not content.exists() and not leftovers[0].exists()

    require(run(V54 / 'install_global.py', *home_args(home)))
    valid = require(run(V54 / 'validate_global_install.py', '--codex-home', home))
    assert valid.get('ok') is True
    assert agents.read_bytes() == original_agents + b'\n' + (V54 / 'GLOBAL_CODEX/AGENTS.global.block.md').read_bytes()
    print(json.dumps({'status': 'PASS', 'child_exit': 'SIGKILL', 'published_before_interrupt': True,
                      'next_launch': 'blocked_and_discoverable', 'operator_recovery': 'PASS',
                      'post_recovery_install': 'PASS', 'fixture_root': str(BASE)}, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
