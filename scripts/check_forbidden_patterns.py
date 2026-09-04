#!/usr/bin/env python3
"""Scan Swift source for blocked or review-required high-risk patterns.

The scanner is deliberately conservative and scope-aware. Blocking findings fail the gate,
while review candidates are reported for human/agent triage without automatically blocking.
"""

import re

from static_gate_scope import display_path, iter_files, parse_scope_args, resolve_scan_roots


PATTERNS = [
    ("blocking", "UIImage(contentsOfFile:) in SwiftUI/source", re.compile(r"UIImage\s*\(\s*contentsOfFile\s*:")),
    ("blocking", "Data(contentsOf:) sync file read", re.compile(r"Data\s*\(\s*contentsOf\s*:")),
    ("blocking", "PDFDocument(url:) sync PDF load", re.compile(r"PDFDocument\s*\(\s*url\s*:")),
    ("blocking", "AVAssetImageGenerator usage", re.compile(r"AVAssetImageGenerator")),
    ("review-candidate", "ForEach(Array(...))", re.compile(r"ForEach\s*\(\s*Array\s*\(")),
    ("review-candidate", "AnyView usage", re.compile(r"\bAnyView\s*\(")),
]


def main() -> int:
    args = parse_scope_args("Scan blocking and review-candidate forbidden Swift patterns.")
    scan_roots = resolve_scan_roots(args.paths)
    findings = []

    # Test fixtures are not shipped SwiftUI/source hot paths; keep this production-pattern gate
    # aligned across app and package test targets without weakening the shipped-source scan.
    for path in iter_files(
        scan_roots,
        "*.swift",
        {"TchopAppTests", "Tests", "UITests", "docs", ".zenflow"},
    ):
        text = path.read_text(errors="ignore")
        for severity, name, rx in PATTERNS:
            for match in rx.finditer(text):
                line = text[:match.start()].count("\n") + 1
                findings.append((severity, name, path, line))

    if findings:
        print("Forbidden/high-risk Swift patterns found:")
        for severity, name, path, line in findings[:args.max_findings]:
            print(f"- [{severity}] {name}: {display_path(path)}:{line}")
        if len(findings) > args.max_findings:
            print(f"... {len(findings) - args.max_findings} more")
        return 1 if any(severity == "blocking" for severity, *_ in findings) else 0

    print("Forbidden/high-risk Swift pattern scan OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
