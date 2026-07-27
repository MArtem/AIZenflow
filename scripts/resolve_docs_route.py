#!/usr/bin/env python3
"""Resolve one or more documentation routes into an ordered, deduplicated file list."""

from __future__ import annotations

import argparse
import fnmatch
import json
import sys
from pathlib import Path
from typing import Any


DEFAULT_ROOT = Path(__file__).resolve().parents[1]
ROUTES_REL = Path("docs/TASK_DOCUMENT_ROUTES.json")
LEVELS_REL = Path("docs/DOCUMENT_ROUTING_REGISTRY.json")


def load_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"cannot read {path}: {error}") from error
    if not isinstance(value, dict):
        raise ValueError(f"{path} must contain a JSON object")
    return value


def relative_path(root: Path, value: str) -> Path:
    if not isinstance(value, str) or not value.startswith("./"):
        raise ValueError(f"documentation path must start with ./: {value!r}")
    return root / value[2:]


def ordered_unique(values: list[str]) -> tuple[list[str], list[str]]:
    result: list[str] = []
    duplicates: list[str] = []
    seen: set[str] = set()
    for value in values:
        if value in seen:
            if value not in duplicates:
                duplicates.append(value)
            continue
        seen.add(value)
        result.append(value)
    return result, duplicates


def discover_task_id(root: Path, requested: str | None) -> tuple[str | None, list[str]]:
    notes: list[str] = []
    if requested:
        if requested in {".", ".."} or Path(requested).name != requested:
            raise ValueError(f"task ID must be one directory name: {requested!r}")
        return requested, notes
    task_root = root / ".zenflow" / "tasks"
    if not task_root.is_dir():
        notes.append("dynamic task documents skipped: .zenflow/tasks is absent")
        return None, notes
    candidates = sorted(
        child.name
        for child in task_root.iterdir()
        if child.is_dir() and ((child / "handoff.md").is_file() or (child / "plan.md").is_file())
    )
    if len(candidates) == 1:
        return candidates[0], notes
    if not candidates:
        notes.append("dynamic task documents skipped: no task handoff/plan found")
    else:
        notes.append("dynamic task documents skipped: multiple task IDs found; pass --task-id")
    return None, notes


def is_classified(path: str, levels: dict[str, Any]) -> bool:
    for level in ("level0", "level1", "level2", "level3"):
        if path in levels.get(level, []):
            return True
    for patterns in levels.get("path_patterns", {}).values():
        if not isinstance(patterns, list):
            continue
        if any(fnmatch.fnmatch(path, pattern) for pattern in patterns if isinstance(pattern, str)):
            return True
    return False


def validate_route_registry(registry: dict[str, Any]) -> list[str]:
    failures: list[str] = []
    if registry.get("schema_version") != 1:
        failures.append("TASK_DOCUMENT_ROUTES.json schema_version must be 1")
    level0 = registry.get("level0")
    if not isinstance(level0, dict) or not isinstance(level0.get("documents"), list):
        failures.append("TASK_DOCUMENT_ROUTES.json level0.documents must be a list")
    else:
        for key in ("documents", "dynamic_task_documents"):
            values = level0.get(key, [])
            if not isinstance(values, list):
                failures.append(f"TASK_DOCUMENT_ROUTES.json level0.{key} must be a list")
                continue
            for value in values:
                if not isinstance(value, str) or not value.startswith("./"):
                    failures.append(f"TASK_DOCUMENT_ROUTES.json level0.{key} has invalid value: {value!r}")
    routes = registry.get("routes")
    if not isinstance(routes, dict) or not routes:
        failures.append("TASK_DOCUMENT_ROUTES.json routes must be a non-empty object")
        return failures
    for name, route in routes.items():
        if not isinstance(name, str) or not name:
            failures.append("route names must be non-empty strings")
            continue
        if not isinstance(route, dict):
            failures.append(f"route {name} must be an object")
            continue
        documents = route.get("documents")
        if not isinstance(documents, list):
            failures.append(f"route {name}.documents must be a list")
        for key in ("optional_documents", "trigger_patterns"):
            if key in route and not isinstance(route[key], list):
                failures.append(f"route {name}.{key} must be a list")
        for key in ("documents", "optional_documents", "trigger_patterns"):
            values = route.get(key, [])
            if not isinstance(values, list):
                continue
            for value in values:
                if not isinstance(value, str) or not value.startswith("./"):
                    failures.append(f"route {name}.{key} has invalid value: {value!r}")
    return failures


def resolve_routes(
    root: Path,
    route_names: list[str],
    task_id: str | None = None,
) -> dict[str, Any]:
    root = root.resolve()
    routes_registry = load_json(root / ROUTES_REL)
    levels_registry = load_json(root / LEVELS_REL)
    failures = validate_route_registry(routes_registry)
    routes = routes_registry.get("routes", {})
    unknown_routes = [name for name in route_names if name not in routes]
    if unknown_routes:
        failures.extend(f"unknown route: {name}" for name in unknown_routes)

    active_task_id, notes = discover_task_id(root, task_id)
    level0_values = list(routes_registry.get("level0", {}).get("documents", []))
    if active_task_id:
        for template in routes_registry.get("level0", {}).get("dynamic_task_documents", []):
            if not isinstance(template, str):
                failures.append("dynamic task document templates must be strings")
                continue
            level0_values.append(template.replace("{task_id}", active_task_id))
    level0_documents, level0_duplicates = ordered_unique(level0_values)

    route_values: list[str] = []
    optional_values: list[str] = []
    trigger_values: list[str] = []
    route_documents: dict[str, list[str]] = {}
    for name in route_names:
        route = routes.get(name)
        if not isinstance(route, dict):
            continue
        documents = [value for value in route.get("documents", []) if isinstance(value, str)]
        optional = [value for value in route.get("optional_documents", []) if isinstance(value, str)]
        route_documents[name] = documents + optional
        route_values.extend(documents)
        route_values.extend(optional)
        optional_values.extend(optional)
        trigger_values.extend(
            value for value in route.get("trigger_patterns", []) if isinstance(value, str)
        )

    documents, duplicates_removed = ordered_unique(route_values)
    optional_documents, _ = ordered_unique(optional_values)
    trigger_patterns, _ = ordered_unique(trigger_values)
    optional_set = set(optional_documents)

    missing: list[str] = []
    optional_missing: list[str] = []
    unclassified: list[str] = []
    for path in level0_documents + documents:
        try:
            candidate = relative_path(root, path)
        except ValueError as error:
            failures.append(str(error))
            continue
        if not candidate.is_file():
            if path in optional_set:
                optional_missing.append(path)
            else:
                missing.append(path)
            continue
        if path.startswith("./.zenflow/tasks/"):
            continue
        if not is_classified(path, levels_registry):
            unclassified.append(path)

    combined_documents, _ = ordered_unique(level0_documents + documents)
    return {
        "root": str(root),
        "task_id": active_task_id,
        "selected_routes": route_names,
        "level0_documents": level0_documents,
        "route_documents": route_documents,
        "documents": documents,
        "combined_documents": combined_documents,
        "trigger_patterns": trigger_patterns,
        "duplicates_removed": ordered_unique(level0_duplicates + duplicates_removed)[0],
        "missing": sorted(set(missing)),
        "optional_missing": sorted(set(optional_missing)),
        "unclassified": sorted(set(unclassified)),
        "unknown_routes": unknown_routes,
        "notes": notes,
        "failures": failures,
    }


def print_text(result: dict[str, Any]) -> None:
    print("Level 0:")
    for path in result["level0_documents"]:
        print(f"- {path}")
    print("Resolved route documents:")
    for path in result["documents"]:
        print(f"- {path}")
    if result["trigger_patterns"]:
        print("Triggered references (resolve only when relevant):")
        for pattern in result["trigger_patterns"]:
            print(f"- {pattern}")
    for label, key in (
        ("Duplicates removed", "duplicates_removed"),
        ("Missing", "missing"),
        ("Optional missing", "optional_missing"),
        ("Unclassified", "unclassified"),
    ):
        values = result[key]
        print(f"{label}: {len(values)}")
        for value in values:
            print(f"- {value}")
    for note in result["notes"]:
        print(f"Note: {note}")
    for failure in result["failures"]:
        print(f"Failure: {failure}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("routes", nargs="*", help="Route names to combine in the supplied order.")
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT, help="Active worktree root.")
    parser.add_argument("--task-id", help="Task ID used for dynamic Level 0 handoff/plan paths.")
    parser.add_argument("--list", action="store_true", help="List available route names and exit.")
    parser.add_argument("--all", action="store_true", help="Resolve every route; useful for validation.")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON.")
    args = parser.parse_args()

    try:
        registry = load_json(args.root.resolve() / ROUTES_REL)
    except ValueError as error:
        print(error, file=sys.stderr)
        return 2
    routes = registry.get("routes", {})
    if args.list:
        for name in routes:
            print(name)
        return 0
    selected = list(routes) if args.all else args.routes
    if not selected:
        parser.error("provide one or more route names, or use --list/--all")

    try:
        result = resolve_routes(args.root, selected, args.task_id)
    except ValueError as error:
        print(error, file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print_text(result)
    return 1 if result["failures"] or result["missing"] or result["unclassified"] else 0


if __name__ == "__main__":
    sys.exit(main())
