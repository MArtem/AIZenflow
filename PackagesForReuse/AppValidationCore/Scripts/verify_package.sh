#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' 'Package verification disabled: the build/test scratch lifecycle has not been scenario-verified under the current ownership contract. No verification was run.' >&2
exit 2
