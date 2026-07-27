#!/usr/bin/env python3
"""Report documentation route size, overlap, budgets, and reachability."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

from resolve_docs_route import LEVELS_REL, ROUTES_REL, load_json, ordered_unique, relative_path, resolve_routes


DEFAULT_ROOT = Path(__file__).resolve().parents[1]
WORD_PATTERN = re.compile(r"\b\w+[\w.-]*\b")


def file_cost(root: Path, path: str) -> dict[str, Any]:
    candidate = relative_path(root, path)
    if not candidate.is_file():
        return {"path": path, "exists": False, "words": 0, "bytes": 0}
    data = candidate.read_bytes()
    text = data.decode("utf-8", errors="replace")
    return {
        "path": path,
        "exists": True,
        "words": len(WORD_PATTERN.findall(text)),
        "bytes": len(data),
    }


def summarize(root: Path, paths: list[str]) -> dict[str, Any]:
    unique, duplicates = ordered_unique(paths)
    costs = [file_cost(root, path) for path in unique]
    return {
        "documents": len(unique),
        "existing_documents": sum(1 for item in costs if item["exists"]),
        "words": sum(item["words"] for item in costs),
        "bytes": sum(item["bytes"] for item in costs),
        "duplicates": duplicates,
        "files": costs,
    }


def build_report(root: Path, task_id: str | None, top: int) -> dict[str, Any]:
    root = root.resolve()
    route_registry = load_json(root / ROUTES_REL)
    levels = load_json(root / LEVELS_REL)
    route_names = list(route_registry.get("routes", {}))
    resolved = resolve_routes(root, route_names, task_id)

    level0 = summarize(root, resolved["level0_documents"])
    dynamic_paths = [
        path for path in resolved["level0_documents"] if path.startswith("./.zenflow/tasks/")
    ]
    dynamic = summarize(root, dynamic_paths)

    route_summaries: dict[str, Any] = {}
    route_sets: dict[str, set[str]] = {}
    for name in route_names:
        paths = resolved["route_documents"].get(name, [])
        route_sets[name] = set(paths)
        own = summarize(root, paths)
        with_level0 = summarize(root, resolved["level0_documents"] + paths)
        configured_budget = route_registry["routes"][name].get("max_words")
        route_summaries[name] = {
            "documents": own["documents"],
            "words": own["words"],
            "bytes": own["bytes"],
            "with_level0_documents": with_level0["documents"],
            "with_level0_words": with_level0["words"],
            "with_level0_bytes": with_level0["bytes"],
            "max_words": configured_budget,
            "budget_exceeded": isinstance(configured_budget, int) and own["words"] > configured_budget,
        }

    overlaps: list[dict[str, Any]] = []
    for index, left in enumerate(route_names):
        for right in route_names[index + 1 :]:
            shared = sorted(route_sets[left] & route_sets[right])
            if shared:
                overlaps.append({"left": left, "right": right, "count": len(shared), "documents": shared})
    overlaps.sort(key=lambda item: (-item["count"], item["left"], item["right"]))

    all_route_paths = set(resolved["documents"])
    registered_paths = {
        path
        for level in ("level0", "level1", "level2", "level3")
        for path in levels.get(level, [])
        if isinstance(path, str)
    }
    reachable = set(resolved["level0_documents"]) | all_route_paths
    unreachable = sorted(registered_paths - reachable)

    all_costs = [
        file_cost(root, path)
        for path in sorted(reachable)
        if not path.startswith("./.zenflow/tasks/")
    ]
    heaviest = sorted(
        (item for item in all_costs if item["exists"]),
        key=lambda item: (-item["words"], -item["bytes"], item["path"]),
    )[:top]

    level0_max = levels.get("level0_max_words")
    return {
        "root": str(root),
        "task_id": resolved["task_id"],
        "level0": {
            "documents": level0["documents"],
            "words": level0["words"],
            "bytes": level0["bytes"],
            "max_words": level0_max,
            "budget_exceeded": isinstance(level0_max, int) and level0["words"] > level0_max,
        },
        "dynamic_task_documents": {
            "documents": dynamic["documents"],
            "words": dynamic["words"],
            "bytes": dynamic["bytes"],
            "files": dynamic["files"],
        },
        "routes": route_summaries,
        "overlaps": overlaps,
        "heaviest_documents": heaviest,
        "unreachable_registered_documents": unreachable,
        "missing": resolved["missing"],
        "optional_missing": resolved["optional_missing"],
        "unclassified": resolved["unclassified"],
        "failures": resolved["failures"],
        "notes": resolved["notes"],
    }


def print_text(report: dict[str, Any]) -> None:
    level0 = report["level0"]
    print(
        "Level 0: "
        f"{level0['documents']} docs; {level0['words']}/{level0['max_words']} words; "
        f"{level0['bytes']} bytes"
    )
    dynamic = report["dynamic_task_documents"]
    print(
        "Dynamic task state: "
        f"{dynamic['documents']} docs; {dynamic['words']} words; {dynamic['bytes']} bytes"
    )
    print("Routes (route-only -> with Level 0):")
    for name, values in report["routes"].items():
        budget = ""
        if values["max_words"] is not None:
            budget = f"; budget {values['max_words']}"
        print(
            f"- {name}: {values['documents']} docs, {values['words']} words, {values['bytes']} bytes"
            f" -> {values['with_level0_documents']} docs, {values['with_level0_words']} words"
            f"{budget}"
        )
    print(f"Route overlaps: {len(report['overlaps'])} pairs")
    for overlap in report["overlaps"][:10]:
        print(f"- {overlap['left']} + {overlap['right']}: {overlap['count']} shared")
    print("Heaviest routed documents:")
    for item in report["heaviest_documents"]:
        print(f"- {item['path']}: {item['words']} words; {item['bytes']} bytes")
    print(f"Unreachable registered documents: {len(report['unreachable_registered_documents'])}")
    for path in report["unreachable_registered_documents"]:
        print(f"- {path}")
    for label, key in (
        ("Missing", "missing"),
        ("Optional missing", "optional_missing"),
        ("Unclassified", "unclassified"),
        ("Failures", "failures"),
    ):
        print(f"{label}: {len(report[key])}")
        for value in report[key]:
            print(f"- {value}")
    for note in report["notes"]:
        print(f"Note: {note}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT, help="Active worktree root.")
    parser.add_argument("--task-id", help="Task ID used for dynamic Level 0 costs.")
    parser.add_argument("--top", type=int, default=10, help="Number of heaviest documents to show.")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON.")
    parser.add_argument(
        "--check",
        action="store_true",
        help="Fail for missing/unclassified/unreachable docs or configured budget overruns.",
    )
    args = parser.parse_args()
    if args.top <= 0:
        parser.error("--top must be positive")
    try:
        report = build_report(args.root, args.task_id, args.top)
    except ValueError as error:
        print(error, file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps(report, indent=2, ensure_ascii=False))
    else:
        print_text(report)
    if not args.check:
        return 0
    route_budget_failure = any(values["budget_exceeded"] for values in report["routes"].values())
    failed = any(
        (
            report["level0"]["budget_exceeded"],
            route_budget_failure,
            report["unreachable_registered_documents"],
            report["missing"],
            report["unclassified"],
            report["failures"],
        )
    )
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
