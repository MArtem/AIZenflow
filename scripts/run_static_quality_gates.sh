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
SOURCE_SHA="$(git -C "$ROOT" rev-parse HEAD)"
if [[ -z "$(git -C "$ROOT" status --porcelain --untracked-files=normal)" ]]; then
  WORKTREE_CLEAN=true
else
  WORKTREE_CLEAN=false
fi
RULE_FILES=(
  scripts/run_static_quality_gates.sh
  scripts/static_gate_scope.py
  scripts/check_docs_index.py
  scripts/check_docs_consistency.py
  scripts/validate_ios_production_framework.py
  scripts/check_secrets.py
  scripts/check_large_files.py
  scripts/check_forbidden_patterns.py
  scripts/check_localization.py
  scripts/check_swiftui_hot_path_patterns.py
)
RULE_VERSION="$({ for path in "${RULE_FILES[@]}"; do git -C "$ROOT" hash-object "$path"; done; } | git -C "$ROOT" hash-object --stdin)"
SCAN_SCOPE_JSON="$(PYTHONPATH="$ROOT/scripts" python3 - "${SCOPE[@]}" <<'PY'
import json
from static_gate_scope import display_path, parse_scope_args, resolve_scan_roots

args = parse_scope_args("Resolve static-gate scope.")
print(json.dumps([display_path(path) for path in resolve_scan_roots(args.paths)]))
PY
)"
METADATA_SCOPE_JSON='["repository-documentation-contract"]'

emit_receipt() {
  python3 - "$SOURCE_SHA" "$RULE_VERSION" "$WORKTREE_CLEAN" "$1" "$2" <<'PY'
import json
import sys

print(json.dumps({
    "kind": "static-gate-evidence",
    "status": "PASS",
    "source_sha": sys.argv[1],
    "rule_version": sys.argv[2],
    "worktree_clean": sys.argv[3] == "true",
    "check": sys.argv[4],
    "scope": json.loads(sys.argv[5]),
}, sort_keys=True))
PY
}

run_gate() {
  local check="$1"
  local scope_json="$2"
  shift 2
  "$@"
  emit_receipt "$check" "$scope_json"
}

run_gate "docs-index" "$METADATA_SCOPE_JSON" python3 "$ROOT/scripts/check_docs_index.py"
run_gate "docs-consistency" "$METADATA_SCOPE_JSON" python3 "$ROOT/scripts/check_docs_consistency.py"
run_gate "ios-production-framework" "$METADATA_SCOPE_JSON" python3 "$ROOT/scripts/validate_ios_production_framework.py"
run_gate "secrets" "$SCAN_SCOPE_JSON" python3 "$ROOT/scripts/check_secrets.py" "${SCOPE[@]}"
run_gate "large-files" "$SCAN_SCOPE_JSON" python3 "$ROOT/scripts/check_large_files.py" "${SCOPE[@]}"
run_gate "forbidden-patterns" "$SCAN_SCOPE_JSON" python3 "$ROOT/scripts/check_forbidden_patterns.py" "${SCOPE[@]}"
run_gate "localization" "$SCAN_SCOPE_JSON" python3 "$ROOT/scripts/check_localization.py" "${SCOPE[@]}"
run_gate "swiftui-hot-path-patterns" "$SCAN_SCOPE_JSON" python3 "$ROOT/scripts/check_swiftui_hot_path_patterns.py" "${SCOPE[@]}"
