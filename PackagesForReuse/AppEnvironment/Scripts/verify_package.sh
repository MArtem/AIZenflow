#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME="AppEnvironment"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKTREES_ROOT="$(cd "${ROOT_DIR}/../../.." && pwd)"
SCRATCH_ROOT="${APP_PACKAGE_BUILD_CACHE:-${WORKTREES_ROOT}/.package-build-cache/InfrastructureSDKBuild}"
SCRATCH_PATH="${SCRATCH_ROOT}/${PACKAGE_NAME}"
STRICT_SCRATCH_PATH="${SCRATCH_ROOT}/${PACKAGE_NAME}_strict"

fail() {
  echo "error: $1" >&2
  exit 1
}

cd "$ROOT_DIR"

[[ "$(basename "$ROOT_DIR")" == "$PACKAGE_NAME" ]] || fail "package folder name must be ${PACKAGE_NAME}"
[[ -f Package.swift ]] || fail "Package.swift is missing"
[[ -f README.md ]] || fail "README.md is missing"
[[ -f PackageContract.md ]] || fail "PackageContract.md is missing"
[[ -d Sources/${PACKAGE_NAME} ]] || fail "Sources/${PACKAGE_NAME} is missing"
[[ -d Tests/${PACKAGE_NAME}Tests ]] || fail "Tests/${PACKAGE_NAME}Tests is missing"
[[ -d Sources/${PACKAGE_NAME}/Documentation.docc ]] || fail "source-owned DocC is missing: Sources/${PACKAGE_NAME}/Documentation.docc"
[[ -f Sources/${PACKAGE_NAME}/Documentation.docc/${PACKAGE_NAME}.md ]] || fail "DocC overview is missing"

if grep -R "\.package(path: *\"\.\./" -n Package.swift Sources Tests 2>/dev/null; then
  fail "sibling path dependency is forbidden"
fi

FORBIDDEN_IMPORTS=(
  AppNetworking AppErrors AppAnalytics AppNavigation AppSession AppSecureStorage
  AppFeatureFlags AppLogging AppObservability AppConnectivity AppPermissions
)
for module in "${FORBIDDEN_IMPORTS[@]}"; do
  if [[ "$module" != "$PACKAGE_NAME" ]]; then
    if grep -R "^import ${module}$" -n Sources Tests 2>/dev/null; then
      fail "forbidden sibling import: ${module}"
    fi
  fi
done

if find . \( -name .build -o -name .swiftpm -o -name xcuserdata -o -name Package.resolved -o -name .DS_Store -o -name __MACOSX \) -print | grep -q .; then
  fail "package-local build/archive artifacts are forbidden"
fi

if grep -R "<#\|TODO_PLACEHOLDER\|MODULE_NAME\|APP_SPECIFIC\|TCHOP_SPECIFIC" -n Sources Tests Package.swift README.md PackageContract.md Docs 2>/dev/null; then
  fail "unresolved template placeholder found"
fi

if grep -R "String(describing: *error)\|localizedDescription\|@unchecked Sendable\|stablePrivacyHash\|raw telemetry\|bodyText\|Authorization\|Cookie" -n Sources Tests Package.swift README.md PackageContract.md Docs 2>/dev/null; then
  fail "forbidden source/privacy/concurrency pattern found"
fi

mkdir -p "$SCRATCH_ROOT"
rm -rf "$SCRATCH_PATH"

swift test --jobs 1 --scratch-path "$SCRATCH_PATH"
rm -rf "$SCRATCH_PATH"
rm -rf "$STRICT_SCRATCH_PATH"

swift build --jobs 1 --scratch-path "$STRICT_SCRATCH_PATH" -Xswiftc -strict-concurrency=complete
rm -rf "$STRICT_SCRATCH_PATH"

if find . \( -name .build -o -name .swiftpm -o -name Package.resolved \) -print | grep -q .; then
  fail "verification created package-local SwiftPM artifacts"
fi

echo "${PACKAGE_NAME} verification passed with worktree-local scratch path"
