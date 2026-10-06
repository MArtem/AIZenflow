from pathlib import Path
import json, os, subprocess, time

base = Path(__file__).resolve().parent
env = os.environ.copy()
env.update({k: str(base / v) for k, v in [('TMPDIR', 'tmp'), ('CFFIXED_USER_HOME', 'cocoa-home'), ('XDG_CACHE_HOME', 'cache')]})
simctl = '/Applications/Xcode.app/Contents/Developer/usr/bin/simctl'
results = []

def run(args, log, limit=90, allowed=()):
    start = time.monotonic()
    try:
        p = subprocess.run(args, env=env, capture_output=True, text=True, timeout=limit)
    except subprocess.TimeoutExpired as error:
        p = subprocess.CompletedProcess(args, 124,
            error.stdout.decode() if isinstance(error.stdout, bytes) else (error.stdout or ''),
            error.stderr.decode() if isinstance(error.stderr, bytes) else (error.stderr or ''))
    log.write_text(p.stdout + p.stderr)
    results.append({'args': args, 'exit_code': p.returncode, 'elapsed_seconds': round(time.monotonic()-start, 3), 'log': str(log)})
    (base / 'sim-execution-results.json').write_text(json.dumps(results, indent=2) + '\n')
    print(log.name, p.returncode, p.stdout[-2500:], flush=True)
    if p.returncode and not any(x in p.stderr for x in allowed):
        print(p.stderr[-2500:], flush=True)
        raise RuntimeError('terminal execution failure')

for version, device in [('18.2', 'BE43D4FD-1B71-4E6F-9EE7-DB32BD2D4D7C'), ('27.0', '2BED6C3B-5DA5-4F43-A44E-FB1CC9BB8F8D')]:
    out = base / ('sim-' + version)
    out.mkdir(exist_ok=False)
    run([simctl, 'boot', device], out / 'boot.log', allowed=('current state: Booted',))
    try:
        run([simctl, 'bootstatus', device, '-b'], out / 'ready.log')
        for phase in ['old', 'new', 'reopen']:
            run([simctl, 'spawn', device, str(base / 'DatabaseProbe.app/DatabaseProbe'), phase,
                 str(out / 'fixture.store')], out / (phase + '.log'))
    finally:
        run([simctl, 'shutdown', device], out / 'shutdown.log', allowed=('current state: Shutdown',))
