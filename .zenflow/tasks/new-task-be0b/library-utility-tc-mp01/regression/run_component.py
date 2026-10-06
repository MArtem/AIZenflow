from pathlib import Path
import json, os, subprocess, sys, time

r = Path(__file__).resolve().parent
stage = sys.argv[1]
assert stage in ['baseline', 'after']
base = r / ('component-' + stage)
invocation = json.loads((base / 'invocation.json').read_text())
env = os.environ.copy()
env.update(invocation['environment'])
simctl = '/Applications/Xcode.app/Contents/Developer/usr/bin/simctl'
failed = False
for version, udid in [('18.2', 'BE43D4FD-1B71-4E6F-9EE7-DB32BD2D4D7C'),
                      ('27.0', '2BED6C3B-5DA5-4F43-A44E-FB1CC9BB8F8D')]:
    out = base / ('runtime-' + version)
    out.mkdir(exist_ok=False)
    fixtures = out / 'fixtures'
    fixtures.mkdir()
    def sim(args):
        return subprocess.run([simctl, *args], env=env, capture_output=True, text=True, timeout=90)
    boot = sim(['boot', udid])
    assert boot.returncode == 0 or 'current state: Booted' in boot.stderr, boot.stderr
    ready = sim(['bootstatus', udid, '-b'])
    assert ready.returncode == 0, ready.stderr
    args = [simctl, 'spawn', udid, str(base / 'MediaPreviewProbe.app/MediaPreviewProbe'), str(fixtures)]
    (out / 'invocation.json').write_text(json.dumps({'args': args, 'runtime': version,
        'source': invocation, 'scope': 'Real renderer component, trusted fixture-file resolver; no full host or UI claim'}, indent=2) + '\n')
    print('COMPONENT START', stage, version, flush=True)
    start = time.monotonic()
    try:
        try:
            p = subprocess.run(args, env=env, capture_output=True, text=True, timeout=60)
        except subprocess.TimeoutExpired as e:
            p = subprocess.CompletedProcess(args, 124,
                e.stdout.decode() if isinstance(e.stdout, bytes) else (e.stdout or ''),
                e.stderr.decode() if isinstance(e.stderr, bytes) else (e.stderr or ''))
        (out / 'stdout.log').write_text(p.stdout)
        (out / 'stderr.log').write_text(p.stderr)
        result = {'exit_code': p.returncode, 'elapsed_seconds': round(time.monotonic() - start, 3)}
        (out / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
        print('COMPONENT RESULT', version, json.dumps(result), p.stdout[:2000], p.stderr[:300], flush=True)
        failed = failed or p.returncode != 0
    finally:
        shutdown = sim(['shutdown', udid])
        (out / 'shutdown.json').write_text(json.dumps({'exit_code': shutdown.returncode, 'stderr': shutdown.stderr}) + '\n')
        assert shutdown.returncode == 0 or 'current state: Shutdown' in shutdown.stderr
raise SystemExit(1 if failed else 0)
