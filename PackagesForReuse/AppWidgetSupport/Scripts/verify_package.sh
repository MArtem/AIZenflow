#!/bin/sh
set -eu

package_dir="$(cd "$(dirname "$0")/.." && pwd)"
packages_dir="$package_dir"
while [ "$(basename "$packages_dir")" != "Packages" ]; do
  parent="$(dirname "$packages_dir")"
  if [ "$parent" = "$packages_dir" ]; then
    echo "Unable to locate Packages root for $package_dir" >&2
    exit 1
  fi
  packages_dir="$parent"
done
root_dir="$(dirname "$packages_dir")"
worktrees_root="$(cd "$root_dir/.." && pwd)"
package_name="$(basename "$package_dir")"
build_path="${PACKAGE_BUILD_PATH:-$worktrees_root/.package-build-cache/local-package-verification/$package_name}"

cleanup_generated_package_state() {
  rm -rf "$package_dir/.swiftpm" "$package_dir/.build"
}

cleanup_generated_package_state
trap cleanup_generated_package_state EXIT

swift test \
  --package-path "$package_dir" \
  --build-path "$build_path" \
  "$@"
