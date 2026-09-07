#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

cd "$QUALITY_REPO_ROOT" || exit 1

if [[ -n "${QUALITY_BUILD_COMMAND:-}" ]]; then
  q_info "Running project override build command"
  bash -lc "$QUALITY_BUILD_COMMAND"
  exit $?
fi

q_require_xcode_profile || exit 2

args=()
if [[ -n "${QUALITY_WORKSPACE:-}" ]]; then
  args+=("-workspace" "$QUALITY_WORKSPACE")
else
  args+=("-project" "$QUALITY_PROJECT")
fi
args+=("-scheme" "$QUALITY_SCHEME" "-configuration" "$QUALITY_CONFIGURATION")
if [[ -n "${QUALITY_DESTINATION:-}" ]]; then
  args+=("-destination" "$QUALITY_DESTINATION")
fi

if [[ -n "${QUALITY_DERIVED_DATA:-}" ]]; then
  derived="$QUALITY_DERIVED_DATA"
else
  derived="$(mktemp -d "${TMPDIR:-/tmp}/ios-quality-derived.XXXXXX")"
  trap 'rm -rf "$derived"' EXIT
fi
args+=("-derivedDataPath" "$derived")

q_info "xcodebuild ${args[*]} build"
xcodebuild "${args[@]}" build
