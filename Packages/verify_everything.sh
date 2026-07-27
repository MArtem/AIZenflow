#!/bin/sh
set -eu

packages_dir="$(cd "$(dirname "$0")" && pwd)"

cleanup_generated_package_state() {
  find "$packages_dir" -name .swiftpm -type d -prune -exec rm -rf {} +
}

cleanup_generated_package_state
trap cleanup_generated_package_state EXIT

"$packages_dir/verify_single_folder_standalone.sh"
"$packages_dir/verify_foundation_only_packages.sh"
"$packages_dir/verify_integration_helpers.sh"

if [ "$(uname)" = "Darwin" ]; then
  "$packages_dir/verify_apple_packages_macos.sh"
  "$packages_dir/verify_strict_concurrency_macos.sh"
else
  echo "Skipping Apple-only package tests on non-macOS. Run verify_apple_packages_macos.sh and verify_strict_concurrency_macos.sh on macOS/Xcode." >&2
fi
