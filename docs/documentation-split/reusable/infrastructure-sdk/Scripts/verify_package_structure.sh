#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <PackagePath>"
  exit 1
fi

PACKAGE_PATH="$1"
PACKAGE_NAME="$(basename "$PACKAGE_PATH")"

required=(
  "Package.swift"
  "README.md"
  "PackageContract.md"
  "Sources"
  "Tests"
  "Scripts/verify_package.sh"
)

for item in "${required[@]}"; do
  if [[ ! -e "$PACKAGE_PATH/$item" ]]; then
    echo "❌ Missing $item in $PACKAGE_PATH"
    exit 1
  fi
done

python3 - "$PACKAGE_PATH" "$PACKAGE_NAME" <<'PYVERIFY'
from pathlib import Path
import re
import sys
package_path = Path(sys.argv[1])
package_name = sys.argv[2]
text = (package_path / "Package.swift").read_text(errors="ignore")
if not re.search(r'name\s*:\s*"' + re.escape(package_name) + r'"', text):
    print(f"❌ Package.swift name does not match folder name: {package_name}", file=sys.stderr)
    sys.exit(1)
if not any(p.is_dir() for p in (package_path / "Sources").iterdir()):
    print(f"❌ Sources/ has no target directories in {package_path}", file=sys.stderr)
    sys.exit(1)
if not any((p.is_dir() and p.name.endswith('.docc')) for p in (package_path / "Sources").rglob('*.docc')):
    print(f"❌ Source-owned DocC documentation is missing in {package_path}", file=sys.stderr)
    sys.exit(1)
if not any(p.is_dir() for p in (package_path / "Tests").iterdir()):
    print(f"❌ Tests/ has no test target directories in {package_path}", file=sys.stderr)
    sys.exit(1)
PYVERIFY

if grep -R '^[[:space:]]*\.package(path: "\.\.' "$PACKAGE_PATH/Package.swift" >/dev/null 2>&1; then
  echo "❌ Sibling path dependency found in $PACKAGE_PATH/Package.swift"
  exit 1
fi

if grep -R "unsafeFlags" "$PACKAGE_PATH/Package.swift" >/dev/null 2>&1; then
  echo "❌ unsafeFlags found in $PACKAGE_PATH/Package.swift"
  exit 1
fi

if find "$PACKAGE_PATH" \( -name ".DS_Store" -o -name "__MACOSX" -o -name ".build" -o -name ".swiftpm" -o -name "xcuserdata" \) | grep .; then
  echo "❌ Forbidden generated/metadata files found in $PACKAGE_PATH"
  exit 1
fi

if grep -R "{{" "$PACKAGE_PATH" >/dev/null 2>&1; then
  echo "❌ Unresolved template placeholder found in $PACKAGE_PATH"
  exit 1
fi

echo "✅ Package structure looks valid: $PACKAGE_PATH"
