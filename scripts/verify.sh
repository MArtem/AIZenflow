#!/usr/bin/env bash

set -euo pipefail

readonly PROJECT="TchopApp.xcodeproj"
readonly SCHEME="TchopApp"
readonly DESTINATION_IOS_26="platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0"
readonly DESTINATION_IOS_18="platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2"
readonly WORKTREES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
readonly DERIVED_DATA_PATH="${TCHOP_DERIVED_DATA_PATH:-${WORKTREES_ROOT}/.xcode-derived-data/TchopApp}"
readonly CLONED_PACKAGES_PATH="${TCHOP_XCODE_PACKAGE_CACHE:-${WORKTREES_ROOT}/.xcode-package-cache/TchopApp}"

cleanup_generated_package_state() {
  find ./Packages -name .swiftpm -type d -prune -exec rm -rf {} +
}

usage() {
  cat <<'EOF'
Usage:
  ./scripts/verify.sh <low|medium|full>

Levels:
  low     Build TchopApp on iPhone 17 Pro (iOS 26.0)
  medium  Run package tests, app tests, then build on iPhone 17 Pro (iOS 26.0)
  full    Run package tests, app tests, then build on iPhone 16 Pro (iOS 18.2) and iPhone 17 Pro (iOS 26.0)
EOF
}

run_package_tests() {
  ./Packages/verify_everything.sh
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
      run_build "${DESTINATION_IOS_26}"
      ;;
    medium)
      run_package_tests
      run_app_tests "${DESTINATION_IOS_26}"
      run_build "${DESTINATION_IOS_26}"
      ;;
    full)
      run_package_tests
      run_app_tests "${DESTINATION_IOS_26}"
      run_build "${DESTINATION_IOS_18}"
      run_build "${DESTINATION_IOS_26}"
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
