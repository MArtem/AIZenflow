#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' 'Archive normalization disabled: it previously deleted files recursively without verified ownership or containment. No files were changed.' >&2
exit 2
