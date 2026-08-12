#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

git diff --check
python3 AIFieldbook/scripts/static_quality_gate.py
