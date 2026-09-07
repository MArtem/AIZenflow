#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

cd "$QUALITY_REPO_ROOT" || exit 1
files="$(q_changed_files)"
review=0

if printf '%s\n' "$files" | grep -Eq '(^|/)Package\.resolved$|(^|/)Package\.swift$|(^|/)Podfile(\.lock)?$|(^|/)Cartfile(\.resolved)?$|\.xcframework($|/)'; then
  q_review "Dependency-related file changed:"
  printf '%s\n' "$files" | grep -E '(^|/)Package\.resolved$|(^|/)Package\.swift$|(^|/)Podfile(\.lock)?$|(^|/)Cartfile(\.resolved)?$|\.xcframework($|/)' >&2 || true
  review=1
fi

base="$(q_diff_base)"
if [[ -n "$base" ]]; then
  dep_diff="$(git diff "$base" -- '*.swift' '*.pbxproj' | grep -E '^\+.*(\.package\(|packageProductDependencies|XCRemoteSwiftPackageReference)' || true)"
  if [[ -n "$dep_diff" ]]; then
    q_review "Possible dependency declaration change detected:"
    printf '%s\n' "$dep_diff" >&2
    review=1
  fi
fi

if (( review )); then
  q_review "Dependency changes require explicit human approval and supply-chain review."
  exit 3
fi
q_pass "No dependency-resolution/declaration changes detected."
