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
import re
import subprocess
from functools import lru_cache
from pathlib import Path
from typing import Iterable, Iterator


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


DEFAULT_MAX_FINDINGS = 150
MAX_FINDINGS_LIMIT = 1000
MAX_SCAN_BYTES = 5 * 1024 * 1024
FINDING_SEVERITIES = ("blocking", "warning", "review-candidate")
GIT_METADATA_CHUNK_BYTES = 64 * 1024
MAX_GIT_PATH_RECORD_BYTES = 16 * 1024
MAX_IGNORED_METADATA_BYTES = 2 * 1024 * 1024
MAX_IGNORED_METADATA_PATHS = 8192
MAX_SUBMODULE_PATHS = 256


def nonnegative_findings_limit(raw: str) -> int:
    """Reject output limits outside the bounded retained-findings envelope."""
    try:
        value = int(raw)
    except ValueError as error:
        raise argparse.ArgumentTypeError("expected a nonnegative integer") from error
    if not 0 <= value <= MAX_FINDINGS_LIMIT:
        raise argparse.ArgumentTypeError(f"expected an integer from 0 to {MAX_FINDINGS_LIMIT}")
    return value


class FindingCollector:
    """Count findings and their severities before retaining bounded examples.

    Gate findings default to blocking; a recognized first tuple field carries an explicit
    severity, as used by the SwiftUI review-candidate scanner.
    """

    def __init__(self, limit: int = DEFAULT_MAX_FINDINGS) -> None:
        if not 0 <= limit <= MAX_FINDINGS_LIMIT:
            raise ValueError(f"limit must be between 0 and {MAX_FINDINGS_LIMIT}")
        self.limit = limit
        self.items: list[object] = []
        self.total = 0
        self.severity_totals = {severity: 0 for severity in FINDING_SEVERITIES}

    def add(self, finding: object) -> None:
        self.total += 1
        candidate = finding[0] if isinstance(finding, (tuple, list)) and finding else None
        severity = candidate if isinstance(candidate, str) and candidate in self.severity_totals else "blocking"
        self.severity_totals[severity] += 1
        if len(self.items) < self.limit:
            self.items.append(finding)

    @property
    def omitted(self) -> int:
        return self.total - len(self.items)

    def summary(self) -> str:
        severity_totals = ", ".join(
            f"{severity}={self.severity_totals[severity]}" for severity in FINDING_SEVERITIES
        )
        return (
            f"Finding counts: total={self.total}, reported={len(self.items)}, omitted={self.omitted}\n"
            f"Finding severity totals: {severity_totals}"
        )


class OversizedScanInputError(Exception):
    """Raised when a source file exceeds the fixed scanner read envelope."""


def read_text_limited(path: Path, max_bytes: int = MAX_SCAN_BYTES) -> str:
    """Read at most max_bytes plus one sentinel byte and decode like read_text(errors=ignore)."""
    with path.open("rb") as source:
        data = source.read(max_bytes + 1)
    if len(data) > max_bytes:
        raise OversizedScanInputError(f"input exceeds {max_bytes} bytes")
    text = data.decode("utf-8", errors="ignore")
    return text.replace("\r\n", "\n").replace("\r", "\n")


def iter_matches_with_lines(text: str, pattern: re.Pattern[str]) -> Iterator[tuple[re.Match[str], int]]:
    """Yield regex matches with one-pass line numbers instead of rescanning every prefix."""
    previous_start = 0
    line = 1
    for match in pattern.finditer(text):
        line += text.count("\n", previous_start, match.start())
        yield match, line
        previous_start = match.start()


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
        default=DEFAULT_MAX_FINDINGS,
        help=f"Maximum findings to retain and report (0-{MAX_FINDINGS_LIMIT}); scan totals remain complete.",
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


def iter_git_nul_records(
    command: list[str],
    failure_message: str,
    *,
    max_output_bytes: int | None = None,
    max_records: int | None = None,
) -> Iterator[bytes]:
    """Stream NUL-delimited Git records with bounded working memory."""
    try:
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    except OSError as error:
        raise SystemExit(failure_message) from error
    if process.stdout is None:
        process.kill()
        process.wait()
        raise SystemExit(failure_message)

    buffered = bytearray()
    bytes_read = 0
    record_count = 0
    try:
        while True:
            try:
                chunk = process.stdout.read(GIT_METADATA_CHUNK_BYTES)
            except OSError as error:
                raise SystemExit(failure_message) from error
            if not chunk:
                break
            bytes_read += len(chunk)
            if max_output_bytes is not None and bytes_read > max_output_bytes:
                raise SystemExit(f"{failure_message} Git output exceeded its byte limit.")
            buffered.extend(chunk)
            offset = 0
            while True:
                boundary = buffered.find(b"\0", offset)
                if boundary < 0:
                    break
                if boundary - offset > MAX_GIT_PATH_RECORD_BYTES:
                    raise SystemExit(f"{failure_message} Git path record exceeded its byte limit.")
                record = bytes(buffered[offset:boundary])
                offset = boundary + 1
                if not record:
                    continue
                record_count += 1
                if max_records is not None and record_count > max_records:
                    raise SystemExit(f"{failure_message} Git record count exceeded its limit.")
                yield record
            if offset:
                del buffered[:offset]
            if len(buffered) > MAX_GIT_PATH_RECORD_BYTES:
                raise SystemExit(f"{failure_message} Git path record exceeded its byte limit.")

        return_code = process.wait()
        if buffered:
            raise SystemExit(f"{failure_message} Git output was not NUL-terminated.")
        if return_code != 0:
            raise SystemExit(failure_message)
    finally:
        process.stdout.close()
        if process.poll() is None:
            try:
                process.terminate()
            except OSError:
                pass
            process.wait()


def ignored_untracked_paths(root: Path, roots: Iterable[Path]) -> set[Path]:
    """Return bounded Git-ignored untracked paths excluded from scan evidence."""
    pathspecs = []
    for scan_root in roots:
        try:
            relative = scan_root.relative_to(root)
        except ValueError:
            continue
        pathspecs.append(relative.as_posix())
    ignored: set[Path] = set()
    for raw_path in iter_git_nul_records(
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
        "Cannot establish Git-ignored scan exclusions.",
        max_output_bytes=MAX_IGNORED_METADATA_BYTES,
        max_records=MAX_IGNORED_METADATA_PATHS,
    ):
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
    found = False
    for entry in iter_git_nul_records(
        ["git", "-C", str(root), "ls-files", "-t", "-z", "--", *pathspecs],
        "Cannot establish Git sparse-checkout exclusions.",
    ):
        found = found or entry.startswith(b"S ")
    return found


def has_assume_unchanged_entries(root: Path, roots: Iterable[Path]) -> bool:
    """Reject index entries whose mutable bytes Git is configured not to notice."""
    pathspecs = []
    for scan_root in roots:
        try:
            relative = scan_root.relative_to(root)
        except ValueError:
            continue
        pathspecs.append(relative.as_posix())
    found = False
    for entry in iter_git_nul_records(
        ["git", "-C", str(root), "ls-files", "-v", "-z", "--", *pathspecs],
        "Cannot establish Git assume-unchanged exclusions.",
    ):
        found = found or entry[:1].islower()
    return found


def is_ignored_path(path: Path, ignored_paths: set[Path]) -> bool:
    """Match ignored entries lexically so an ignored symlink cannot hide its tracked target."""
    return any(candidate in ignored_paths for candidate in (path, *path.parents))


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


@lru_cache(maxsize=1)
def submodule_paths(root: Path) -> frozenset[Path]:
    """Return tracked Gitlinks so mutable nested worktrees never enter a parent receipt."""
    paths: set[Path] = set()
    too_many_paths = False
    for entry in iter_git_nul_records(
        ["git", "-C", str(root), "ls-files", "--stage", "-z"],
        "Cannot establish Git submodule scan exclusions.",
    ):
        header, separator, raw_path = entry.partition(b"\t")
        if not separator:
            raise SystemExit("Cannot decode Git submodule scan exclusions.")
        if header.split(b" ", maxsplit=1)[0] == b"160000":
            path = root / raw_path.decode("utf-8", errors="surrogateescape")
            if path not in paths:
                if len(paths) == MAX_SUBMODULE_PATHS:
                    too_many_paths = True
                else:
                    paths.add(path)
    if too_many_paths:
        raise SystemExit("Git submodule scan exclusions exceed the configured path limit.")
    return frozenset(paths)


def is_submodule_path(path: Path, paths: frozenset[Path]) -> bool:
    """Return whether a lexical path belongs to a tracked nested worktree."""
    return any(candidate in paths for candidate in (path, *path.parents))


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
    ordered_roots = sorted(
        {scan_root.absolute() for scan_root in roots},
        key=lambda scan_root: (len(scan_root.parts), scan_root.as_posix()),
    )
    roots = []
    resolved_file_roots: set[Path] = set()
    for candidate_root in ordered_roots:
        if any(
            parent.is_dir()
            and not parent.is_symlink()
            and candidate_root.is_relative_to(parent)
            for parent in roots
        ):
            continue
        if candidate_root.is_file():
            resolved_file = candidate_root.resolve()
            if resolved_file in resolved_file_roots:
                continue
            resolved_file_roots.add(resolved_file)
        roots.append(candidate_root)
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

    for scan_root in roots:
        lexical = scan_root.absolute()
        if (should_exclude(lexical) or excluded(lexical) or is_ignored_path(lexical, ignored)
                or is_submodule_path(lexical, submodules)):
            continue
        if lexical.is_file():
            candidate = checked_file(lexical)
            if candidate is not None:
                yield candidate
            continue
        if lexical.is_symlink():
            raise SystemExit(f"Directory symlink cannot provide complete scan evidence: {lexical}")
        # Walk with explicit error handling: pathlib.rglob may silently skip
        # inaccessible directories and incorrectly leave an empty success.
        for directory, directories, files in os.walk(lexical, topdown=True, onerror=on_walk_error, followlinks=False):
            directories.sort()
            files.sort()
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
                if candidate is not None:
                    yield candidate


def display_path(path: Path) -> str:
    """Format paths consistently for gate output and reviewer triage."""
    root = repo_root()
    return f"./{path.relative_to(root)}"
