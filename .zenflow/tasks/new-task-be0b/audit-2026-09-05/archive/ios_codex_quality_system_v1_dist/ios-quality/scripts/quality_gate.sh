#!/usr/bin/env bash
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

phase="${1:-precommit}"
cd "$QUALITY_REPO_ROOT" || exit 1

printf 'iOS Quality Gate\n'
printf '  mode: %s\n' "$QUALITY_MODE"
printf '  risk: %s\n' "$QUALITY_RISK"
printf '  triggers: %s\n' "${QUALITY_TRIGGERS:-none}"
printf '  phase: %s\n\n' "$phase"

failures=0
reviews=0

run_gate() {
  local name="$1"; shift
  echo "== $name =="
  "$@"
  rc=$?
  case "$rc" in
    0) ;;
    3) reviews=$((reviews + 1)) ;;
    *) failures=$((failures + 1)) ;;
  esac
  echo
}

run_gate "G10 unsafe-pattern scan" "$SCRIPT_DIR/forbidden_patterns.sh"
run_gate "G31 secret scan" "$SCRIPT_DIR/secrets_check.sh"
run_gate "G20 dependency review" "$SCRIPT_DIR/dependency_check.sh"
run_gate "G19/G26 privacy metadata review" "$SCRIPT_DIR/privacy_check.sh"
run_gate "G30/G32 diff review" "$SCRIPT_DIR/diff_check.sh"
run_gate "Static/lint checks" "$SCRIPT_DIR/static_checks.sh"

risk_num="$(q_risk_number)"
if (( risk_num >= 1 )); then
  run_gate "G11 build" "$SCRIPT_DIR/build.sh"
fi

if (( risk_num >= 2 )); then
  run_gate "G12 targeted tests" "$SCRIPT_DIR/test.sh" targeted
fi

if (( risk_num >= 4 )) || [[ "${QUALITY_REQUIRE_FULL_TESTS:-0}" == "1" ]] || [[ "$phase" == "prepr" && $risk_num -ge 3 ]]; then
  run_gate "G13 full tests" "$SCRIPT_DIR/test.sh" full
fi

if q_has_trigger CONCURRENCY; then
  if [[ -n "${QUALITY_TSAN_TEST_COMMAND:-}" ]]; then
    echo "== G14/G15 TSan =="
    bash -lc "$QUALITY_TSAN_TEST_COMMAND"
    rc=$?
    (( rc == 0 )) || failures=$((failures + 1))
    echo
  else
    q_review "CONCURRENCY trigger active but no automated TSan command configured. Manual/explicit concurrency verification is still required."
    reviews=$((reviews + 1))
  fi
fi

if q_has_trigger MEMORY && [[ -n "${QUALITY_ASAN_TEST_COMMAND:-}" ]]; then
  echo "== G15 ASan =="
  bash -lc "$QUALITY_ASAN_TEST_COMMAND"
  rc=$?
  (( rc == 0 )) || failures=$((failures + 1))
  echo
fi

printf 'Summary: failures=%d review_required=%d\n' "$failures" "$reviews"

if (( failures > 0 )); then
  q_fail "Quality gate FAILED."
  exit 1
fi
if (( reviews > 0 )); then
  q_review "Quality gate requires explicit review/justification before completion."
  exit 3
fi
q_pass "Automatable quality gates passed. Complete any non-automatable specialist gates from GATE_MATRIX.md."
