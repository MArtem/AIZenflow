#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

kind="${1:-targeted}"
cd "$QUALITY_REPO_ROOT" || exit 1

if [[ "$kind" == "full" && -n "${QUALITY_FULL_TEST_COMMAND:-}" ]]; then
  q_info "Running project override full test command"
  bash -lc "$QUALITY_FULL_TEST_COMMAND"
  exit $?
fi
if [[ "$kind" != "full" && -n "${QUALITY_TARGETED_TEST_COMMAND:-}" ]]; then
  q_info "Running project override targeted test command"
  bash -lc "$QUALITY_TARGETED_TEST_COMMAND"
  exit $?
fi

q_require_xcode_profile || exit 2
if [[ -z "${QUALITY_DESTINATION:-}" ]]; then
  q_fail "QUALITY_DESTINATION is required for default test runner."
  exit 2
fi

args=()
if [[ -n "${QUALITY_WORKSPACE:-}" ]]; then
  args+=("-workspace" "$QUALITY_WORKSPACE")
else
  args+=("-project" "$QUALITY_PROJECT")
fi
args+=("-scheme" "$QUALITY_SCHEME" "-configuration" "$QUALITY_CONFIGURATION" "-destination" "$QUALITY_DESTINATION")
if [[ -n "${QUALITY_TEST_PLAN:-}" ]]; then
  args+=("-testPlan" "$QUALITY_TEST_PLAN")
fi

result_dir="$(mktemp -d "${TMPDIR:-/tmp}/ios-quality-test.XXXXXX")"
trap 'rm -rf "$result_dir"' EXIT
args+=("-resultBundlePath" "$result_dir/result.xcresult")

if [[ "$kind" != "full" && -n "${QUALITY_ONLY_TESTING:-}" ]]; then
  normalized="$(printf '%s' "$QUALITY_ONLY_TESTING" | tr ',' ' ')"
  for test_id in $normalized; do
    args+=("-only-testing:$test_id")
  done
fi

q_info "xcodebuild ${args[*]} test"
xcodebuild "${args[@]}" test
