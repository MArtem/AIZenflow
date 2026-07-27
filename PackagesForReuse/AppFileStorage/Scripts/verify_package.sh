#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_NAME="$(basename "${PACKAGE_DIR}")"
EXPECTED_NAME="AppFileStorage"
WORKTREE_DIR="$(cd "${PACKAGE_DIR}/.." && pwd)"
SCRATCH_ROOT="${WORKTREE_DIR}/WorktreeScratch/${PACKAGE_NAME}"

fail() {
  echo "error: $1" >&2
  exit 1
}

[ "${PACKAGE_NAME}" = "${EXPECTED_NAME}" ] || fail "package folder name mismatch"
[ -f "${PACKAGE_DIR}/Package.swift" ] || fail "missing Package.swift"
[ -f "${PACKAGE_DIR}/README.md" ] || fail "missing README.md"
[ -f "${PACKAGE_DIR}/PackageContract.md" ] || fail "missing PackageContract.md"
[ -d "${PACKAGE_DIR}/Sources/${EXPECTED_NAME}" ] || fail "missing Sources/${EXPECTED_NAME}"
[ -d "${PACKAGE_DIR}/Sources/${EXPECTED_NAME}/Documentation.docc" ] || fail "missing source-owned Documentation.docc"
[ -d "${PACKAGE_DIR}/Tests" ] || fail "missing Tests"

for forbidden in ".build" ".swiftpm" "xcuserdata" "Package.resolved" ".DS_Store" "__MACOSX"; do
  if find "${PACKAGE_DIR}" -name "${forbidden}" -print -quit | grep -q .; then
    fail "forbidden artifact found: ${forbidden}"
  fi
done

if grep -R "\.package(path: \"\.\." "${PACKAGE_DIR}/Package.swift" "${PACKAGE_DIR}/Sources" "${PACKAGE_DIR}/Tests" >/dev/null 2>&1; then
  fail "sibling path dependency found"
fi

if grep -R "import App" "${PACKAGE_DIR}/Sources" "${PACKAGE_DIR}/Tests" | grep -v "import ${EXPECTED_NAME}" >/dev/null 2>&1; then
  fail "sibling App* import found"
fi

placeholder_a="<""#"
placeholder_b="__""PACKAGE__"
placeholder_c="__""TARGET__"
placeholder_d="TODO""_TEMPLATE"
if grep -R -E "${placeholder_a}|${placeholder_b}|${placeholder_c}|${placeholder_d}" "${PACKAGE_DIR}" >/dev/null 2>&1; then
  fail "unresolved placeholder found"
fi

slash="/"
temp_word="t""mp"
external_phrase="external"" scratch path"
if grep -R -E "${temp_word}|${slash}${temp_word}|${external_phrase}" "${PACKAGE_DIR}" >/dev/null 2>&1; then
  fail "forbidden temporary or scratch wording found"
fi

if grep -R "String(describing: error)\|localizedDescription\|@unchecked Sendable\|stablePrivacyHash" "${PACKAGE_DIR}/Sources" >/dev/null 2>&1; then
  fail "forbidden privacy/concurrency pattern found in Sources"
fi

rm -rf "${SCRATCH_ROOT}"
mkdir -p "${SCRATCH_ROOT}"
export APP_FILE_STORAGE_TEST_BASE="${SCRATCH_ROOT}/test-files"
trap 'rm -rf "${SCRATCH_ROOT}"' EXIT

cd "${PACKAGE_DIR}"
swift test --scratch-path "${SCRATCH_ROOT}/strict-test" -Xswiftc -strict-concurrency=complete

for forbidden in ".build" ".swiftpm" "Package.resolved"; do
  if find "${PACKAGE_DIR}" -maxdepth 2 -name "${forbidden}" -print -quit | grep -q .; then
    fail "verification created package-local artifact: ${forbidden}"
  fi
done

echo "AppFileStorage verification passed with worktree-local scratch path"
