#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import argparse
import ctypes
import json
import os
import re
import secrets
import shlex
import stat

import install_global as I


RECEIPT_NAME = I.HOST_ENTRY_RECEIPT_NAME
MANAGED_BY = 'ios-engineering-host-entry'


class HostEntryError(RuntimeError):
    pass


class HostEntryRollbackIncomplete(HostEntryError):
    pass


_RENAME_SWAP = 0x00000002
_RENAME_EXCL = 0x00000004


def _rename_sibling(src: Path, dst: Path, flags: int):
    """Darwin atomic rename inside one stable directory; durability is acknowledged separately."""
    src = I.abs_lex(src)
    dst = I.abs_lex(dst)
    if src.parent != dst.parent:
        raise HostEntryError('host-entry transaction paths must be siblings')
    pfd = I._open_dir_chain(src.parent, create=False)
    try:
        libc = ctypes.CDLL(None, use_errno=True)
        renameatx = getattr(libc, 'renameatx_np', None)
        if renameatx is None:
            raise HostEntryError('safe host-entry publication requires Darwin renameatx_np')
        renameatx.argtypes = [ctypes.c_int, ctypes.c_char_p, ctypes.c_int, ctypes.c_char_p, ctypes.c_uint]
        renameatx.restype = ctypes.c_int
        if renameatx(pfd, os.fsencode(src.name), pfd, os.fsencode(dst.name), flags) != 0:
            error = ctypes.get_errno()
            raise OSError(error, os.strerror(error), str(src))
    finally:
        os.close(pfd)


def _fsync_parent(path: Path):
    pfd = I._open_dir_chain(I.abs_lex(path).parent, create=False)
    try:
        os.fsync(pfd)
    finally:
        os.close(pfd)


def _transaction_path(path: Path, purpose: str):
    return path.parent / f'.{path.name}.ioslib-host-entry-{purpose}.{secrets.token_hex(8)}'


def _reverse_exchange(path: Path, staged: Path, replacement: bytes, replacement_mode: int):
    """Reverse one completed swap and delete only the verified bytes produced by this operation."""
    try:
        _rename_sibling(staged, path, _RENAME_SWAP)
        _fsync_parent(path)
        displaced, displaced_mode = I.read_regular_snapshot(staged, I.TEXT_LIMIT)
        if displaced != replacement or displaced_mode != replacement_mode:
            raise HostEntryRollbackIncomplete(
                f'host AGENTS changed during exchange rollback; concurrent bytes preserved at '
                f'{path} and {staged}'
            )
        I.unlink_nofollow_file(staged)
    except HostEntryRollbackIncomplete:
        raise
    except Exception as error:
        raise HostEntryRollbackIncomplete(
            f'host AGENTS exchange rollback incomplete; public path: {path}; recovery file: {staged}'
        ) from error


def _restore_recreated_snapshot(path: Path, current: bytes, current_mode: int,
                                original: bytes, original_mode: int):
    """Restore a verified snapshot after its displaced inode was already unlinked."""
    staged = _transaction_path(path, 'restore')
    staged_published = False
    def observe_staged_publication():
        nonlocal staged_published
        staged_published = True
    try:
        I.write_new_atomic(
            staged, original, original_mode,
            publication_observer=observe_staged_publication,
        )
    except Exception as error:
        recovery = f'; recovery file: {staged}' if staged_published or I.lexists(staged) else ''
        raise HostEntryRollbackIncomplete(
            f'host AGENTS snapshot recreation could not start; public path: {path}{recovery}'
        ) from error
    exchanged = False
    try:
        _rename_sibling(staged, path, _RENAME_SWAP)
        exchanged = True
        _fsync_parent(path)
        displaced, displaced_mode = I.read_regular_snapshot(staged, I.TEXT_LIMIT)
        if displaced != current or displaced_mode != current_mode:
            exchanged = False
            _reverse_exchange(path, staged, original, original_mode)
            raise HostEntryRollbackIncomplete(
                f'host AGENTS changed during snapshot recreation; concurrent bytes preserved: {path}'
            )
        try:
            I.unlink_nofollow_file(staged)
        except Exception as cleanup_error:
            if I.lexists(staged):
                raise HostEntryRollbackIncomplete(
                    f'host AGENTS snapshot restored but displaced recovery file remains: {staged}'
                ) from cleanup_error
        exchanged = False
    except HostEntryRollbackIncomplete:
        raise
    except Exception as error:
        if exchanged:
            try:
                _reverse_exchange(path, staged, original, original_mode)
            except HostEntryRollbackIncomplete:
                raise
        elif I.lexists(staged):
            try:
                I.unlink_nofollow_file(staged)
            except Exception:
                pass
        raise HostEntryRollbackIncomplete(
            f'host AGENTS snapshot recreation incomplete; public path: {path}'
        ) from error


def _exchange_if_unchanged(path: Path, expected: bytes, expected_mode: int,
                           replacement: bytes, replacement_mode: int):
    """Replace an existing file only when the atomically displaced entry is the expected one."""
    staged = _transaction_path(path, 'exchange')
    I.write_new_atomic(staged, replacement, replacement_mode)
    exchanged = False
    swapped_once = False
    displaced_removed = False
    def observe_displaced_removal():
        nonlocal displaced_removed
        displaced_removed = True
    try:
        _rename_sibling(staged, path, _RENAME_SWAP)
        exchanged = True
        swapped_once = True
        _fsync_parent(path)
        displaced, displaced_mode = I.read_regular_snapshot(staged, I.TEXT_LIMIT)
        if displaced != expected or displaced_mode != expected_mode:
            exchanged = False
            _reverse_exchange(path, staged, replacement, replacement_mode)
            raise HostEntryError('host AGENTS changed concurrently; publication refused')
        I.unlink_nofollow_file(staged, removal_observer=observe_displaced_removal)
        exchanged = False
    except Exception as error:
        if exchanged:
            exchanged = False
            if displaced_removed:
                _restore_recreated_snapshot(
                    path, replacement, replacement_mode, expected, expected_mode,
                )
            else:
                try:
                    _reverse_exchange(path, staged, replacement, replacement_mode)
                except HostEntryRollbackIncomplete:
                    raise
        if not swapped_once and I.lexists(staged):
            try:
                I.unlink_nofollow_file(staged)
            except Exception:
                pass
        raise


def _remove_if_unchanged(path: Path, expected: bytes, expected_mode: int):
    """Remove an existing file without ever unlinking a concurrently replaced path."""
    staged = _transaction_path(path, 'remove')
    _rename_sibling(path, staged, _RENAME_EXCL)
    staged_removed = False
    def observe_staged_removal():
        nonlocal staged_removed
        staged_removed = True
    try:
        _fsync_parent(path)
        displaced, displaced_mode = I.read_regular_snapshot(staged, I.TEXT_LIMIT)
        if displaced != expected or displaced_mode != expected_mode:
            if I.lexists(path):
                raise HostEntryRollbackIncomplete(
                    f'host AGENTS changed during atomic removal; concurrent path preserved at {path} '
                    f'and displaced bytes preserved at {staged}'
                )
            _rename_sibling(staged, path, _RENAME_EXCL)
            _fsync_parent(path)
            raise HostEntryError('host AGENTS changed concurrently; removal refused')
        I.unlink_nofollow_file(staged, removal_observer=observe_staged_removal)
    except Exception as error:
        if staged_removed:
            try:
                I.write_new_atomic(path, expected, expected_mode)
            except Exception as rollback_error:
                raise HostEntryRollbackIncomplete(
                    f'host AGENTS removal rollback incomplete; public path: {path}'
                ) from rollback_error
            raise
        if I.lexists(staged) and not I.lexists(path):
            try:
                _rename_sibling(staged, path, _RENAME_EXCL)
                _fsync_parent(path)
            except Exception as rollback_error:
                raise HostEntryRollbackIncomplete(
                    f'host AGENTS removal rollback incomplete; recovery file: {staged}'
                ) from rollback_error
        elif I.lexists(staged):
            raise HostEntryRollbackIncomplete(
                f'host AGENTS removal cleanup/rollback incomplete; '
                f'public path: {path}; recovery file: {staged}'
            ) from error
        raise


def _extract_block(text: str):
    match = re.search(re.escape(I.BEGIN) + r'.*?' + re.escape(I.END), text, re.S)
    return match.group(0) if match else None


def _read_json(path: Path):
    try:
        value = json.loads(I.read_regular_bytes(path, I.TEXT_LIMIT).decode('utf-8'))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError, I.InstallError) as error:
        raise HostEntryError(f'unsafe or malformed JSON: {path}') from error
    if not isinstance(value, dict):
        raise HostEntryError(f'JSON object required: {path}')
    return value


def _runtime_contract(runtime_home: Path):
    runtime_home = I.abs_lex(runtime_home)
    I.reject_symlink_path(runtime_home)
    if not runtime_home.is_dir():
        raise HostEntryError(f'runtime home is not a directory: {runtime_home}')
    registry = I.read_registry(runtime_home)
    if not registry or not registry.get('installed'):
        raise HostEntryError('runtime home has no managed installation registry')
    if I.abs_lex(registry.get('codex_home', '')) != runtime_home:
        raise HostEntryError('runtime registry belongs to a different home')

    shim_root = I.abs_lex(registry.get('shim_root', ''))
    state_root = I.abs_lex(registry.get('state_root', ''))
    content_root = I.abs_lex(registry.get('content_root', ''))
    for label, path in (
        ('shim_root', shim_root), ('state_root', state_root), ('content_root', content_root),
    ):
        I.reject_symlink_path(path)
        if not path.is_dir():
            raise HostEntryError(f'{label} is not a directory: {path}')

    shim_problems = I.check_existing_managed(
        shim_root, registry.get('ownership', {}).get('shim', {}),
    )
    if shim_problems:
        raise HostEntryError(f'managed runtime shim mismatch: {shim_problems[0]}')
    if I.package_tree_identity(content_root) != registry.get('source_tree_sha256'):
        raise HostEntryError('installed package identity mismatch')

    descriptor_path = shim_root / 'INSTALLATION.json'
    descriptor = _read_json(descriptor_path)
    runtime_cli = I.abs_lex(descriptor.get('runtime_cli', ''))
    shim_cli = shim_root / 'bin' / 'ios_ai.py'
    expected_runtime_cli = content_root / 'GLOBAL_CODEX' / 'runtime' / 'bin' / 'ios_ai.py'
    checks = {
        'managed_by': 'ios-engineering-library',
        'release_id': registry.get('version'),
        'protection_version': registry.get('protection_version'),
        'mode': registry.get('mode'),
        'knowledge_root': str(content_root),
        'runtime_cli': str(expected_runtime_cli),
        'state_root': str(state_root),
        'source_tree_sha256': registry.get('source_tree_sha256'),
    }
    for key, expected in checks.items():
        if descriptor.get(key) != expected:
            raise HostEntryError(f'installation descriptor mismatch: {key}')
    I.reject_symlink_path(runtime_cli)
    if not runtime_cli.is_file():
        raise HostEntryError(f'runtime CLI missing: {runtime_cli}')
    I.reject_symlink_path(shim_cli)
    if not shim_cli.is_file():
        raise HostEntryError(f'runtime shim CLI missing: {shim_cli}')

    marker = state_root / '.ioslib-state-owned.json'
    expected_marker = registry.get('ownership', {}).get('state_files', {}).get(marker.name)
    if not expected_marker or not I.lexists(marker) or I.sha_file(marker) != expected_marker:
        raise HostEntryError('state ownership marker missing or modified')

    return {
        'runtime_home': runtime_home,
        'registry': registry,
        'descriptor': descriptor,
        'descriptor_path': descriptor_path,
        'descriptor_sha256': I.sha_file(descriptor_path),
        'runtime_cli': runtime_cli,
        'shim_cli': shim_cli,
        'state_root': state_root,
    }


def _render_block(contract):
    template = I.read_regular_bytes(I.G / 'AGENTS.global.block.md', I.TEXT_LIMIT).decode('utf-8')
    runtime_command = 'python3 "${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/bin/ios_ai.py"'
    rendered_command = 'python3 ' + shlex.quote(str(contract['shim_cli']))
    rendered = template.replace(runtime_command, rendered_command)
    rendered = rendered.replace(
        '${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/INSTALLATION.json',
        str(contract['descriptor_path']),
    )
    rendered = rendered.replace(
        '${CODEX_HOME:-$HOME/.codex}/ios-engineering-state',
        str(contract['state_root']),
    )
    if '${CODEX_HOME' in rendered:
        raise HostEntryError('unresolved CODEX_HOME placeholder in rendered host entry')
    if any(c in str(path) for path in (contract['descriptor_path'], contract['state_root']) for c in ('\n', '\r', '`')):
        raise HostEntryError('host-entry path cannot be represented safely in Markdown')
    return rendered.rstrip()


def _agents_without_block(raw: bytes, receipt: dict):
    try:
        text = raw.decode('utf-8')
    except UnicodeDecodeError as error:
        raise HostEntryError('host AGENTS is not UTF-8') from error
    matches = list(re.finditer(re.escape(I.BEGIN) + r'.*?' + re.escape(I.END), text, re.S))
    if len(matches) != 1:
        raise HostEntryError(f'managed host-entry block count {len(matches)} != 1')
    block = matches[0].group(0)
    if I.sha_bytes(block.rstrip().encode()) != receipt.get('managed_block_sha256'):
        raise HostEntryError('managed host-entry block modified')
    block_bytes = block.encode('utf-8')
    start = raw.find(block_bytes)
    end = start + len(block_bytes)
    if raw[end:end + 1] == b'\n':
        end += 1
    try:
        separator = bytes.fromhex(receipt.get('separator_hex', ''))
    except (TypeError, ValueError) as error:
        raise HostEntryError('host-entry receipt has an invalid separator') from error
    if separator and start >= len(separator) and raw[start - len(separator):start] == separator:
        candidate = raw[:start - len(separator)] + raw[end:]
        if I.sha_bytes(candidate) == receipt.get('original_sha256'):
            return candidate
    return raw[:start] + raw[end:]


def _connect_preflight(runtime_home: Path, host_home: Path):
    contract = _runtime_contract(runtime_home)
    host_home = I.abs_lex(host_home)
    I.reject_symlink_path(host_home)
    if not host_home.is_dir():
        raise HostEntryError(f'host Codex home is not a directory: {host_home}')
    if host_home == contract['runtime_home']:
        raise HostEntryError('host bridge is unnecessary when host and runtime homes are identical')
    agents = I.active_agents_file(host_home)
    I.reject_symlink_path(agents)
    receipt_path = contract['runtime_home'] / RECEIPT_NAME
    I.reject_symlink_path(receipt_path)
    collisions = []
    if I.lexists(receipt_path):
        collisions.append(f'existing host-entry receipt: {receipt_path}')
    existed = I.lexists(agents)
    try:
        raw, mode = I.read_regular_snapshot(agents, I.TEXT_LIMIT) if existed else (b'', 0o600)
        text = raw.decode('utf-8')
        if I.BEGIN in text or I.END in text:
            collisions.append(f'orphan managed marker in host AGENTS: {agents}')
    except (OSError, UnicodeDecodeError, I.InstallError) as error:
        raw, mode = b'', 0o600
        collisions.append(f'host AGENTS unreadable: {agents}: {type(error).__name__}')
    block = _render_block(contract)
    base = {
        'schema_version': 1,
        'managed_by': MANAGED_BY,
        'runtime_home': str(contract['runtime_home']),
        'host_codex_home': str(host_home),
        'agents_file': str(agents),
        'receipt': str(receipt_path),
        'runtime_release_id': contract['descriptor'].get('release_id'),
        'descriptor_sha256': contract['descriptor_sha256'],
        'managed_block_sha256': I.sha_bytes(block.encode()),
        'agents_existed_before': existed,
        'agents_original_sha256': I.sha_bytes(raw),
        'agents_original_mode': mode if existed else None,
        'separator_hex': I.agents_separator(raw).hex(),
        'collisions': collisions,
        'operations': [
            {'op': 'merge_host_entry_preserving_existing_text', 'target': str(agents)},
            {'op': 'write_host_entry_receipt', 'target': str(receipt_path)},
        ],
    }
    base['preflight_id'] = I.canonical_hash(base)
    return base, raw, mode, block


def connect(args):
    pre, old_agents, agents_mode, block = _connect_preflight(args.runtime_home, args.host_codex_home)
    if args.dry_run:
        print(json.dumps({'dry_run': True, 'would_mutate': False, **pre}, indent=2))
        return 0 if not pre['collisions'] else 2
    if pre['collisions']:
        raise HostEntryError('connect preflight has collisions; no mutation performed')
    if args.preflight_id != pre['preflight_id']:
        raise HostEntryError('connect requires --preflight-id from a matching current --dry-run')

    agents = Path(pre['agents_file'])
    receipt_path = Path(pre['receipt'])
    existed = pre['agents_existed_before']
    if existed:
        current, current_mode = I.read_regular_snapshot(agents, I.TEXT_LIMIT)
        if current != old_agents or current_mode != agents_mode:
            raise HostEntryError('host AGENTS changed after preflight')
    elif I.lexists(agents):
        raise HostEntryError('host AGENTS appeared after preflight')
    new_agents = I.merge_block_bytes(old_agents, block)
    receipt = {
        key: pre[key] for key in (
            'schema_version', 'managed_by', 'runtime_home', 'host_codex_home', 'agents_file',
            'runtime_release_id', 'descriptor_sha256', 'managed_block_sha256', 'preflight_id',
        )
    }
    receipt['agents'] = {
        'existed_before': existed,
        'original_sha256': pre['agents_original_sha256'],
        'original_mode': pre['agents_original_mode'],
        'managed_mode': agents_mode,
        'separator_hex': pre['separator_hex'],
    }
    receipt_bytes = (json.dumps(receipt, indent=2, sort_keys=True) + '\n').encode()
    published_agents_sha = I.sha_bytes(new_agents)
    published_receipt_sha = I.sha_bytes(receipt_bytes)
    agents_published = False
    def observe_agents_publication():
        nonlocal agents_published
        agents_published = True
    try:
        if existed:
            _exchange_if_unchanged(agents, old_agents, agents_mode, new_agents, agents_mode)
        else:
            I.write_new_atomic(
                agents, new_agents, 0o600, publication_observer=observe_agents_publication,
            )
        agents_published = True
        I.write_new_atomic(receipt_path, receipt_bytes, 0o600)
    except Exception as original:
        rollback_errors = []
        try:
            if I.lexists(receipt_path):
                current_receipt = I.read_regular_bytes(receipt_path, I.TEXT_LIMIT)
                if I.sha_bytes(current_receipt) == published_receipt_sha:
                    I.unlink_nofollow_file(receipt_path)
                else:
                    rollback_errors.append('host-entry receipt changed concurrently; preserved')
        except Exception as error:
            rollback_errors.append(f'host-entry receipt rollback failed: {type(error).__name__}')
        if agents_published:
            try:
                current = I.read_regular_bytes(agents, I.TEXT_LIMIT) if I.lexists(agents) else None
                if current is not None and I.sha_bytes(current) == published_agents_sha:
                    if existed:
                        _exchange_if_unchanged(
                            agents, new_agents, agents_mode, old_agents, agents_mode,
                        )
                    else:
                        _remove_if_unchanged(agents, new_agents, 0o600)
                elif current != old_agents:
                    rollback_errors.append('host AGENTS changed concurrently; preserved')
            except Exception as error:
                rollback_errors.append(f'host AGENTS rollback failed: {type(error).__name__}')
        if rollback_errors:
            raise HostEntryRollbackIncomplete('; '.join(rollback_errors)) from original
        raise
    print(json.dumps({'ok': True, 'status': 'connected', 'receipt': str(receipt_path)}, indent=2))
    return 0


def _load_receipt(runtime_home: Path):
    runtime_home = I.abs_lex(runtime_home)
    I.reject_symlink_path(runtime_home)
    receipt_path = runtime_home / RECEIPT_NAME
    receipt = _read_json(receipt_path)
    if receipt.get('managed_by') != MANAGED_BY or receipt.get('schema_version') != 1:
        raise HostEntryError('unsupported host-entry receipt')
    if I.abs_lex(receipt.get('runtime_home', '')) != runtime_home:
        raise HostEntryError('host-entry receipt belongs to a different runtime home')
    if not isinstance(receipt.get('agents_file'), str) or not receipt['agents_file']:
        raise HostEntryError('host-entry receipt has no AGENTS path')
    if not isinstance(receipt.get('host_codex_home'), str) or not receipt['host_codex_home']:
        raise HostEntryError('host-entry receipt has no host Codex home')
    host_home = I.abs_lex(receipt['host_codex_home'])
    agents_file = I.abs_lex(receipt['agents_file'])
    if agents_file.parent != host_home or agents_file.name not in {'AGENTS.md', 'AGENTS.override.md'}:
        raise HostEntryError('host-entry receipt AGENTS path is outside its host Codex home')
    if not isinstance(receipt.get('agents'), dict):
        raise HostEntryError('host-entry receipt has no AGENTS state')
    if not isinstance(receipt.get('managed_block_sha256'), str):
        raise HostEntryError('host-entry receipt has no managed block identity')
    agents_state = receipt['agents']
    if not isinstance(agents_state.get('original_sha256'), str):
        raise HostEntryError('host-entry receipt has no original AGENTS identity')
    if not isinstance(agents_state.get('managed_mode'), int):
        raise HostEntryError('host-entry receipt has no managed AGENTS mode')
    return receipt_path, receipt


def _inspect_host_entry(receipt: dict, *, require_active: bool):
    errors = []
    agents = I.abs_lex(receipt.get('agents_file', ''))
    raw = None
    mode = None
    try:
        I.reject_symlink_path(agents)
        host_home = I.abs_lex(receipt['host_codex_home'])
        I.reject_symlink_path(host_home)
        if require_active and I.active_agents_file(host_home) != agents:
            errors.append('recorded host AGENTS is no longer the active global instruction file')
        raw, mode = I.read_regular_snapshot(agents, I.TEXT_LIMIT)
        block = _extract_block(raw.decode('utf-8'))
        if not block or I.sha_bytes(block.rstrip().encode()) != receipt.get('managed_block_sha256'):
            errors.append('managed host-entry block missing or modified')
        if mode != receipt.get('agents', {}).get('managed_mode'):
            errors.append('host AGENTS mode changed')
    except Exception as error:
        errors.append(f'host AGENTS unreadable: {type(error).__name__}')
    return agents, raw, mode, sorted(set(errors))


def _status(runtime_home: Path):
    receipt_path, receipt = _load_receipt(runtime_home)
    _, _, _, errors = _inspect_host_entry(receipt, require_active=True)
    warnings = []
    try:
        contract = _runtime_contract(runtime_home)
        if I.sha_bytes(_render_block(contract).encode()) != receipt.get('managed_block_sha256'):
            warnings.append('installed global block changed; reconnect host entry after reviewing runtime update')
    except Exception as error:
        errors.append(f'runtime validation failed: {type(error).__name__}: {error}')
    return receipt_path, receipt, sorted(set(errors)), sorted(set(warnings))


def status(args):
    receipt_path, receipt, errors, warnings = _status(args.runtime_home)
    healthy = not errors and not warnings
    print(json.dumps({
        'ok': healthy,
        'status': 'connected' if healthy else ('refresh_required' if not errors else 'drifted'),
        'receipt': str(receipt_path),
        'agents_file': receipt.get('agents_file'),
        'errors': errors,
        'warnings': warnings,
    }, indent=2))
    return 0 if healthy else 1


def disconnect(args):
    receipt_path, receipt = _load_receipt(args.runtime_home)
    agents, raw, current_mode, errors = _inspect_host_entry(receipt, require_active=False)
    warnings = []
    try:
        _runtime_contract(args.runtime_home)
    except Exception as error:
        warnings.append(f'runtime validation failed; safe host-only disconnect remains available: {type(error).__name__}: {error}')
    new_agents = None
    if raw is not None:
        try:
            new_agents = _agents_without_block(raw, {
                'managed_block_sha256': receipt['managed_block_sha256'],
                'separator_hex': receipt.get('agents', {}).get('separator_hex', ''),
                'original_sha256': receipt.get('agents', {}).get('original_sha256'),
            })
        except HostEntryError as error:
            errors.append(str(error))
    report = {
        'dry_run': bool(args.dry_run),
        'would_mutate': False,
        'receipt': str(receipt_path),
        'agents_file': str(agents),
        'errors': sorted(set(errors)),
        'warnings': sorted(set(warnings)),
    }
    if args.dry_run or errors or not args.yes:
        if not args.yes and not args.dry_run:
            report['error'] = '--yes required'
        print(json.dumps(report, indent=2))
        return 0 if args.dry_run and not errors else 2

    old_receipt = I.read_regular_bytes(receipt_path, I.TEXT_LIMIT)
    existed_before = bool(receipt.get('agents', {}).get('existed_before'))
    original_mode = receipt.get('agents', {}).get('original_mode')
    exact_original = I.sha_bytes(new_agents) == receipt.get('agents', {}).get('original_sha256')
    restore_mode = original_mode if exact_original and original_mode is not None else current_mode
    published = 'ABSENT' if not existed_before and not new_agents else I.sha_bytes(new_agents)
    receipt_removed = False
    agents_published = False
    try:
        if not existed_before and not new_agents:
            _remove_if_unchanged(agents, raw, current_mode)
        else:
            _exchange_if_unchanged(agents, raw, current_mode, new_agents, restore_mode)
        agents_published = True
        receipt_removed = True
        I.unlink_nofollow_file(receipt_path)
    except Exception as original:
        rollback_errors = []
        if agents_published:
            try:
                current = I.read_regular_bytes(agents, I.TEXT_LIMIT) if I.lexists(agents) else None
                published_matches = (published == 'ABSENT' and current is None) or (
                    current is not None and published != 'ABSENT' and I.sha_bytes(current) == published
                )
                if published_matches:
                    if I.lexists(agents):
                        _exchange_if_unchanged(
                            agents, new_agents, restore_mode, raw, current_mode,
                        )
                    else:
                        I.write_new_atomic(agents, raw, current_mode)
                elif current != raw:
                    rollback_errors.append('host AGENTS changed concurrently; preserved')
            except Exception as error:
                rollback_errors.append(f'host AGENTS rollback failed: {type(error).__name__}')
        try:
            if receipt_removed and not I.lexists(receipt_path):
                I.write_new_atomic(receipt_path, old_receipt, 0o600)
        except Exception as error:
            rollback_errors.append(f'host-entry receipt rollback failed: {type(error).__name__}')
        if rollback_errors:
            raise HostEntryRollbackIncomplete('; '.join(rollback_errors)) from original
        raise
    print(json.dumps({
        'ok': True,
        'status': 'disconnected',
        'agents_file': str(agents),
        'warnings': sorted(set(warnings)),
    }, indent=2))
    return 0


def parser():
    ap = argparse.ArgumentParser(
        description='Connect one host Codex global instruction file to a separately installed managed runtime.',
    )
    sub = ap.add_subparsers(dest='command', required=True)
    connect_parser = sub.add_parser('connect')
    connect_parser.add_argument('--runtime-home', required=True)
    connect_parser.add_argument('--host-codex-home', required=True)
    connect_parser.add_argument('--dry-run', action='store_true')
    connect_parser.add_argument('--preflight-id')
    status_parser = sub.add_parser('status')
    status_parser.add_argument('--runtime-home', required=True)
    disconnect_parser = sub.add_parser('disconnect')
    disconnect_parser.add_argument('--runtime-home', required=True)
    disconnect_parser.add_argument('--dry-run', action='store_true')
    disconnect_parser.add_argument('--yes', action='store_true')
    return ap


def main():
    args = parser().parse_args()
    return {'connect': connect, 'status': status, 'disconnect': disconnect}[args.command](args)


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except HostEntryRollbackIncomplete as error:
        print(json.dumps({'ok': False, 'error': str(error), 'mutation_state': 'rollback_incomplete'}, indent=2))
        raise SystemExit(4)
    except (HostEntryError, I.InstallError, OSError) as error:
        print(json.dumps({'ok': False, 'error': str(error), 'mutation_state': 'none_or_rolled_back'}, indent=2))
        raise SystemExit(3)
