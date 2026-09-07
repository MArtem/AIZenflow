#!/usr/bin/env bash
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

cd "$QUALITY_REPO_ROOT" || exit 1

echo "# iOS project discovery"
echo "repo_root=$QUALITY_REPO_ROOT"
echo "branch=$(git branch --show-current 2>/dev/null || true)"
echo

echo "## Xcode"
if command -v xcodebuild >/dev/null 2>&1; then
  xcodebuild -version || true
else
  echo "xcodebuild: NOT FOUND"
fi

echo
echo_workspaces() { find . -maxdepth 3 -name '*.xcworkspace' -not -path '*/.build/*' -not -path '*/DerivedData/*' -print; }
echo "## Workspaces"
echo_workspaces || true

echo "## Projects"
find . -maxdepth 3 -name '*.xcodeproj' -not -path '*/.build/*' -not -path '*/DerivedData/*' -print || true

echo "## Package manifests"
find . -maxdepth 4 -name Package.swift -print || true

echo "## Schemes"
find . -path '*xcshareddata/xcschemes/*.xcscheme' -print || true

echo "## Test plans"
find . -name '*.xctestplan' -print || true

echo "## Privacy manifests"
find . -name 'PrivacyInfo.xcprivacy' -print || true

echo "## Entitlements"
find . -name '*.entitlements' -print || true

echo "## String catalogs"
find . -name '*.xcstrings' -print || true

echo "## Package.resolved"
find . -name 'Package.resolved' -print || true

echo "## Available iOS simulators (summary)"
if command -v xcrun >/dev/null 2>&1; then
  xcrun simctl list devices available 2>/dev/null | sed -n '/-- iOS/,/-- /p' | head -80 || true
fi

echo
echo "Discovery is read-only. Copy config/project.env.example to config/project.env and fill verified values."
