#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGE_NAME="$(basename "$PACKAGE_DIR")"
WORKTREE_DIR="$(cd "$PACKAGE_DIR/.." && pwd)"
SCRATCH_ROOT="$WORKTREE_DIR/WorktreeScratch/$PACKAGE_NAME"

fail() {
  echo "error: $1" >&2
  exit 1
}

[[ "$PACKAGE_NAME" == "AppImagePipeline" ]] || fail "Package folder must be AppImagePipeline"
[[ -f "$PACKAGE_DIR/Package.swift" ]] || fail "Package.swift missing"
[[ -f "$PACKAGE_DIR/README.md" ]] || fail "README.md missing"
[[ -f "$PACKAGE_DIR/PackageContract.md" ]] || fail "PackageContract.md missing"
[[ -d "$PACKAGE_DIR/Sources/AppImagePipeline" ]] || fail "Sources/AppImagePipeline missing"
[[ -d "$PACKAGE_DIR/Sources/AppImagePipeline/Documentation.docc" ]] || fail "source-owned Documentation.docc missing"
[[ -d "$PACKAGE_DIR/Tests/AppImagePipelineTests" ]] || fail "Tests/AppImagePipelineTests missing"

if grep -R '\.package(path:[[:space:]]*"\.\./' "$PACKAGE_DIR/Package.swift" "$PACKAGE_DIR/Sources" "$PACKAGE_DIR/Tests" >/dev/null 2>&1; then
  fail "sibling path dependency found"
fi

if grep -R 'import App\|import Tchop' "$PACKAGE_DIR/Sources" "$PACKAGE_DIR/Tests" | grep -v 'import AppImagePipeline' >/dev/null 2>&1; then
  fail "sibling package import found"
fi

if grep -R --exclude='verify_package.sh' 'TODO_PACKAGE\|__PACKAGE__\|<Package>\|PLACEHOLDER' "$PACKAGE_DIR" >/dev/null 2>&1; then
  fail "unresolved placeholder found"
fi

if grep -R --exclude='verify_package.sh' 'String(describing:[[:space:]]*error)\|localizedDescription\|@unchecked Sendable\|stablePrivacyHash' "$PACKAGE_DIR/Sources" >/dev/null 2>&1; then
  fail "forbidden privacy/concurrency pattern found in Sources"
fi

if find "$PACKAGE_DIR" \( -name '.build' -o -name '.swiftpm' -o -name 'Package.resolved' -o -name '.DS_Store' -o -name '__MACOSX' \) | grep . >/dev/null 2>&1; then
  fail "forbidden generated/archive artifact found inside package"
fi

rm -rf "$SCRATCH_ROOT"
mkdir -p "$SCRATCH_ROOT"
trap 'rm -rf "$SCRATCH_ROOT"' EXIT

cd "$PACKAGE_DIR"

run_and_check() {
  local log_file="$1"
  shift
  "$@" 2>&1 | tee "$log_file"
  if grep -E '(^|[^A-Za-z])(warning|error):' "$log_file" >/dev/null 2>&1; then
    fail "verification output contains warning/error lines: $log_file"
  fi
}

run_and_check "$SCRATCH_ROOT/test.log" swift test --scratch-path "$SCRATCH_ROOT/test"
run_and_check "$SCRATCH_ROOT/strict-test.log" swift test --scratch-path "$SCRATCH_ROOT/strict-test" -Xswiftc -strict-concurrency=complete

rm -rf "$SCRATCH_ROOT"
trap - EXIT

if find "$PACKAGE_DIR" \( -name '.build' -o -name '.swiftpm' -o -name 'Package.resolved' \) | grep . >/dev/null 2>&1; then
  fail "package-local SwiftPM artifact was created"
fi

echo "AppImagePipeline verification passed with worktree-local scratch path"
