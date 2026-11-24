#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' 'AppInputFormatting verification disabled: previous cleanup could delete package-owned state and Package.resolved. No verification was run.' >&2
exit 2
