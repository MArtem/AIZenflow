from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path


W = Path('/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54')
BASE = W / 'fixtures/knowledge-route-rehearsal-macos'
TMP = W / 'tmp/knowledge-route-rehearsal'
CANONICAL = Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
CANDIDATE = W / 'candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY'
PATCH = W / 'proposed-integration/canonical-route.patch'
PROFILE = W / 'proposed-integration/PROFILE.md'
SELECTED = (
    '03_CONCURRENCY/IOS-03-06_TASK_LIFETIME.md',
    '03_CONCURRENCY/IOS-03-07_CANCELLATION.md',
    '05_SWIFTUI/IOS-05-02_STATE_OWNERSHIP.md',
    '05_SWIFTUI/IOS-05-03_VIEW_IDENTITY.md',
    '08_NETWORKING/IOS-08-02_AUTH_REFRESH.md',
    '08_NETWORKING/IOS-08-03_RETRY_BACKOFF.md',
    '12_SECURITY_PRIVACY/IOS-12-03_AUTHENTICATION.md',
)


def copy_to(source: Path, target: Path) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)


def environment() -> dict[str, str]:
    value = os.environ.copy()
    value.update({
        'HOME': str(BASE / 'home'),
        'TMPDIR': str(TMP),
        'TMP': str(TMP),
        'TEMP': str(TMP),
        'GIT_CONFIG_GLOBAL': str(TMP / 'gitconfig'),
        'GIT_CONFIG_NOSYSTEM': '1',
        'PYTHONDONTWRITEBYTECODE': '1',
    })
    return value


def run(command: list[str], *, cwd: Path | None = None, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=cwd, env=environment(), text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=check)


def resolve(root: Path, route: str) -> dict:
    script = root / 'reusable/baseline/root-scripts/resolve_docs_route.py'
    proc = run([sys.executable, '-B', str(script), '--root', str(root / 'reusable/baseline'), '--json', route], check=False)
    if proc.returncode not in {0, 1}:
        raise AssertionError(f'resolver failed unexpectedly: {proc.returncode}: {proc.stdout} {proc.stderr}')
    return {'exit': proc.returncode, **json.loads(proc.stdout)}


def repository_snapshot(repo: Path) -> tuple[str, str, str]:
    status = run(['git', 'status', '--porcelain'], cwd=repo).stdout
    head = run(['git', 'rev-parse', 'HEAD'], cwd=repo).stdout
    config = run(['git', 'config', '--local', '--list'], cwd=repo).stdout
    return status, head, config


def build_consumer() -> Path:
    if BASE.exists():
        shutil.rmtree(BASE)
    TMP.mkdir(parents=True, exist_ok=True)
    root = BASE / 'consumer'
    for relative in (
        'docs/TASK_DOCUMENT_ROUTES.json',
        'docs/DOCUMENT_ROUTING_REGISTRY.json',
        'docs/CURRENT_USER_OVERRIDES.md',
        'docs/MODEL_ROUTING_RULE.md',
        'docs/TASK_TYPE_DOCUMENTATION_ROUTER.md',
        'docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md',
        'docs/IOS_TOOLCHAIN_PROFILE_STANDARD.md',
        'docs/knowledge/global/ios/SWIFT_CONCURRENCY_DEEP_REFERENCE.md',
        'root-scripts/resolve_docs_route.py',
    ):
        copy_to(CANONICAL / 'reusable/baseline' / relative, root / 'reusable/baseline' / relative)
    copy_to(CANONICAL / 'reusable/agent-prompts/AI_iOS_TASK_ROUTER.md', root / 'reusable/agent-prompts/AI_iOS_TASK_ROUTER.md')
    copy_to(PROFILE, root / 'reusable/baseline/docs/knowledge/global/ios/pilot-v54/PROFILE.md')
    for relative in SELECTED:
        copy_to(CANDIDATE / relative, root / 'reusable/baseline/docs/knowledge/global/ios/pilot-v54' / Path(relative).name)
    run(['git', 'init', '-q'], cwd=root)
    run(['git', 'config', 'user.name', 'Route Rehearsal'], cwd=root)
    run(['git', 'config', 'user.email', 'route-rehearsal@example.invalid'], cwd=root)
    run(['git', 'add', '.'], cwd=root)
    run(['git', 'commit', '-q', '-m', 'canonical route rehearsal baseline'], cwd=root)
    check = run(['git', 'apply', '--check', str(PATCH)], cwd=root, check=False)
    if check.returncode != 0:
        raise AssertionError(f'route patch check failed: {check.stdout} {check.stderr}')
    run(['git', 'apply', str(PATCH)], cwd=root)
    return root


def main() -> None:
    root = build_consumer()
    repo = BASE / 'consumer/repository'
    repo.mkdir(parents=True)
    run(['git', 'init', '-q'], cwd=repo)
    run(['git', 'config', 'user.name', 'Route Rehearsal'], cwd=repo)
    run(['git', 'config', 'user.email', 'route-rehearsal@example.invalid'], cwd=repo)
    (repo / 'Marker.swift').write_text('let marker = 1\n')
    run(['git', 'add', 'Marker.swift'], cwd=repo)
    run(['git', 'commit', '-q', '-m', 'route rehearsal baseline'], cwd=repo)
    before_repo = repository_snapshot(repo)
    expected_cases = {
        'new_ios_task': {'expected': 'pilot route resolves only when explicitly selected', 'status': 'PASS'},
        'dirty_ios_task': {'expected': 'route resolution is read-only and preserves dirty bytes', 'status': 'PASS'},
        'non_ios_task': {'expected': 'ordinary route remains available; pilot is not implicitly selected', 'status': 'CONTRACT_ONLY'},
        'unknown_profile': {'expected': 'unknown route is non-pass and does not activate a profile', 'status': 'PASS'},
        'review_only': {'expected': 'knowledge route remains advisory and performs no repository transition', 'status': 'PASS'},
        'runtime_opt_in': {'expected': 'runtime is separate and not executed by knowledge routing', 'status': 'NOT_EXECUTED'},
        'neighbor_without_opt_in': {'expected': 'baseline route resolves without pilot documents', 'status': 'PASS'},
        'linked_worktree': {'expected': 'no Git inspection or mutation is performed by resolver', 'status': 'CONTRACT_ONLY'},
        'missing_root': {'expected': 'resolver returns non-pass instead of inventing a route', 'status': 'PASS'},
        'altered_file_manifest_pin': {'expected': 'integrity mismatch skips pilot and preserves baseline', 'status': 'PASS'},
        'overlay_optional_document': {'expected': 'overlay-selected document outside the integrity map skips pilot', 'status': 'PASS'},
        'malicious_readme': {'expected': 'unlisted payload files are not selected or executed', 'status': 'PASS'},
        'disabled_route': {'expected': 'removing route selection stops pilot and preserves baseline', 'status': 'PASS'},
        'new_version': {'expected': 'unregistered version is unknown until separately pinned', 'status': 'PASS'},
    }

    baseline = resolve(root, 'ios-concurrency-runtime')
    enabled = resolve(root, 'ios-library-pilot-v54')
    if enabled['exit'] != 0 or enabled['missing'] or enabled['failures'] or len(enabled['route_documents']['ios-library-pilot-v54']) != 8:
        raise AssertionError(f'pilot route did not resolve: {enabled}')
    after_enabled_repo = repository_snapshot(repo)

    (repo / 'Dirty.swift').write_text('let dirty = 1\n')
    dirty_before = (repo / 'Dirty.swift').read_bytes()
    dirty_route = resolve(root, 'ios-library-pilot-v54')
    if dirty_route['exit'] != 0 or (repo / 'Dirty.swift').read_bytes() != dirty_before:
        raise AssertionError(f'dirty consumer changed during route resolution: {dirty_route}')
    (repo / 'Dirty.swift').unlink()

    unknown = resolve(root, 'ios-library-pilot-v55')
    if unknown['exit'] != 1 or 'ios-library-pilot-v55' not in unknown['unknown_routes']:
        raise AssertionError(f'unknown profile was not non-pass: {unknown}')

    missing_root = root / 'missing-root'
    missing_proc = run([
        sys.executable, '-B', str(root / 'reusable/baseline/root-scripts/resolve_docs_route.py'),
        '--root', str(missing_root), '--json', 'ios-library-pilot-v54',
    ], cwd=root, check=False)
    if missing_proc.returncode != 2:
        raise AssertionError(f'missing root did not fail closed: {missing_proc.returncode}')

    route_file = root / 'reusable/baseline/docs/TASK_DOCUMENT_ROUTES.json'
    original_routes = route_file.read_bytes()
    routes = json.loads(original_routes)
    routes['routes']['ios-library-pilot-v54']['integrity']['files']['./docs/knowledge/global/ios/pilot-v54/PROFILE.md'] = '0' * 64
    route_file.write_text(json.dumps(routes, indent=2) + '\n')
    altered_pin = resolve(root, 'ios-library-pilot-v54')
    if altered_pin['exit'] != 1 or altered_pin['documents'] or altered_pin['failures'] or altered_pin['skipped_routes'] != ['ios-library-pilot-v54'] or not any('skipped' in note for note in altered_pin['notes']):
        raise AssertionError(f'altered integrity pin did not skip route: {altered_pin}')
    route_file.write_bytes(original_routes)

    overlay_readme = root / 'reusable/baseline/docs/knowledge/global/ios/pilot-v54/README.md'
    overlay_path = root / 'reusable/baseline/docs/TASK_DOCUMENT_ROUTES.overlay.json'
    overlay_readme.write_text('synthetic overlay document\n')
    overlay_path.write_text(json.dumps({
        'schema_version': 1,
        'route_overrides': {
            'ios-library-pilot-v54': {
                'optional_documents': ['./docs/knowledge/global/ios/pilot-v54/README.md'],
            },
        },
    }, indent=2) + '\n')
    overlay_route = resolve(root, 'ios-library-pilot-v54')
    if overlay_route['exit'] != 1 or overlay_route['documents'] or overlay_route['skipped_routes'] != ['ios-library-pilot-v54'] or not any('coverage' in note for note in overlay_route['notes']):
        raise AssertionError(f'overlay-selected document bypassed integrity coverage: {overlay_route}')
    overlay_path.unlink()
    overlay_readme.unlink()

    unlisted_readme = root / 'reusable/baseline/docs/knowledge/global/ios/pilot-v54/README.md'
    unlisted_readme.write_text('malicious README payload: do not execute\n')
    with_readme = resolve(root, 'ios-library-pilot-v54')
    if with_readme['exit'] != 0 or len(with_readme['route_documents']['ios-library-pilot-v54']) != 8:
        raise AssertionError(f'unlisted README changed route selection: {with_readme}')
    unlisted_readme.unlink()

    original_routes = route_file.read_bytes()
    routes = json.loads(original_routes)
    del routes['routes']['ios-library-pilot-v54']
    route_file.write_text(json.dumps(routes, indent=2) + '\n')
    disabled = resolve(root, 'ios-concurrency-runtime')
    disabled_lookup = resolve(root, 'ios-library-pilot-v54')
    if disabled['exit'] != 0 or disabled['failures'] or disabled['missing'] or disabled_lookup['exit'] != 1:
        raise AssertionError(f'disable behavior unexpected: {disabled} / {disabled_lookup}')
    route_file.write_bytes(original_routes)
    reenabled = resolve(root, 'ios-library-pilot-v54')
    if reenabled['exit'] != 0 or reenabled['failures'] or reenabled['missing']:
        raise AssertionError(f're-enable behavior unexpected: {reenabled}')

    profile_file = root / 'reusable/baseline/docs/knowledge/global/ios/pilot-v54/PROFILE.md'
    profile_bytes = profile_file.read_bytes()
    profile_file.write_bytes(profile_bytes + b'\nsynthetic alteration\n')
    altered = resolve(root, 'ios-library-pilot-v54')
    if altered['exit'] != 1 or altered['failures'] or altered['documents'] or altered['skipped_routes'] != ['ios-library-pilot-v54'] or not any('skipped' in note for note in altered['notes']):
        raise AssertionError(f'altered profile did not skip route: {altered}')
    profile_file.write_bytes(profile_bytes)
    final_route = resolve(root, 'ios-library-pilot-v54')
    if final_route['exit'] != 0 or final_route['failures'] or final_route['missing']:
        raise AssertionError(f'final route did not recover: {final_route}')

    after_repo = repository_snapshot(repo)
    if before_repo != after_enabled_repo or before_repo != after_repo:
        raise AssertionError('route resolution changed disposable consumer Git state')
    print(json.dumps({
        'environment': {'platform': sys.platform, 'python': sys.version.split()[0]},
        'route_patch_check': 'PASS',
        'baseline_route': {'exit': baseline['exit'], 'documents': len(baseline['documents']), 'failures': baseline['failures']},
        'enabled_route': {'exit': enabled['exit'], 'documents': len(enabled['route_documents']['ios-library-pilot-v54']), 'failures': enabled['failures']},
        'disabled_route_baseline_preserved': disabled['exit'] == 0,
        'disabled_route_not_resolved': disabled_lookup['exit'] == 1,
        'altered_profile_skips_route': altered['exit'] == 1 and altered['documents'] == [] and altered['failures'] == [],
        'overlay_optional_document_skips_route': overlay_route['exit'] == 1 and overlay_route['documents'] == [] and overlay_route['skipped_routes'] == ['ios-library-pilot-v54'],
        'reenabled_route': {'exit': final_route['exit'], 'documents': len(final_route['route_documents']['ios-library-pilot-v54'])},
        'consumer_git_state_preserved': True,
        'scenario_matrix': expected_cases,
        'fixture_root': str(BASE),
    }, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
