#!/usr/bin/env python3
"""Shared scope helper for repository-local static quality gates.

The gate scripts import this module so every scanner resolves requested paths the same way:
inside the current repository, with build artifacts and VCS folders excluded. Keeping this
logic centralized prevents a scoped gate such as `AIFieldbook` from accidentally reporting
findings from sibling apps or legacy folders.
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Iterable


DEFAULT_EXCLUDES = {
    ".git",
    ".build",
    ".zenflow-build",
    ".zenflow-attachments",
    "DerivedData",
}


def repo_root() -> Path:
    """Return the repository root inferred from this script's stable location."""
    return Path(__file__).resolve().parents[1]


def parse_scope_args(description: str) -> argparse.Namespace:
    """Parse common scanner arguments used by static gate scripts."""
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument(
        "paths",
        nargs="*",
        help="Files or directories to scan. Defaults to repository root.",
    )
    parser.add_argument(
        "--max-findings",
        type=int,
        default=150,
        help="Maximum findings to print before truncating output.",
    )
    return parser.parse_args()


def resolve_scan_roots(paths: Iterable[str]) -> list[Path]:
    """Resolve user-provided scan roots and reject paths outside the repository.

    External usage:
    Called by every static gate before walking files.

    Failure behavior:
    Exits with a clear message when a requested path does not exist or escapes the repo root.
    """
    root = repo_root()
    requested = list(paths)
    if not requested:
        return [root]

    resolved: list[Path] = []
    for raw_path in requested:
        path = Path(raw_path).expanduser()
        if not path.is_absolute():
            path = root / path
        path = path.resolve()
        try:
            path.relative_to(root)
        except ValueError as error:
            raise SystemExit(f"Refusing to scan outside repository root: {path}") from error
        if not path.exists():
            raise SystemExit(f"Scan path does not exist: {path}")
        resolved.append(path)
    return resolved


def should_exclude(path: Path, extra_excludes: set[str] | None = None) -> bool:
    """Return whether a candidate path belongs to excluded repository/runtime folders."""
    root = repo_root()
    excludes = DEFAULT_EXCLUDES | (extra_excludes or set())
    try:
        rel = path.relative_to(root)
    except ValueError:
        return True
    return any(part in excludes for part in rel.parts)


def iter_files(
    roots: Iterable[Path],
    pattern: str = "*",
    extra_excludes: set[str] | None = None,
) -> Iterable[Path]:
    """Yield files under the resolved scan roots while preserving scope boundaries."""
    root = repo_root().resolve()
    for scan_root in roots:
        resolved_root = scan_root.resolve()
        try:
            resolved_root.relative_to(root)
        except ValueError:
            continue
        if resolved_root.is_file():
            if resolved_root.match(pattern) and not should_exclude(resolved_root, extra_excludes):
                yield resolved_root
            continue

        for path in resolved_root.rglob(pattern):
            resolved_path = path.resolve()
            try:
                resolved_path.relative_to(root)
            except ValueError:
                continue
            if resolved_path.is_file() and not should_exclude(resolved_path, extra_excludes):
                yield resolved_path


def display_path(path: Path) -> str:
    """Format paths consistently for gate output and reviewer triage."""
    root = repo_root()
    return f"./{path.relative_to(root)}"
