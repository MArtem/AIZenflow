from pathlib import Path
import json, os, subprocess, time, plistlib

base = Path(__file__).resolve().parent
env = os.environ.copy()
isolated = {}
for key, child in [('TMPDIR', 'tmp'), ('CFFIXED_USER_HOME', 'cocoa-home'), ('XDG_CACHE_HOME', 'cache')]:
    p = base / child
    p.mkdir(exist_ok=True)
    isolated[key] = str(p)
env.update(isolated)
swiftc = '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc'
developer = '/Applications/Xcode.app/Contents/Developer'
sources = [str(base / x) for x in ['AppDatabaseCore.swift', 'SwiftDataModelActorDatabaseManager.swift', 'AppSwiftDataDatabase.swift', 'DatabaseProbe.swift']]
results = []

def run(args, output, limit=90):
    start = time.monotonic()
    with output.open('w') as log:
        try:
            p = subprocess.run(args, env=env, stdout=log, stderr=subprocess.STDOUT, timeout=limit)
            code = p.returncode
        except subprocess.TimeoutExpired:
            code = 124
    record = {'args': args, 'exit_code': code, 'elapsed_seconds': round(time.monotonic() - start, 3), 'log': str(output)}
    results.append(record)
    (base / 'execution-results.json').write_text(json.dumps({'environment': isolated, 'results': results}, indent=2) + '\n')
    print('RESULT', output.name, code, flush=True)
    if code:
        print(output.read_text()[-5000:], flush=True)
        raise SystemExit(code)
    return output.read_text()

mac = base / 'macos'
mac.mkdir(exist_ok=True)
run([swiftc, '-disable-sandbox', '-parse-as-library', '-swift-version', '6', '-strict-concurrency=complete', '-warnings-as-errors',
     '-sdk', developer + '/Platforms/MacOSX.platform/Developer/SDKs/MacOSX27.0.sdk',
     '-target', 'arm64-apple-macos14.0', '-module-cache-path', str(base / 'cache/mac-modules'),
     '-o', str(mac / 'DatabaseProbe'), *sources], mac / 'compile.log', 120)
for phase in ['old', 'new', 'reopen']:
    print(run([str(mac / 'DatabaseProbe'), phase, str(mac / 'fixture.store')], mac / (phase + '.log')), flush=True)

app = base / 'DatabaseProbe.app'
app.mkdir(exist_ok=True)
(app / 'Info.plist').write_bytes(plistlib.dumps({'CFBundleExecutable': 'DatabaseProbe',
    'CFBundleIdentifier': 'com.zenflow.F02.DatabaseProbe', 'CFBundlePackageType': 'APPL'}))
run([swiftc, '-disable-sandbox', '-parse-as-library', '-swift-version', '6', '-strict-concurrency=complete', '-warnings-as-errors',
     '-sdk', developer + '/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator27.0.sdk',
     '-target', 'arm64-apple-ios17.0-simulator', '-module-cache-path', str(base / 'cache/ios-modules'),
     '-o', str(app / 'DatabaseProbe'), *sources], base / 'ios-compile.log', 120)
simctl = developer + '/usr/bin/simctl'
for version, device in [('18.2', 'BE43D4FD-1B71-4E6F-9EE7-DB32BD2D4D7C'), ('27.0', '2BED6C3B-5DA5-4F43-A44E-FB1CC9BB8F8D')]:
    out = base / ('ios-' + version)
    out.mkdir(exist_ok=True)
    run([simctl, 'boot', device], out / 'boot.log')
    try:
        run([simctl, 'bootstatus', device, '-b'], out / 'bootstatus.log')
        for phase in ['old', 'new', 'reopen']:
            print(run([simctl, 'spawn', device, str(app / 'DatabaseProbe'), phase, str(out / 'fixture.store')],
                      out / (phase + '.log')), flush=True)
    finally:
        run([simctl, 'shutdown', device], out / 'shutdown.log')

print('COMPLETE exact database mechanism, disposable schema fixture only; no host app/schema or real data claim', flush=True)
