#!/bin/sh
set -eu

packages_dir="$(cd "$(dirname "$0")" && pwd)"

cleanup_generated_package_state() {
  find "$packages_dir" -name .swiftpm -type d -prune -exec rm -rf {} +
}

cleanup_generated_package_state
trap cleanup_generated_package_state EXIT
root_dir="$(cd "$packages_dir/.." && pwd)"
build_root="$root_dir/.build/integration-helpers"

# Integration helpers are optional composition packages. They intentionally depend on
# the root packages they compose, but root packages never depend on helpers.
portable_helpers="
AppAnalyticsNetworkingIntegration
AppAnalyticsPushNotificationsIntegration
AppErrorsNetworkingIntegration
TchopProductLocalizationResourcesAppLocalizationIntegration
"

apple_helpers="
AppAnalyticsNavigationIntegration
"

# Copy-file form must stay byte-equivalent to the package source file so host apps
# can choose either direct source inclusion or helper-package inclusion.
for helper in $portable_helpers $apple_helpers; do
  src="$packages_dir/IntegrationHelpers/$helper/Sources/$helper/$helper.swift"
  copy="$packages_dir/IntegrationHelpers/CopyFiles/$helper.swift"
  if [ ! -f "$src" ] || [ ! -f "$copy" ]; then
    echo "Missing helper source or copy file for $helper" >&2
    exit 1
  fi
  if ! cmp -s "$src" "$copy"; then
    echo "CopyFiles/$helper.swift differs from package source $src" >&2
    exit 1
  fi
  if [ ! -f "$packages_dir/IntegrationHelpers/$helper/PackageContract.md" ]; then
    echo "Integration helper $helper is missing PackageContract.md" >&2
    exit 1
  fi
  if [ ! -d "$packages_dir/IntegrationHelpers/$helper/Sources/$helper/Documentation.docc" ]; then
    echo "Integration helper $helper is missing DocC documentation" >&2
    exit 1
  fi
  echo "✓ helper contract: $helper"
done

for helper in $portable_helpers; do
  echo "=== integration helper: $helper ==="
  swift test \
    --package-path "$packages_dir/IntegrationHelpers/$helper" \
    --build-path "$build_root/$helper"
done

if [ "$(uname)" = "Darwin" ]; then
  for helper in $apple_helpers; do
    echo "=== Apple integration helper: $helper ==="
    swift test \
      --package-path "$packages_dir/IntegrationHelpers/$helper" \
      --build-path "$build_root/$helper"
  done
else
  echo "Apple integration helpers skipped because this host is not macOS." >&2
fi
