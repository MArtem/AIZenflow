#!/usr/bin/env python3
"""Report SwiftUI performance and task-lifecycle review candidates.

Findings from this script are intentionally non-blocking because patterns such as `Task {}` can
be correct when owned by a user action, `.task(id:)`, a model lifecycle, or app maintenance.
"""

import re

from static_gate_scope import display_path, iter_files, parse_scope_args, resolve_scan_roots


PATTERNS = [
    ("warning", "GeometryReader usage; verify not in repeated row hot path", re.compile(r"\bGeometryReader\b")),
    ("warning", "PreferenceKey usage; verify scroll/layout update rate", re.compile(r"\bPreferenceKey\b")),
    ("warning", "Broad animation without obvious value parameter", re.compile(r"\.animation\s*\([^\n)]*\)")),
    ("review-candidate", "Task lifecycle; verify owner/cancellation/stale-result policy", re.compile(r"\bTask\s*\{")),
]


def main() -> int:
    args = parse_scope_args("Scan SwiftUI hot-path review candidates.")
    scan_roots = resolve_scan_roots(args.paths)
    findings = []

    for path in iter_files(scan_roots, "*.swift", {"TchopAppTests"}):
        text = path.read_text(errors="ignore")
        for severity, name, rx in PATTERNS:
            for match in rx.finditer(text):
                line = text[:match.start()].count("\n") + 1
                findings.append((severity, name, path, line))

    if findings:
        print("SwiftUI hot-path review candidates (non-blocking):")
        for severity, name, path, line in findings[:args.max_findings]:
            print(f"- [{severity}] {name}: {display_path(path)}:{line}")
        if len(findings) > args.max_findings:
            print(f"... {len(findings) - args.max_findings} more")
        return 0

    print("SwiftUI hot-path candidate scan OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
