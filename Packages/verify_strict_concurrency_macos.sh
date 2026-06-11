#!/bin/sh
set -eu

# Strict concurrency is intentionally checked by CI/build commands instead of
# public Package.swift unsafeFlags, so the packages remain importable by other
# SwiftPM clients.

packages_dir="$(cd "$(dirname "$0")" && pwd)"

cleanup_generated_package_state() {
  find "$packages_dir" -name .swiftpm -type d -prune -exec rm -rf {} +
}

cleanup_generated_package_state
trap cleanup_generated_package_state EXIT
worktrees_root="$(cd "$packages_dir/../.." && pwd)"
cache_root="${TCHOP_PACKAGE_BUILD_CACHE:-$worktrees_root/.package-build-cache/TchopPackageBuilds}"
build_root="$cache_root/strict-concurrency"

foundation_packages="
AppWidgetSupport
AppConfiguration
AppPushNotifications
AppLocalization
AppNetworking
AppErrors
AppAnalytics
AppOnDeviceAI
TchopProductLocalizationResources
"

# Apple-only packages are included on macOS because they can import frameworks such as
# SwiftUI, CoreData, SwiftData, AuthenticationServices, UniformTypeIdentifiers,
# Observation, or FoundationModels.
apple_packages="
AppNavigation
AppAppleAuthentication
AppShareExtensionSupport
AppBranding
AppGlassUI
AppDatabase
"

portable_helpers="
IntegrationHelpers/AppAnalyticsNetworkingIntegration
IntegrationHelpers/AppAnalyticsPushNotificationsIntegration
"

apple_helpers="
IntegrationHelpers/AppAnalyticsNavigationIntegration
"

run_strict() {
  package_path="$1"
  package_name="$(basename "$package_path")"
  echo "=== strict concurrency: $package_path ==="
  swift test \
    --package-path "$packages_dir/$package_path" \
    --build-path "$build_root/$package_name" \
    -Xswiftc -strict-concurrency=complete
}

for package in $foundation_packages; do
  run_strict "$package"
done

for helper in $portable_helpers; do
  run_strict "$helper"
done

if [ "$(uname)" = "Darwin" ]; then
  for package in $apple_packages; do
    run_strict "$package"
  done
  for helper in $apple_helpers; do
    run_strict "$helper"
  done
else
  echo "Apple-only strict concurrency packages skipped because this host is not macOS." >&2
fi
