#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE_ROOT="${ZENFLOW_SANDBOX_ROOT:-$(git -C "$PACKAGE_DIR" rev-parse --show-toplevel 2>/dev/null || true)}"
[[ "$WORKSPACE_ROOT" == "/Users/Artem/.zenflow" || "$WORKSPACE_ROOT" == "/Users/Artem/.zenflow/"* ]] || { echo "error: Verification root must stay inside /Users/Artem/.zenflow" >&2; exit 1; }
BUILD_ROOT="${ZENFLOW_PACKAGE_BUILD_CACHE:-$WORKSPACE_ROOT/.package-build-cache}/AppIntentSupport"
[[ "$BUILD_ROOT" == "$WORKSPACE_ROOT"/* ]] || { echo "error: Scratch path must stay inside the sandbox root" >&2; exit 1; }
LOG_FILE="$BUILD_ROOT/swift-build.log"

rm -rf "$BUILD_ROOT"
mkdir -p "$BUILD_ROOT"

cd "$PACKAGE_DIR"
swift build --build-path "$BUILD_ROOT" 2>&1 | tee "$LOG_FILE"

if grep -E "(^|[^A-Za-z])(warning|error):" "$LOG_FILE" >/dev/null; then
    echo "AppIntentSupport verification emitted warning/error output" >&2
    exit 1
fi

find "$PACKAGE_DIR" -name .build -o -name .swiftpm -o -name Package.resolved -o -name build | grep . && {
    echo "Generated package artifacts must not be left in AppIntentSupport" >&2
    exit 1
} || true
