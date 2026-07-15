#!/usr/bin/env python3
"""Validate path references inside `docs/TASK_TYPE_DOCUMENTATION_ROUTER.md`.

The router is intentionally the lightweight replacement for always loading the full
documentation library. This check keeps that optimization safe by failing when the
router points at missing local documentation paths.
"""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
ROUTER = ROOT / "docs" / "TASK_TYPE_DOCUMENTATION_ROUTER.md"


def should_skip(path: str) -> bool:
    """Return true for placeholders or external canonical roots that are not local docs."""
    return (
        "<" in path
        or "*" in path
        or path.startswith("/Users/Artem/.zenflow/worktrees/documentation-vault/")
        or path in {"./scripts/check_*.py"}
    )


def main() -> int:
    if not ROUTER.exists():
        print(f"Missing router: {ROUTER.relative_to(ROOT)}")
        return 1

    text = ROUTER.read_text()
    paths = sorted(set(re.findall(r"`(\./[^`]+)`", text)))
    missing: list[str] = []

    for path in paths:
        if should_skip(path):
            continue
        candidate = ROOT / path[2:]
        if not candidate.exists():
            missing.append(path)

    if missing:
        print("Missing router paths:")
        for path in missing:
            print(f"- {path}")
        return 1

    print(f"Task type documentation router OK: {len(paths)} referenced paths checked")
    return 0


if __name__ == "__main__":
    sys.exit(main())
