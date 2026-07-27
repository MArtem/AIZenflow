#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-.}"

if find "$TARGET" \( -name ".DS_Store" -o -name "__MACOSX" -o -name ".build" -o -name ".swiftpm" -o -name "xcuserdata" \) | grep .; then
  echo "❌ Archive hygiene check failed"
  exit 1
fi

echo "✅ Archive hygiene passed"
