#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGE_NAME="$(basename "${PACKAGE_DIR}")"
WORKTREE_DIR="$(cd "${PACKAGE_DIR}/.." && pwd)"
SCRATCH_ROOT="${WORKTREE_DIR}/WorktreeScratch/${PACKAGE_NAME}"
BUILD_DIR="${SCRATCH_ROOT}/build"
VERIFY_LOG="${SCRATCH_ROOT}/verify.log"

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

[[ "${PACKAGE_NAME}" == "AppInputFormatting" ]] || fail "package folder name must be AppInputFormatting"
[[ -f "${PACKAGE_DIR}/Package.swift" ]] || fail "Package.swift missing"
[[ -f "${PACKAGE_DIR}/README.md" ]] || fail "README.md missing"
[[ -f "${PACKAGE_DIR}/PackageContract.md" ]] || fail "PackageContract.md missing"
[[ -d "${PACKAGE_DIR}/Sources/AppInputFormatting" ]] || fail "Sources/AppInputFormatting missing"
[[ -d "${PACKAGE_DIR}/Tests/AppInputFormattingTests" ]] || fail "Tests/AppInputFormattingTests missing"
[[ -f "${PACKAGE_DIR}/Sources/AppInputFormatting/Documentation.docc/AppInputFormatting.md" ]] || fail "source-owned DocC missing"
[[ -x "${PACKAGE_DIR}/Scripts/verify_package.sh" ]] || fail "verify_package.sh must be executable"

grep -q 'name: "AppInputFormatting"' "${PACKAGE_DIR}/Package.swift" || fail "package name mismatch"
grep -q 'name: "AppInputFormatting"' "${PACKAGE_DIR}/Package.swift" || fail "target name missing"
grep -q 'name: "AppInputFormattingTests"' "${PACKAGE_DIR}/Package.swift" || fail "test target name missing"

if grep -R --line-number --fixed-strings '.package(path:' "${PACKAGE_DIR}/Package.swift" >/dev/null; then
  fail "sibling path dependency found"
fi
if grep -R --line-number --fixed-strings '.package(url:' "${PACKAGE_DIR}/Package.swift" >/dev/null; then
  fail "remote package dependency found"
fi
if grep -R --line-number -E '^import App[A-Za-z0-9_]+' "${PACKAGE_DIR}/Sources/AppInputFormatting" | grep -v 'import AppInputFormatting' >/dev/null; then
  fail "sibling SDK import found"
fi

if find "${PACKAGE_DIR}" \( -name '.build' -o -name '.swiftpm' -o -name 'Package.resolved' -o -name '.DS_Store' -o -name '__MACOSX' -o -name 'xcuserdata' \) | grep -q .; then
  fail "package-local generated artifact found"
fi

if grep -R --line-number -E 'TODO|FIXME|PLACEHOLDER|Tchop|News|Profile|Feed' "${PACKAGE_DIR}/Sources" "${PACKAGE_DIR}/Tests" "${PACKAGE_DIR}/PackageContract.md" >/dev/null; then
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
  if grep -R --line-number -E "${pattern}" "${PACKAGE_DIR}/Sources/AppInputFormatting" >/dev/null; then
    fail "forbidden source pattern found: ${pattern}"
  fi
done

mkdir -p "${BUILD_DIR}"
{
  swift test --package-path "${PACKAGE_DIR}" --scratch-path "${BUILD_DIR}"
  swift test --package-path "${PACKAGE_DIR}" --scratch-path "${BUILD_DIR}" -Xswiftc -strict-concurrency=complete
} 2>&1 | tee "${VERIFY_LOG}"

if grep -E '(^|[^A-Za-z])(warning|error):' "${VERIFY_LOG}" >/dev/null; then
  fail "verification emitted warning/error output"
fi

echo "✅ AppInputFormatting verification passed"
