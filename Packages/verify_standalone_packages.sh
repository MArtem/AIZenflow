#!/bin/sh
set -eu

packages_dir="$(cd "$(dirname "$0")" && pwd)"
root_dir="$(cd "$packages_dir/.." && pwd)"
build_root="$root_dir/.build/standalone-packages"

packages="
AppCache
AppWidgetSupport
AppConfiguration
AppPushNotifications
AppNavigation
AppAppleAuthentication
AppShareExtensionSupport
AppOnDeviceAI
AppLocalization
AppBranding
AppSync
AppNetworking
AppDatabase
AppErrors
AppAnalytics
TchopProductLocalizationResources
"

for package in $packages; do
  echo "=== $package ==="
  swift test \
    --package-path "$packages_dir/$package" \
    --build-path "$build_root/$package"
done
