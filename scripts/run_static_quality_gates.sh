#!/usr/bin/env bash
# Run the repository's lightweight static quality gates for an optional scope.
#
# Contract:
# - path arguments are forwarded to scope-aware checks;
# - blocking gates fail the script;
# - SwiftUI hot-path output remains review-candidate evidence, not an automatic failure.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCOPE=("$@")
python3 "$ROOT/scripts/check_docs_index.py"
python3 "$ROOT/scripts/check_docs_consistency.py"
python3 "$ROOT/scripts/validate_ios_production_framework.py"
python3 "$ROOT/scripts/check_secrets.py" "${SCOPE[@]}"
python3 "$ROOT/scripts/check_large_files.py" "${SCOPE[@]}"
python3 "$ROOT/scripts/check_forbidden_patterns.py" "${SCOPE[@]}"
python3 "$ROOT/scripts/check_localization.py" "${SCOPE[@]}"
python3 "$ROOT/scripts/check_swiftui_hot_path_patterns.py" "${SCOPE[@]}"
