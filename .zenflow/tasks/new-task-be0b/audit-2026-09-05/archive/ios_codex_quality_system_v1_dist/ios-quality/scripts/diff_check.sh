#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

cd "$QUALITY_REPO_ROOT" || exit 1
files="$(q_changed_files)"
if [[ -z "$files" ]]; then
  q_warn "No changed tracked files detected relative to HEAD."
  exit 0
fi

echo "Changed files:"
printf '%s\n' "$files" | sed 's/^/  - /'

bad="$(printf '%s\n' "$files" | grep -E '(^|/)(DerivedData|\.build|xcuserdata|Pods)/|\.xcresult$|\.trace$|\.DS_Store$|\.ipa$|\.app$|\.dSYM($|/)|\.mobileprovision$' || true)"
if [[ -n "$bad" ]]; then
  q_fail "Build/local artifacts are present in the diff:"
  printf '%s\n' "$bad" >&2
  exit 1
fi

project_sensitive="$(printf '%s\n' "$files" | grep -E 'project\.pbxproj$|\.xcworkspace/|\.xcscheme$|\.xctestplan$|\.entitlements$|Info\.plist$|PrivacyInfo\.xcprivacy$|Package\.resolved$' || true)"
if [[ -n "$project_sensitive" ]]; then
  q_review "Sensitive metadata files changed and require explicit line-by-line review:"
  printf '%s\n' "$project_sensitive" >&2
  exit 3
fi

q_pass "No obvious build artifacts or sensitive metadata changes detected."
