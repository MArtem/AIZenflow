#!/usr/bin/env bash
set -euo pipefail

PACKAGES_DIR="${1:-Packages}"

if [[ ! -d "$PACKAGES_DIR" ]]; then
  echo "No Packages directory found at $PACKAGES_DIR"
  exit 0
fi

for package in "$PACKAGES_DIR"/*; do
  [[ -d "$package" ]] || continue
  [[ -f "$package/Package.swift" ]] || continue
  echo "=== Verifying $(basename "$package") ==="
  if [[ -x "$package/Scripts/verify_package.sh" ]]; then
    (cd "$package" && ./Scripts/verify_package.sh)
  else
    (cd "$package" && swift test --build-path "$BUILD_DIR")
  fi
done

echo "✅ All package verifications completed"
