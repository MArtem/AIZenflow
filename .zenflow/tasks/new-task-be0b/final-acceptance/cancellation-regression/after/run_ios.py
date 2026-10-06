from pathlib import Path
import argparse
import hashlib
import json
import os
import plistlib
import subprocess
import time

base = Path(__file__).resolve().parent
original = base
developer = Path('/Applications/Xcode.app/Contents/Developer')
simctl = str(developer / 'usr/bin/simctl')
devices = [('18.2', 'BE43D4FD-1B71-4E6F-9EE7-DB32BD2D4D7C'),
           ('27.0', '2BED6C3B-5DA5-4F43-A44E-FB1CC9BB8F8D')]
env = os.environ.copy()
isolated = {}
for key, folder in [('TMPDIR', 'tmp'), ('CFFIXED_USER_HOME', 'cocoa-home'), ('XDG_CACHE_HOME', 'cache')]:
    path = base / folder
    path.mkdir(exist_ok=True)
    isolated[key] = str(path)
env.update(isolated)
sources = [original / name for name in ['AppDatabaseCore.swift', 'SwiftDataModelActorDatabaseManager.swift', 'AppSwiftDataDatabase.swift']]
sources.append(base / 'DatabaseProbe.swift')
hashes = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in sources}
parser = argparse.ArgumentParser()
parser.add_argument('mode', choices=['compile', 'runtime'])
mode = parser.parse_args().mode
receipt = {'mode': mode, 'authority': 'Direct human six-source cancellation patch and necessary QA approval',
           'source_sha256': hashes, 'environment': isolated, 'commands': [], 'devices': [],
           'limits': ['Disposable schema/component only, no app/user data', 'SDK27 compile, not SDK18.2',
                      'CancellationError preservation and rollback on corrected sources', 'No physical/iPad/VoiceOver checks']}
receipt_path = base / (mode + '-receipt.json')
if receipt_path.exists():
    raise SystemExit('Refuse overwriting prior execution receipt')

def save():
    receipt_path.write_text(json.dumps(receipt, ensure_ascii=False, indent=2) + '\n')

def run(args, relative_log, limit=90):
    log = base / relative_log
    log.parent.mkdir(parents=True, exist_ok=True)
    if log.exists():
        raise RuntimeError('Refuse overwriting execution log')
    start = time.monotonic()
    with log.open('w') as stream:
        try:
            process = subprocess.run(args, env=env, stdout=stream, stderr=subprocess.STDOUT, timeout=limit)
            code = process.returncode
        except subprocess.TimeoutExpired:
            code = 124
    receipt['commands'].append({'args': args, 'log': str(log), 'exit_code': code,
                                'elapsed_seconds': round(time.monotonic() - start, 3)})
    save()
    print('COMMAND', relative_log, 'exit', code, flush=True)
    if code:
        raise RuntimeError('Command failed; retained log ' + str(log))
    return log.read_text()

app = base / 'DatabaseProbe.app'
binary = app / 'DatabaseProbe'
if mode == 'compile':
    app.mkdir(exist_ok=False)
    (app / 'Info.plist').write_bytes(plistlib.dumps({'CFBundleExecutable': 'DatabaseProbe',
        'CFBundleIdentifier': 'com.zenflow.F02.DatabaseProbe', 'CFBundlePackageType': 'APPL'}))
    compiler = str(developer / 'Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc')
    run([compiler, '-disable-sandbox', '-parse-as-library', '-swift-version', '6',
         '-strict-concurrency=complete', '-warnings-as-errors', '-sdk',
         str(developer / 'Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator27.0.sdk'),
         '-target', 'arm64-apple-ios17.0-simulator', '-module-cache-path', str(base / 'cache/ios-modules'),
         '-o', str(binary), *map(str, sources)], 'compile.log', 120)
    receipt['binary_sha256'] = hashlib.sha256(binary.read_bytes()).hexdigest()
    receipt['status'] = 'COMPILE_PASS'
    save()
else:
    compiled = json.loads((base / 'compile-receipt.json').read_text())
    assert compiled['status'] == 'COMPILE_PASS' and compiled['source_sha256'] == hashes
    assert hashlib.sha256(binary.read_bytes()).hexdigest() == compiled['binary_sha256']
    receipt['binary_sha256'] = compiled['binary_sha256']
    for version, device in devices:
        item = {'version': version, 'udid': device, 'status': 'RUNNING', 'phases': []}
        receipt['devices'].append(item)
        boot_attempted = False
        try:
            inventory = json.loads(run([simctl, 'list', 'devices', device, '--json'], version + '/initial.json'))
            selected = [(runtime, d) for runtime, values in inventory['devices'].items() for d in values if d['udid'] == device]
            assert len(selected) == 1 and selected[0][1]['isAvailable']
            runtime, selected_device = selected[0]
            assert runtime.endswith('iOS-' + version.replace('.', '-'))
            assert selected_device['state'] == 'Shutdown', 'Do not interrupt an already-booted device'
            item['runtime_identifier'] = runtime
            item['name'] = selected_device['name']
            boot_attempted = True
            run([simctl, 'boot', device], version + '/boot.log')
            run([simctl, 'bootstatus', device, '-b'], version + '/bootstatus.log')
            for group, phases in [('cancellation', ['cancellation']), ('success', ['old', 'new', 'reopen']), ('failure', ['old', 'migrate-failure', 'old-reopen'])]:
                store = base / version / group / 'fixture.store'
                store.parent.mkdir(parents=True, exist_ok=True)
                for phase in phases:
                    text = run([simctl, 'spawn', device, str(binary), phase, str(store)],
                               version + '/' + group + '/' + phase + '.log')
                    lines = text.splitlines()
                    assert 'RESULT phase=' + phase + ' PASS' in lines
                    if phase == 'migrate-failure':
                        assert 'INJECTED fixture migration callback failure' in lines
                    if phase == 'cancellation':
                        assert sum(line.startswith('MISMATCH ') for line in lines) == 0
                    labels = [line[5:] for line in lines if line.startswith('PASS ')]
                    item['phases'].append({'group': group, 'phase': phase, 'pass_labels': labels})
                    print('PHASE', version, group, phase, 'PASS', len(labels), flush=True)
            item['assertions'] = sum(len(p['pass_labels']) for p in item['phases'])
            assert item['assertions'] == 33
            item['status'] = 'PASS'
        except Exception as error:
            item['status'] = 'FAIL'
            item['error'] = str(error)
            print('DEVICE', version, 'FAIL', str(error), flush=True)
        finally:
            if boot_attempted:
                try:
                    run([simctl, 'shutdown', device], version + '/shutdown.log')
                    after = json.loads(run([simctl, 'list', 'devices', device, '--json'], version + '/final.json'))
                    final_devices = [d for values in after['devices'].values() for d in values if d['udid'] == device]
                    assert len(final_devices) == 1 and final_devices[0]['state'] == 'Shutdown'
                    item['shutdown_verified'] = True
                except Exception as error:
                    item['status'] = 'FAIL'
                    item['cleanup_error'] = str(error)
            save()
    receipt['status'] = 'PASS' if all(d['status'] == 'PASS' and d.get('shutdown_verified') for d in receipt['devices']) else 'FAIL'
    save()
    raise SystemExit(0 if receipt['status'] == 'PASS' else 1)
