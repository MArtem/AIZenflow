#!/usr/bin/env python3
"""Scan repository text files for common committed-secret patterns.

The scanner avoids oversized files and preserves the project's narrowly scoped safe fixtures,
then reports candidate secrets as blocking findings because token leakage is a security/privacy
stop condition.
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
    ("private key", re.compile(r"-----BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY-----")),
    ("aws access key", re.compile(r"AKIA[0-9A-Z]{16}")),
    ("generic token assignment", re.compile(r'(?i)(api[_-]?key|secret|token|password)\s*[:=]\s*["\'][^"\']{16,}["\']')),
]
SAFE_TEST_FIXTURE_LITERALS = frozenset(
    {
        "access-rollback",
        "refresh-rollback",
        "expired-access",
        "refresh-token",
        "access-to-revoke",
        "username-refresh",
        "register-refresh",
        "refreshed-access",
        "refreshed-refresh",
    }
)


def main() -> int:
    args = parse_scope_args("Scan potential committed secrets.")
    scan_roots = resolve_scan_roots(args.paths)
    findings = FindingCollector(args.max_findings)
    scanned = 0

    for path in iter_baseline_gate_files(scan_roots, "secrets"):
        try:
            text = read_text_limited(path, MAX_SCAN_BYTES)
        except OversizedScanInputError:
            findings.add(("oversized", path))
            continue
        except OSError:
            findings.add(("unreadable", path))
            continue
        scanned += 1
        for name, pattern in PATTERNS:
            for match, line in iter_matches_with_lines(text, pattern):
                literal_match = re.search(r'["\']([^"\']+)["\']\s*$', match.group(0))
                literal = literal_match.group(1) if literal_match else ""
                if name == "generic token assignment" and (
                    literal.startswith("${")
                    # These exact values are bounded authentication fixtures in XCTest sources,
                    # not credentials. Keep the allowlist literal- and path-specific.
                    or (path.name.endswith("Tests.swift") and literal in SAFE_TEST_FIXTURE_LITERALS)
                ):
                    continue
                findings.add(("secret", name, path, line))

    if not scanned and findings.total == 0:
        raise SystemExit("No readable files within the secret scan size limit.")
    if findings.total:
        print("Secret scan failed (blocking until reviewed):")
        for item in findings.items:
            if item[0] == "oversized":
                print(f"- [blocking] unscanned oversized file: {display_path(item[1])}")
            elif item[0] == "unreadable":
                print(f"- [blocking] unreadable file: {display_path(item[1])}")
            else:
                _, name, path, line = item
                print(f"- [blocking] {name}: {display_path(path)}:{line}")
        print(findings.summary())
        return 1

    print("Secret pattern scan OK (limited patterns: private-key headers, AWS access-key IDs, quoted token assignments)")
    print(findings.summary())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
