#!/usr/bin/env python3
"""Inactive, explicit per-Xcode-project reference mode control.

This is not an installed Codex command or a project entrypoint. Importing it has no
side effects. A caller must have the user's authority for each state transition.
"""

from __future__ import annotations

import argparse
from contextlib import contextmanager
import fcntl
import hashlib
import json
import os
from pathlib import Path
import stat
import subprocess
import sys
import tempfile


ZENFLOW = Path("/Users/Artem/.zenflow")
STATE_DIR = ZENFLOW / "worktrees/documentation-vault/tasks/reference-status"
MAX_RECORD_BYTES = 1024
SCHEMA_FIELDS = {"schema_version", "mode", "profile", "scope_fingerprint"}


class ModeError(Exception):
    """A scoped, user-reportable failure without record contents."""


def _inside(path: Path, boundary: Path) -> bool:
    return path == boundary or boundary in path.parents


def _no_symlink_components(path: Path) -> None:
    current = Path(path.anchor)
    for part in path.parts[1:]:
        current /= part
        if stat.S_ISLNK(current.lstat().st_mode):
            raise ModeError("symlinked path component")


def _sha(prefix: str, kind: str, component: str, relative: str) -> str:
    value = "\0".join((prefix, kind, component, relative)).encode("utf-8")
    return hashlib.sha256(value).hexdigest()


def _git(root: Path, argument: str) -> str | None:
    result = subprocess.run(
        ["git", "-C", str(root), "rev-parse", "--path-format=absolute", argument],
        capture_output=True, text=True, timeout=5, check=False,
    )
    if result.returncode:
        return None
    value = result.stdout.strip()
    return value if value and "\n" not in value else None


def scope(root_arg: str, selector_arg: str) -> tuple[str, str]:
    root = Path(os.path.abspath(root_arg))
    if not _inside(root, ZENFLOW):
        raise ModeError("project root outside allowed boundary")
    _no_symlink_components(root)
    if not root.is_dir():
        raise ModeError("project root is not a directory")
    selector = Path(selector_arg)
    if selector.is_absolute() or not selector.parts or any(
        part in {"", ".", ".."} for part in selector.parts
    ):
        raise ModeError("selector must be a repository-relative project path")
    project = root / selector
    if not _inside(project, root):
        raise ModeError("project selector escapes root")
    _no_symlink_components(project)
    if selector.name.endswith(".xcodeproj"):
        if not project.is_dir():
            raise ModeError("selected Xcode project does not exist")
        project_type = "xcodeproj"
    elif selector.name == "Package.swift":
        if not project.is_file():
            raise ModeError("selected Swift package does not exist")
        project_type = "package"
    else:
        raise ModeError("select an exact .xcodeproj or Package.swift")
    relative = selector.as_posix()

    git_root = _git(root, "--show-toplevel")
    if git_root is not None and Path(git_root) == root:
        common = _git(root, "--git-common-dir")
        if common is None:
            raise ModeError("Git common directory unavailable")
        component = Path(os.path.abspath(common))
        if not _inside(component, ZENFLOW):
            raise ModeError("Git common directory outside allowed boundary")
        _no_symlink_components(component)
        root_kind = "git"
    else:
        if (os.path.lexists(root / ".git")
                or (git_root is not None and _inside(Path(git_root), ZENFLOW))):
            raise ModeError("ambiguous Git repository")
        component = root
        root_kind = "local"
    component_stat = component.lstat()
    if not stat.S_ISDIR(component_stat.st_mode):
        raise ModeError("identity component is not a directory")
    kind = f"{root_kind}-{project_type}"
    key = _sha("ios-reference-project-v1", kind, str(component), relative)
    fingerprint = _sha(
        "ios-reference-object-v1", kind,
        f"{component_stat.st_dev}\0{component_stat.st_ino}", relative,
    )
    return key, fingerprint


def _unique_pairs(pairs: list[tuple[str, object]]) -> dict:
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("duplicate field")
        result[key] = value
    return result


def _record(directory_fd: int, name: str, fingerprint: str) -> tuple[str, dict | None]:
    try:
        fd = os.open(name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=directory_fd)
    except FileNotFoundError:
        return "UNSET", None
    except OSError:
        return "UNSET/invalid", None
    try:
        info = os.fstat(fd)
        if not stat.S_ISREG(info.st_mode) or info.st_size > MAX_RECORD_BYTES:
            return "UNSET/invalid", None
        with os.fdopen(fd, "rb", closefd=False) as stream:
            raw = stream.read(MAX_RECORD_BYTES + 1)
        if len(raw) > MAX_RECORD_BYTES:
            return "UNSET/invalid", None
        value = json.loads(raw.decode("utf-8"), object_pairs_hook=_unique_pairs)
        if not isinstance(value, dict) or set(value) != SCHEMA_FIELDS:
            return "UNSET/invalid", None
        if type(value["schema_version"]) is not int or value["schema_version"] != 1:
            return "UNSET/invalid", None
        if value["mode"] not in ("ON", "OFF") or value["profile"] not in (
            "AUTO", "ADVISORY"
        ):
            return "UNSET/invalid", None
        if value["scope_fingerprint"] != fingerprint:
            return "UNSET/invalid", None
        return value["mode"], value
    except (OSError, UnicodeError, ValueError, TypeError):
        return "UNSET/invalid", None
    finally:
        os.close(fd)


@contextmanager
def _locked_state(state_dir: Path, exclusive: bool):
    _no_symlink_components(state_dir)
    candidate = ZENFLOW
    for part in ("", *state_dir.relative_to(ZENFLOW).parts[:-1]):
        if part:
            candidate /= part
        parent_info = candidate.lstat()
        if (parent_info.st_uid not in (0, os.geteuid())
                or parent_info.st_mode & (stat.S_IWGRP | stat.S_IWOTH)):
            raise ModeError("state parent writable by another UID")
    info = state_dir.lstat()
    if not stat.S_ISDIR(info.st_mode) or info.st_uid not in (0, os.geteuid()):
        raise ModeError("untrusted state directory")
    if info.st_mode & (stat.S_IWGRP | stat.S_IWOTH):
        raise ModeError("state directory writable by another UID")
    fd = os.open(state_dir, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    try:
        try:
            fcntl.flock(fd, (fcntl.LOCK_EX if exclusive else fcntl.LOCK_SH) | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise ModeError("state lock busy; retry explicitly") from error
        yield fd
    finally:
        fcntl.flock(fd, fcntl.LOCK_UN)
        os.close(fd)


def _write(directory_fd: int, state_dir: Path, name: str, value: dict) -> None:
    payload = (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode()
    if len(payload) > MAX_RECORD_BYTES:
        raise ModeError("record size exceeds bound")
    fd, temporary = tempfile.mkstemp(prefix=".reference-mode-", dir=state_dir)
    try:
        os.fchmod(fd, 0o600)
        with os.fdopen(fd, "wb") as stream:
            stream.write(payload)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, state_dir / name)
        os.fsync(directory_fd)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def operate(
    command: str, root: str, selector: str, state_dir: Path = STATE_DIR,
    recovery_mode: str | None = None,
) -> dict:
    if command == "recover":
        raise ModeError("recovery disabled; invalid record preserved unchanged")
    key, fingerprint = scope(root, selector)
    name = f"{key}.json"
    write = command in {"on", "off", "auto", "advisory"}
    if command not in {"status", "on", "off", "auto", "advisory", "config", "recover"}:
        raise ModeError("unsupported command")
    if recovery_mode is not None:
        raise ModeError("mode option is only accepted by the disabled recovery command")
    if not _inside(state_dir, ZENFLOW):
        raise ModeError("state directory outside allowed boundary")
    with _locked_state(state_dir, write) as fd:
        if write and scope(root, selector) != (key, fingerprint):
            raise ModeError("project identity changed before transition")
        mode, current = _record(fd, name, fingerprint)
        if not write:
            result = {"status": mode, "profile": current["profile"] if current else None}
            if command == "config":
                result["safety"] = "local rules first; no implicit build/test/agent/Git/host authority"
            return result
        if mode == "UNSET/invalid":
            raise ModeError("invalid record preserved; recovery disabled")
        if command in {"auto", "advisory"} and mode != "ON":
            raise ModeError("profile change requires ON mode")
        updated = {
            "schema_version": 1,
            "mode": mode if command in {"auto", "advisory"} else command.upper(),
            "profile": (command.upper() if command in {"auto", "advisory"}
                        else current["profile"] if current else "AUTO"),
            "scope_fingerprint": fingerprint,
        }
        _write(fd, state_dir, name, updated)
        return {"status": updated["mode"], "profile": updated["profile"]}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("status", "on", "off", "auto", "advisory", "config", "recover"))
    parser.add_argument("--root", required=True, help="exact authorized repository root")
    parser.add_argument("--project", required=True, help="repository-relative .xcodeproj or Package.swift")
    parser.add_argument("--mode", choices=("ON", "OFF"), help="required explicit recovery choice")
    arguments = parser.parse_args(argv)
    try:
        result = operate(arguments.command, arguments.root, arguments.project,
                         recovery_mode=arguments.mode)
    except (ModeError, OSError, subprocess.TimeoutExpired) as error:
        print(json.dumps({"status": "UNKNOWN", "error": str(error)}), file=sys.stderr)
        return 2
    print(json.dumps(result, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
