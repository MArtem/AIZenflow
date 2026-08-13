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
from functools import lru_cache
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
    if has_skip_worktree_entries(root, resolved):
        raise SystemExit("Scan scope contains sparse skip-worktree entries and cannot produce exact-SHA evidence.")
    if has_assume_unchanged_entries(root, resolved):
        raise SystemExit("Scan scope contains assume-unchanged entries and cannot produce exact-SHA evidence.")
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


def has_skip_worktree_entries(root: Path, roots: Iterable[Path]) -> bool:
    """Reject sparse-checkout entries that are absent from the filesystem scan universe."""
    pathspecs = []
    for scan_root in roots:
        try:
            relative = scan_root.relative_to(root)
        except ValueError:
            continue
        pathspecs.append(relative.as_posix())
    result = subprocess.run(
        ["git", "-C", str(root), "ls-files", "-t", "-z", "--", *pathspecs],
        capture_output=True,
    )
    if result.returncode != 0:
        raise SystemExit("Cannot establish Git sparse-checkout exclusions.")
    return any(entry.startswith(b"S ") for entry in result.stdout.split(b"\0") if entry)


def has_assume_unchanged_entries(root: Path, roots: Iterable[Path]) -> bool:
    """Reject index entries whose mutable bytes Git is configured not to notice."""
    pathspecs = []
    for scan_root in roots:
        try:
            relative = scan_root.relative_to(root)
        except ValueError:
            continue
        pathspecs.append(relative.as_posix())
    result = subprocess.run(
        ["git", "-C", str(root), "ls-files", "-v", "-z", "--", *pathspecs],
        capture_output=True,
    )
    if result.returncode != 0:
        raise SystemExit("Cannot establish Git assume-unchanged exclusions.")
    return any(entry[:1].islower() for entry in result.stdout.split(b"\0") if entry)


def is_ignored_path(path: Path, ignored_paths: set[Path]) -> bool:
    """Match ignored entries lexically so an ignored symlink cannot hide its tracked target."""
    return any(path == ignored or path.is_relative_to(ignored) for ignored in ignored_paths)


def is_ignored_untracked_target(root: Path, path: Path, ignored_paths: set[Path]) -> bool:
    """Fail closed when a tracked symlink resolves to ignored mutable content."""
    if is_ignored_path(path, ignored_paths):
        return True
    try:
        relative = path.relative_to(root)
    except ValueError:
        return False
    result = subprocess.run(
        ["git", "-C", str(root), "check-ignore", "-q", "--", relative.as_posix()],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    if result.returncode == 0:
        return True
    if result.returncode == 1:
        return False
    raise SystemExit("Cannot establish Git-ignored target exclusions.")


@lru_cache(maxsize=None)
def submodule_paths(root: Path) -> frozenset[Path]:
    """Return tracked Gitlinks so mutable nested worktrees never enter a parent receipt."""
    result = subprocess.run(
        ["git", "-C", str(root), "ls-files", "--stage", "-z"],
        capture_output=True,
    )
    if result.returncode != 0:
        raise SystemExit("Cannot establish Git submodule scan exclusions.")

    paths: set[Path] = set()
    for entry in result.stdout.split(b"\0"):
        if not entry:
            continue
        header, separator, raw_path = entry.partition(b"\t")
        if not separator:
            raise SystemExit("Cannot decode Git submodule scan exclusions.")
        if header.split(b" ", maxsplit=1)[0] == b"160000":
            paths.add(root / raw_path.decode("utf-8", errors="surrogateescape"))
    return frozenset(paths)


def is_submodule_path(path: Path, paths: frozenset[Path]) -> bool:
    """Return whether a lexical path belongs to a tracked nested worktree."""
    return any(path == submodule or path.is_relative_to(submodule) for submodule in paths)


def iter_files(
    roots: Iterable[Path],
    pattern: str = "*",
    extra_excludes: set[str] | None = None,
) -> Iterable[Path]:
    """Yield files under the resolved scan roots while preserving scope boundaries."""
    root = repo_root().resolve()
    ignored_paths = ignored_untracked_paths(root, roots)
    nested_submodules = submodule_paths(root)
    for scan_root in roots:
        lexical_root = scan_root.absolute()
        if is_submodule_path(lexical_root, nested_submodules):
            continue
        resolved_root = lexical_root.resolve()
        try:
            resolved_root.relative_to(root)
        except ValueError:
            continue
        if resolved_root.is_file():
            if (
                not is_ignored_path(lexical_root, ignored_paths)
                and (
                    not lexical_root.is_symlink()
                    or not is_ignored_untracked_target(root, resolved_root, ignored_paths)
                )
                and resolved_root.match(pattern)
                and not should_exclude(resolved_root, extra_excludes)
            ):
                yield resolved_root
            continue

        for path in lexical_root.rglob(pattern):
            if is_ignored_path(path, ignored_paths) or is_submodule_path(path, nested_submodules):
                continue
            resolved_path = path.resolve()
            try:
                resolved_path.relative_to(root)
            except ValueError:
                continue
            if (
                resolved_path.is_file()
                and (
                    not path.is_symlink()
                    or not is_ignored_untracked_target(root, resolved_path, ignored_paths)
                )
                and not should_exclude(resolved_path, extra_excludes)
            ):
                yield resolved_path


def display_path(path: Path) -> str:
    """Format paths consistently for gate output and reviewer triage."""
    root = repo_root()
    return f"./{path.relative_to(root)}"
