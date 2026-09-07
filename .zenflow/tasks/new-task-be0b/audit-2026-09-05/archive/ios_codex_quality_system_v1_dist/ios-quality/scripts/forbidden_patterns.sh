#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

cd "$QUALITY_REPO_ROOT" || exit 1
added="$(q_added_lines)"
[[ -z "$added" ]] && { q_pass "No added lines to scan."; exit 0; }

patterns=(
  '@unchecked[[:space:]]+Sendable'
  'nonisolated\(unsafe\)'
  '@preconcurrency[[:space:]]+import'
  'Task\.detached'
  'try!'
  'fatalError\('
  'preconditionFailure\('
  'swiftlint:disable'
  'SWIFT_SUPPRESS_WARNINGS'
  'NSAllowsArbitraryLoads'
  'DispatchSemaphore'
  'DispatchGroup[^\n]*\.wait\('
)

found=0
for pattern in "${patterns[@]}"; do
  matches="$(printf '%s\n' "$added" | grep -En "$pattern" || true)"
  if [[ -n "$matches" ]]; then
    found=1
    q_review "Risk pattern '$pattern' found in added lines:"
    printf '%s\n' "$matches" >&2
  fi
done

if (( found )); then
  q_review "Risk-pattern review required. Presence can be valid, but each occurrence needs explicit justification."
  exit 3
fi
q_pass "No configured high-risk shortcut patterns found in added lines."
