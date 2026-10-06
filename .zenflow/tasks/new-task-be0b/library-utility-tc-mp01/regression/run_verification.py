from pathlib import Path
import argparse, hashlib, json, os, signal, subprocess, time

parser = argparse.ArgumentParser()
parser.add_argument('stage', choices=['baseline', 'after'])
parser.add_argument('runtime', choices=['18.2', '27.0'])
parser.add_argument('scheme', choices=['TchopApp', 'TchopAppOcean'])
parser.add_argument('action', choices=['test', 'build'])
a = parser.parse_args()
assert a.action != 'test' or a.scheme == 'TchopApp'
w = Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
r = w / '.zenflow/tasks/new-task-be0b/library-utility-tc-mp01/regression'
cache = r / 'build-cache'
out = r / (a.stage + '-' + a.runtime + '-' + a.scheme + '-' + a.action)
out.mkdir(exist_ok=False)
udid = {'18.2': 'BE43D4FD-1B71-4E6F-9EE7-DB32BD2D4D7C',
        '27.0': '2BED6C3B-5DA5-4F43-A44E-FB1CC9BB8F8D'}[a.runtime]
env = os.environ.copy()
isolation = {'TMPDIR': str(r / 'tmp'), 'CFFIXED_USER_HOME': str(r / 'cocoa-home'),
             'XDG_CACHE_HOME': str(r / 'cache')}
env.update(isolation)
for p in isolation.values():
    Path(p).mkdir(exist_ok=True)
owned = json.loads((r / 'contract.json').read_text())['owned_paths']
hashes = {p: hashlib.sha256((w / p).read_bytes()).hexdigest() for p in owned}
args = ['/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild',
        '-project', str(w / 'TchopApp.xcodeproj'), '-scheme', a.scheme,
        '-configuration', 'Debug', '-sdk', 'iphonesimulator',
        '-destination', 'platform=iOS Simulator,id=' + udid,
        '-destination-timeout', '30', '-derivedDataPath', str(cache / 'derived-data'),
        '-clonedSourcePackagesDirPath', str(cache / 'source-packages'),
        '-packageCachePath', str(cache / 'swiftpm'), '-disableAutomaticPackageResolution',
        '-skipPackageUpdates', '-resultBundlePath', str(out / 'result.xcresult'), '-quiet',
        'CODE_SIGNING_ALLOWED=NO', 'CODE_SIGNING_REQUIRED=NO',
        'COMPILER_INDEX_STORE_ENABLE=NO', 'INDEX_ENABLE_DATA_STORE=NO',
        'CLANG_MODULE_CACHE_PATH=' + str(cache / 'clang'),
        'SWIFT_MODULE_CACHE_PATH=' + str(cache / 'swift'),
        'SDK_STAT_CACHE_DIR=' + str(cache / 'sdk-stat'), 'CACHE_ROOT=' + str(cache)]
if a.action == 'test':
    args += ['-only-testing:TchopAppTests/FeedMediaPreviewRendererTests',
             '-parallel-testing-enabled', 'NO', '-collect-test-diagnostics', 'never']
args += [a.action]
(out / 'invocation.json').write_text(json.dumps({
    'args': args, 'environment_overrides': isolation, 'input_sha256': hashes,
    'runtime': a.runtime, 'SDK': 'iPhoneSimulator27.0, distinct from runtime',
    'scope': 'Selected real-media component suite or exact host build; no full/UI suite',
    'baseline': 'Old pixel behavior; only internal test visibility and membership changed'
                if a.stage == 'baseline' else 'Bounded video envelope correction',
    'simulator_fixture_exception': 'Only owned temporary media in Simulator test app'
}, indent=2) + '\n')
print('START', a.stage, a.runtime, a.scheme, a.action, flush=True)
start = time.monotonic()
with (out / 'build.log').open('w') as log:
    process = subprocess.Popen(args, cwd=w, env=env, stdout=log,
                               stderr=subprocess.STDOUT, start_new_session=True)
    try:
        code = process.wait(timeout=180 if a.action == 'test' else 300)
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGTERM)
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait()
        code = 124
result = {'exit_code': code, 'elapsed_seconds': round(time.monotonic() - start, 3),
          'inputs_unchanged': all(hashlib.sha256((w / p).read_bytes()).hexdigest() == h
                                  for p, h in hashes.items()),
          'interpretation': 'Terminal evidence only; baseline failures require diagnosis'}
if a.action == 'test':
    cleanup = subprocess.run(['/Applications/Xcode.app/Contents/Developer/usr/bin/simctl',
                              'shutdown', udid], env=env, capture_output=True,
                             text=True, timeout=30)
    result['shutdown'] = {'exit_code': cleanup.returncode, 'stderr': cleanup.stderr}
(out / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
print('RESULT', json.dumps(result), flush=True)
if code:
    lines = (out / 'build.log').read_text(errors='replace').splitlines()
    selected = [line for line in lines if 'error:' in line or 'failed' in line
                or 'recorded an issue' in line or '** TEST' in line]
    print('\n'.join(selected[:12]), flush=True)
raise SystemExit(code)
