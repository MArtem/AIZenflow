#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <HelperName> <OutputDirectory>"
  exit 1
fi

HELPER_NAME="$1"
OUTPUT_DIR="$2"

if [[ ! "$HELPER_NAME" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
  echo "❌ Name must be a valid Swift identifier: $HELPER_NAME"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/Templates/IntegrationHelperTemplate"
DEST_DIR="$OUTPUT_DIR/$HELPER_NAME"

if [[ -e "$DEST_DIR" ]]; then
  echo "❌ Destination already exists: $DEST_DIR"
  exit 1
fi

mkdir -p "$DEST_DIR"
cp -R "$TEMPLATE_DIR"/. "$DEST_DIR/"

python3 - "$DEST_DIR" "$HELPER_NAME" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1])
name = sys.argv[2]
placeholder = "{{HelperName}}"
for path in sorted([p for p in root.rglob('*') if p.is_dir()], key=lambda p: len(p.parts)):
    if placeholder in path.name:
        path.rename(path.with_name(path.name.replace(placeholder, name)))
for path in sorted([p for p in root.rglob('*') if p.is_file()], key=lambda p: len(p.parts)):
    current = path
    if placeholder in current.name:
        new = current.with_name(current.name.replace(placeholder, name))
        current.rename(new)
        current = new
    if current.name.endswith('.template'):
        new = current.with_name(current.name[:-len('.template')])
        current.rename(new)
        current = new
    try:
        text = current.read_text()
    except UnicodeDecodeError:
        continue
    current.write_text(text.replace(placeholder, name))
PY

chmod +x "$DEST_DIR/Scripts/verify_package.sh"

echo "✅ Created integration helper: $DEST_DIR"
