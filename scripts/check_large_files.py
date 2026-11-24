#!/usr/bin/env python3
"""Detect oversized files that should not enter normal source/documentation commits.

Large artifacts often indicate build output, traces, media fixtures, or accidental exports.
The script respects explicit scan scope through `static_gate_scope`.
"""

from static_gate_scope import FindingCollector, display_path, iter_baseline_gate_files, parse_scope_args, resolve_scan_roots


LIMIT = 5 * 1024 * 1024


def main() -> int:
    args = parse_scope_args("Scan large files over the repository limit.")
    scan_roots = resolve_scan_roots(args.paths)
    findings = FindingCollector(args.max_findings)

    scanned = 0
    for path in iter_baseline_gate_files(scan_roots, "large-files"):
        scanned += 1
        try:
            size = path.stat().st_size
        except OSError:
            findings.add(("unreadable", path))
            continue
        if size > LIMIT:
            findings.add(("large", path, size))

    if not scanned:
        raise SystemExit("No eligible files for this scoped scan.")
    if findings.total:
        print("Large files over 5MB:")
        for item in findings.items:
            if item[0] == "unreadable":
                print(f"- [blocking] unable to inspect file: {display_path(item[1])}")
            else:
                _, path, size = item
                print(f"- [blocking] {display_path(path)}: {size / 1024 / 1024:.1f} MB")
        print(findings.summary())
        return 1

    print("Large file scan OK")
    print(findings.summary())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
