#!/bin/sh
set -eu

packages_dir="$(cd "$(dirname "$0")" && pwd)"

cleanup_generated_package_state() {
  find "$packages_dir" -name .swiftpm -type d -prune -exec rm -rf {} +
}

cleanup_generated_package_state
trap cleanup_generated_package_state EXIT
worktrees_root="$(cd "$packages_dir/../.." && pwd)"
cache_root="${TCHOP_PACKAGE_BUILD_CACHE:-$worktrees_root/.package-build-cache/TchopPackageBuilds}"
build_root="$cache_root/apple-packages"

if [ "$(uname)" != "Darwin" ]; then
  echo "Apple platform packages require macOS/Xcode. Run this script on macOS." >&2
  exit 1
fi

# Packages that import Apple-only frameworks such as SwiftUI, CoreData, SwiftData,
# AuthenticationServices, UniformTypeIdentifiers, Observation, or FoundationModels.
packages="
AppNavigation
AppAppleAuthentication
AppShareExtensionSupport
AppOnDeviceAI
AppBranding
AppGlassUI
AppDatabase
AppAnalytics
"

for package in $packages; do
  echo "=== $package ==="
  swift test \
    --package-path "$packages_dir/$package" \
    --build-path "$build_root/$package"
done
