#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGE_NAME="$(basename "${PACKAGE_DIR}")"
WORKTREE_DIR="$(cd "${PACKAGE_DIR}/.." && pwd)"
SCRATCH_ROOT="${WORKTREE_DIR}/WorktreeScratch/${PACKAGE_NAME}"
BUILD_DIR="${SCRATCH_ROOT}/build"
LOG_DIR="${SCRATCH_ROOT}/logs"

fail() {
  echo "❌ $1" >&2
  exit 1
}

cleanup() {
  rm -rf "${SCRATCH_ROOT}"
  rm -rf "${PACKAGE_DIR}/.build" "${PACKAGE_DIR}/.swiftpm" "${PACKAGE_DIR}/Package.resolved"
  find "${PACKAGE_DIR}" -name ".DS_Store" -delete
  find "${PACKAGE_DIR}" -name "__MACOSX" -type d -prune -exec rm -rf {} + 2>/dev/null || true
  find "${PACKAGE_DIR}" -name "xcuserdata" -type d -prune -exec rm -rf {} + 2>/dev/null || true
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

if find "${PACKAGE_DIR}" \( -name '.build' -o -name '.swiftpm' -o -name 'Package.resolved' -o -name '.DS_Store' -o -name '__MACOSX' -o -name 'xcuserdata' \) | grep -q .; then
  fail "package-local generated artifact found"
fi

if grep -R --line-number -E 'TODO|FIXME|PLACEHOLDER|Tchop|News|Profile|Feed' "${PACKAGE_DIR}/Sources" "${PACKAGE_DIR}/Tests" "${PACKAGE_DIR}/README.md" "${PACKAGE_DIR}/PackageContract.md" >/dev/null; then
  fail "unresolved placeholder or app-specific wording found"
fi

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
  if grep -R --line-number -E "${pattern}" "${PACKAGE_DIR}/Sources/AppValidationCore" >/dev/null; then
    fail "forbidden source pattern found: ${pattern}"
  fi
done

rm -rf "${SCRATCH_ROOT}"
mkdir -p "${BUILD_DIR}" "${LOG_DIR}"

run_swift_test() {
  local name="$1"
  shift
  local log_file="${LOG_DIR}/${name}.log"
  if ! swift test --package-path "${PACKAGE_DIR}" --scratch-path "${BUILD_DIR}" "$@" 2>&1 | tee "${log_file}"; then
    fail "swift test failed during ${name}"
  fi
  if grep -E '(^|[[:space:]])(warning|error):' "${log_file}" >/dev/null; then
    fail "swift test emitted warning/error output during ${name}"
  fi
}

run_swift_test standard
run_swift_test strict -Xswiftc -strict-concurrency=complete

if find "${PACKAGE_DIR}" \( -name '.build' -o -name '.swiftpm' -o -name 'Package.resolved' -o -name '.DS_Store' -o -name '__MACOSX' -o -name 'xcuserdata' \) | grep -q .; then
  fail "verification left package-local generated artifact"
fi

echo "✅ AppValidationCore verification passed"
