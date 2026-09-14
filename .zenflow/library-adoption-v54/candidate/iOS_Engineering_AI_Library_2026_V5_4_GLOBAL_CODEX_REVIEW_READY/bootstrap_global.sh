#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"
python3 validate_package.py
python3 install_global.py --use-source-in-place "$@"
python3 validate_global_install.py
printf '
Global iOS Engineering Library registered. Restart Codex.
'
