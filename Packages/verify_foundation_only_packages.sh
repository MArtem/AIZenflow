#!/bin/sh
set -eu

packages_dir="$(cd "$(dirname "$0")" && pwd)"

cleanup_generated_package_state() {
  find "$packages_dir" -name .swiftpm -type d -prune -exec rm -rf {} +
}

cleanup_generated_package_state
trap cleanup_generated_package_state EXIT
cache_root="${TCHOP_PACKAGE_BUILD_CACHE:-$HOME/Library/Caches/TchopPackageBuilds}"
build_root="$cache_root/foundation-only-packages"

# Packages that are expected to build with portable Foundation-only SwiftPM toolchains.
packages="
AppWidgetSupport
AppConfiguration
AppPushNotifications
AppLocalization
AppNetworking
AppErrors
AppAnalytics
TchopProductLocalizationResources
AppOnDeviceAI
"

for package in $packages; do
  echo "=== $package ==="
  swift test \
    --package-path "$packages_dir/$package" \
    --build-path "$build_root/$package"
done
