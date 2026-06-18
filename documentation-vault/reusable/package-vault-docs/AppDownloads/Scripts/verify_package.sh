#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "❌ $*" >&2
  exit 1
}

note() {
  echo "• $*"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGE_NAME="$(basename "${PACKAGE_DIR}")"
WORKTREE_DIR="$(cd "${PACKAGE_DIR}/.." && pwd)"
SCRATCH_ROOT="${WORKTREE_DIR}/WorktreeScratch/${PACKAGE_NAME}"
SCRATCH_PACKAGE="${SCRATCH_ROOT}/${PACKAGE_NAME}"

cleanup() {
  rm -rf "${SCRATCH_ROOT}"
}
trap cleanup EXIT

assert_exists() {
  [[ -e "${PACKAGE_DIR}/$1" ]] || fail "Missing required path: $1"
}

assert_file() {
  [[ -f "${PACKAGE_DIR}/$1" ]] || fail "Missing required file: $1"
}

assert_directory() {
  [[ -d "${PACKAGE_DIR}/$1" ]] || fail "Missing required directory: $1"
}

assert_no_matches() {
  local description="$1"
  local pattern="$2"
  local path="$3"
  if grep -R -n -E "${pattern}" "${path}" >/dev/null 2>&1; then
    grep -R -n -E "${pattern}" "${path}" >&2 || true
    fail "Forbidden content found: ${description}"
  fi
}

assert_no_fixed_string() {
  local description="$1"
  local needle="$2"
  local path="$3"
  if grep -R -n -F "${needle}" "${path}" >/dev/null 2>&1; then
    grep -R -n -F "${needle}" "${path}" >&2 || true
    fail "Forbidden content found: ${description}"
  fi
}

note "Checking required structure"
assert_file "Package.swift"
assert_file "README.md"
assert_file "PackageContract.md"
assert_directory "Sources/${PACKAGE_NAME}"
assert_directory "Tests/${PACKAGE_NAME}Tests"
assert_file "Sources/${PACKAGE_NAME}/Documentation.docc/${PACKAGE_NAME}.md"
assert_file "Scripts/verify_package.sh"
[[ -x "${PACKAGE_DIR}/Scripts/verify_package.sh" ]] || fail "Scripts/verify_package.sh must be executable"

note "Checking package and target identity"
grep -q "name:[[:space:]]*\"${PACKAGE_NAME}\"" "${PACKAGE_DIR}/Package.swift" || fail "Package.swift name must match folder name"
grep -q "\.target(" "${PACKAGE_DIR}/Package.swift" || fail "Package.swift must declare a target"
grep -q "name:[[:space:]]*\"${PACKAGE_NAME}\"" "${PACKAGE_DIR}/Package.swift" || fail "Main target must match package name"
grep -q "name:[[:space:]]*\"${PACKAGE_NAME}Tests\"" "${PACKAGE_DIR}/Package.swift" || fail "Test target must be ${PACKAGE_NAME}Tests"

note "Checking DocC ownership"
if find "${PACKAGE_DIR}" -maxdepth 1 -name "*.docc" -print -quit | grep -q .; then
  fail "Root-level DocC bundle is not allowed"
fi

note "Checking standalone dependency rules"
assert_no_matches "sibling path dependencies" "\.package[[:space:]]*\([[:space:]]*path[[:space:]]*:" "${PACKAGE_DIR}/Package.swift"
assert_no_matches "remote package dependencies" "\.package[[:space:]]*\([[:space:]]*url[[:space:]]*:" "${PACKAGE_DIR}/Package.swift"
assert_no_matches "sibling SDK imports in sources" "^import[[:space:]]+App(SecureStorage|Session|FeatureFlags|Logging|Observability|Connectivity|Permissions|Environment|DeviceInfo|Lifecycle|BackgroundTasks|FileStorage|ImagePipeline|Uploads|RemoteAssets|TaskQueue|RateLimiter|StateMachine|Pagination|FormValidation|ValidationCore|InputFormatting|DateTime|NumberFormatting|Haptics|AccessibilitySupport|ReviewPrompt|EmptyStateKit|Onboarding|URLSafety|DeepLinking|InAppBrowser|Clipboard|Privacy|Consent|ABTesting|Crypto|Diagnostics|Performance|CrashReportingCore|Search|SortingFiltering|Markdown|HTMLText|MediaPicker|DocumentPicker|QRBarcode|CoordinatorSupport)" "${PACKAGE_DIR}/Sources"

note "Checking verifier scratch-path constraints"
slash_tmp="/""tmp"
tmp_dir_word="TMP""DIR"
assert_no_fixed_string "script must not use disallowed system scratch literal" "${slash_tmp}" "${PACKAGE_DIR}/Scripts/verify_package.sh"
assert_no_fixed_string "script must not use disallowed scratch environment name" "${tmp_dir_word}" "${PACKAGE_DIR}/Scripts/verify_package.sh"
grep -q "WorktreeScratch" "${PACKAGE_DIR}/Scripts/verify_package.sh" || fail "Verifier must use worktree-local scratch path"

note "Checking package-local build/archive artifacts"
if find "${PACKAGE_DIR}" \( -name ".build" -o -name ".swiftpm" -o -name "Package.resolved" -o -name ".DS_Store" -o -name "__MACOSX" -o -name "xcuserdata" -o -name "*.zip" \) -print -quit | grep -q .; then
  find "${PACKAGE_DIR}" \( -name ".build" -o -name ".swiftpm" -o -name "Package.resolved" -o -name ".DS_Store" -o -name "__MACOSX" -o -name "xcuserdata" -o -name "*.zip" \) >&2
  fail "Package contains build/archive artifacts"
fi

note "Checking unresolved placeholders"
placeholder_pattern="(<#|#>|TO""DO|FIX""ME|YOUR_|REPLACE_ME|PLACEHOLDER)"
if find "${PACKAGE_DIR}" -type f ! -path "${PACKAGE_DIR}/Scripts/verify_package.sh" -print0 | xargs -0 grep -n -E "${placeholder_pattern}" >/dev/null 2>&1; then
  find "${PACKAGE_DIR}" -type f ! -path "${PACKAGE_DIR}/Scripts/verify_package.sh" -print0 | xargs -0 grep -n -E "${placeholder_pattern}" >&2 || true
  fail "Forbidden content found: unresolved placeholder markers"
fi

note "Checking forbidden source patterns"
SOURCE_DIR="${PACKAGE_DIR}/Sources/${PACKAGE_NAME}"
for needle in \
  "String(describing: error)" \
  "localizedDescription" \
  "@unchecked Sendable" \
  "stablePrivacyHash" \
  "raw telemetry" \
  "raw bodyText" \
  "raw HTTP body" \
  "raw headers" \
  "Authorization" \
  "Cookie" \
  "raw token" \
  "password" \
  "secret" \
  "silent try?" \
  "silent security fallback"
do
  assert_no_fixed_string "${needle}" "${needle}" "${SOURCE_DIR}"
done

note "Preparing worktree-local verification copy"
cleanup
mkdir -p "${SCRATCH_ROOT}"
cp -R "${PACKAGE_DIR}" "${SCRATCH_ROOT}/"

note "Running swift test"
run_and_check() {
  local log_file="$1"
  shift
  "$@" 2>&1 | tee "${log_file}"
  if grep -E '(^|[^A-Za-z])(warning|error):' "${log_file}" >/dev/null 2>&1; then
    fail "Verification output contains warning/error lines: ${log_file}"
  fi
}

(
  cd "${SCRATCH_PACKAGE}"
  run_and_check "${SCRATCH_ROOT}/test.log" swift test
)

note "Running strict concurrency swift test"
(
  cd "${SCRATCH_PACKAGE}"
  run_and_check "${SCRATCH_ROOT}/strict-test.log" swift test -Xswiftc -strict-concurrency=complete
)

note "Ensuring package folder stayed clean"
if find "${PACKAGE_DIR}" \( -name ".build" -o -name ".swiftpm" -o -name "Package.resolved" -o -name ".DS_Store" -o -name "__MACOSX" -o -name "xcuserdata" \) -print -quit | grep -q .; then
  fail "Verification left package-local artifacts"
fi

echo "✅ ${PACKAGE_NAME} verification passed"
