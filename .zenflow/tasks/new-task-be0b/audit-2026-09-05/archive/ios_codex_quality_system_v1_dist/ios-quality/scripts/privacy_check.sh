#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

cd "$QUALITY_REPO_ROOT" || exit 1
files="$(q_changed_files)"
review=0

sensitive_files="$(printf '%s\n' "$files" | grep -E 'PrivacyInfo\.xcprivacy$|\.entitlements$|Info\.plist$|project\.pbxproj$' || true)"
if [[ -n "$sensitive_files" ]]; then
  q_review "Privacy/capability/build metadata changed:"
  printf '%s\n' "$sensitive_files" >&2
  review=1
fi

added="$(q_added_lines)"
api_matches="$(printf '%s\n' "$added" | grep -E 'UserDefaults|systemUptime|volumeAvailableCapacity|contentModificationDateKey|creationDateKey|NSFileCreationDate|NSFileModificationDate' || true)"
if [[ -n "$api_matches" ]]; then
  q_review "Possible required-reason/privacy-sensitive API addition; verify PrivacyInfo.xcprivacy and approved reason applicability:"
  printf '%s\n' "$api_matches" >&2
  review=1
fi

if (( review )); then
  exit 3
fi
q_pass "No configured privacy/capability review triggers detected."
