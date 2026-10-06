from pathlib import Path
import hashlib, json, os, subprocess, time

base = Path(__file__).resolve().parent / 'package'
env = os.environ.copy()
overrides = {key: str(base / name) for key, name in [
    ('TMPDIR', 'tmp'), ('CFFIXED_USER_HOME', 'cocoa-home'), ('XDG_CACHE_HOME', 'cache'),
    ('CLANG_MODULE_CACHE_PATH', 'clang-cache'), ('SWIFTPM_MODULECACHE_OVERRIDE', 'swift-cache')]}
for value in overrides.values(): Path(value).mkdir(parents=True, exist_ok=True)
env.update(overrides)
args = ['/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift',
    'build', '--package-path', str(base / 'source'), '--scratch-path', str(base / 'build'),
    '--cache-path', str(base / 'spm-cache'), '--config-path', str(base / 'spm-config'),
    '--security-path', str(base / 'spm-security'), '--manifest-cache', 'none',
    '--disable-sandbox', '--disable-keychain', '--disable-netrc', '--disable-index-store',
    '-Xswiftc', '-strict-concurrency=complete', '-Xswiftc', '-warnings-as-errors',
    '-Xswiftc', '-swift-version', '-Xswiftc', '6']
receipt = base / 'build-receipt.json'
assert not receipt.exists() and not (base / 'build.log').exists()
started = time.monotonic()
with (base / 'build.log').open('w') as stream:
    try:
        code = subprocess.run(args, env=env, stdout=stream, stderr=subprocess.STDOUT, timeout=180).returncode
    except subprocess.TimeoutExpired:
        code = 124
inputs = json.loads((base / 'inputs.json').read_text())
unchanged = all(hashlib.sha256((base / 'source' / path).read_bytes()).hexdigest() == digest
                for path, digest in inputs.items())
result = {'args': args, 'environment': overrides, 'exit_code': code,
    'elapsed_seconds': round(time.monotonic() - started, 3), 'inputs_unchanged': unchanged,
    'scope': 'Copied complete standalone package modules, native macOS compile; no runtime/minimum-OS proof',
    'status': 'PASS' if code == 0 and unchanged else 'FAIL'}
receipt.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result), flush=True)
if code: print((base / 'build.log').read_text()[-4000:])
raise SystemExit(code if code else (0 if unchanged else 1))
