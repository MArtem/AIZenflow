#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

diff_range="${AI_FIELDBOOK_STATIC_DIFF_RANGE:-HEAD^...HEAD}"
git diff --check "$diff_range"
python3 AIFieldbook/scripts/static_quality_gate.py
