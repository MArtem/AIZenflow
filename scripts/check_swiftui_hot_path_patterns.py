#!/usr/bin/env python3
"""Report SwiftUI performance and task-lifecycle review candidates.

Findings from this script are intentionally non-blocking because patterns such as Task {}
can be correct when owned by a user action, .task(id:), a model lifecycle, or app maintenance.
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
    ("warning", "GeometryReader usage; verify not in repeated row hot path", re.compile(r"\bGeometryReader\b")),
    ("warning", "PreferenceKey usage; verify scroll/layout update rate", re.compile(r"\bPreferenceKey\b")),
    ("warning", "Broad animation without obvious value parameter", re.compile(r"\.animation\s*\([^\n)]*\)")),
    ("review-candidate", "Task lifecycle; verify owner/cancellation/stale-result policy", re.compile(r"\bTask\s*\{")),
]


def main() -> int:
    args = parse_scope_args("Scan SwiftUI hot-path review candidates.")
    scan_roots = resolve_scan_roots(args.paths)
    findings = FindingCollector(args.max_findings)
    blocking_input_failure = False
    scanned = 0

    for path in iter_baseline_gate_files(scan_roots, "swiftui-hot-path-patterns"):
        try:
            text = read_text_limited(path, MAX_SCAN_BYTES)
        except OversizedScanInputError:
            findings.add(("blocking", "unscanned oversized file", path, 0))
            blocking_input_failure = True
            continue
        except OSError:
            findings.add(("blocking", "unreadable file", path, 0))
            blocking_input_failure = True
            continue
        scanned += 1
        for severity, name, pattern in PATTERNS:
            for _, line in iter_matches_with_lines(text, pattern):
                findings.add((severity, name, path, line))

    if not scanned and findings.total == 0:
        raise SystemExit("No eligible files for this scoped scan.")
    if findings.total:
        print("SwiftUI hot-path review candidates (non-blocking unless an input could not be scanned):")
        for severity, name, path, line in findings.items:
            location = display_path(path) if not line else f"{display_path(path)}:{line}"
            print(f"- [{severity}] {name}: {location}")
        print(findings.summary())
        return 1 if blocking_input_failure else 0

    print("SwiftUI hot-path candidate scan OK")
    print(findings.summary())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
