#!/usr/bin/env python3
"""Validate the canonical global documentation repository state.

This check prevents the specific failure mode where global documentation is
committed only locally and never pushed to GitHub.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


EXPECTED_REMOTE = "https://github.com/MArtem/AIZenflowDocumentation.git"
DEFAULT_DOCS_REPO = Path("/Users/Artem/.zenflow/worktrees/documentation-vault")


def run_git(repo: Path, *args: str) -> tuple[int, str, str]:
    completed = subprocess.run(
        ["git", *args],
        cwd=repo,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    return completed.returncode, completed.stdout.strip(), completed.stderr.strip()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "repo",
        nargs="?",
        default=DEFAULT_DOCS_REPO,
        type=Path,
        help="Local checkout of MArtem/AIZenflowDocumentation.",
    )
    args = parser.parse_args()
    repo = args.repo.resolve()

    failures: list[str] = []
    if not repo.is_dir():
        failures.append(f"missing documentation repo checkout: {repo}")
    else:
        code, top_level, error = run_git(repo, "rev-parse", "--show-toplevel")
        if code != 0:
            failures.append(f"{repo}: not a git repository: {error}")
        elif Path(top_level).resolve() != repo:
            failures.append(f"{repo}: git top-level is {top_level}")

        code, remote, error = run_git(repo, "remote", "get-url", "origin")
        if code != 0:
            failures.append(f"{repo}: cannot read origin remote: {error}")
        elif remote != EXPECTED_REMOTE:
            failures.append(f"{repo}: origin is `{remote}`, expected `{EXPECTED_REMOTE}`")

        code, branch, error = run_git(repo, "branch", "--show-current")
        if code != 0:
            failures.append(f"{repo}: cannot read branch: {error}")
        elif branch != "main":
            failures.append(f"{repo}: branch is `{branch}`, expected `main`")

        code, status, error = run_git(repo, "status", "--porcelain=v1")
        if code != 0:
            failures.append(f"{repo}: cannot read status: {error}")
        elif status:
            failures.append(f"{repo}: working tree is not clean")

        code, upstream_status, error = run_git(repo, "status", "--short", "--branch")
        if code != 0:
            failures.append(f"{repo}: cannot read upstream status: {error}")
        else:
            first_line = upstream_status.splitlines()[0] if upstream_status else ""
            if "ahead" in first_line or "behind" in first_line:
                failures.append(f"{repo}: upstream is not synced: {first_line}")

    if failures:
        print("Documentation remote state FAILED:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(f"Documentation remote state OK: {repo}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
