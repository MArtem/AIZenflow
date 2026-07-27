#!/bin/sh
set -eu

packages_dir="$(cd "$(dirname "$0")" && pwd)"

"$packages_dir/verify_single_folder_standalone.sh"
"$packages_dir/verify_foundation_only_packages.sh"
"$packages_dir/verify_integration_helpers.sh"

if [ "$(uname)" = "Darwin" ]; then
  "$packages_dir/verify_apple_packages_macos.sh"
  "$packages_dir/verify_strict_concurrency_macos.sh"
else
  echo "Skipping Apple platform packages and Apple strict-concurrency checks on non-macOS host. Run macOS scripts on Xcode." >&2
fi
