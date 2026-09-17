"""Bounded review probes; creates only synthetic files beside this script."""
from pathlib import Path
import json
import shutil
import subprocess
import sys
import tempfile

WORK = Path(__file__).resolve().parent
CANDIDATE = WORK.parent / 'candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY'
ROOT = Path(tempfile.mkdtemp(prefix='astra-v13-', dir=WORK))
# Retain these small fixtures for inspection; never target a real Codex home.
home = ROOT / 'manual-home'
shim = home / 'ios-engineering-shim/bin/ios_ai.py'
shim.parent.mkdir(parents=True)
shutil.copy2(CANDIDATE / 'MANUAL_SHIM/bin/ios_ai.py', shim)
for name, version in [('ios-engineering', 'old'), ('releases/new-version', 'new')]:
    runtime = home / name / 'GLOBAL_CODEX/runtime/bin/ios_ai.py'
    runtime.parent.mkdir(parents=True)
    runtime.write_text('print(' + repr(version) + ')\n')
first = subprocess.run([sys.executable, '-B', str(shim)], capture_output=True, text=True, check=True)
# The update runbook copies a new release and replaces the identical shipped shim.
shutil.copy2(CANDIDATE / 'MANUAL_SHIM/bin/ios_ai.py', shim)
second = subprocess.run([sys.executable, '-B', str(shim)], capture_output=True, text=True, check=True)
source = ROOT / 'copy-source'
target = ROOT / 'occupied-target'
source.mkdir(); target.mkdir()
(source / 'example.txt').write_text('new library bytes')
(target / 'example.txt').write_text('user-owned bytes')
copy = subprocess.run(['/usr/bin/ditto', str(source) + '/.', str(target) + '/'], capture_output=True, text=True)
print(json.dumps({'fixture': str(ROOT), 'shim_before_update': first.stdout.strip(),
    'shim_after_copy_new_release_and_replace_shim': second.stdout.strip(),
    'ditto_exit': copy.returncode, 'occupied_target_after': (target / 'example.txt').read_text()}, indent=2))
