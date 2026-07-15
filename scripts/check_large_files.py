#!/usr/bin/env python3
"""Detect oversized files that should not enter normal source/documentation commits.

Large artifacts often indicate build output, traces, media fixtures, or accidental exports.
The script respects explicit scan scope through `static_gate_scope`.
"""

from static_gate_scope import display_path, iter_files, parse_scope_args, resolve_scan_roots


LIMIT = 5 * 1024 * 1024


def main() -> int:
    args = parse_scope_args("Scan large files over the repository limit.")
    scan_roots = resolve_scan_roots(args.paths)
    large = []

    for path in iter_files(scan_roots, "*", {"traces"}):
        size = path.stat().st_size
        if size > LIMIT:
            large.append((path, size))

    if large:
        print("Large files over 5MB:")
        for path, size in large[:args.max_findings]:
            print(f"- [blocking] {display_path(path)}: {size / 1024 / 1024:.1f} MB")
        if len(large) > args.max_findings:
            print(f"... {len(large) - args.max_findings} more")
        return 1

    print("Large file scan OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
