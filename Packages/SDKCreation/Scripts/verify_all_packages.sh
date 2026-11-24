#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' 'Aggregate package verification disabled: existing package scripts may remove unowned state or escape the approved sandbox. No verification was run.' >&2
exit 2
