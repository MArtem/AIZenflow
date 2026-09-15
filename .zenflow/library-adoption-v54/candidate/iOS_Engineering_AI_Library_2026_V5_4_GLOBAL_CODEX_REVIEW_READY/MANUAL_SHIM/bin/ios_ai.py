#!/usr/bin/env python3
"""Relocatable manual-deployment shim driven by a validated descriptor."""
import json
import importlib.util
import os
from pathlib import Path
import runpy
import stat

MAX_DESCRIPTOR_BYTES = 64 * 1024
SHIM_ROOT = Path(__file__).resolve().parents[1]
DESCRIPTOR = SHIM_ROOT / 'INSTALLATION.json'


def fail(message):
    raise SystemExit('manual deployment refused: ' + message)


def safe_path(path, label):
    path = Path(path)
    if not path.is_absolute():
        fail(f'{label} must be absolute')
    current = Path(path.anchor)
    for part in path.parts[1:]:
        current /= part
        if not os.path.lexists(current):
            continue
        if stat.S_ISLNK(os.lstat(current).st_mode):
            fail(f'{label} contains a symlink component: {current}')
    return path


def read_regular(path, limit):
    path = safe_path(path, 'file')
    st = os.lstat(path)
    if stat.S_ISLNK(st.st_mode) or not stat.S_ISREG(st.st_mode):
        fail(f'file is not regular: {path}')
    if st.st_size > limit:
        fail(f'file exceeds read limit: {path}')
    fd = os.open(str(path), os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0))
    try:
        data = os.read(fd, limit + 1)
        if len(data) > limit:
            fail(f'file exceeds read limit: {path}')
        opened = os.fstat(fd)
        if (opened.st_dev, opened.st_ino, opened.st_size) != (st.st_dev, st.st_ino, st.st_size):
            fail(f'file changed during read: {path}')
        return data
    finally:
        os.close(fd)


def read_descriptor():
    try:
        raw = read_regular(DESCRIPTOR, MAX_DESCRIPTOR_BYTES)
        data = json.loads(raw.decode('utf-8'))
    except SystemExit:
        raise
    except Exception as error:
        fail(f'cannot read INSTALLATION.json ({type(error).__name__})')
    required = {'schema_version', 'managed_by', 'release_id', 'protection_version',
                'mode', 'knowledge_root', 'runtime_cli', 'state_root',
                'source_tree_sha256', 'generated_by'}
    if not isinstance(data, dict) or not required.issubset(data):
        fail('INSTALLATION.json is incomplete')
    if data['schema_version'] != 1 or data['managed_by'] != 'ios-engineering-library':
        fail('INSTALLATION.json schema/owner is unsupported')
    if data['mode'] not in {'reference', 'full'}:
        fail('INSTALLATION.json mode is unsupported')
    for field in ('release_id', 'protection_version', 'knowledge_root', 'runtime_cli',
                  'state_root', 'source_tree_sha256', 'generated_by'):
        if not isinstance(data.get(field), str) or not data[field]:
            fail(f'INSTALLATION.json field is not a non-empty string: {field}')
    if len(data['source_tree_sha256']) != 64 or any(c not in '0123456789abcdef' for c in data['source_tree_sha256']):
        fail('INSTALLATION.json source_tree_sha256 is malformed')
    try:
        library = safe_path(data['knowledge_root'], 'knowledge_root')
        runtime = safe_path(data['runtime_cli'], 'runtime_cli')
        state = safe_path(data['state_root'], 'state_root')
        expected = library / 'GLOBAL_CODEX' / 'runtime' / 'bin' / 'ios_ai.py'
        if runtime != expected:
            fail('runtime_cli is not the declared library runtime')
        runtime_stat = os.lstat(runtime)
        if stat.S_ISLNK(runtime_stat.st_mode) or not stat.S_ISREG(runtime_stat.st_mode):
            fail('runtime_cli is not a regular file')
    except SystemExit:
        raise
    except (TypeError, ValueError, OSError) as error:
        fail(f'INSTALLATION.json contains unsafe paths ({type(error).__name__})')
    if not library.is_dir():
        fail(f'knowledge root is missing: {library}')
    try:
        manifest = library / 'GLOBAL_MANIFEST.json'
        manifest_data = json.loads(read_regular(manifest, MAX_DESCRIPTOR_BYTES).decode('utf-8'))
        if manifest_data.get('version') != data['release_id']:
            fail('descriptor release_id does not match GLOBAL_MANIFEST.json')
        installer_path = library / 'install_global.py'
        safe_path(installer_path, 'install_global.py')
        installer_spec = importlib.util.spec_from_file_location('ioslib_identity_installer', installer_path)
        if installer_spec is None or installer_spec.loader is None:
            fail('package identity mechanism is unavailable')
        installer = importlib.util.module_from_spec(installer_spec)
        installer_spec.loader.exec_module(installer)
        actual_identity = installer.package_tree_identity(library)
        if actual_identity != data['source_tree_sha256']:
            fail('installed package identity does not match INSTALLATION.json')
    except SystemExit:
        raise
    except Exception as error:
        fail(f'knowledge manifest cannot be validated ({type(error).__name__})')
    if not runtime.is_file():
        fail(f'runtime is missing: {runtime}')
    return data, library, runtime, state


descriptor, library, runtime, state = read_descriptor()
os.environ['IOS_ENGINEERING_LIBRARY_ROOT'] = str(library)
os.environ['IOS_ENGINEERING_STATE_ROOT'] = str(state)
os.environ['IOS_ENGINEERING_RELEASE_ID'] = str(descriptor['release_id'])
os.environ['IOS_ENGINEERING_SOURCE_TREE_SHA256'] = str(descriptor['source_tree_sha256'])
runpy.run_path(str(runtime), run_name='__main__')
