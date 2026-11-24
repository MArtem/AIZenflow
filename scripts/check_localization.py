#!/usr/bin/env python3
"""Heuristically detect hard-coded SwiftUI text that may bypass localization.

This is a review gate, not a compiler. It catches simple Text("...") literals so app work does
not accidentally ship user-facing strings outside the localization system.
"""

import re

from static_gate_scope import (
    FindingCollector,
    MAX_SCAN_BYTES,
    OversizedScanInputError,
    display_path,
    iter_baseline_gate_files,
    iter_matches_with_lines,
    parse_scope_args,
    read_text_limited,
    resolve_scan_roots,
)


# Heuristic only: flags simple Text("literal") occurrences that do not look like previews/debug/system symbols.
TEXT_LITERAL = re.compile(r'\bText\s*\(\s*"([^"]*[A-Za-zА-Яа-я][^"]*)"\s*\)')
MAX_REPORTED_LITERAL_CHARS = 200


def main() -> int:
    args = parse_scope_args("Scan potential hard-coded user-facing Text literals.")
    scan_roots = resolve_scan_roots(args.paths)
    findings = FindingCollector(args.max_findings)
    scanned = 0

    for path in iter_baseline_gate_files(scan_roots, "localization"):
        try:
            text = read_text_limited(path, MAX_SCAN_BYTES)
        except OversizedScanInputError:
            findings.add(("unscanned oversized file", path, 0, ""))
            continue
        except OSError:
            findings.add(("unreadable file", path, 0, ""))
            continue
        scanned += 1
        for match, line in iter_matches_with_lines(text, TEXT_LITERAL):
            literal = match.group(1)
            nearby = text[max(0, match.start() - 300):match.start() + 300]
            if literal.startswith("system.") or "#Preview" in nearby:
                continue
            preview = literal[:MAX_REPORTED_LITERAL_CHARS].replace("\r", "\\r").replace("\n", "\\n")
            if len(literal) > MAX_REPORTED_LITERAL_CHARS:
                preview += "…"
            findings.add(("literal", path, line, preview))

    if not scanned and findings.total == 0:
        raise SystemExit("No eligible files for this scoped scan.")
    if findings.total:
        print("Potential hard-coded user-facing Text literals (blocking until reviewed/localized):")
        for kind, path, line, literal in findings.items:
            if kind == "literal":
                print(f'- [blocking] {display_path(path)}:{line}: "{literal}"')
            else:
                print(f"- [blocking] {kind}: {display_path(path)}")
        print(findings.summary())
        return 1

    print("Localization heuristic scan OK")
    print(findings.summary())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
