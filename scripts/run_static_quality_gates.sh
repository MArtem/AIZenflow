#!/usr/bin/env bash
# Run the repository's lightweight static quality gates for an optional scope.
#
# Contract:
# - path arguments are forwarded to scope-aware checks;
# - blocking gates fail the script;
# - SwiftUI hot-path output remains review-candidate evidence, not an automatic failure.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if (( $# )); then
  SCOPE=("$@")
else
  SCOPE=(.)
fi
export PYTHONDONTWRITEBYTECODE=1
for argument in "$@"; do
  if [[ "$argument" == "-h" || "$argument" == "--help" ]]; then
    printf 'Usage: %s [path ...]\n' "${0##*/}"
    printf 'Runs repository static gates. Dirty or unborn worktrees emit BLOCKED exact-SHA evidence.\n'
    exit 0
  fi
done
EMPTY_TREE_SHA="4b825dc642cb6eb9a060e54bf8d69288fbee4904"
if SOURCE_SHA="$(git -C "$ROOT" rev-parse --verify HEAD 2>/dev/null)"; then
  SOURCE_IDENTITY_KIND=commit
else
  SOURCE_SHA="$EMPTY_TREE_SHA"
  SOURCE_IDENTITY_KIND=unborn-worktree
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
  local applicability="${5:-applicable}"
  local worktree_clean cleanliness_exit_code cleanliness_output observed_sha observed_identity_kind head_unchanged
  set +e
  cleanliness_output="$(git -C "$ROOT" status --porcelain --untracked-files=normal --ignore-submodules=none 2>&1)"
  cleanliness_exit_code=$?
  set -e
  if [[ "$cleanliness_exit_code" -ne 0 ]]; then
    worktree_clean=unknown
  elif [[ -z "$cleanliness_output" ]]; then
    worktree_clean=true
  else
    worktree_clean=false
  fi
  if observed_sha="$(git -C "$ROOT" rev-parse --verify HEAD 2>/dev/null)"; then
    observed_identity_kind=commit
  else
    observed_sha="$EMPTY_TREE_SHA"
    observed_identity_kind=unborn-worktree
  fi
  if [[ "$observed_sha" == "$SOURCE_SHA" && "$observed_identity_kind" == "$SOURCE_IDENTITY_KIND" ]]; then
    head_unchanged=true
  else
    head_unchanged=false
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
head_unchanged = sys.argv[8] == "true"
not_applicable = sys.argv[9] == "not-applicable"
advisory = "warning" if counts["warning"] else "review_candidate" if counts["review_candidate"] else "none"
status = "FAIL" if exit_code or not cleanliness_established or not head_unchanged else "NOT_APPLICABLE" if not_applicable else "BLOCKED" if not exact_identity else "PASS"
print(json.dumps({
    "kind": "static-gate-evidence",
    "status": status,
    "source_sha": sys.argv[1],
    "rule_version": sys.argv[2],
    "worktree_clean": None if sys.argv[3] == "unknown" else sys.argv[3] == "true",
    "cleanliness_established": cleanliness_established,
    "head_unchanged": head_unchanged,
    "source_identity_kind": sys.argv[4],
    "check": sys.argv[6],
    "scope": json.loads(sys.argv[7]),
    "exit_code": exit_code,
    "finding_counts": counts,
    "advisory": advisory,
}, sort_keys=True))
' "$SOURCE_SHA" "$RULE_VERSION" "$worktree_clean" "$SOURCE_IDENTITY_KIND" "$exit_code" "$check" "$scope_json" "$head_unchanged" "$applicability"
  encoder_exit_code=$?
  set -e
  if [[ "$encoder_exit_code" -ne 0 ]]; then
    return "$encoder_exit_code"
  fi
  if [[ "$cleanliness_exit_code" -ne 0 || "$head_unchanged" != true ]]; then
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

scope_has_eligible_files() {
  local pattern="$1"
  local excludes="$2"
  PYTHONPATH="$ROOT/scripts" STATIC_GATE_PATTERN="$pattern" STATIC_GATE_EXCLUDES="$excludes" python3 - "${SCOPE[@]}" <<'PY'
import os
from static_gate_scope import iter_files, parse_scope_args, resolve_scan_roots

args = parse_scope_args("Resolve static-gate scope.")
excludes = {value for value in os.environ["STATIC_GATE_EXCLUDES"].split(",") if value}
roots = resolve_scan_roots(args.paths)
print("applicable" if any(iter_files(roots, os.environ["STATIC_GATE_PATTERN"], excludes)) else "not-applicable")
PY
}

run_scope_gate() {
  local check="$1"
  local pattern="$2"
  local excludes="$3"
  shift 3
  local applicability
  if ! applicability="$(scope_has_eligible_files "$pattern" "$excludes")"; then
    return 2
  fi
  if [[ "$applicability" == "applicable" ]]; then
    run_gate "$check" "$SCAN_SCOPE_JSON" "$@"
    return
  fi
  if [[ "$applicability" == "not-applicable" ]]; then
    emit_receipt "$check" "$SCAN_SCOPE_JSON" 0 "No eligible files in the requested scope." not-applicable
    return
  fi
  return 2
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
run_scope_gate "secrets" "*" ".zenflow,traces" python3 "$ROOT/scripts/check_secrets.py" "${SCOPE[@]}"
run_scope_gate "large-files" "*" "traces" python3 "$ROOT/scripts/check_large_files.py" "${SCOPE[@]}"
run_scope_gate "forbidden-patterns" "*.swift" "TchopAppTests,docs,.zenflow" python3 "$ROOT/scripts/check_forbidden_patterns.py" "${SCOPE[@]}"
run_scope_gate "localization" "*.swift" "TchopAppTests" python3 "$ROOT/scripts/check_localization.py" "${SCOPE[@]}"
run_scope_gate "swiftui-hot-path-patterns" "*.swift" "TchopAppTests" python3 "$ROOT/scripts/check_swiftui_hot_path_patterns.py" "${SCOPE[@]}"
