#!/usr/bin/env bash
#
# Legacy app verification helper.
#
# Scope:
# This script still targets the original Tchop app and is not the verification entry point for
# AIFieldbook. Keep it documented so future agents do not mistake it for the current app build
# command or route AIFieldbook artifacts into old DerivedData/cache locations.

set -euo pipefail

readonly PROJECT="TchopApp.xcodeproj"
readonly SCHEME="TchopApp"
readonly DESTINATION_CURRENT="platform=iOS Simulator,name=iPhone 17 Pro"
readonly DESTINATION_IOS_18="platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2"
readonly WORKTREES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
readonly DERIVED_DATA_PATH="${TCHOP_DERIVED_DATA_PATH:-${WORKTREES_ROOT}/.xcode-derived-data/TchopApp}"
readonly CLONED_PACKAGES_PATH="${TCHOP_XCODE_PACKAGE_CACHE:-${WORKTREES_ROOT}/.xcode-package-cache/TchopApp}"

cleanup_generated_package_state() {
  find ./Packages ./PackagesInUse ./PackagesForReuse -name .swiftpm -type d -prune -exec rm -rf {} + 2>/dev/null || true
  find ./Packages ./PackagesInUse ./PackagesForReuse -name .build -type d -prune -exec rm -rf {} + 2>/dev/null || true
}

usage() {
  cat <<'EOF'
Usage:
  ./scripts/verify.sh <low|medium|full>

Levels:
  low     Build TchopApp on iPhone 17 Pro (available iOS runtime)
  medium  Run app tests, then build on iPhone 17 Pro (available iOS runtime)
  full    Run app tests, then build on iPhone 16 Pro (iOS 18.2) and iPhone 17 Pro (available iOS runtime)

Package-vault SwiftPM tests are intentionally not part of app verification in source-only mode.
Run package-local `Scripts/verify_package.sh` explicitly from `./PackagesForReuse/<PackageName>` when reviewing a package archive.
EOF
}


run_build() {
  local destination="$1"

  xcodebuild \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -configuration Debug \
    -destination "${destination}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    -clonedSourcePackagesDirPath "${CLONED_PACKAGES_PATH}" \
    CODE_SIGNING_ALLOWED=NO \
    build
}

run_app_tests() {
  local destination="$1"

  xcodebuild \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -configuration Debug \
    -destination "${destination}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    -clonedSourcePackagesDirPath "${CLONED_PACKAGES_PATH}" \
    CODE_SIGNING_ALLOWED=NO \
    test
}

main() {
  if [[ $# -ne 1 ]]; then
    usage
    exit 1
  fi

  case "$1" in
    low)
      run_build "${DESTINATION_CURRENT}"
      ;;
    medium)
      run_app_tests "${DESTINATION_CURRENT}"
      run_build "${DESTINATION_CURRENT}"
      ;;
    full)
      run_app_tests "${DESTINATION_CURRENT}"
      run_build "${DESTINATION_IOS_18}"
      run_build "${DESTINATION_CURRENT}"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

trap cleanup_generated_package_state EXIT
cleanup_generated_package_state
main "$@"
