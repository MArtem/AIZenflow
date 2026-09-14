#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import argparse, json, re, secrets
import install_global as I

class UninstallError(RuntimeError):
    pass

class UninstallRollbackIncomplete(UninstallError):
    pass

class UninstallCleanupIncomplete(UninstallError):
    pass


def extract_block(text):
    m = re.search(re.escape(I.BEGIN) + r'.*?' + re.escape(I.END), text, re.S)
    return m.group(0) if m else None


def _agents_without_managed_block(raw: bytes, reg: dict) -> bytes:
    try:
        text = raw.decode('utf-8')
    except UnicodeDecodeError as e:
        raise UninstallError('AGENTS file is not UTF-8') from e
    block = extract_block(text)
    if not block or I.sha_bytes(block.rstrip().encode()) != reg.get('agents', {}).get('managed_block_sha256'):
        raise UninstallError('managed AGENTS block missing or modified')
    block_core = block.encode('utf-8')
    idx = raw.find(block_core)
    if idx < 0:
        raise UninstallError('managed AGENTS block bytes not found')
    end = idx + len(block_core)
    if raw[end:end+1] == b'\n':
        end += 1
    sep = bytes.fromhex(reg.get('agents', {}).get('separator_hex', ''))
    start = idx
    if sep and idx >= len(sep) and raw[idx-len(sep):idx] == sep:
        # Remove the installer-added separator only when doing so exactly restores the
        # original pre-install bytes. If user-owned surrounding text changed, keep it.
        candidate = raw[:idx-len(sep)] + raw[end:]
        if I.sha_bytes(candidate) == reg.get('agents', {}).get('original_sha256'):
            return candidate
    return raw[:start] + raw[end:]


def preflight(ch: Path):
    ch = I.codex_home(ch)
    reg = I.read_registry(ch)
    if not reg:
        raise UninstallError('no managed installation registry')
    conflicts = []
    own = reg.get('ownership', {})
    targets = []
    if not reg.get('source_in_place'):
        targets.append(('content', Path(reg['content_root']), own.get('content', {})))
    targets.append(('shim', Path(reg['shim_root']), own.get('shim', {})))
    for n, expected in own.get('skills', {}).items():
        targets.append((f'skill {n}', Path(reg['skills_root']) / n, expected))
    for label, root, expected in targets:
        conflicts += [f'{label}: {x}' for x in I.check_existing_managed(root, expected)]

    agents = Path(reg['agents_file'])
    marker = Path(reg['state_root']) / '.ioslib-state-owned.json'
    registry = ch / I.REGISTRY_NAME
    for label, p in [('agents_file', agents), ('state_root', Path(reg['state_root'])), ('registry', registry)]:
        try:
            I.reject_symlink_path(p)
        except Exception as e:
            conflicts.append(f'{label}: {e}')
    try:
        raw_agents = I.read_regular_bytes(agents, I.TEXT_LIMIT) if I.lexists(agents) else b''
        if len(raw_agents) > I.TEXT_LIMIT:
            conflicts.append('AGENTS file exceeds safe merge budget')
        else:
            _agents_without_managed_block(raw_agents, reg)
    except Exception as e:
        conflicts.append(f'AGENTS: {e}')

    expected_marker = own.get('state_files', {}).get('.ioslib-state-owned.json')
    try:
        if not expected_marker or not I.lexists(marker) or marker.is_symlink() or I.sha_file(marker) != expected_marker:
            conflicts.append('state ownership marker modified/missing')
    except Exception:
        conflicts.append('state ownership marker unreadable')

    return reg, sorted(set(conflicts)), targets


def main():
    ap = argparse.ArgumentParser(description='Transactional manifest-based uninstall; unknown/modified assets are preserved by refusing destructive removal.')
    ap.add_argument('--codex-home')
    ap.add_argument('--yes', action='store_true')
    ap.add_argument('--dry-run', action='store_true')
    a = ap.parse_args()
    ch = I.codex_home(a.codex_home)
    reg, conflicts, targets = preflight(ch)
    agents = Path(reg['agents_file'])
    marker = Path(reg['state_root']) / '.ioslib-state-owned.json'
    registry = ch / I.REGISTRY_NAME
    report = {
        'dry_run': bool(a.dry_run),
        'would_mutate': False,
        'conflicts': conflicts,
        'preservation': 'unknown or modified managed assets block uninstall; repository-derived external state other than the owned marker is always preserved',
        'targets': {
            'content': None if reg.get('source_in_place') else reg['content_root'],
            'shim': reg['shim_root'],
            'skills': list(reg.get('ownership', {}).get('skills', {})),
            'agents_file': reg['agents_file'],
            'state_marker': str(marker),
        },
    }
    if a.dry_run or conflicts or not a.yes:
        if not a.yes and not a.dry_run:
            report['error'] = '--yes required'
        print(json.dumps(report, indent=2))
        return 0 if a.dry_run and not conflicts else 2

    token = secrets.token_hex(8)
    backups = []
    old_agents, agents_mode = I.read_regular_snapshot(agents, I.TEXT_LIMIT)
    old_marker = I.read_regular_bytes(marker, I.TEXT_LIMIT)
    old_registry = I.read_regular_bytes(registry, I.TEXT_LIMIT)
    rollback_errors = []
    published_agents = None
    metadata_removed = {'marker': False, 'registry': False}
    committed = False
    try:
        # Move each complete managed tree out of its public path first, then verify the
        # moved tree against the ownership manifest. A raced-in unknown/modified file
        # causes immediate restoration rather than deletion.
        for label, root, expected in targets:
            backup = root.parent / f'.{root.name}.ioslib-uninstall.{token}'
            if I.lexists(backup):
                raise UninstallError(f'uninstall backup collision: {backup}')
            # Journal before rename: _replace_path can move the tree and then fail
            # while fsyncing its parent directory.
            backups.append((root, backup, expected))
            I._replace_path(root, backup)
            problems = I.check_existing_managed(backup, expected)
            if problems:
                raise UninstallError(f'{label} changed during uninstall transaction: {problems[0]}')

        # Refuse to overwrite concurrent user edits to AGENTS/marker/registry.
        if I.read_regular_bytes(agents, I.TEXT_LIMIT) != old_agents:
            raise UninstallError('AGENTS changed concurrently during uninstall')
        if I.read_regular_bytes(marker, I.TEXT_LIMIT) != old_marker:
            raise UninstallError('state marker changed concurrently during uninstall')
        if I.read_regular_bytes(registry, I.TEXT_LIMIT) != old_registry:
            raise UninstallError('registry changed concurrently during uninstall')

        new_agents = _agents_without_managed_block(old_agents, reg)
        if new_agents:
            # Journal the expected post-publication bytes before write_atomic. If the
            # final directory fsync raises after replacement, rollback can restore it.
            published_agents = I.sha_bytes(new_agents)
            I.write_atomic(agents, new_agents, agents_mode)
        elif I.lexists(agents):
            # Journal the intended absence before unlink_nofollow_file for the same
            # post-unlink fsync failure case.
            published_agents = 'ABSENT'
            I.unlink_nofollow_file(agents)
        metadata_removed['marker'] = True
        I.unlink_nofollow_file(marker)
        metadata_removed['registry'] = True
        I.unlink_nofollow_file(registry)

        # Re-verify hidden trees before final deletion. This is still userspace
        # best-effort protection, not a kernel sandbox; transient/racing writes cannot
        # be absolutely prevented outside the owned paths.
        for root, backup, expected in backups:
            problems = I.check_existing_managed(backup, expected)
            if problems:
                raise UninstallError(f'managed backup changed before deletion: {backup}: {problems[0]}')
        # Deleting a backup is the uninstall commit point. Once this starts, some
        # previous bytes may be unrecoverable; never claim rollback after a partial
        # cleanup and never use remaining backups to overwrite a concurrent path.
        committed = True
        cleanup_errors = []
        for _, backup, _ in backups:
            try:
                I.remove_created(backup)
            except Exception as e:
                cleanup_errors.append(f'{backup}: {type(e).__name__}')
        if cleanup_errors:
            raise UninstallCleanupIncomplete('uninstall applied; backup cleanup incomplete: ' + ', '.join(cleanup_errors))
        print(json.dumps({'ok': True, 'status': 'uninstalled', 'external_project_state_preserved': True}, indent=2))
        return 0
    except Exception as original:
        if committed:
            raise
        # Restore metadata only when the public path still contains exactly what this
        # transaction published (or is still absent after our unlink). Concurrent user
        # content is preserved even if that means rollback cannot be completed.
        try:
            cur = I.read_regular_bytes(agents, I.TEXT_LIMIT) if I.lexists(agents) else None
            if cur == old_agents:
                pass
            elif published_agents == 'ABSENT' and cur is None:
                I.write_new_atomic(agents, old_agents, agents_mode)
            elif published_agents and cur is not None and I.sha_bytes(cur) == published_agents:
                I.write_atomic(agents, old_agents, agents_mode)
            else:
                rollback_errors.append('AGENTS changed concurrently; preserved')
        except Exception as e:
            rollback_errors.append(f'{agents}:{type(e).__name__}')
        for label, p, data in (('marker', marker, old_marker), ('registry', registry, old_registry)):
            try:
                if I.lexists(p):
                    cur = I.read_regular_bytes(p, I.TEXT_LIMIT)
                    if cur != data:
                        rollback_errors.append(f'{p}: appeared/changed concurrently; preserved')
                elif metadata_removed[label]:
                    I.write_new_atomic(p, data, 0o600)
            except Exception as e:
                rollback_errors.append(f'{p}:{type(e).__name__}')
        for root, backup, _ in reversed(backups):
            try:
                # If backup is absent and the public target is still present, its move
                # never published. If both are absent, report a real loss instead of
                # claiming a complete rollback.
                if not I.lexists(backup):
                    if I.lexists(root):
                        continue
                    rollback_errors.append(f'{root}: target and rollback backup both missing')
                    continue
                if I.lexists(root):
                    rollback_errors.append(f'{root}: path appeared concurrently; preserved')
                    continue
                I._replace_path(backup, root)
            except Exception as e:
                rollback_errors.append(f'{root}:{type(e).__name__}')
        if rollback_errors:
            raise UninstallRollbackIncomplete('uninstall failed and safe rollback was incomplete: ' + ', '.join(rollback_errors)) from original
        raise


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except UninstallCleanupIncomplete as e:
        print(json.dumps({'ok': False, 'error': str(e), 'mutation_state': 'uninstall_applied_cleanup_incomplete', 'recovery': 'inspect listed backup paths and retry manually'}, indent=2))
        raise SystemExit(5)
    except UninstallRollbackIncomplete as e:
        print(json.dumps({'ok': False, 'error': str(e), 'mutation_state': 'rollback_incomplete_user_data_preserved_where_detected'}, indent=2))
        raise SystemExit(4)
    except (UninstallError, I.InstallError, OSError) as e:
        print(json.dumps({'ok': False, 'error': str(e), 'mutation_state': 'none_or_rolled_back'}, indent=2))
        raise SystemExit(3)
