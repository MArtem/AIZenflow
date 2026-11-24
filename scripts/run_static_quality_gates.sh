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
if ! EMPTY_TREE_SHA="$(git -C "$ROOT" hash-object -t tree --stdin </dev/null)"; then
  printf 'Cannot derive the repository empty-tree identifier.\n' >&2
  exit 2
fi
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
validate_rule_files() {
  local path resolved
  for path in "${RULE_FILES[@]}"; do
    if [[ -L "$ROOT/$path" ]]; then
      printf 'Static gate implementation must not be a symlink: %s\n' "$path" >&2
      return 1
    fi
    if [[ ! -f "$ROOT/$path" || ! -r "$ROOT/$path" ]]; then
      printf 'Static gate implementation must be a readable regular file: %s\n' "$path" >&2
      return 1
    fi
    resolved="$(cd -P "$(dirname "$ROOT/$path")" && printf '%s/%s' "$(pwd)" "$(basename "$path")")"
    case "$resolved" in
      "$ROOT"/*) ;;
      *)
        printf 'Static gate implementation escapes repository root: %s\n' "$path" >&2
        return 1
        ;;
    esac
  done
}
validate_metadata_inputs() {
  python3 - "$ROOT" <<'PY'
import os
import subprocess
import sys
from fnmatch import fnmatch
from pathlib import Path

root = Path(sys.argv[1]).resolve()
sys.path.insert(0, str(root / "scripts"))
from static_gate_scope import (
    MAX_IGNORED_METADATA_BYTES,
    MAX_IGNORED_METADATA_PATHS,
    iter_git_nul_records,
)

inputs = (
    "AGENTS.md",
    "PROJECT_DOCUMENTATION.md",
    "PROJECT_HEALTH.md",
    "docs",
    ".zenflow/tasks",
    ".codex/skills",
)

# Task attachments and retained recovery evidence are intentionally Git-ignored and are not
# authoritative inputs to a committed-SHA metadata gate. Keep this allowlist narrow: an ignored
# path anywhere else under the metadata roots must still fail closed rather than being silently
# treated as evidence for the committed revision.
ALLOWED_IGNORED_TASK_ARTIFACTS = (
    ".zenflow/tasks/*/incoming/",
    ".zenflow/tasks/*/quality-doc-closeout/",
    ".zenflow/tasks/*/runtime/",
    ".zenflow/tasks/*/retired-generated-artifacts/",
    ".zenflow/tasks/*/retired-*-task-copies/",
    "docs/archive/retired-documentation-cleanup/",
)

def matches_allowed_artifact(relative: str) -> bool:
    normalized = relative.rstrip("/")
    return any(
        fnmatch(normalized, pattern.rstrip("/"))
        or fnmatch(normalized, pattern.rstrip("/") + "/*")
        for pattern in ALLOWED_IGNORED_TASK_ARTIFACTS
    )

def is_git_ignored(relative: str) -> bool:
    completed = subprocess.run(
        ["git", "-C", str(root), "check-ignore", "--no-index", "--quiet", "--", relative],
        capture_output=True,
    )
    return completed.returncode == 0

for relative in inputs:
    candidate = root / relative
    if candidate.is_symlink():
        raise SystemExit(f"Static metadata input must not be a symlink: {relative}")
    if not candidate.exists():
        continue
    try:
        candidate.resolve().relative_to(root)
    except ValueError as error:
        raise SystemExit(f"Static metadata input escapes repository root: {relative}") from error
    if candidate.is_file():
        continue
    for directory, directories, files in os.walk(candidate, followlinks=False):
        directory_path = Path(directory)
        for name in [*directories, *files]:
            path = directory_path / name
            if path.is_symlink():
                relative_path = path.relative_to(root).as_posix()
                if not (
                    matches_allowed_artifact(relative_path)
                    and is_git_ignored(relative_path)
                ):
                    raise SystemExit(f"Static metadata input must not be a symlink: {relative_path}")

unexpected_ignored = None
for raw_entry in iter_git_nul_records(
    [
        "git", "-C", str(root), "ls-files", "--others", "--ignored", "--exclude-standard",
        "--directory", "--no-empty-directory", "-z", "--", *inputs,
    ],
    "Cannot establish Git-ignored metadata exclusions.",
    max_output_bytes=MAX_IGNORED_METADATA_BYTES,
    max_records=MAX_IGNORED_METADATA_PATHS,
):
    entry = raw_entry.decode("utf-8", errors="surrogateescape")
    if unexpected_ignored is None and not any(
        fnmatch(entry, pattern) for pattern in ALLOWED_IGNORED_TASK_ARTIFACTS
    ):
        unexpected_ignored = entry
if unexpected_ignored is not None:
    raise SystemExit(f"Static metadata inputs include Git-ignored content: {unexpected_ignored}")

has_assume_unchanged = False
for entry in iter_git_nul_records(
    ["git", "-C", str(root), "ls-files", "-v", "-z", "--", *inputs],
    "Cannot establish Git metadata index flags.",
):
    has_assume_unchanged = has_assume_unchanged or entry[:1].islower()
if has_assume_unchanged:
    raise SystemExit("Static metadata inputs contain assume-unchanged entries.")
PY
}
RULE_VERSION="$({ for path in "${RULE_FILES[@]}"; do
  if index_blob="$(git -C "$ROOT" rev-parse --verify ":$path" 2>/dev/null)"; then
    printf '%s %s\n' "$path" "$index_blob"
  else
    printf '%s missing\n' "$path"
  fi
done; } | git -C "$ROOT" hash-object --stdin)"
METADATA_SCOPE_JSON='["repository-documentation-contract"]'

emit_receipt() {
  local check="$1"
  local scope_json="$2"
  local exit_code="$3"
  local output="$4"
  local applicability="${5:-applicable}"
  local worktree_clean cleanliness_exit_code cleanliness_output observed_sha observed_identity_kind head_unchanged exact_identity
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
  if [[ "$SOURCE_IDENTITY_KIND" == commit && "$worktree_clean" == true ]]; then
    exact_identity=true
  else
    exact_identity=false
  fi
  local encoder_exit_code receipt receipt_validation_exit_code
  set +e
  receipt="$(printf '%s' "$output" | python3 -I -c '
import json
import sys

output = sys.stdin.read()
counts = {
    "blocking": sum("[blocking]" in line for line in output.splitlines()),
    "warning": sum("[warning]" in line for line in output.splitlines()),
    "review_candidate": sum("[review-candidate]" in line for line in output.splitlines()),
}
severity_names = {
    "blocking": "blocking",
    "warning": "warning",
    "review-candidate": "review_candidate",
}
reported_severity_counts = {name: 0 for name in severity_names.values()}
for line in output.splitlines():
    if not line.startswith("- ["):
        continue
    marker = line[3:].split("]", 1)[0]
    if marker in severity_names:
        reported_severity_counts[severity_names[marker]] += 1

scanner_checks = {
    "secrets",
    "large-files",
    "forbidden-patterns",
    "localization",
    "swiftui-hot-path-patterns",
}
scanner_counts = None
scanner_summary_complete = None
severity_counts_complete = None
scanner_severity_counts = None
omitted_severity_counts = None
if sys.argv[6] in scanner_checks:
    import re

    summaries = re.findall(
        r"^Finding counts: total=(\d+), reported=(\d+), omitted=(\d+)$",
        output,
        flags=re.MULTILINE,
    )
    severity_summaries = re.findall(
        r"^Finding severity totals: blocking=(\d+), warning=(\d+), review-candidate=(\d+)$",
        output,
        flags=re.MULTILINE,
    )
    if sys.argv[9] == "not-applicable":
        if summaries or severity_summaries:
            raise SystemExit("Not-applicable receipt unexpectedly contains scanner summaries.")
        scanner_summary_complete = False
        severity_counts_complete = False
    elif len(summaries) == 1:
        total, reported, omitted = map(int, summaries[0])
        if total != reported + omitted or reported != sum(reported_severity_counts.values()):
            raise SystemExit("Scanner summary does not match its reported finding markers.")
        scanner_counts = {"total": total, "reported": reported, "omitted": omitted}
        scanner_summary_complete = True
        if len(severity_summaries) == 1:
            blocking, warning, review_candidate = map(int, severity_summaries[0])
            scanner_severity_counts = {
                "blocking": blocking,
                "warning": warning,
                "review_candidate": review_candidate,
            }
            if sum(scanner_severity_counts.values()) != total:
                raise SystemExit("Scanner severity totals do not match total findings.")
            if any(scanner_severity_counts[name] < reported_severity_counts[name] for name in severity_names.values()):
                raise SystemExit("Reported severity markers exceed scanner severity totals.")
            omitted_severity_counts = {
                name: scanner_severity_counts[name] - reported_severity_counts[name]
                for name in severity_names.values()
            }
            severity_counts_complete = True
        elif len(severity_summaries) > 1:
            raise SystemExit("Scanner output contains duplicate severity-total summaries.")
        elif int(sys.argv[5]) in (0, 1):
            exact_identity = sys.argv[3] == "true" and sys.argv[4] == "commit" and sys.argv[8] == "true"
            if exact_identity:
                raise SystemExit("Scanner output is missing its required severity-total summary.")
            severity_counts_complete = False
        else:
            severity_counts_complete = False
    elif len(summaries) > 1:
        raise SystemExit("Scanner output contains duplicate finding-count summaries.")
    elif int(sys.argv[5]) in (0, 1):
        exact_identity = sys.argv[3] == "true" and sys.argv[4] == "commit" and sys.argv[8] == "true"
        if exact_identity:
            raise SystemExit("Scanner output is missing its required finding-count summary.")
        scanner_summary_complete = False
        severity_counts_complete = False
    else:
        scanner_summary_complete = False
        severity_counts_complete = False

exit_code = int(sys.argv[5])
cleanliness_established = sys.argv[3] != "unknown"
exact_identity = sys.argv[4] == "commit" and sys.argv[3] == "true"
head_unchanged = sys.argv[8] == "true"
not_applicable = sys.argv[9] == "not-applicable"
if severity_counts_complete is True:
    advisory_counts = scanner_severity_counts
elif scanner_summary_complete is True:
    advisory_counts = reported_severity_counts
else:
    advisory_counts = counts
advisory = "warning" if advisory_counts["warning"] else "review_candidate" if advisory_counts["review_candidate"] else "none"
status = "FAIL" if exit_code or not cleanliness_established or not head_unchanged else "BLOCKED" if not exact_identity else "NOT_APPLICABLE" if not_applicable else "PASS"
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
    "scanner_finding_counts": scanner_counts,
    "scanner_summary_complete": scanner_summary_complete,
    "reported_severity_counts": reported_severity_counts if sys.argv[6] in scanner_checks else None,
    "severity_counts": scanner_severity_counts if severity_counts_complete is True else None,
    "omitted_severity_counts": omitted_severity_counts if severity_counts_complete is True else None,
    "severity_counts_complete": severity_counts_complete,
    "advisory": advisory,
}, sort_keys=True))
' "$SOURCE_SHA" "$RULE_VERSION" "$worktree_clean" "$SOURCE_IDENTITY_KIND" "$exit_code" "$check" "$scope_json" "$head_unchanged" "$applicability"
  )"
  encoder_exit_code=$?
  set -e
  if [[ "$encoder_exit_code" -ne 0 || -z "$receipt" ]]; then
    return 2
  fi
  set +e
  printf '%s' "$receipt" | python3 -I -c '
import json
import sys

receipt = json.load(sys.stdin)
required = {"kind", "status", "source_sha", "rule_version", "scope", "check"}
if receipt.get("kind") != "static-gate-evidence" or not required.issubset(receipt):
    raise SystemExit(1)
'
  receipt_validation_exit_code=$?
  set -e
  if [[ "$receipt_validation_exit_code" -ne 0 ]]; then
    return 2
  fi
  printf '%s\n' "$receipt"
  if [[ "$cleanliness_exit_code" -ne 0 || "$head_unchanged" != true || "$exact_identity" != true ]]; then
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
rule_output="$(validate_rule_files 2>&1)"
rule_exit_code=$?
set -e
if [[ "$rule_exit_code" -ne 0 ]]; then
  printf '%s\n' "$rule_output"
  if ! emit_receipt "rule-file-preflight" "$METADATA_SCOPE_JSON" "$rule_exit_code" "$rule_output"; then
    exit 2
  fi
  exit "$rule_exit_code"
fi
RULE_VERSION="$({ for path in "${RULE_FILES[@]}"; do git -C "$ROOT" hash-object "$path"; done; } | git -C "$ROOT" hash-object --stdin)"

set +e
metadata_output="$(validate_metadata_inputs 2>&1)"
metadata_exit_code=$?
set -e
if [[ "$metadata_exit_code" -ne 0 ]]; then
  printf '%s\n' "$metadata_output"
  if ! emit_receipt "metadata-preflight" "$METADATA_SCOPE_JSON" "$metadata_exit_code" "$metadata_output"; then
    exit 2
  fi
  exit "$metadata_exit_code"
fi

scope_has_eligible_files() {
  local gate="$1"
  PYTHONPATH="$ROOT/scripts" STATIC_GATE_NAME="$gate" python3 - "${SCOPE[@]}" <<'PY_GATE'
import os
from static_gate_scope import iter_baseline_gate_files, parse_scope_args, resolve_scan_roots

args = parse_scope_args("Resolve static-gate scope.")
roots = resolve_scan_roots(args.paths)
gate = os.environ["STATIC_GATE_NAME"]
extra = {"docs"} if gate == "forbidden-patterns" else None
print("applicable" if any(iter_baseline_gate_files(roots, gate, extra)) else "not-applicable")
PY_GATE
}

run_scope_gate() {
  local check="$1"
  shift
  local applicability
  if ! applicability="$(scope_has_eligible_files "$check")"; then
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
run_scope_gate "secrets" python3 "$ROOT/scripts/check_secrets.py" "${SCOPE[@]}"
run_scope_gate "large-files" python3 "$ROOT/scripts/check_large_files.py" "${SCOPE[@]}"
run_scope_gate "forbidden-patterns" python3 "$ROOT/scripts/check_forbidden_patterns.py" "${SCOPE[@]}"
run_scope_gate "localization" python3 "$ROOT/scripts/check_localization.py" "${SCOPE[@]}"
run_scope_gate "swiftui-hot-path-patterns" python3 "$ROOT/scripts/check_swiftui_hot_path_patterns.py" "${SCOPE[@]}"
