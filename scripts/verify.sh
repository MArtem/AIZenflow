#!/usr/bin/env bash

set -euo pipefail

readonly PROJECT="TchopApp.xcodeproj"
readonly SCHEME="TchopApp"
readonly PACKAGE_PATH="Packages/TchopInfrastructure"
readonly DESTINATION_IOS_26="platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0"
readonly DESTINATION_IOS_18="platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2"

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
  swift test --package-path "${PACKAGE_PATH}"
}

run_build() {
  local destination="$1"

  xcodebuild \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -configuration Debug \
    -destination "${destination}" \
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

main "$@"
