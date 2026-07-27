#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-.}"
failed=0

forbidden_patterns=(
  "String(describing: error)"
  "Authorization"
  "Set-Cookie"
  "access_token"
  "refresh_token"
)

for pattern in "${forbidden_patterns[@]}"; do
  if grep -R "$pattern" "$TARGET" --include='*.swift' --include='*.swift.template' >/dev/null 2>&1; then
    echo "❌ Found pattern '$pattern' in Swift source/template. Review and sanitize before release."
    failed=1
  fi
done

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi

echo "✅ Forbidden content scan passed"
