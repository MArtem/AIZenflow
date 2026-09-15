#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import argparse, json, os, re, secrets, shutil
import install_global as I

class SyncError(RuntimeError):
    pass

class SyncRollbackIncomplete(SyncError):
    pass

class SyncCleanupIncomplete(SyncError):
    pass


def extract_block(text: str):
    m = re.search(re.escape(I.BEGIN) + r'.*?' + re.escape(I.END), text, re.S)
    return m.group(0) if m else None


def replace_block(text: str, new_block: str):
    pat = re.compile(re.escape(I.BEGIN) + r'.*?' + re.escape(I.END), re.S)
    if not pat.search(text):
        raise SyncError('managed AGENTS block missing')
    return pat.sub(new_block.rstrip(), text, count=1)


def preflight(ch: Path, mode_override=None):
    ch = I.codex_home(ch)
    old = I.read_registry(ch)
    if not old:
        raise SyncError('no managed installation registry; use install_global.py')
    mode = mode_override or old.get('mode', 'reference')
    if mode not in {'reference', 'full'}:
        raise SyncError('invalid installed mode')

    conflicts = []
    incoming_source = I.abs_lex(I.HERE)
    if old.get('source_in_place'):
        content_root = incoming_source
        try:
            I.reject_symlink_path(content_root)
            if not content_root.is_dir():
                conflicts.append(f'source-in-place release root is not a directory: {content_root}')
        except Exception as e:
            conflicts.append(f'source-in-place release root is unsafe: {e}')
    else:
        content_root = Path(old.get('content_root', ''))
    own = old.get('ownership', {})
    path_items = [
        ('codex_home', ch),
        ('shim_root', Path(old.get('shim_root', ''))),
        ('state_root', Path(old.get('state_root', ''))),
        ('skills_root', Path(old.get('skills_root', ''))),
        ('agents_file', Path(old.get('agents_file', ''))),
        ('registry', ch / I.REGISTRY_NAME),
    ]
    if not old.get('source_in_place'):
        path_items.append(('content_root', Path(old.get('content_root', ''))))
    destination_targets = {label: path for label, path in path_items}
    conflicts.extend(I.destination_layout_collisions(
        destination_targets,
        source_root=incoming_source,
        source_in_place=bool(old.get('source_in_place')),
        canonical_repository_root=old.get('canonical_repository_root'),
        allow_canonical_repository_runtime=(old.get('deployment_profile') == I.CANONICAL_REPOSITORY_RUNTIME_PROFILE),
    ))
    for label, p in path_items:
        try:
            I.reject_symlink_path(p)
        except Exception as e:
            conflicts.append(f'{label}: {e}')

    try:
        blockers = I.incompatible_active_sessions(Path(old['state_root']), I.PROTECTION_VERSION)
        conflicts.extend(
            'incompatible active protection session: {session_id} ({protection_version}); '
            'close/recover it with the old runtime before update'.format(**row)
            for row in blockers
        )
    except Exception as e:
        conflicts.append(f'active-session admission check failed: {type(e).__name__}: {e}')

    if not old.get('source_in_place'):
        conflicts += [f'content: {x}' for x in I.check_existing_managed(Path(old['content_root']), own.get('content', {}))]
    conflicts += [f'shim: {x}' for x in I.check_existing_managed(Path(old['shim_root']), own.get('shim', {}))]
    for n, expected in own.get('skills', {}).items():
        conflicts += [f'skill {n}: {x}' for x in I.check_existing_managed(Path(old['skills_root']) / n, expected)]

    agents = Path(old['agents_file'])
    try:
        raw_agents = I.read_regular_bytes(agents, I.TEXT_LIMIT) if I.lexists(agents) else b''
        text = raw_agents.decode('utf-8')
        block = extract_block(text)
        if not block or I.sha_bytes(block.rstrip().encode()) != old.get('agents', {}).get('managed_block_sha256'):
            conflicts.append('managed AGENTS block missing or locally modified')
    except Exception:
        conflicts.append('AGENTS file unreadable')

    marker = Path(old['state_root']) / '.ioslib-state-owned.json'
    expected_marker = own.get('state_files', {}).get('.ioslib-state-owned.json')
    try:
        if not expected_marker or not I.lexists(marker) or marker.is_symlink() or I.sha_file(marker) != expected_marker:
            conflicts.append('state ownership marker modified/missing')
    except Exception:
        conflicts.append('state ownership marker unreadable')

    incoming = I.skill_names() if mode == 'full' else []
    oldskills = set(own.get('skills', {}))
    for n in incoming:
        dst = Path(old['skills_root']) / n
        if n not in oldskills and I.lexists(dst):
            conflicts.append(f'new incoming skill collides with unmanaged path: {dst}')

    try:
        source_tree_sha256 = I.package_tree_identity()
    except Exception as e:
        conflicts.append(f'package source invalid: {e}')
        source_tree_sha256 = None

    base = {
        'version': I.VERSION,
        'protection_version': I.PROTECTION_VERSION,
        'deployment_profile': old.get('deployment_profile', 'user_global'),
        'mode': mode,
        'source': str(incoming_source),
        'source_tree_sha256': source_tree_sha256,
        'codex_home': str(ch),
        'content_root': str(content_root),
        'source_in_place': bool(old.get('source_in_place')),
        'shim_root': old['shim_root'],
        'state_root': old['state_root'],
        'skills_root': old['skills_root'],
        'agents_file': old['agents_file'],
        'skills_to_install': incoming,
        'collisions': sorted(set(conflicts)),
        'policy_precedence': old.get('policy_precedence', []),
        'operations': [
            'verify previous ownership hashes and target ancestry',
            'prepare all incoming trees on each target filesystem',
            'atomically swap managed trees with target-local rollback backups',
            'replace only the unchanged managed AGENTS block',
            'update only the owned external-state marker',
            'write a new ownership registry',
        ],
    }
    if old.get('canonical_repository_root'):
        base['canonical_repository_root'] = old['canonical_repository_root']
        base['canonical_runtime_root'] = old.get('canonical_runtime_root')
    base['preflight_id'] = I.canonical_hash(base)
    return old, base


def main():
    ap = argparse.ArgumentParser(description='Transactional update of unchanged managed assets; local edits are conflicts and are preserved.')
    ap.add_argument('--codex-home')
    ap.add_argument('--mode', choices=['reference', 'full'])
    ap.add_argument('--dry-run', action='store_true')
    ap.add_argument('--preflight-id')
    a = ap.parse_args()
    ch = I.codex_home(a.codex_home)
    old, pre = preflight(ch, a.mode)
    if a.dry_run:
        print(json.dumps({'dry_run': True, 'would_mutate': False, **pre}, indent=2))
        return 0 if not pre['collisions'] else 2
    if pre['collisions']:
        raise SyncError('update blocked by managed/unmanaged conflicts; no mutation performed')
    if pre['mode'] == 'full' and a.preflight_id != pre['preflight_id']:
        raise SyncError('full update requires --preflight-id from matching --dry-run')

    class X:
        pass
    x = X()
    x.use_source_in_place = pre['source_in_place']
    x.mode = pre['mode']

    txn = I.build_stage(pre, x)
    token = secrets.token_hex(8)
    incoming_specs = []
    if not pre['source_in_place']:
        incoming_specs.append((txn / 'content', Path(pre['content_root'])))
    incoming_specs.append((txn / 'shim', Path(pre['shim_root'])))
    if pre['mode'] == 'full':
        for n in pre['skills_to_install']:
            incoming_specs.append((txn / 'skills' / n, Path(pre['skills_root']) / n))

    prepared = []
    incoming_expected = {}
    backups = []
    published_metadata = {}
    agents = Path(pre['agents_file'])
    registry = ch / I.REGISTRY_NAME
    marker = Path(pre['state_root']) / '.ioslib-state-owned.json'
    old_agents, agents_mode = I.read_regular_snapshot(agents, I.TEXT_LIMIT)
    old_registry = I.read_regular_bytes(registry, I.TEXT_LIMIT)
    old_marker = I.read_regular_bytes(marker, I.TEXT_LIMIT)
    rollback_errors = []
    published_new_targets = []
    published = False
    try:
        # No managed target is touched until every incoming target-local stage succeeds.
        for src, target in incoming_specs:
            local = I.prepare_local_tree(src, target, token)
            prepared.append((target, local))
            incoming_expected[str(target)] = I.managed_hashes(local)

        incoming_by_target = {str(t): p for t, p in prepared}
        targets = []
        old_expected = {}
        old_ownership = old.get('ownership', {})
        if not pre['source_in_place']:
            content_target=Path(pre['content_root']); targets.append(content_target); old_expected[str(content_target)]=old_ownership.get('content', {})
        shim_target=Path(pre['shim_root']); targets.append(shim_target); old_expected[str(shim_target)]=old_ownership.get('shim', {})
        oldskills = set(old_ownership.get('skills', {}))
        newskills = set(pre['skills_to_install'])
        for n in sorted(oldskills | newskills):
            target=Path(old['skills_root']) / n
            targets.append(target)
            if n in oldskills: old_expected[str(target)]=old_ownership.get('skills', {}).get(n, {})

        # Every existing managed target is moved to a hidden sibling backup before a
        # replacement/removal, so each switch is same-filesystem and reversible.
        # Revalidate the moved old tree against the *previous* ownership manifest before
        # publishing incoming bytes. This catches edits racing after preflight rather than
        # deleting them as part of a successful update.
        for target in targets:
            backup = target.parent / f'.{target.name}.ioslib-backup.{token}'
            if I.lexists(backup):
                raise SyncError(f'backup staging collision: {backup}')
            expected_old=old_expected.get(str(target))
            if expected_old is not None and not I.lexists(target):
                raise SyncError(f'managed target disappeared after preflight: {target}')
            if I.lexists(target):
                if expected_old is None:
                    raise SyncError(f'unmanaged target appeared after preflight: {target}')
                # Journal before rename: _replace_path can publish the backup and then
                # fail while fsyncing its parent directory.
                backups.append((target, backup, expected_old))
                I._replace_path(target, backup)
                if expected_old is not None:
                    problems=I.check_existing_managed(backup,expected_old)
                    if problems:
                        raise SyncError(f'managed target changed after preflight: {target}: {problems[0]}')
            incoming = incoming_by_target.get(str(target))
            if incoming is not None:
                if expected_old is None:
                    # Recheck at the publication boundary so a path that appeared
                    # after preflight is never replaced as an implicit new target.
                    if I.lexists(target):
                        raise SyncError(f'unmanaged target appeared before publication: {target}')
                    # Journal before rename: _replace_path can publish the target and
                    # then fail while fsyncing its parent directory.
                    published_new_targets.append(target)
                I._replace_path(incoming, target)

        current = old_agents.decode('utf-8')
        newblock = I.read_regular_bytes(I.G / 'AGENTS.global.block.md', I.TEXT_LIMIT).decode('utf-8')
        new_agents = replace_block(current, newblock).encode()
        if I.read_regular_bytes(agents, I.TEXT_LIMIT) != old_agents:
            raise SyncError('AGENTS changed concurrently before update publication')
        published_metadata[str(agents)] = I.sha_bytes(new_agents)
        I.write_atomic(agents, new_agents, agents_mode)
        marker_bytes = json.dumps({'managed_by': 'ios-engineering-library', 'version': I.VERSION}).encode() + b'\n'
        if I.read_regular_bytes(marker, I.TEXT_LIMIT) != old_marker:
            raise SyncError('state ownership marker changed concurrently before update publication')
        published_metadata[str(marker)] = I.sha_bytes(marker_bytes)
        I.write_atomic(marker, marker_bytes, 0o600)

        ownership = {
            'content': {} if pre['source_in_place'] else I.managed_hashes(Path(pre['content_root'])),
            'shim': I.managed_hashes(Path(pre['shim_root'])),
            'skills': {n: I.managed_hashes(Path(pre['skills_root']) / n) for n in pre['skills_to_install']},
            'state_files': {'.ioslib-state-owned.json': I.sha_file(marker)},
        }
        result = {
            **pre,
            'installed': True,
            'ownership': ownership,
            'agents': {
                'existed_before': old.get('agents', {}).get('existed_before', True),
                'original_sha256': old.get('agents', {}).get('original_sha256'),
                'original_mode': old.get('agents', {}).get('original_mode'),
                'managed_mode': agents_mode,
                'managed_block_sha256': I.sha_bytes(newblock.rstrip().encode()),
                'separator_hex': old.get('agents', {}).get('separator_hex', ''),
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
        registry_bytes = (json.dumps(result, indent=2, sort_keys=True) + '\n').encode()
        if I.read_regular_bytes(registry, I.TEXT_LIMIT) != old_registry:
            raise SyncError('registry changed concurrently before update publication')
        published_metadata[str(registry)] = I.sha_bytes(registry_bytes)
        I.write_atomic(registry, registry_bytes, 0o600)
        # The new managed trees and metadata are now one published installation. From this
        # point on, a rollback would be unsafe because some old backups may already be gone.
        published = True

        cleanup_errors = []
        for _, backup, expected_old in backups:
            try:
                if expected_old is None:
                    cleanup_errors.append(f'{backup}: unmanaged backup is not deletable')
                    continue
                if expected_old is not None:
                    problems=I.check_existing_managed(backup,expected_old)
                    if problems:
                        raise SyncError(f'managed backup changed before deletion: {backup}: {problems[0]}')
                I.remove_created(backup)
            except Exception as e:
                cleanup_errors.append(f'{backup}: {type(e).__name__}')
        if cleanup_errors:
            raise SyncCleanupIncomplete('update applied; rollback-backup cleanup incomplete: ' + ', '.join(cleanup_errors))
        print(json.dumps({'ok': True, 'updated_to': I.VERSION, 'mode': pre['mode'], 'preflight_id': pre['preflight_id']}, indent=2))
        return 0
    except Exception as original:
        if published:
            raise
        for path, data, restore_mode in ((agents, old_agents, agents_mode), (marker, old_marker, 0o600), (registry, old_registry, 0o600)):
            try:
                current = I.read_regular_bytes(path, I.TEXT_LIMIT) if I.lexists(path) else None
                if current == data:
                    continue
                published_sha = published_metadata.get(str(path))
                if current is not None and published_sha and I.sha_bytes(current) == published_sha:
                    I.write_atomic(path, data, restore_mode)
                else:
                    rollback_errors.append(f'{path.name}: changed concurrently; preserved')
            except Exception as e:
                rollback_errors.append(f'{path.name}:{type(e).__name__}')
        for target, backup, _expected_old in reversed(backups):
            try:
                # If backup is absent, the move never published; the original target
                # remains in place and must not be compared with incoming bytes.
                if not I.lexists(backup):
                    continue
                if I.lexists(target):
                    expected = incoming_expected.get(str(target))
                    if expected is None:
                        rollback_errors.append(f'{target}: path appeared concurrently; preserved')
                        continue
                    problems = I.check_existing_managed(target, expected)
                    if problems:
                        rollback_errors.append(f'{target}: changed after update publication; preserved')
                        continue
                    I.remove_created(target)
                I._replace_path(backup, target)
            except Exception as e:
                rollback_errors.append(f'{target}:{type(e).__name__}')
        for target in reversed(published_new_targets):
            try:
                if not I.lexists(target):
                    continue
                expected = incoming_expected.get(str(target))
                if expected is None:
                    rollback_errors.append(f'{target}: new target ownership is unknown; preserved')
                    continue
                problems = I.check_existing_managed(target, expected)
                if problems:
                    rollback_errors.append(f'{target}: changed after update publication; preserved')
                    continue
                I.remove_created(target)
            except Exception as e:
                rollback_errors.append(f'{target}:{type(e).__name__}')
        if rollback_errors:
            raise SyncRollbackIncomplete('update failed and safe rollback was incomplete: ' + ', '.join(rollback_errors)) from original
        raise
    finally:
        # Prepared incoming trees are library-created random paths, but even these are
        # deleted only while they still match the bytes we staged. If anything external
        # appeared inside, preserve the path for manual inspection rather than risking
        # destruction. Backups are never blindly deleted here: success deletes them only
        # after revalidation, and complete rollback moves them back to their public paths.
        for target, local in prepared:
            try:
                if not I.lexists(local):
                    continue
                expected=incoming_expected.get(str(target))
                if expected is not None and not I.check_existing_managed(local,expected):
                    I.remove_created(local)
            except Exception:
                pass
        shutil.rmtree(txn, ignore_errors=True)


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except SyncCleanupIncomplete as e:
        print(json.dumps({'ok': False, 'error': str(e), 'mutation_state': 'applied_new_version_cleanup_incomplete', 'recovery': 'inspect listed backup paths and retry sync'}, indent=2))
        raise SystemExit(5)
    except SyncRollbackIncomplete as e:
        print(json.dumps({'ok': False, 'error': str(e), 'mutation_state': 'rollback_incomplete_user_data_preserved_where_detected'}, indent=2))
        raise SystemExit(4)
    except (SyncError, I.InstallError, OSError) as e:
        print(json.dumps({'ok': False, 'error': str(e), 'mutation_state': 'none_or_rolled_back'}, indent=2))
        raise SystemExit(3)
