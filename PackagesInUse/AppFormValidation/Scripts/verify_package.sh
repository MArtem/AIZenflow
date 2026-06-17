#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "❌ $1" >&2
  exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGE_NAME="$(basename "${PACKAGE_DIR}")"
WORKTREE_DIR="$(cd "${PACKAGE_DIR}/.." && pwd)"
SCRATCH_ROOT="${WORKTREE_DIR}/WorktreeScratch/${PACKAGE_NAME}"

cleanup() {
  rm -rf "${SCRATCH_ROOT}"
}
trap cleanup EXIT

[[ "${PACKAGE_NAME}" == "AppFormValidation" ]] || fail "package folder must be AppFormValidation"

[[ -f "${PACKAGE_DIR}/Package.swift" ]] || fail "Package.swift missing"
[[ -f "${PACKAGE_DIR}/README.md" ]] || fail "README.md missing"
[[ -f "${PACKAGE_DIR}/PackageContract.md" ]] || fail "PackageContract.md missing"
[[ -d "${PACKAGE_DIR}/Sources/${PACKAGE_NAME}" ]] || fail "Sources/${PACKAGE_NAME} missing"
[[ -d "${PACKAGE_DIR}/Tests/${PACKAGE_NAME}Tests" ]] || fail "Tests/${PACKAGE_NAME}Tests missing"
[[ -f "${PACKAGE_DIR}/Sources/${PACKAGE_NAME}/Documentation.docc/${PACKAGE_NAME}.md" ]] || fail "source-owned DocC missing"
[[ -x "${PACKAGE_DIR}/Scripts/verify_package.sh" ]] || fail "verify_package.sh must be executable"

if ! grep -q "name: \"${PACKAGE_NAME}\"" "${PACKAGE_DIR}/Package.swift"; then
  fail "package name must match folder name"
fi

if ! grep -q "name: \"${PACKAGE_NAME}\"" "${PACKAGE_DIR}/Package.swift"; then
  fail "target name must match package name"
fi

if grep -R "\.package(path:" "${PACKAGE_DIR}/Package.swift" >/dev/null; then
  fail "sibling path dependencies are forbidden"
fi

if grep -R "\.package(url:" "${PACKAGE_DIR}/Package.swift" >/dev/null; then
  fail "remote dependencies are forbidden"
fi

if grep -R "^import App" "${PACKAGE_DIR}/Sources/${PACKAGE_NAME}" --include='*.swift' | grep -v "import ${PACKAGE_NAME}" >/dev/null; then
  fail "sibling SDK imports are forbidden"
fi

if find "${PACKAGE_DIR}" \( -name ".build" -o -name ".swiftpm" -o -name "Package.resolved" -o -name ".DS_Store" -o -name "__MACOSX" -o -name "xcuserdata" \) | grep . >/dev/null; then
  fail "package-local build or archive artifacts found"
fi

if find "${PACKAGE_DIR}" -type f \( -name "*.swift" -o -name "*.md" -o -name "Package.swift" \) -not -path "${PACKAGE_DIR}/Scripts/verify_package.sh" -print0 | xargs -0 grep -E "TODO|FIXME|TBD|<#[^[:space:]]*" >/dev/null; then
  fail "unresolved placeholders found"
fi

if grep -R -E "String\(describing:[[:space:]]*error\)|localizedDescription|@unchecked[[:space:]]+Sendable|stablePrivacyHash|bodyText|HTTP body|raw headers|Authorization|Cookie|password|secret|silent try\?|try\?" "${PACKAGE_DIR}/Sources/${PACKAGE_NAME}" --include='*.swift' >/dev/null; then
  fail "forbidden privacy, security, or concurrency pattern found in Sources"
fi

rm -rf "${SCRATCH_ROOT}"
mkdir -p "${SCRATCH_ROOT}/logs"

run_swift_test() {
  local name="$1"
  shift
  local log_file="${SCRATCH_ROOT}/logs/${name}.log"
  if ! swift test --package-path "${PACKAGE_DIR}" --scratch-path "${SCRATCH_ROOT}/build" "$@" 2>&1 | tee "${log_file}"; then
    fail "swift test failed during ${name}"
  fi
  if grep -E "(^|[[:space:]])(warning|error):" "${log_file}" >/dev/null; then
    fail "swift test emitted warning/error output during ${name}"
  fi
}

run_swift_test strict -Xswiftc -strict-concurrency=complete
run_swift_test standard

if find "${PACKAGE_DIR}" \( -name ".build" -o -name ".swiftpm" -o -name "Package.resolved" -o -name ".DS_Store" -o -name "__MACOSX" -o -name "xcuserdata" \) | grep . >/dev/null; then
  fail "verification left package-local artifacts"
fi

echo "✅ AppFormValidation verification passed"
