#!/usr/bin/env python3
"""Scan repository text files for common committed-secret patterns.

The scanner avoids large/binary files and known dev placeholders, then reports candidate
secrets as blocking findings because token leakage is a security/privacy stop condition.
"""

import re

from static_gate_scope import display_path, iter_files, parse_scope_args, resolve_scan_roots


PATTERNS = [
    ("private key", re.compile(r"-----BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY-----")),
    ("aws access key", re.compile(r"AKIA[0-9A-Z]{16}")),
    ("generic token assignment", re.compile(r'(?i)(api[_-]?key|secret|token|password)\s*[:=]\s*["\'][^"\']{16,}["\']')),
]


def main() -> int:
    args = parse_scope_args("Scan potential committed secrets.")
    scan_roots = resolve_scan_roots(args.paths)
    findings = []

    for path in iter_files(scan_roots, "*", {".zenflow", "traces"}):
        if path.stat().st_size > 2_000_000:
            continue
        try:
            text = path.read_text(errors="ignore")
        except Exception:
            continue
        for name, rx in PATTERNS:
            for match in rx.finditer(text):
                literal_match = re.search(r'["\']([^"\']+)["\']\s*$', match.group(0))
                literal = literal_match.group(1) if literal_match else ""
                if name == "generic token assignment" and (
                    literal.startswith(("dev-access-", "dev-refresh-", "reqres-demo-refresh-"))
                    or literal.startswith("${")
                ):
                    continue
                line = text[:match.start()].count("\n") + 1
                findings.append((name, path, line))

    if findings:
        print("Potential secrets found (blocking until reviewed):")
        for name, path, line in findings[:args.max_findings]:
            print(f"- [blocking] {name}: {display_path(path)}:{line}")
        if len(findings) > args.max_findings:
            print(f"... {len(findings) - args.max_findings} more")
        return 1

    print("Secret pattern scan OK (limited patterns: private-key headers, AWS access-key IDs, quoted token assignments)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
