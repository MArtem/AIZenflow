#!/usr/bin/env bash

set -u

QUALITY_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUALITY_DIR="$(cd "$QUALITY_SCRIPT_DIR/.." && pwd)"

if git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  QUALITY_REPO_ROOT="$git_root"
else
  QUALITY_REPO_ROOT="$(pwd)"
fi

QUALITY_CONFIG_FILE="${QUALITY_CONFIG_FILE:-$QUALITY_DIR/config/project.env}"
if [[ -f "$QUALITY_CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$QUALITY_CONFIG_FILE"
fi

QUALITY_MODE="${QUALITY_MODE:-STRICT}"
QUALITY_RISK="${QUALITY_RISK:-R2}"
QUALITY_TRIGGERS="${QUALITY_TRIGGERS:-}"
QUALITY_CONFIGURATION="${QUALITY_CONFIGURATION:-Debug}"

q_info() { printf '[INFO] %s\n' "$*"; }
q_pass() { printf '[PASS] %s\n' "$*"; }
q_warn() { printf '[WARN] %s\n' "$*" >&2; }
q_fail() { printf '[FAIL] %s\n' "$*" >&2; }
q_review() { printf '[REVIEW] %s\n' "$*" >&2; }
q_skip() { printf '[SKIP] %s\n' "$*"; }

q_has_trigger() {
  local needle="$1"
  local normalized
  normalized="$(printf '%s' "$QUALITY_TRIGGERS" | tr ',;' '  ')"
  for item in $normalized; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

q_risk_number() {
  case "$QUALITY_RISK" in
    R0) echo 0 ;;
    R1) echo 1 ;;
    R2) echo 2 ;;
    R3) echo 3 ;;
    R4) echo 4 ;;
    R5) echo 5 ;;
    *) echo 99 ;;
  esac
}

q_diff_base() {
  if git -C "$QUALITY_REPO_ROOT" rev-parse --verify HEAD >/dev/null 2>&1; then
    printf 'HEAD'
  else
    printf ''
  fi
}

q_changed_files() {
  local base
  base="$(q_diff_base)"
  if [[ -n "$base" ]]; then
    git -C "$QUALITY_REPO_ROOT" diff --name-only "$base" --
  else
    git -C "$QUALITY_REPO_ROOT" ls-files --others --exclude-standard
  fi
}

q_added_lines() {
  local base
  base="$(q_diff_base)"
  if [[ -n "$base" ]]; then
    git -C "$QUALITY_REPO_ROOT" diff --unified=0 "$base" -- \
      | grep '^+' \
      | grep -v '^+++' || true
  else
    return 0
  fi
}

q_xcode_container_args() {
  if [[ -n "${QUALITY_WORKSPACE:-}" ]]; then
    printf '%s\n' "-workspace" "$QUALITY_WORKSPACE"
  elif [[ -n "${QUALITY_PROJECT:-}" ]]; then
    printf '%s\n' "-project" "$QUALITY_PROJECT"
  else
    return 1
  fi
}

q_require_xcode_profile() {
  if [[ -z "${QUALITY_SCHEME:-}" ]]; then
    q_fail "QUALITY_SCHEME is not configured. Run discover_project.sh and fill config/project.env."
    return 1
  fi
  if [[ -z "${QUALITY_WORKSPACE:-}" && -z "${QUALITY_PROJECT:-}" ]]; then
    q_fail "Neither QUALITY_WORKSPACE nor QUALITY_PROJECT is configured."
    return 1
  fi
}
