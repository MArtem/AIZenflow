#!/usr/bin/env bash
set -u
ROOT="${1:-.}"
cd "$ROOT" || exit 2
echo "== git status --short =="
git status --short || true
echo "== git diff --check =="
git diff --check; RC=$?
echo "== changed files =="
{ git diff --name-only --diff-filter=ACMR; git diff --cached --name-only --diff-filter=ACMR; } | sort -u
echo "== changed Swift heuristic leads =="
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/swift_risk_scan.py" . || true
exit "$RC"
