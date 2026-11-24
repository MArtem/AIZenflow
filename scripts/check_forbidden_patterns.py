#!/usr/bin/env python3
"""Scan Swift source for blocked or review-required high-risk patterns.

The scanner is deliberately conservative and scope-aware. Blocking findings fail the gate,
while review candidates are reported for human/agent triage without automatically blocking.
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


PATTERNS = [
    ("blocking", "UIImage(contentsOfFile:) in SwiftUI/source", re.compile(r"UIImage\s*\(\s*contentsOfFile\s*:")),
    ("blocking", "Data(contentsOf:) sync file read", re.compile(r"Data\s*\(\s*contentsOf\s*:")),
    ("blocking", "PDFDocument(url:) sync PDF load", re.compile(r"PDFDocument\s*\(\s*url\s*:")),
    # Async AVAssetImageGenerator.image(at:) is the supported non-blocking API. The
    # synchronous copyCGImage path remains forbidden because it can block a UI executor.
    ("blocking", "AVAssetImageGenerator synchronous frame generation", re.compile(r"\.copyCGImage\s*\(")),
    ("review-candidate", "ForEach(Array(...))", re.compile(r"ForEach\s*\(\s*Array\s*\(")),
    ("review-candidate", "AnyView usage", re.compile(r"\bAnyView\s*\(")),
]


def main() -> int:
    args = parse_scope_args("Scan blocking and review-candidate forbidden Swift patterns.")
    scan_roots = resolve_scan_roots(args.paths)
    findings = FindingCollector(args.max_findings)
    blocking_found = False
    scanned = 0

    # Test fixtures are not shipped SwiftUI/source hot paths; keep this production-pattern gate
    # aligned across app and package test targets without weakening the shipped-source scan.
    for path in iter_baseline_gate_files(scan_roots, "forbidden-patterns", {"docs"}):
        try:
            text = read_text_limited(path, MAX_SCAN_BYTES)
        except OversizedScanInputError:
            findings.add(("blocking", "unscanned oversized file", path, 0))
            blocking_found = True
            continue
        except OSError:
            findings.add(("blocking", "unreadable file", path, 0))
            blocking_found = True
            continue
        scanned += 1
        for severity, name, pattern in PATTERNS:
            for _, line in iter_matches_with_lines(text, pattern):
                findings.add((severity, name, path, line))
                blocking_found = blocking_found or severity == "blocking"

    if not scanned and findings.total == 0:
        raise SystemExit("No eligible files for this scoped scan.")
    if findings.total:
        print("Forbidden/high-risk Swift patterns found:")
        for severity, name, path, line in findings.items:
            location = display_path(path) if not line else f"{display_path(path)}:{line}"
            print(f"- [{severity}] {name}: {location}")
        print(findings.summary())
        return 1 if blocking_found else 0

    print("Forbidden/high-risk Swift pattern scan OK")
    print(findings.summary())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
