#!/bin/sh
set -eu

packages_dir="$(cd "$(dirname "$0")" && pwd)"

cleanup_generated_package_state() {
  find "$packages_dir" -name .swiftpm -type d -prune -exec rm -rf {} +
}

cleanup_generated_package_state
trap cleanup_generated_package_state EXIT
root_dir="$(cd "$packages_dir/.." && pwd)"
build_root="$root_dir/.build/foundation-only-packages"

# Packages that are expected to build with portable Foundation-only SwiftPM toolchains.
packages="
AppCache
AppWidgetSupport
AppConfiguration
AppPushNotifications
AppLocalization
AppNetworking
AppErrors
AppAnalytics
TchopProductLocalizationResources
AppOnDeviceAI
AppSecureStorage
"

for package in $packages; do
  echo "=== $package ==="
  swift test \
    --package-path "$packages_dir/$package" \
    --build-path "$build_root/$package"
done
