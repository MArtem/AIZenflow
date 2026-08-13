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
export PYTHONDONTWRITEBYTECODE=1
EMPTY_TREE_SHA="4b825dc642cb6eb9a060e54bf8d69288fbee4904"
if SOURCE_SHA="$(git -C "$ROOT" rev-parse --verify HEAD 2>/dev/null)"; then
  SOURCE_IDENTITY_KIND=commit
else
  SOURCE_SHA="$EMPTY_TREE_SHA"
  SOURCE_IDENTITY_KIND=unborn-worktree
fi
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  printf 'Usage: %s [path ...]\n' "${0##*/}"
  printf 'Runs repository static gates. Dirty or unborn worktrees emit PROVISIONAL evidence.\n'
  exit 0
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
METADATA_SCOPE_JSON='["repository-documentation-contract"]'

emit_receipt() {
  local check="$1"
  local scope_json="$2"
  local exit_code="$3"
  local output="$4"
  local worktree_clean cleanliness_exit_code cleanliness_output
  set +e
  cleanliness_output="$(git -C "$ROOT" status --porcelain --untracked-files=normal 2>&1)"
  cleanliness_exit_code=$?
  set -e
  if [[ "$cleanliness_exit_code" -ne 0 ]]; then
    worktree_clean=unknown
  elif [[ -z "$cleanliness_output" ]]; then
    worktree_clean=true
  else
    worktree_clean=false
  fi
  local encoder_exit_code
  set +e
  printf '%s' "$output" | python3 -c '
import json
import sys

output = sys.stdin.read()
counts = {
    "blocking": sum("[blocking]" in line for line in output.splitlines()),
    "warning": sum("[warning]" in line for line in output.splitlines()),
    "review_candidate": sum("[review-candidate]" in line for line in output.splitlines()),
}
exit_code = int(sys.argv[5])
cleanliness_established = sys.argv[3] != "unknown"
exact_identity = sys.argv[4] == "commit" and sys.argv[3] == "true"
status = "FAIL" if exit_code or not cleanliness_established else "PROVISIONAL" if not exact_identity else "WARN" if counts["warning"] else "REVIEW_CANDIDATE" if counts["review_candidate"] else "PASS"
print(json.dumps({
    "kind": "static-gate-evidence",
    "status": status,
    "source_sha": sys.argv[1],
    "rule_version": sys.argv[2],
    "worktree_clean": None if sys.argv[3] == "unknown" else sys.argv[3] == "true",
    "cleanliness_established": cleanliness_established,
    "source_identity_kind": sys.argv[4],
    "check": sys.argv[6],
    "scope": json.loads(sys.argv[7]),
    "exit_code": exit_code,
    "finding_counts": counts,
}, sort_keys=True))
' "$SOURCE_SHA" "$RULE_VERSION" "$worktree_clean" "$SOURCE_IDENTITY_KIND" "$exit_code" "$check" "$scope_json"
  encoder_exit_code=$?
  set -e
  if [[ "$encoder_exit_code" -ne 0 ]]; then
    return "$encoder_exit_code"
  fi
  if [[ "$cleanliness_exit_code" -ne 0 ]]; then
    return 2
  fi
}

run_gate() {
  local check="$1"
  local scope_json="$2"
  shift 2
  local output exit_code
  set +e
  output="$("$@" 2>&1)"
  exit_code=$?
  set -e
  printf '%s\n' "$output"
  if ! emit_receipt "$check" "$scope_json" "$exit_code" "$output"; then
    return 2
  fi
  return "$exit_code"
}

set +e
scope_output="$(PYTHONPATH="$ROOT/scripts" python3 - "${SCOPE[@]}" <<'PY'
import json
from static_gate_scope import display_path, parse_scope_args, resolve_scan_roots

args = parse_scope_args("Resolve static-gate scope.")
print(json.dumps([display_path(path) for path in resolve_scan_roots(args.paths)]))
PY
)"
scope_exit_code=$?
set -e
if [[ "$scope_exit_code" -ne 0 ]]; then
  printf '%s\n' "$scope_output"
  if ! emit_receipt "scope-validation" '[]' "$scope_exit_code" "$scope_output"; then
    exit 2
  fi
  exit "$scope_exit_code"
fi
SCAN_SCOPE_JSON="$scope_output"

run_gate "docs-index" "$METADATA_SCOPE_JSON" python3 "$ROOT/scripts/check_docs_index.py"
run_gate "docs-consistency" "$METADATA_SCOPE_JSON" python3 "$ROOT/scripts/check_docs_consistency.py"
run_gate "ios-production-framework" "$METADATA_SCOPE_JSON" python3 "$ROOT/scripts/validate_ios_production_framework.py"
run_gate "secrets" "$SCAN_SCOPE_JSON" python3 "$ROOT/scripts/check_secrets.py" "${SCOPE[@]}"
run_gate "large-files" "$SCAN_SCOPE_JSON" python3 "$ROOT/scripts/check_large_files.py" "${SCOPE[@]}"
run_gate "forbidden-patterns" "$SCAN_SCOPE_JSON" python3 "$ROOT/scripts/check_forbidden_patterns.py" "${SCOPE[@]}"
run_gate "localization" "$SCAN_SCOPE_JSON" python3 "$ROOT/scripts/check_localization.py" "${SCOPE[@]}"
run_gate "swiftui-hot-path-patterns" "$SCAN_SCOPE_JSON" python3 "$ROOT/scripts/check_swiftui_hot_path_patterns.py" "${SCOPE[@]}"
