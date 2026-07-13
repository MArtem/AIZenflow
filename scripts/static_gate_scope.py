#!/usr/bin/env python3
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
    return Path(__file__).resolve().parents[1]


def parse_scope_args(description: str) -> argparse.Namespace:
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
    for scan_root in roots:
        if scan_root.is_file():
            if scan_root.match(pattern) and not should_exclude(scan_root, extra_excludes):
                yield scan_root
            continue

        for path in scan_root.rglob(pattern):
            if path.is_file() and not should_exclude(path, extra_excludes):
                yield path


def display_path(path: Path) -> str:
    root = repo_root()
    return f"./{path.relative_to(root)}"
