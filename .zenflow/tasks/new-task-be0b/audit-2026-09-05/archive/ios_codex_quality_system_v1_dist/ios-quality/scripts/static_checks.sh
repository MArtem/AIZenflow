#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
cd "$QUALITY_REPO_ROOT" || exit 1

status=0

if [[ -n "${QUALITY_LINT_COMMAND:-}" ]]; then
  q_info "Running configured lint command"
  bash -lc "$QUALITY_LINT_COMMAND" || status=1
elif command -v swiftlint >/dev/null 2>&1 && [[ -f .swiftlint.yml || -f .swiftlint.yaml ]]; then
  q_info "Running SwiftLint"
  swiftlint lint --strict || status=1
elif [[ "${QUALITY_REQUIRE_SWIFTLINT:-0}" == "1" ]]; then
  q_fail "SwiftLint is required by project profile but unavailable/not configured."
  status=1
else
  q_skip "SwiftLint not configured; no tool added automatically."
fi

if [[ -n "${QUALITY_FORMAT_COMMAND:-}" ]]; then
  q_info "Running configured format check"
  bash -lc "$QUALITY_FORMAT_COMMAND" || status=1
elif [[ "${QUALITY_REQUIRE_FORMAT_CHECK:-0}" == "1" ]]; then
  q_fail "Format check required but QUALITY_FORMAT_COMMAND is empty."
  status=1
else
  q_skip "No project format-check command configured."
fi

exit "$status"
