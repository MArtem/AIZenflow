#!/bin/sh
set -eu

packages_dir="$(cd "$(dirname "$0")" && pwd)"

cleanup_generated_package_state() {
  find "$packages_dir" -name .swiftpm -type d -prune -exec rm -rf {} +
}

cleanup_generated_package_state
trap cleanup_generated_package_state EXIT
root_dir="$(cd "$packages_dir/.." && pwd)"
build_root="$root_dir/.build/apple-packages"

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
AppSync
"

for package in $packages; do
  echo "=== $package ==="
  swift test \
    --package-path "$packages_dir/$package" \
    --build-path "$build_root/$package"
done
