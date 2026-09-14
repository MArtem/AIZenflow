#!/usr/bin/env python3
"""Read-only safety gate for connecting an unpacked release to a CODEX_HOME.

This helper never creates directories, writes a descriptor, edits AGENTS, copies skills, or
removes anything. A non-zero result means the operator must not execute the displayed plan.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import stat
import sys

MAX_DESCRIPTOR_BYTES = 64 * 1024
MAX_TEXT_BYTES = 2 * 1024 * 1024
BEGIN = '<!-- IOS_ENGINEERING_GLOBAL:BEGIN -->'
END = '<!-- IOS_ENGINEERING_GLOBAL:END -->'


class PreflightError(RuntimeError):
    pass


def absolute(value):
    path = Path(value).expanduser()
    if not path.is_absolute():
        raise PreflightError(f'path must be absolute: {path}')
    return Path(os.path.abspath(os.path.normpath(str(path))))


def lexists(path):
    return os.path.lexists(str(path))


def reject_symlink_components(path):
    path = absolute(path)
    current = Path(path.anchor)
    for part in path.parts[1:]:
        current /= part
        if lexists(current) and stat.S_ISLNK(os.lstat(current).st_mode):
            raise PreflightError(f'symlink path component: {current}')


def read_regular(path, max_bytes):
    path = absolute(path)
    reject_symlink_components(path.parent)
    st = os.lstat(path)
    if stat.S_ISLNK(st.st_mode) or not stat.S_ISREG(st.st_mode):
        raise PreflightError(f'not a regular file: {path}')
    if st.st_size > max_bytes:
        raise PreflightError(f'file exceeds read budget: {path}')
    flags = os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0)
    fd = os.open(str(path), flags)
    try:
        opened = os.fstat(fd)
        if (opened.st_dev, opened.st_ino, opened.st_size) != (st.st_dev, st.st_ino, st.st_size):
            raise PreflightError(f'file changed during read: {path}')
        data = os.read(fd, max_bytes + 1)
        if len(data) > max_bytes:
            raise PreflightError(f'file exceeds read budget: {path}')
        return data
    finally:
        os.close(fd)


def sha_bytes(data):
    return hashlib.sha256(data).hexdigest()


def sha_file(path):
    return sha_bytes(read_regular(path, 512 * 1024 * 1024))


def package_identity(release):
    """Recompute the release identity from the shipped file manifest, without trust by path."""
    manifest_path = release / 'PACKAGE_FILE_MANIFEST.json'
    data = safe_json(manifest_path, MAX_TEXT_BYTES)
    entries = data.get('files')
    if not isinstance(entries, list):
        raise PreflightError('PACKAGE_FILE_MANIFEST.files is not a list')
    rows = []
    seen = set()
    for item in entries:
        if not isinstance(item, dict) or not isinstance(item.get('path'), str):
            raise PreflightError('PACKAGE_FILE_MANIFEST contains an invalid entry')
        rel = item['path']
        if rel in seen or rel == 'PACKAGE_FILE_MANIFEST.json' or rel.startswith('/') or '..' in Path(rel).parts:
            raise PreflightError(f'PACKAGE_FILE_MANIFEST contains an unsafe/duplicate path: {rel}')
        seen.add(rel)
        path = release / rel
        raw = read_regular(path, 512 * 1024 * 1024)
        if len(raw) != item.get('size') or sha_bytes(raw) != item.get('sha256'):
            raise PreflightError(f'package manifest hash mismatch: {rel}')
        if path.name == 'REVIEW_READY_VALIDATION_REPORT.md':
            continue
        rows.append([rel, item['sha256']])
    rows.append(['PACKAGE_FILE_MANIFEST.json', sha_file(manifest_path)])
    rows.sort(key=lambda row: row[0])
    return sha_bytes(json.dumps(rows, sort_keys=True, separators=(',', ':')).encode('utf-8'))


def active_agents(ch, explicit):
    override = ch / 'AGENTS.override.md'
    override_is_active = False
    if lexists(override):
        try:
            if read_regular(override, MAX_TEXT_BYTES).decode('utf-8').strip():
                override_is_active = True
        except Exception:
            override_is_active = True
    # Passing the conventional AGENTS.md path must not bypass an active override. A deliberately
    # different explicit path remains an intentional selection for custom host layouts.
    if explicit:
        selected = absolute(explicit)
        if selected != absolute(ch / 'AGENTS.md') or not override_is_active:
            return selected
    if override_is_active:
        return override
    return ch / 'AGENTS.md'


def path_contains(parent, child):
    try:
        absolute(child).relative_to(absolute(parent))
        return True
    except ValueError:
        return False


def existing_ancestor(path):
    current = absolute(path)
    while not lexists(current) and current != current.parent:
        current = current.parent
    return current


def git_root_for_destination(path):
    """Find a lexical Git root without invoking Git or following a destination symlink."""
    current = existing_ancestor(path)
    while True:
        marker = current / '.git'
        if lexists(marker):
            try:
                marker_stat = os.lstat(marker)
                if stat.S_ISLNK(marker_stat.st_mode):
                    return current, 'symlink .git marker'
                if stat.S_ISDIR(marker_stat.st_mode) or stat.S_ISREG(marker_stat.st_mode):
                    return current, None
            except OSError as error:
                return current, f'unreadable .git marker: {type(error).__name__}'
        if current == current.parent:
            return None, None
        current = current.parent


def destination_layout_collisions(targets, release):
    """Reject mutable destinations inside client repositories or overlapping each other."""
    rows = [(label, absolute(path)) for label, path in targets.items()]
    collisions = []
    release = absolute(release)
    for label, path in rows:
        git_root, issue = git_root_for_destination(path)
        if issue:
            collisions.append(f'{label}: {issue}: {git_root}')
        elif git_root is not None:
            collisions.append(f'{label}: installation destination is inside client Git repository: {git_root}')
        if label == 'codex_home' and path_contains(path, release):
            continue
        if path_contains(release, path) or path_contains(path, release):
            collisions.append(f'{label}: destination overlaps immutable release root: {path}')
    for index, (left_label, left) in enumerate(rows):
        for right_label, right in rows[index + 1:]:
            # The Codex home intentionally contains its managed children.
            if left_label == 'codex_home' or right_label == 'codex_home':
                continue
            if path_contains(left, right) or path_contains(right, left):
                collisions.append(f'destination overlap: {left_label}={left} and {right_label}={right}')
    return sorted(set(collisions))


def safe_json(path, max_bytes=MAX_DESCRIPTOR_BYTES):
    try:
        return json.loads(read_regular(path, max_bytes).decode('utf-8'))
    except Exception as error:
        raise PreflightError(f'invalid JSON at {path}: {type(error).__name__}') from error


def tree_entries(root):
    root = absolute(root)
    if not lexists(root):
        return []
    reject_symlink_components(root)
    if not root.is_dir():
        raise PreflightError(f'expected directory: {root}')
    result = []
    for base, dirs, files in os.walk(str(root), topdown=True, followlinks=False):
        bp = Path(base)
        for name in sorted(dirs):
            path = bp / name
            st = os.lstat(path)
            if stat.S_ISLNK(st.st_mode) or not stat.S_ISDIR(st.st_mode):
                raise PreflightError(f'unsafe directory entry: {path}')
        for name in sorted(files):
            path = bp / name
            st = os.lstat(path)
            if stat.S_ISLNK(st.st_mode) or not stat.S_ISREG(st.st_mode):
                raise PreflightError(f'unsafe file entry: {path}')
            result.append(path.relative_to(root).as_posix())
    return result


def build(args):
    release = absolute(args.release_root)
    ch = absolute(args.codex_home or os.environ.get('CODEX_HOME', str(Path.home() / '.codex')))
    state = absolute(args.state_root or ch / 'ios-engineering-state')
    shim = ch / 'ios-engineering-shim'
    skills = absolute(args.skills_root or Path.home() / '.agents' / 'skills')
    agents = active_agents(ch, args.agents_file)
    collisions = []
    operations = []

    for label, path in [('release_root', release), ('codex_home', ch), ('shim_root', shim),
                        ('state_root', state), ('skills_root', skills), ('agents_file', agents)]:
        try:
            reject_symlink_components(path)
        except Exception as error:
            collisions.append(f'{label}: {error}')
    collisions.extend(destination_layout_collisions({
        'codex_home': ch,
        'shim_root': shim,
        'state_root': state,
        'skills_root': skills,
        'agents_file': agents,
    }, release))

    if not release.is_dir():
        collisions.append(f'release_root is missing or not a directory: {release}')
    manifest = {}
    try:
        manifest = safe_json(release / 'GLOBAL_MANIFEST.json', MAX_TEXT_BYTES)
        if manifest.get('status') not in {'review_candidate_independent_review_required', 'accepted_internal_pilot'}:
            collisions.append('release manifest status is not an installable candidate')
        runtime = release / 'GLOBAL_CODEX' / 'runtime' / 'bin' / 'ios_ai.py'
        manual_shim = release / 'MANUAL_SHIM' / 'bin' / 'ios_ai.py'
        read_regular(runtime, MAX_TEXT_BYTES)
        read_regular(manual_shim, MAX_TEXT_BYTES)
    except Exception as error:
        collisions.append(f'release validation failed: {error}')

    try:
        release_identity = package_identity(release)
    except Exception as error:
        release_identity = None
        collisions.append(f'release package identity failed: {error}')

    version = manifest.get('version')
    # The descriptor's release_id is the runtime release identity shared with the installer;
    # the manifest's artifact name remains a separate packaging label.
    release_id = version
    protection_version = manifest.get('runtime', {}).get('protection_version')
    descriptor = {
        'schema_version': 1,
        'managed_by': 'ios-engineering-library',
        'release_id': release_id,
        'protection_version': protection_version,
        'mode': args.mode,
        'knowledge_root': str(release),
        'runtime_cli': str(release / 'GLOBAL_CODEX' / 'runtime' / 'bin' / 'ios_ai.py'),
        'state_root': str(state),
        'source_tree_sha256': release_identity,
        'generated_by': 'manual_preflight.py',
    }
    state_marker = {
        'managed_by': 'ios-engineering-library',
        'version': version,
        'protection_version': protection_version,
        'deployment': 'manual',
    }

    try:
        # Reuse the release's bounded, read-only admission check. Importing the package helper
        # does not mutate the target; all actual manual writes remain outside this process.
        if str(release) not in sys.path:
            sys.path.insert(0, str(release))
        import install_global as installer
        blockers = installer.incompatible_active_sessions(state, protection_version)
        collisions.extend(
            'incompatible active protection session: {session_id} ({protection_version}); '
            'close/recover it with the old runtime before manual activation'.format(**row)
            for row in blockers
        )
    except Exception as error:
        collisions.append(f'active-session admission check failed: {type(error).__name__}: {error}')

    if lexists(shim):
        try:
            entries = tree_entries(shim)
            expected = {'INSTALLATION.json', 'INSTALLATION.md', '.ioslib-managed.json', 'bin/ios_ai.py'}
            unknown = sorted(set(entries) - expected)
            if unknown:
                collisions.append('shim contains unknown files: ' + ', '.join(unknown))
            launcher_hash_matches = sha_file(shim / 'bin' / 'ios_ai.py') == sha_file(release / 'MANUAL_SHIM' / 'bin' / 'ios_ai.py')
            if set(entries) == {'bin/ios_ai.py'} and launcher_hash_matches:
                # This is the only safe transitional state after the operator has copied the
                # verified launcher and before INSTALLATION.json is published.
                operations.append({'op': 'complete_selector_for_verified_transitional_shim', 'target': str(shim)})
            else:
                old_descriptor = safe_json(shim / 'INSTALLATION.json')
                if old_descriptor.get('managed_by') != 'ios-engineering-library':
                    collisions.append('existing shim descriptor has a different owner')
                old_mode = old_descriptor.get('mode')
                if old_mode != args.mode and not (old_mode == 'reference' and args.mode == 'full'):
                    collisions.append('existing shim mode differs; only reference-to-full migration is supported')
                elif old_mode == 'reference' and args.mode == 'full':
                    operations.append({'op': 'migrate_verified_reference_shim_to_full_mode', 'target': str(shim)})
                if not launcher_hash_matches:
                    collisions.append('existing shim launcher is modified or from a pre-descriptor release')
                operations.append({'op': 'replace_only_verified_managed_shim_files', 'target': str(shim)})
        except Exception as error:
            collisions.append(f'existing shim is not safely updatable: {error}')
    else:
        operations.append({'op': 'create_managed_shim_after_all_checks', 'target': str(shim)})

    if lexists(agents):
        try:
            text = read_regular(agents, MAX_TEXT_BYTES).decode('utf-8')
            matches = text.count(BEGIN), text.count(END)
            if matches != (0, 0):
                if matches != (1, 1) or BEGIN not in text or END not in text:
                    collisions.append('AGENTS has an incomplete managed block')
                else:
                    expected_block = read_regular(release / 'GLOBAL_CODEX' / 'AGENTS.global.block.md', MAX_TEXT_BYTES).decode('utf-8').rstrip()
                    start = text.index(BEGIN); end = text.index(END, start) + len(END)
                    if text[start:end].rstrip() != expected_block:
                        collisions.append('AGENTS managed block is modified or from another release')
                    else:
                        operations.append({'op': 'replace_only_exact_managed_AGENTS_block', 'target': str(agents)})
        except Exception as error:
            collisions.append(f'AGENTS cannot be read safely: {error}')
    operations.append({'op': 'append_managed_block_after_exact_text_review', 'target': str(agents)})

    if args.mode == 'full':
        try:
            incoming = sorted(p.name for p in (release / 'GLOBAL_CODEX' / 'skills').iterdir() if p.is_dir())
            for name in incoming:
                target = skills / name
                if lexists(target):
                    collisions.append(f'full-mode skill target already exists: {target}')
                else:
                    operations.append({'op': 'copy_namespaced_skill_after_all_checks', 'target': str(target)})
        except Exception as error:
            collisions.append(f'full-mode skill preflight failed: {error}')

    marker = state / '.ioslib-state-owned.json'
    if lexists(state):
        try:
            if not state.is_dir() or stat.S_IMODE(os.lstat(state).st_mode) & 0o077:
                collisions.append('state root must be a private directory')
            elif lexists(marker):
                owned = safe_json(marker)
                if owned.get('managed_by') != 'ios-engineering-library':
                    collisions.append('existing state marker has a different owner')
            elif tree_entries(state):
                collisions.append('existing state root has no library ownership marker; explicit migration is required')
        except Exception as error:
            collisions.append(f'state root is not safely inspectable: {error}')
    operations.append({'op': 'create_private_state_root_and_marker_if_absent', 'target': str(state)})

    operations.append({'op': 'write_descriptor_last', 'target': str(shim / 'INSTALLATION.json')})
    operations.append({'op': 'activation_is_last_and_old_release_remains_untouched', 'target': str(shim / 'bin' / 'ios_ai.py')})
    return {
        'ok': not collisions,
        'release': {'release_id': release_id, 'version': version, 'protection_version': protection_version, 'root': str(release)},
        'paths': {'codex_home': str(ch), 'shim_root': str(shim), 'state_root': str(state), 'skills_root': str(skills), 'agents_file': str(agents)},
        'descriptor': descriptor,
        'state_marker': state_marker,
        'collisions': sorted(set(collisions)),
        'operations': operations,
        'read_only': True,
    }


def main():
    ap = argparse.ArgumentParser(description='Read-only manual deployment preflight')
    ap.add_argument('--release-root', required=True)
    ap.add_argument('--codex-home')
    ap.add_argument('--state-root')
    ap.add_argument('--skills-root')
    ap.add_argument('--agents-file')
    ap.add_argument('--mode', choices=['reference', 'full'], default='reference')
    ap.add_argument('--emit-descriptor', action='store_true', help='print only the descriptor JSON when preflight passes')
    ap.add_argument('--emit-state-marker', action='store_true', help='print only the state marker JSON when preflight passes')
    args = ap.parse_args()
    try:
        result = build(args)
    except Exception as error:
        result = {'ok': False, 'read_only': True, 'collisions': [f'preflight failed: {type(error).__name__}: {error}'], 'operations': []}
    if args.emit_descriptor and result.get('ok'):
        print(json.dumps(result['descriptor'], indent=2, sort_keys=True))
    elif args.emit_state_marker and result.get('ok'):
        print(json.dumps(result['state_marker'], indent=2, sort_keys=True))
    else:
        print(json.dumps(result, indent=2, sort_keys=True))
    return 0 if result.get('ok') else 2


if __name__ == '__main__':
    raise SystemExit(main())
