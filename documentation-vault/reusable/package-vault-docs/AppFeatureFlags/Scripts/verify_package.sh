#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PACKAGE_NAME="$(basename "$PACKAGE_ROOT")"
SCRATCH_BASE="${TMPDIR:-/tmp}/InfrastructureSDKBuild"
SCRATCH_PATH="$SCRATCH_BASE/$PACKAGE_NAME"
VERIFY_LOG="$SCRATCH_BASE/${PACKAGE_NAME}.verify.log"

fail() {
  echo "error: $*" >&2
  exit 1
}

case "$PACKAGE_NAME" in
  App[A-Z]*) ;;
  *) fail "Package name must use AppPascalCase and start with App: $PACKAGE_NAME" ;;
esac

if [[ ! "$PACKAGE_NAME" =~ ^App[A-Za-z0-9]+$ ]]; then
  fail "Package name contains forbidden characters: $PACKAGE_NAME"
fi

[[ -f "$PACKAGE_ROOT/Package.swift" ]] || fail "Missing Package.swift"
[[ -f "$PACKAGE_ROOT/README.md" ]] || fail "Missing README.md"
[[ -f "$PACKAGE_ROOT/PackageContract.md" ]] || fail "Missing PackageContract.md"
[[ -d "$PACKAGE_ROOT/Sources" ]] || fail "Missing Sources/"
[[ -d "$PACKAGE_ROOT/Tests" ]] || fail "Missing Tests/"
[[ -x "$PACKAGE_ROOT/Scripts/verify_package.sh" ]] || fail "Missing executable Scripts/verify_package.sh"

grep -q "name: \"${PACKAGE_NAME}\"" "$PACKAGE_ROOT/Package.swift" || fail "Package.swift name does not match folder name: $PACKAGE_NAME"

if ! find "$PACKAGE_ROOT/Sources" -path "*/Documentation.docc" -type d | grep -q .; then
  fail "Missing source-owned DocC: Sources/<TargetName>/Documentation.docc"
fi

if find "$PACKAGE_ROOT" \( -name '.build' -o -name '.swiftpm' -o -name 'xcuserdata' -o -name '__MACOSX' -o -name '.DS_Store' -o -name 'Package.resolved' \) | grep -q .; then
  fail "Package contains forbidden local/build/archive artifact"
fi

if grep -RInE '__PACKAGE_NAME__|__TARGET_NAME__|__DESCRIPTION__|<PackageName>|<TargetName>|TODO|FIXME|PLACEHOLDER|AppTemplate'   "$PACKAGE_ROOT/Package.swift"   "$PACKAGE_ROOT/README.md"   "$PACKAGE_ROOT/PackageContract.md"   "$PACKAGE_ROOT/Sources"   "$PACKAGE_ROOT/Tests"   "$PACKAGE_ROOT/Docs" 2>/dev/null; then
  fail "Unresolved placeholder or forbidden template marker found"
fi

if grep -RInE '\.package[[:space:]]*\(|path:[[:space:]]*"\.\./|from:[[:space:]]*"|url:[[:space:]]*"' "$PACKAGE_ROOT/Package.swift"; then
  fail "Root package must not declare external or sibling package dependencies"
fi

# Reject sibling module imports in source/tests while allowing Foundation, XCTest and Apple/system modules.
SIBLING_IMPORTS=(
  AppAnalytics AppAppleAuthentication AppBranding AppCache AppConfiguration AppDatabase AppErrors
  AppLocalization AppNavigation AppNetworking AppOnDeviceAI AppPushNotifications AppShareExtensionSupport
  AppSync AppWidgetSupport AppSecureStorage AppSession AppFeatureFlags AppLogging AppObservability
  AppConnectivity AppPermissions AppEnvironment AppDeviceInfo AppLifecycle AppBackgroundTasks AppFileStorage
  AppImagePipeline AppDownloads AppUploads AppRemoteAssets AppTaskQueue AppRateLimiter AppStateMachine
  AppPagination AppFormValidation AppValidationCore AppInputFormatting AppDateTime AppNumberFormatting
  AppHaptics AppAccessibilitySupport AppReviewPrompt AppEmptyStateKit AppOnboarding AppURLSafety AppDeepLinking
  AppInAppBrowser AppClipboard AppPrivacy AppConsent AppABTesting AppCrypto AppDiagnostics AppPerformance
  AppCrashReportingCore AppSearch AppSortingFiltering AppMarkdown AppHTMLText AppMediaPicker AppDocumentPicker
  AppQRBarcode AppCoordinatorSupport
)
for module in "${SIBLING_IMPORTS[@]}"; do
  if [[ "$module" == "$PACKAGE_NAME" ]]; then
    continue
  fi
  if grep -RInE "^[[:space:]]*@testable[[:space:]]+import[[:space:]]+$module\b|^[[:space:]]*import[[:space:]]+$module\b" "$PACKAGE_ROOT/Sources" "$PACKAGE_ROOT/Tests"; then
    fail "Forbidden sibling module import detected: $module"
  fi
done

rm -rf "$SCRATCH_PATH"
mkdir -p "$SCRATCH_BASE"
(
  cd "$PACKAGE_ROOT"
  swift test --scratch-path "$SCRATCH_PATH"
  swift test --scratch-path "$SCRATCH_PATH" -Xswiftc -strict-concurrency=complete
) 2>&1 | tee "$VERIFY_LOG"

if grep -E "warning:|error:" "$VERIFY_LOG" >/dev/null; then
  fail "Package verification emitted compiler warnings/errors"
fi
rm -rf "$SCRATCH_PATH"
rm -f "$VERIFY_LOG"

if find "$PACKAGE_ROOT" \( -name '.build' -o -name '.swiftpm' -o -name "Package.resolved" \) | grep -q .; then
  fail "Verification created package-local SwiftPM artifacts"
fi

echo "$PACKAGE_NAME verification passed with external scratch path"
