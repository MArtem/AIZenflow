#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="${1:-$ROOT_DIR/Packages}"

if [[ ! -d "$PACKAGES_DIR" ]]; then
  echo "No Packages directory found at $PACKAGES_DIR. Pass a package root explicitly."
  exit 0
fi

for package in "$PACKAGES_DIR"/*; do
  [[ -d "$package" ]] || continue
  [[ -f "$package/Package.swift" ]] || continue
  "$ROOT_DIR/Scripts/verify_package_structure.sh" "$package"
done

echo "✅ Single-folder standalone structural verification passed"
