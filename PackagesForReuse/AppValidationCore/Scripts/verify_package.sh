#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGE_NAME="$(basename "${PACKAGE_DIR}")"
WORKTREE_DIR="$(cd "${PACKAGE_DIR}/.." && pwd)"
SCRATCH_PARENT="${WORKTREE_DIR}/WorktreeScratch/${PACKAGE_NAME}"
SCRATCH_ROOT=""

fail() {
  echo "❌ $1" >&2
  exit 1
}

cleanup() {
  # Remove only the unique directory created by this invocation.
  if [[ -n "${SCRATCH_ROOT}" ]]; then
    rm -rf "${SCRATCH_ROOT}"
  fi
}
trap cleanup EXIT

[[ "${PACKAGE_NAME}" == "AppValidationCore" ]] || fail "package folder name must be AppValidationCore"
[[ -f "${PACKAGE_DIR}/Package.swift" ]] || fail "Package.swift missing"
[[ -f "${PACKAGE_DIR}/README.md" ]] || fail "README.md missing"
[[ -f "${PACKAGE_DIR}/PackageContract.md" ]] || fail "PackageContract.md missing"
[[ -d "${PACKAGE_DIR}/Sources/AppValidationCore" ]] || fail "Sources/AppValidationCore missing"
[[ -d "${PACKAGE_DIR}/Tests/AppValidationCoreTests" ]] || fail "Tests/AppValidationCoreTests missing"
[[ -f "${PACKAGE_DIR}/Sources/AppValidationCore/Documentation.docc/AppValidationCore.md" ]] || fail "source-owned DocC missing"
[[ -x "${PACKAGE_DIR}/Scripts/verify_package.sh" ]] || fail "verify_package.sh must be executable"

grep -q 'name: "AppValidationCore"' "${PACKAGE_DIR}/Package.swift" || fail "package name mismatch"
grep -q 'name: "AppValidationCore"' "${PACKAGE_DIR}/Package.swift" || fail "target name missing"
grep -q 'name: "AppValidationCoreTests"' "${PACKAGE_DIR}/Package.swift" || fail "test target name missing"

if grep -R --line-number --fixed-strings '.package(path:' "${PACKAGE_DIR}/Package.swift" >/dev/null; then
  fail "sibling path dependency found"
fi
if grep -R --line-number --fixed-strings '.package(url:' "${PACKAGE_DIR}/Package.swift" >/dev/null; then
  fail "remote package dependency found"
fi
if grep -R --line-number -E '^import App[A-Za-z0-9_]+' "${PACKAGE_DIR}/Sources/AppValidationCore" | grep -v 'import AppValidationCore' >/dev/null; then
  fail "sibling SDK import found"
fi

reject_generated_artifacts() {
  local found
  found="$(find "${PACKAGE_DIR}" \( -name '.build' -o -name '.swiftpm' -o -name 'Package.resolved' -o -name '.DS_Store' -o -name '__MACOSX' -o -name 'xcuserdata' \) -print)" || fail "unable to inspect package artifacts"
  [[ -z "${found}" ]] || fail "$1"
}
reject_generated_artifacts "package-local generated artifact found"

reject_pattern() {
  local pattern="$1"
  local message="$2"
  shift 2
  local status=0
  grep -R --line-number -E "${pattern}" "$@" >/dev/null || status=$?
  case "${status}" in
    0) fail "${message}" ;;
    1) return 0 ;;
    *) fail "unable to inspect package content: ${message}" ;;
  esac
}

reject_pattern 'TODO|FIXME|PLACEHOLDER' "unresolved placeholder found" \
  "${PACKAGE_DIR}/Sources" "${PACKAGE_DIR}/Tests" "${PACKAGE_DIR}/README.md" "${PACKAGE_DIR}/PackageContract.md"
# Consuming-app names are valid README integration context, not package behavior.
reject_pattern 'Tchop|News|Profile|Feed' "app-specific package wording found" \
  "${PACKAGE_DIR}/Sources" "${PACKAGE_DIR}/Tests" "${PACKAGE_DIR}/PackageContract.md"

for pattern in \
  'String\(describing:[[:space:]]*error\)' \
  'localizedDescription' \
  '@unchecked[[:space:]]+Sendable' \
  'stablePrivacyHash' \
  'bodyText' \
  'HTTP body' \
  'headers' \
  'Authorization' \
  'Cookie' \
  'token' \
  'password' \
  'secret' \
  'try[[:space:]]*\?'
do
  reject_pattern "${pattern}" "forbidden source pattern found: ${pattern}" "${PACKAGE_DIR}/Sources/AppValidationCore"
done

[[ ! -L "${WORKTREE_DIR}/WorktreeScratch" && ! -L "${SCRATCH_PARENT}" ]] || fail "scratch directories must not be symlinks"
mkdir -p "${SCRATCH_PARENT}"
SCRATCH_ROOT="$(mktemp -d "${SCRATCH_PARENT}/verify.XXXXXXXX")"
BUILD_DIR="${SCRATCH_ROOT}/build"
LOG_DIR="${SCRATCH_ROOT}/logs"
mkdir -p "${BUILD_DIR}" "${LOG_DIR}" "${SCRATCH_ROOT}/tmp" "${SCRATCH_ROOT}/module-cache"
export TMPDIR="${SCRATCH_ROOT}/tmp"
export CLANG_MODULE_CACHE_PATH="${SCRATCH_ROOT}/module-cache"
export SWIFT_MODULECACHE_PATH="${SCRATCH_ROOT}/module-cache"

run_swift_test() {
  local name="$1"
  shift
  local log_file="${LOG_DIR}/${name}.log"
  if ! swift test --package-path "${PACKAGE_DIR}" --scratch-path "${BUILD_DIR}" \
    --cache-path "${SCRATCH_ROOT}/cache" --config-path "${SCRATCH_ROOT}/config" \
    --security-path "${SCRATCH_ROOT}/security" --manifest-cache none \
    --disable-keychain --disable-netrc --disable-index-store "$@" 2>&1 | tee "${log_file}"; then
    fail "swift test failed during ${name}"
  fi
  reject_pattern '(^|[[:space:]])(warning|error):' "swift test emitted warning/error output during ${name}" "${log_file}"
}

run_swift_test standard
run_swift_test strict -Xswiftc -strict-concurrency=complete

reject_generated_artifacts "verification left package-local generated artifact"

echo "✅ AppValidationCore verification passed"
