#!/usr/bin/env python3
"""Shared scope helper for repository-local static quality gates.

The gate scripts import this module so every scanner resolves requested paths the same way:
inside the current repository, with build artifacts and VCS folders excluded. Keeping this
logic centralized prevents a scoped gate such as `AIFieldbook` from accidentally reporting
findings from sibling apps or legacy folders.
"""

from __future__ import annotations

import argparse
import os
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


def nonnegative_findings_limit(raw: str) -> int:
    """Reject invalid output limits before any scan starts."""
    try:
        value = int(raw)
    except ValueError as error:
        raise argparse.ArgumentTypeError("expected a nonnegative integer") from error
    if value < 0:
        raise argparse.ArgumentTypeError("expected a nonnegative integer")
    return value


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
        type=nonnegative_findings_limit,
        default=150,
        help="Requested output limit; support varies by scanner and does not bound memory.",
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
    # An omitted path means the repository root, not an unvalidated fast path.
    # The same index-integrity checks must protect option-only invocations.
    requested = list(paths) or ["."]

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
    index_validation_paths = [
        *resolved,
        *(path.resolve() for path in resolved if path.is_symlink()),
    ]
    if has_skip_worktree_entries(root, index_validation_paths):
        raise SystemExit("Scan scope contains sparse skip-worktree entries and cannot produce exact-SHA evidence.")
    if has_assume_unchanged_entries(root, index_validation_paths):
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
                if path.is_symlink():
                    raise SystemExit(
                        f"Static scan symlink escapes repository root: {path}"
                    )
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


# Canonical baseline gate eligibility. The scanner and its wrapper must use this exact
# shared iterator so a non-applicable result cannot hide a different file universe.
BASELINE_GATE_RULES = {
    "secrets": ("*", (".zenflow", "traces", "docs/reusable-baseline/external-environment")),
    "large-files": ("*", (".zenflow", "traces", "docs/reusable-baseline/external-environment")),
    "forbidden-patterns": ("*.swift", ("Tests", ".zenflow", "docs/archive", "docs/reusable-baseline/external-environment")),
    "localization": ("*.swift", ("Tests", ".zenflow", "docs/reusable-baseline/external-environment")),
    "swiftui-hot-path-patterns": ("*.swift", ("Tests", ".zenflow", "docs/reusable-baseline/external-environment")),
}


def iter_baseline_gate_files(
    roots: Iterable[Path], gate: str, extra_excludes: set[str] | None = None,
) -> Iterable[Path]:
    """Yield the exact eligible universe shared by a named baseline gate and its wrapper."""
    if gate not in BASELINE_GATE_RULES:
        raise SystemExit(f"Unknown baseline gate: {gate}")
    pattern, excluded_substrings = BASELINE_GATE_RULES[gate]
    root = repo_root().resolve()
    roots = list(roots)
    ignored = ignored_untracked_paths(root, roots)
    submodules = submodule_paths(root)

    def excluded(path: Path) -> bool:
        relative = path.relative_to(root)
        def matches(value: str) -> bool:
            if value in {".zenflow", "traces"}:
                return value in relative.parts
            if value == "Tests":
                return any(part == "Tests" or part.endswith("Tests") or part.endswith("Tests.swift")
                           for part in relative.parts)
            return value in relative.as_posix()

        return any(part in (extra_excludes or set()) for part in relative.parts) or any(
            matches(value) for value in excluded_substrings
        )

    def on_walk_error(error: OSError) -> None:
        raise SystemExit(f"Cannot enumerate scan directory: {error.filename}") from error

    def checked_file(path: Path) -> Path | None:
        if (should_exclude(path) or excluded(path) or is_ignored_path(path, ignored)
                or is_submodule_path(path, submodules)):
            return None
        resolved = path.resolve()
        try:
            resolved.relative_to(root)
        except ValueError as error:
            raise SystemExit(f"Static scan symlink escapes repository root: {path}") from error
        if path.is_symlink() and not resolved.is_file():
            raise SystemExit(f"Static scan link is not a readable file: {path}")
        if path.is_symlink() and is_ignored_untracked_target(root, resolved, ignored):
            return None
        if not resolved.is_file():
            raise SystemExit(f"Static scan entry is not a readable file: {path}")
        if resolved.match(pattern) and not excluded(resolved):
            return resolved
        return None

    seen: set[Path] = set()
    for scan_root in roots:
        lexical = scan_root.absolute()
        if (should_exclude(lexical) or excluded(lexical) or is_ignored_path(lexical, ignored)
                or is_submodule_path(lexical, submodules)):
            continue
        if lexical.is_file():
            candidate = checked_file(lexical)
            if candidate is not None and candidate not in seen:
                seen.add(candidate)
                yield candidate
            continue
        if lexical.is_symlink():
            raise SystemExit(f"Directory symlink cannot provide complete scan evidence: {lexical}")
        # Walk with explicit error handling: pathlib.rglob may silently skip
        # inaccessible directories and incorrectly leave an empty success.
        for directory, directories, files in os.walk(lexical, topdown=True, onerror=on_walk_error, followlinks=False):
            parent = Path(directory)
            kept = []
            for name in directories:
                child = parent / name
                if (should_exclude(child) or excluded(child) or is_ignored_path(child, ignored)
                        or is_submodule_path(child, submodules)):
                    continue
                if child.is_symlink():
                    raise SystemExit(f"Directory symlink cannot provide complete scan evidence: {child}")
                kept.append(name)
            directories[:] = kept
            for name in files:
                candidate = checked_file(parent / name)
                if candidate is not None and candidate not in seen:
                    seen.add(candidate)
                    yield candidate


def display_path(path: Path) -> str:
    """Format paths consistently for gate output and reviewer triage."""
    root = repo_root()
    return f"./{path.relative_to(root)}"
