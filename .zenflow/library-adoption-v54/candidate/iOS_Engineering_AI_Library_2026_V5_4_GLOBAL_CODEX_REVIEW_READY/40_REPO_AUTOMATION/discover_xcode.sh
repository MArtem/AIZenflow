#!/usr/bin/env bash
set -u
ROOT="${1:-.}"
cd "$ROOT" || exit 2
find . -path '*/xcshareddata/xcschemes/*.xcscheme' -print 2>/dev/null | sort
printf '\n# xcodebuild discovery candidates\n'
find . -maxdepth 3 \( -name '*.xcworkspace' -o -name '*.xcodeproj' \) -print 2>/dev/null | sort
printf '\nUse CI/repository commands as source of truth before constructing a build invocation.\n'
