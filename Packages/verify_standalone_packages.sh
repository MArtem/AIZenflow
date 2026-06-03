#!/bin/sh
set -eu

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
  (cd "$(dirname "$0")/$package" && swift test)
done
