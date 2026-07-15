#!/usr/bin/env python3
"""Heuristically detect hard-coded SwiftUI text that may bypass localization.

This is a review gate, not a compiler. It catches simple `Text("...")` literals so app work
does not accidentally ship user-facing strings outside the localization system.
"""

import re

from static_gate_scope import display_path, iter_files, parse_scope_args, resolve_scan_roots


# Heuristic only: flags simple Text("literal") occurrences that do not look like previews/debug/system symbols.
TEXT_LITERAL = re.compile(r'\bText\s*\(\s*"([^"]*[A-Za-zА-Яа-я][^"]*)"\s*\)')


def main() -> int:
    args = parse_scope_args("Scan potential hard-coded user-facing Text literals.")
    scan_roots = resolve_scan_roots(args.paths)
    findings = []

    for path in iter_files(scan_roots, "*.swift", {"TchopAppTests"}):
        text = path.read_text(errors="ignore")
        for match in TEXT_LITERAL.finditer(text):
            literal = match.group(1)
            nearby = text[max(0, match.start() - 300):match.start() + 300]
            if literal.startswith("system.") or "#Preview" in nearby:
                continue
            line = text[:match.start()].count("\n") + 1
            findings.append((path, line, literal))

    if findings:
        print("Potential hard-coded user-facing Text literals (blocking until reviewed/localized):")
        for path, line, literal in findings[:args.max_findings]:
            print(f'- [blocking] {display_path(path)}:{line}: "{literal}"')
        if len(findings) > args.max_findings:
            print(f"... {len(findings) - args.max_findings} more")
        return 1

    print("Localization heuristic scan OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
