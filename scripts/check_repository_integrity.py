#!/usr/bin/env python3
"""Produce a read-only integrity receipt for explicitly allowlisted Git worktrees.

The checker never fetches, writes, stages, cleans, or removes anything.  Each repository is
provided as ``NAME|ABSOLUTE_PATH|BRANCH|REMOTE``.  A PASS requires an authenticated local branch
and matching remote branch SHA, a checkout whose current HEAD agrees when that branch is checked
out, and no staged/unstaged tracked deletions or untracked files.  Ignored files are deliberately
excluded from the cleanliness claim.  Dirty user-owned files are reported as FAIL, not silently
preserved as PASS.  Missing or unavailable identity evidence is BLOCKED.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any


ALLOWED_ROOT = Path("/Users/Artem/.zenflow").resolve()
FORBIDDEN_ROOT = ALLOWED_ROOT / "secrets"
MAX_REPOSITORIES = 32
MAX_OUTPUT_BYTES = 256 * 1024
MAX_ERROR_LENGTH = 1_024
COMMAND_TIMEOUT_SECONDS = 5
SHA_PATTERN = re.compile(r"^[0-9a-f]{40}$")


class IntegrityError(RuntimeError):
    """A bounded, read-only inspection failure."""


@dataclass(frozen=True)
class RepositorySpec:
    name: str
    path: Path
    branch: str
    remote: str


def bounded_text(value: str) -> str:
    return value.strip()[:MAX_ERROR_LENGTH]


def safe_error(value: str) -> str:
    """Keep remote credentials out of a diagnostic receipt."""
    redacted = re.sub(r"(https?://)([^/@\s]+)@", r"\1<redacted>@", value)
    return bounded_text(redacted)


def validate_path(path: Path) -> Path:
    resolved = path.expanduser().resolve()
    try:
        resolved.relative_to(ALLOWED_ROOT)
    except ValueError as error:
        raise IntegrityError(f"repository path escapes allowed sandbox: {resolved}") from error
    try:
        resolved.relative_to(FORBIDDEN_ROOT)
    except ValueError:
        pass
    else:
        raise IntegrityError("repository path is inside the forbidden secrets directory")
    if not resolved.is_dir():
        raise IntegrityError(f"repository path is not a directory: {resolved}")
    return resolved


def parse_spec(raw: str) -> RepositorySpec:
    parts = raw.split("|")
    if len(parts) != 4 or any(not part.strip() for part in parts):
        raise IntegrityError("repository must use NAME|ABSOLUTE_PATH|BRANCH|REMOTE")
    name, raw_path, branch, remote = (part.strip() for part in parts)
    if len(name) > MAX_ERROR_LENGTH or not re.fullmatch(r"[A-Za-z0-9._-]+", name):
        raise IntegrityError("repository name is malformed")
    if not raw_path.startswith("/"):
        raise IntegrityError(f"{name}: repository path must be absolute")
    if len(branch) > MAX_ERROR_LENGTH or branch.startswith("-"):
        raise IntegrityError(f"{name}: branch is malformed")
    if len(remote) > MAX_ERROR_LENGTH or not re.fullmatch(r"[A-Za-z0-9._-]+", remote):
        raise IntegrityError(f"{name}: remote name is malformed")
    return RepositorySpec(name, validate_path(Path(raw_path)), branch, remote)


def git_environment(allow_credential_helper: bool = False) -> dict[str, str]:
    environment = os.environ.copy()
    for key in (
        "GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE", "GIT_OBJECT_DIRECTORY",
        "GIT_ALTERNATE_OBJECT_DIRECTORIES", "GIT_CONFIG_GLOBAL", "GIT_CONFIG_SYSTEM",
        "GIT_CONFIG_COUNT", "GIT_CONFIG_PARAMETERS",
    ):
        environment.pop(key, None)
    environment.update({"GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_SYSTEM": os.devnull, "GIT_NO_REPLACE_OBJECTS": "1"})
    if allow_credential_helper:
        environment["GIT_TERMINAL_PROMPT"] = "0"
    else:
        environment["GIT_CONFIG_GLOBAL"] = os.devnull
    return environment


def run_git(
    spec: RepositorySpec,
    arguments: list[str],
    maximum_bytes: int = MAX_OUTPUT_BYTES,
    allowed_returncodes: set[int] | None = None,
    allow_credential_helper: bool = False,
) -> str:
    try:
        result = subprocess.run(
            ["/usr/bin/git", "-C", str(spec.path), *arguments],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=git_environment(allow_credential_helper=allow_credential_helper),
            timeout=COMMAND_TIMEOUT_SECONDS,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as error:
        raise IntegrityError(f"{spec.name}: bounded Git command failed: {error}") from error
    if len(result.stdout) > maximum_bytes or len(result.stderr) > MAX_ERROR_LENGTH:
        raise IntegrityError(f"{spec.name}: Git output exceeded the immutable limit")
    allowed = {0} if allowed_returncodes is None else allowed_returncodes
    if result.returncode not in allowed:
        message = result.stderr.decode("utf-8", errors="replace")
        raise IntegrityError(f"{spec.name}: {safe_error(message) or 'Git command failed'}")
    try:
        return result.stdout.decode("utf-8", errors="strict")
    except UnicodeDecodeError as error:
        raise IntegrityError(f"{spec.name}: Git output is not valid UTF-8") from error


def require_sha(spec: RepositorySpec, value: str, label: str) -> str:
    sha = value.strip()
    if not SHA_PATTERN.fullmatch(sha):
        raise IntegrityError(f"{spec.name}: {label} is not a full lowercase commit SHA")
    return sha


def tracked_deletions(spec: RepositorySpec) -> tuple[list[str], list[str]]:
    status = run_git(spec, ["status", "--porcelain=v1", "--untracked-files=all"])
    deletions: set[str] = set()
    dirty_entries: list[str] = []
    for line in status.splitlines():
        if len(line) < 3:
            raise IntegrityError(f"{spec.name}: malformed porcelain status output")
        state, path = line[:2], line[3:]
        if not path:
            raise IntegrityError(f"{spec.name}: status entry has no path")
        dirty_entries.append(line[: MAX_ERROR_LENGTH])
        if "D" in state:
            deletions.add(path)
    return sorted(deletions), dirty_entries


def inspect(spec: RepositorySpec) -> dict[str, Any]:
    reported_root = Path(run_git(spec, ["rev-parse", "--show-toplevel" ]).strip()).resolve()
    if reported_root != spec.path:
        raise IntegrityError(f"{spec.name}: Git top-level is {reported_root}, expected {spec.path}")

    run_git(spec, ["check-ref-format", "--branch", spec.branch])
    local_sha = require_sha(
        spec,
        run_git(spec, ["rev-parse", "--verify", "--end-of-options", f"{spec.branch}^{{commit}}"]),
        "local branch revision",
    )
    head_sha = require_sha(spec, run_git(spec, ["rev-parse", "HEAD"]), "HEAD revision")
    current_branch = run_git(
        spec,
        ["symbolic-ref", "--quiet", "--short", "HEAD"],
        allowed_returncodes={0, 1},
    ).strip()
    deletions, dirty_entries = tracked_deletions(spec)
    clean = not dirty_entries
    try:
        remote_url = run_git(spec, ["remote", "get-url", spec.remote]).strip()
    except IntegrityError as error:
        return {
            "name": spec.name,
            "path": str(spec.path),
            "branch": spec.branch,
            "remote": spec.remote,
            "currentBranch": current_branch or None,
            "headSHA": head_sha,
            "localBranchSHA": local_sha,
            "parity": None,
            "clean": clean,
            "trackedDeletions": deletions,
            "dirtyEntries": dirty_entries[:64],
            "status": "BLOCKED",
            "message": "remote identity is unavailable; local facts are recorded but parity is unproven",
            "remoteError": safe_error(str(error)),
        }
    if not remote_url:
        raise IntegrityError(f"{spec.name}: remote URL is empty")

    try:
        remote_output = run_git(
            spec,
            ["ls-remote", "--heads", spec.remote, f"refs/heads/{spec.branch}"],
            maximum_bytes=MAX_ERROR_LENGTH,
            allow_credential_helper=True,
        )
    except IntegrityError as error:
        return {
            "name": spec.name,
            "path": str(spec.path),
            "branch": spec.branch,
            "remote": spec.remote,
            "currentBranch": current_branch or None,
            "headSHA": head_sha,
            "localBranchSHA": local_sha,
            "parity": None,
            "clean": clean,
            "trackedDeletions": deletions,
            "dirtyEntries": dirty_entries[:64],
            "status": "BLOCKED",
            "message": "remote branch is unavailable; local facts are recorded but parity is unproven",
            "remoteError": safe_error(str(error)),
        }
    remote_lines = [line for line in remote_output.splitlines() if line.strip()]
    if len(remote_lines) != 1:
        raise IntegrityError(f"{spec.name}: remote branch ref is missing or ambiguous")
    remote_fields = remote_lines[0].split("\t")
    if len(remote_fields) != 2 or remote_fields[1] != f"refs/heads/{spec.branch}":
        raise IntegrityError(f"{spec.name}: remote branch ref has an unexpected shape")
    remote_sha = require_sha(spec, remote_fields[0], "remote branch revision")

    branch_head_matches = current_branch != spec.branch or head_sha == local_sha
    parity = local_sha == remote_sha
    clean = not dirty_entries
    if not parity:
        status = "FAIL"
        message = "local and remote target branch revisions differ"
    elif deletions:
        status = "FAIL"
        message = "tracked deletion diff is present"
    elif not clean:
        status = "FAIL"
        message = "working tree is dirty; ignored files are excluded from this claim"
    elif not branch_head_matches:
        status = "BLOCKED"
        message = "checked-out target branch HEAD does not match its local branch ref"
    else:
        status = "PASS"
        message = "exact target ref is clean and local/remote revisions are identical"

    return {
        "name": spec.name,
        "path": str(spec.path),
        "branch": spec.branch,
        "remote": spec.remote,
        "currentBranch": current_branch or None,
        "headSHA": head_sha,
        "localBranchSHA": local_sha,
        "remoteBranchSHA": remote_sha,
        "parity": parity,
        "clean": clean,
        "trackedDeletions": deletions,
        "dirtyEntries": dirty_entries[:64],
        "status": status,
        "message": message,
    }


def emit(report: dict[str, Any], exit_code: int) -> int:
    encoded = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True)
    if len(encoded.encode("utf-8")) > MAX_OUTPUT_BYTES:
        fallback = {"command": report["command"], "schemaVersion": 1, "status": "BLOCKED", "message": "receipt exceeded immutable output limit"}
        print(json.dumps(fallback, sort_keys=True))
        return 2
    print(encoded)
    return exit_code


def main() -> int:
    parser = argparse.ArgumentParser(description="Read-only exact-SHA repository integrity receipt")
    parser.add_argument(
        "--repository",
        action="append",
        required=True,
        metavar="NAME|ABSOLUTE_PATH|BRANCH|REMOTE",
        help="Explicit allowlisted repository specification; repeat for each target.",
    )
    args = parser.parse_args()
    if len(args.repository) > MAX_REPOSITORIES:
        return emit({"command": "repository-integrity", "schemaVersion": 1, "status": "BLOCKED", "message": "repository count exceeds immutable limit"}, 2)

    try:
        specs = [parse_spec(raw) for raw in args.repository]
        if len({spec.name for spec in specs}) != len(specs):
            raise IntegrityError("repository names must be unique")
        results: list[dict[str, Any]] = []
        blocked: list[str] = []
        for spec in sorted(specs, key=lambda item: item.name):
            try:
                results.append(inspect(spec))
            except IntegrityError as error:
                results.append({
                    "name": spec.name,
                    "path": str(spec.path),
                    "branch": spec.branch,
                    "remote": spec.remote,
                    "status": "BLOCKED",
                    "message": "repository identity could not be completely inspected",
                    "error": safe_error(str(error)),
                })
                blocked.append(str(error))
        returned_blockers = [
            safe_error(result.get("remoteError", ""))
            for result in results
            if result.get("status") == "BLOCKED" and result.get("remoteError")
        ]
        if blocked or returned_blockers or any(result.get("status") == "BLOCKED" for result in results):
            report = {
                "command": "repository-integrity",
                "schemaVersion": 1,
                "status": "BLOCKED",
                "repositories": results,
                "errors": (blocked + returned_blockers)[:MAX_REPOSITORIES],
                "message": "complete integrity evidence was not available for every allowlisted repository",
            }
            return emit(report, 2)
        overall = "PASS" if all(result["status"] == "PASS" for result in results) else "FAIL"
        message = "all allowlisted repositories passed exact-SHA integrity checks" if overall == "PASS" else "one or more allowlisted repositories require review"
        return emit({
            "command": "repository-integrity",
            "schemaVersion": 1,
            "status": overall,
            "repositories": results,
            "message": message,
        }, 0 if overall == "PASS" else 1)
    except IntegrityError as error:
        return emit({
            "command": "repository-integrity",
            "schemaVersion": 1,
            "status": "BLOCKED",
            "repositories": [],
            "errors": [safe_error(str(error))],
            "message": "allowlist or repository identity could not be validated",
        }, 2)


if __name__ == "__main__":
    sys.exit(main())
