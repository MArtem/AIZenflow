#!/usr/bin/env python3
"""Shared scope helper for repository-local static quality gates.

The gate scripts import this module so every scanner resolves requested paths the same way:
inside the current repository, with build artifacts and VCS folders excluded. Keeping this
logic centralized prevents a scoped gate such as `AIFieldbook` from accidentally reporting
findings from sibling apps or legacy folders.
"""

from __future__ import annotations

import argparse
import subprocess
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
        candidate = path.resolve()
        try:
            candidate.relative_to(root)
        except ValueError as error:
            raise SystemExit(f"Refusing to scan outside repository root: {candidate}") from error
        if not path.exists():
            raise SystemExit(f"Scan path does not exist: {path}")
        if should_exclude(path):
            raise SystemExit(f"Scan path is excluded from static evidence: {path}")
        resolved.append(path.absolute())

    ignored_paths = ignored_untracked_paths(root, resolved)
    for path in resolved:
        if is_ignored_path(path, ignored_paths):
            raise SystemExit(f"Scan path is Git-ignored and excluded from static evidence: {path}")
    if not any(iter_files(resolved)):
        raise SystemExit("Scan scope has no eligible files for static evidence.")
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


def ignored_untracked_paths(root: Path, roots: Iterable[Path]) -> set[Path]:
    """Return Git-ignored untracked files that must not enter SHA-bound scan evidence."""
    pathspecs = []
    for scan_root in roots:
        try:
            relative = scan_root.relative_to(root)
        except ValueError:
            continue
        pathspecs.append(relative.as_posix())
    result = subprocess.run(
        [
            "git",
            "-C",
            str(root),
            "ls-files",
            "--others",
            "--ignored",
            "--exclude-standard",
            "--directory",
            "--no-empty-directory",
            "-z",
            "--",
            *pathspecs,
        ],
        capture_output=True,
    )
    if result.returncode != 0:
        raise SystemExit("Cannot establish Git-ignored scan exclusions.")

    ignored: set[Path] = set()
    for raw_path in result.stdout.split(b"\0"):
        if not raw_path:
            continue
        ignored.add(root / raw_path.decode("utf-8", errors="surrogateescape"))
    return ignored


def is_ignored_path(path: Path, ignored_paths: set[Path]) -> bool:
    """Match ignored entries lexically so an ignored symlink cannot hide its tracked target."""
    return any(path == ignored or path.is_relative_to(ignored) for ignored in ignored_paths)


def iter_files(
    roots: Iterable[Path],
    pattern: str = "*",
    extra_excludes: set[str] | None = None,
) -> Iterable[Path]:
    """Yield files under the resolved scan roots while preserving scope boundaries."""
    root = repo_root().resolve()
    ignored_paths = ignored_untracked_paths(root, roots)
    for scan_root in roots:
        lexical_root = scan_root.absolute()
        resolved_root = lexical_root.resolve()
        try:
            resolved_root.relative_to(root)
        except ValueError:
            continue
        if resolved_root.is_file():
            if (
                not is_ignored_path(lexical_root, ignored_paths)
                and resolved_root.match(pattern)
                and not should_exclude(resolved_root, extra_excludes)
            ):
                yield resolved_root
            continue

        for path in lexical_root.rglob(pattern):
            if is_ignored_path(path, ignored_paths):
                continue
            resolved_path = path.resolve()
            try:
                resolved_path.relative_to(root)
            except ValueError:
                continue
            if (
                resolved_path.is_file()
                and not should_exclude(resolved_path, extra_excludes)
            ):
                yield resolved_path


def display_path(path: Path) -> str:
    """Format paths consistently for gate output and reviewer triage."""
    root = repo_root()
    return f"./{path.relative_to(root)}"
