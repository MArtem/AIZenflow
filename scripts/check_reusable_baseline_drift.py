#!/usr/bin/env python3
"""Compare canonical reusable baseline files with an active worktree without modifying either."""

from __future__ import annotations

import argparse
import fnmatch
import json
import sys
from pathlib import Path
from typing import Any


DEFAULT_WORKTREE = Path(__file__).resolve().parents[1]
DEFAULT_POLICY = Path("docs/REUSABLE_BASELINE_POLICY.json")


def load_policy(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"cannot read baseline policy {path}: {error}") from error
    if not isinstance(value, dict):
        raise ValueError("baseline policy must contain a JSON object")
    return value


def matches(path: str, patterns: list[str]) -> bool:
    return any(fnmatch.fnmatch(path, pattern) for pattern in patterns)


def files_under(root: Path) -> dict[str, Path]:
    if not root.is_dir():
        return {}
    return {
        path.relative_to(root).as_posix(): path
        for path in root.rglob("*")
        if path.is_file()
    }


def compare(canonical_root: Path, worktree_root: Path, policy_path: Path) -> dict[str, Any]:
    canonical_root = canonical_root.resolve()
    worktree_root = worktree_root.resolve()
    policy = load_policy(policy_path.resolve())
    failures: list[str] = []
    if policy.get("schema_version") != 1:
        failures.append("REUSABLE_BASELINE_POLICY.json schema_version must be 1")

    ignored_patterns = [
        value for value in policy.get("ignored_local_patterns", []) if isinstance(value, str)
    ]
    result: dict[str, Any] = {
        "canonical_root": str(canonical_root),
        "worktree_root": str(worktree_root),
        "policy": str(policy_path.resolve()),
        "exact": [],
        "overlays": [],
        "canonical_only": [],
        "local_only": [],
        "missing": [],
        "stale": [],
        "unexpected": [],
        "failures": failures,
    }

    mappings = policy.get("file_mappings")
    if not isinstance(mappings, list):
        failures.append("file_mappings must be a list")
        mappings = []
    for mapping in mappings:
        if not isinstance(mapping, dict):
            failures.append("file_mappings entries must be objects")
            continue
        source_rel = mapping.get("source")
        target_rel = mapping.get("target")
        mode = mapping.get("mode")
        if not all(isinstance(value, str) for value in (source_rel, target_rel, mode)):
            failures.append(f"invalid file mapping: {mapping!r}")
            continue
        source = canonical_root / source_rel
        target = worktree_root / target_rel
        label = f"{source_rel} -> {target_rel}"
        if not source.is_file():
            failures.append(f"missing canonical source: {source_rel}")
        elif not target.is_file():
            result["missing"].append(label)
        elif mode == "exact":
            if source.read_bytes() == target.read_bytes():
                result["exact"].append(label)
            else:
                result["stale"].append(label)
        elif mode == "overlay":
            result["overlays"].append(label)
        else:
            failures.append(f"unsupported file mapping mode {mode!r}: {label}")

    trees = policy.get("tree_mappings")
    if not isinstance(trees, list):
        failures.append("tree_mappings must be a list")
        trees = []
    for mapping in trees:
        if not isinstance(mapping, dict):
            failures.append("tree_mappings entries must be objects")
            continue
        source_rel = mapping.get("source")
        target_rel = mapping.get("target")
        mode = mapping.get("default_mode")
        if not all(isinstance(value, str) for value in (source_rel, target_rel, mode)):
            failures.append(f"invalid tree mapping: {mapping!r}")
            continue
        if mode != "exact":
            failures.append(f"unsupported tree default_mode {mode!r}: {source_rel}")
            continue
        overlay_patterns = [
            value for value in mapping.get("overlay_patterns", []) if isinstance(value, str)
        ]
        canonical_only_patterns = [
            value for value in mapping.get("canonical_only_patterns", []) if isinstance(value, str)
        ]
        local_only_patterns = [
            value for value in mapping.get("local_only_patterns", []) if isinstance(value, str)
        ]
        source_root = canonical_root / source_rel
        target_root = worktree_root / target_rel
        source_files = files_under(source_root)
        target_files = files_under(target_root)
        if not source_root.is_dir():
            failures.append(f"missing canonical tree: {source_rel}")
            continue
        if not target_root.is_dir():
            result["missing"].append(f"{source_rel}/ -> {target_rel}/")
            continue

        for rel, source in sorted(source_files.items()):
            target = target_files.get(rel)
            label = f"{source_rel}/{rel} -> {target_rel}/{rel}"
            if matches(rel, canonical_only_patterns):
                result["canonical_only"].append(f"{source_rel}/{rel}")
                if target is not None:
                    result["unexpected"].append(f"{target_rel}/{rel} (declared canonical-only)")
            elif target is None:
                result["missing"].append(label)
            elif matches(rel, overlay_patterns):
                result["overlays"].append(label)
            elif source.read_bytes() == target.read_bytes():
                result["exact"].append(label)
            else:
                result["stale"].append(label)

        for rel in sorted(set(target_files) - set(source_files)):
            full_target = f"{target_rel}/{rel}"
            if matches(full_target, ignored_patterns) or matches(rel, ignored_patterns):
                continue
            if matches(rel, local_only_patterns):
                result["local_only"].append(full_target)
            else:
                result["unexpected"].append(full_target)

    for key in (
        "exact",
        "overlays",
        "canonical_only",
        "local_only",
        "missing",
        "stale",
        "unexpected",
        "failures",
    ):
        result[key] = sorted(set(result[key]))
    return result


def print_text(result: dict[str, Any]) -> None:
    print(f"Canonical baseline: {result['canonical_root']}")
    print(f"Active worktree: {result['worktree_root']}")
    for label, key in (
        ("Exact mirrors", "exact"),
        ("Allowed overlays", "overlays"),
        ("Canonical-only", "canonical_only"),
        ("Allowed local-only", "local_only"),
        ("Missing", "missing"),
        ("Stale", "stale"),
        ("Unexpected", "unexpected"),
        ("Policy failures", "failures"),
    ):
        values = result[key]
        print(f"{label}: {len(values)}")
        if key in {"missing", "stale", "unexpected", "failures"}:
            for value in values:
                print(f"- {value}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--canonical-root",
        required=True,
        type=Path,
        help="Canonical reusable/baseline directory.",
    )
    parser.add_argument(
        "--worktree-root",
        type=Path,
        default=DEFAULT_WORKTREE,
        help="Active project/worktree root.",
    )
    parser.add_argument(
        "--policy",
        type=Path,
        help="Policy JSON; defaults to canonical baseline docs/REUSABLE_BASELINE_POLICY.json.",
    )
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON.")
    args = parser.parse_args()
    policy = args.policy or (args.canonical_root / DEFAULT_POLICY)
    try:
        result = compare(args.canonical_root, args.worktree_root, policy)
    except ValueError as error:
        print(error, file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print_text(result)
    return 1 if any(result[key] for key in ("missing", "stale", "unexpected", "failures")) else 0


if __name__ == "__main__":
    sys.exit(main())
