#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

cd "$QUALITY_REPO_ROOT" || exit 1
added="$(q_added_lines)"
[[ -z "$added" ]] && { q_pass "No added lines to scan for secrets."; exit 0; }

patterns=(
  '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'
  'AKIA[0-9A-Z]{16}'
  'gh[pousr]_[A-Za-z0-9_]{20,}'
  'sk-[A-Za-z0-9_-]{20,}'
  'Bearer[[:space:]]+[A-Za-z0-9._~+/-]{20,}'
  '(password|passwd|secret|api[_-]?key)[[:space:]]*[:=][[:space:]]*["'"''][^"'"'']{8,}'
)

found=0
for pattern in "${patterns[@]}"; do
  matches="$(printf '%s\n' "$added" | grep -EIn "$pattern" || true)"
  if [[ -n "$matches" ]]; then
    found=1
    q_review "Possible secret pattern '$pattern' found:"
    printf '%s\n' "$matches" >&2
  fi
done

if (( found )); then
  q_review "Possible secrets require manual review. False positives are possible."
  exit 3
fi
q_pass "No configured obvious secret patterns found in added lines."
