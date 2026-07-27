#!/usr/bin/env bash
set -euo pipefail

readonly PROJECT="<AppName>.xcodeproj"
readonly SCHEME="<AppName>"
readonly DESTINATION_CURRENT="platform=iOS Simulator,name=iPhone 17 Pro"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/verify.sh <list|build>

Levels:
  list   Verify Xcode project structure
  build  Build <AppName> on iPhone 17 Pro (available iOS runtime)
EOF
}

run_list() {
  xcodebuild -list -project "${PROJECT}"
}

run_build() {
  xcodebuild \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -configuration Debug \
    -destination "${DESTINATION_CURRENT}" \
    CODE_SIGNING_ALLOWED=NO \
    build
}

main() {
  if [[ $# -ne 1 ]]; then
    usage
    exit 1
  fi

  case "$1" in
    list) run_list ;;
    build) run_build ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"
