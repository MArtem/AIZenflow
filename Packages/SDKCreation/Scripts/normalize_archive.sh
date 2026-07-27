#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-.}"

find "$TARGET" -name ".DS_Store" -delete
find "$TARGET" -name "__MACOSX" -type d -prune -exec rm -rf {} +
find "$TARGET" -name ".build" -type d -prune -exec rm -rf {} +
find "$TARGET" -name ".swiftpm" -type d -prune -exec rm -rf {} +
find "$TARGET" -name "xcuserdata" -type d -prune -exec rm -rf {} +

echo "✅ Archive normalized"
