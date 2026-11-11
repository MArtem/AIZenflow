#!/usr/bin/env python3
"""Owned JSON fixture only; separate processes demonstrate a file preservation contract.
Not a SwiftData/CoreData migration or a power-loss/disk-full guarantee.
"""
import argparse
import json
import os
from pathlib import Path
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["seed", "migrate", "verify"])
    parser.add_argument("root", type=Path)
    parser.add_argument("--fail-before-replace", action="store_true")
    args = parser.parse_args()
    root = args.root.absolute()
    # The user's approved fixture sandbox, never a production store or symlink.
    if ".zenflow" not in root.parts or root.is_symlink() or root.resolve() != root:
        raise ValueError("explicit real fixture root inside .zenflow required")
    marker = root / ".kb-migration-probe"
    legacy = {"version": 1, "folders": ["f1"],
              "notes": [{"id": "n1", "folder": "f1", "text": "Preserve me"}]}
    expected = {"version": 2, "folders": ["f1"],
                "notes": [{"id": "n1", "folderID": "f1", "body": "Preserve me"}]}
    if args.action == "seed":
        root.mkdir(parents=True, exist_ok=False)
        marker.write_text("owned-example-v1")
        (root / "old.json").write_text(json.dumps(legacy))
        return
    if marker.read_text() != "owned-example-v1":
        raise ValueError("not an owned fixture")
    if args.action == "verify":
        if json.loads((root / "store.json").read_text()) != expected:
            raise ValueError("reopened IDs/relationships/values differ")
        print("PASS file-backed new-process reopen")
        return
    old = json.loads((root / "old.json").read_text())
    # Intentionally exact tiny input envelope, not a general migration engine.
    if old != legacy:
        raise ValueError("unsupported or malformed old fixture")
    temporary = root / "store.pending"
    with temporary.open("x") as stream:
        json.dump(expected, stream)
    try:
        if args.fail_before_replace:
            raise OSError("injected before publication; not a real disk-full event")
        os.replace(temporary, root / "store.json")
    finally:
        temporary.unlink(missing_ok=True)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as error:
        print("FAIL fixture:", error)
        sys.exit(2)
