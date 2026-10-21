#!/usr/bin/env python3
"""Report required route cost and the upper bound including optional candidates."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

from resolve_docs_route import (
    LEVELS_REL, ROUTES_REL, load_json, ordered_unique, relative_path,
    resolve_routes, validate_route_registry,
)


DEFAULT_ROOT = Path(__file__).resolve().parents[1]
CANONICAL_REUSABLE = Path("/Users/Artem/.zenflow/worktrees/documentation-vault/reusable")
WORD_PATTERN = re.compile(r"\b\w+[\w.-]*\b")


def file_cost(root: Path, path: str) -> dict[str, Any]:
    candidate = relative_path(root, path)
    return candidate_cost(candidate, path)


def candidate_cost(candidate: Path, path: str) -> dict[str, Any]:
    if not candidate.is_file():
        return {
            "path": path,
            "physical_path": str(candidate.resolve()),
            "exists": False,
            "words": 0,
            "bytes": 0,
        }
    data = candidate.read_bytes()
    text = data.decode("utf-8", errors="replace")
    return {
        "path": path,
        "physical_path": str(candidate.resolve()),
        "exists": True,
        "words": len(WORD_PATTERN.findall(text)),
        "bytes": len(data),
    }


def instruction_envelope(root: Path, startup: dict[str, Any]) -> dict[str, Any]:
    baseline = CANONICAL_REUSABLE / "baseline"
    bootstrap = CANONICAL_REUSABLE / "GLOBAL_RULES_BOOTSTRAP.md"
    canonical_available = bootstrap.is_file() and (baseline / "AGENTS.md").is_file()
    authority_root = baseline if canonical_available else root
    authority_paths = [relative_path(root, "./AGENTS.md")]
    if canonical_available:
        authority_paths.extend([relative_path(CANONICAL_REUSABLE, "./GLOBAL_RULES_BOOTSTRAP.md"), relative_path(baseline, "./AGENTS.md")])
    else:
        authority_paths.append(relative_path(root, "./GLOBAL_RULES_PORTABLE_SNAPSHOT.md"))
    registry_path = relative_path(authority_root, "./" + ROUTES_REL.as_posix())
    registry = load_json(registry_path) if registry_path.is_file() else {}
    registry_failures = validate_route_registry(registry)
    if not registry.get("level0", {}).get("documents"):
        registry_failures.append("startup authority has no static Level 0 documents")
    authority_paths.append(relative_path(authority_root, "./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md"))
    authority_paths.extend(
        relative_path(authority_root, path)
        for path in registry.get("level0", {}).get("documents", [])
    )
    # Count actual task documents separately from the canonical static Level 0.
    costs = [candidate_cost(path, str(path)) for path in authority_paths]
    costs.extend(
        item for item in startup["files"]
        if item["exists"] and item["path"].startswith("./.zenflow/tasks/")
    )
    summary = summarize_costs(costs)
    snapshot = relative_path(root, "./GLOBAL_RULES_PORTABLE_SNAPSHOT.md")
    fallback_valid = canonical_available or (
        snapshot.is_file()
        and "AIZENFLOW_GLOBAL_RULES_PORTABLE_SNAPSHOT_V1" in snapshot.read_text(encoding="utf-8")
    )
    missing = [item["physical_path"] for item in summary["files"] if not item["exists"]]
    if not registry_path.is_file():
        missing.append(str(registry_path))
    summary.update({
        "authority": "canonical" if canonical_available else "canonical-baseline-unavailable",
        "authority_root": str(authority_root),
        "fallback_marker_valid": fallback_valid if not canonical_available else None,
        "missing": missing,
        "failures": registry_failures,
        "incomplete": bool(missing or registry_failures) or not fallback_valid,
        "cost_basis": "unique_physical_files_static_startup_only",
        "transitive_route_reads": "DECLARED_ROUTE_REQUIREMENTS_ONLY; CONDITIONAL_READS_NOT_INFERRED",
        "actual_token_telemetry": "UNAVAILABLE",
    })
    return summary


def task_state_candidate(root: Path, path: str) -> Path:
    candidate = relative_path(root, path)
    if candidate.is_file() or not path.startswith("./.zenflow/tasks/") or root.resolve() != (CANONICAL_REUSABLE / "baseline").resolve():
        return candidate
    task_relative_path = Path(path.removeprefix("./.zenflow/tasks/"))
    return relative_path(CANONICAL_REUSABLE.parent / "tasks", "./" + task_relative_path.as_posix())


def summarize_task_state(root: Path, paths: list[str]) -> dict[str, Any]:
    unique, duplicates = ordered_unique(paths)
    costs = [candidate_cost(task_state_candidate(root, path), path) for path in unique]
    absent = [item["path"] for item in costs if not item["exists"]]
    summary = summarize_costs([item for item in costs if item["exists"]])
    summary["absent_conditional_documents"] = absent
    summary["duplicates"] = duplicates + summary["duplicates"]
    return summary


def summarize_costs(costs: list[dict[str, Any]]) -> dict[str, Any]:
    files: dict[str, dict[str, Any]] = {}
    duplicates: list[str] = []
    for item in costs:
        key = item["physical_path"]
        if key in files:
            duplicates.append(item["path"])
        else:
            files[key] = item
    unique = list(files.values())
    return {
        "documents": len(unique),
        "existing_documents": sum(int(item["exists"]) for item in unique),
        "words": sum(item["words"] for item in unique),
        "bytes": sum(item["bytes"] for item in unique),
        "duplicates": duplicates,
        "files": unique,
    }


def combine_summaries(*summaries: dict[str, Any]) -> dict[str, Any]:
    return summarize_costs([
        item for summary in summaries for item in summary.get("files", [])
    ])


def summarize(root: Path, paths: list[str]) -> dict[str, Any]:
    unique, duplicates = ordered_unique(paths)
    costs = [file_cost(root, path) for path in unique]
    summary = summarize_costs(costs)
    summary["duplicates"] = duplicates + summary["duplicates"]
    return summary


def build_report(root: Path, task_id: str | None, top: int) -> dict[str, Any]:
    root = root.resolve()
    route_registry = load_json(relative_path(root, "./" + ROUTES_REL.as_posix()))
    levels = load_json(relative_path(root, "./" + LEVELS_REL.as_posix()))
    route_names = list(route_registry.get("routes", {}))
    resolved = resolve_routes(root, route_names, task_id)

    dynamic_paths = [
        path for path in resolved["level0_documents"] if path.startswith("./.zenflow/tasks/")
    ]
    static_level0_paths = [
        path for path in resolved["level0_documents"] if path not in dynamic_paths
    ]
    level0 = summarize(root, static_level0_paths)
    dynamic = summarize_task_state(root, dynamic_paths)
    startup = combine_summaries(level0, dynamic)
    envelope = instruction_envelope(root, startup)
    # Keep the project inventory and canonical inventory distinct. A stale local
    # copy must neither mask a missing canonical dependency nor price its body.
    authority_root = Path(envelope["authority_root"])
    authority_registry = load_json(relative_path(authority_root, "./" + ROUTES_REL.as_posix()))
    authority_names = list(authority_registry.get("routes", {}))
    authority_resolved = resolve_routes(authority_root, authority_names, task_id)
    authority_routes = {}
    for name in authority_names:
        required = summarize(authority_root, authority_resolved["required_route_documents"].get(name, []))
        own = summarize(authority_root, authority_resolved["route_documents"].get(name, []))
        authority_routes[name] = {"required_words": required["words"], "words": own["words"],
                                  "required_files": required["files"], "files": own["files"]}
    authority_inventory = {
        "root": str(authority_root),
        "basis": "canonical_declared_inventory" if envelope["authority"] == "canonical" else "portable_declared_inventory",
        "routes": authority_routes,
        "missing": authority_resolved["missing"],
        "failures": authority_resolved["failures"],
        "unclassified": authority_resolved["unclassified"],
        "incomplete": bool(authority_resolved["missing"] or authority_resolved["failures"] or authority_resolved["unclassified"]),
        "limits": "Separate declared inventories, not effective task reads. Project overlays and conditional reads require task-specific selection; do not sum inventories.",
    }

    route_summaries: dict[str, Any] = {}
    route_sets: dict[str, set[str]] = {}
    for name in route_names:
        paths = resolved["route_documents"].get(name, [])
        required_paths = resolved["required_route_documents"].get(name, [])
        route_sets[name] = set(paths)
        required = summarize(root, required_paths)
        own = summarize(root, paths)
        with_level0 = combine_summaries(startup, own)
        with_level0_required = combine_summaries(startup, required)
        with_envelope = combine_summaries(envelope, own)
        configured_budget = route_registry["routes"][name].get("max_words")
        route_summaries[name] = {
            "cost_basis": "upper_bound_including_optional_candidates",
            "documents": own["documents"],
            "words": own["words"],
            "bytes": own["bytes"],
            "required_documents": required["documents"],
            "required_words": required["words"],
            "required_bytes": required["bytes"],
            "optional_candidate_documents": own["documents"] - required["documents"],
            "optional_increment_words": own["words"] - required["words"],
            "optional_increment_bytes": own["bytes"] - required["bytes"],
            "with_level0_documents": with_level0["documents"],
            "with_level0_words": with_level0["words"],
            "with_level0_bytes": with_level0["bytes"],
            "with_level0_required_words": with_level0_required["words"],
            "with_instruction_envelope_documents": with_envelope["documents"],
            "with_instruction_envelope_words": with_envelope["words"],
            "with_instruction_envelope_bytes": with_envelope["bytes"],
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
    dynamic_task_max = levels.get("dynamic_task_max_words")
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
            "max_words": dynamic_task_max,
            "budget_exceeded": (
                isinstance(dynamic_task_max, int) and dynamic["words"] > dynamic_task_max
            ),
            "files": dynamic["files"],
        },
        "startup_total": {
            "documents": startup["documents"],
            "words": startup["words"],
            "bytes": startup["bytes"],
        },
        "instruction_envelope": envelope,
        "authority_route_inventory": authority_inventory,
        "project_route_inventory_root": str(root),
        "routes": route_summaries,
        "overlaps": overlaps,
        "heaviest_documents": heaviest,
        "unreachable_registered_documents": unreachable,
        "missing": [
            path
            for path in resolved["missing"]
            if path not in dynamic_paths or not task_state_candidate(root, path).is_file()
        ],
        "optional_missing": resolved["optional_missing"],
        "unclassified": resolved["unclassified"],
        "failures": resolved["failures"],
        "notes": resolved["notes"],
    }


def print_text(report: dict[str, Any]) -> None:
    level0 = report["level0"]
    print(
        "Level 0 baseline: "
        f"{level0['documents']} docs; {level0['words']}/{level0['max_words']} words; "
        f"{level0['bytes']} bytes"
    )
    dynamic = report["dynamic_task_documents"]
    print(
        "Dynamic task state: "
        f"{dynamic['documents']} docs; {dynamic['words']}/{dynamic['max_words']} words; "
        f"{dynamic['bytes']} bytes"
    )
    startup = report["startup_total"]
    print(
        "Startup total: "
        f"{startup['documents']} docs; {startup['words']} words; {startup['bytes']} bytes"
    )
    envelope = report["instruction_envelope"]
    print(
        "Instruction envelope: "
        f"{envelope['documents']} docs; {envelope['words']} words; {envelope['bytes']} bytes"
    )
    print(f"Startup authority: {envelope['authority']}; incomplete: {envelope['incomplete']}")
    authority = report["authority_route_inventory"]
    print(f"Authority route inventory: {authority['root']}; incomplete: {authority['incomplete']}")
    print(authority["limits"])
    print(f"Route dependency scope: {envelope['transitive_route_reads']}")
    print("Actual token telemetry: UNAVAILABLE; this is not a full task-read trace")
    for path in envelope["missing"]:
        print(f"Missing startup input: {path}")
    for failure in envelope["failures"]:
        print(f"Invalid startup authority: {failure}")
    print("Routes (required -> upper bound with optional candidates; not observed reads):")
    for name, values in report["routes"].items():
        budget = ""
        if values["max_words"] is not None:
            budget = f"; budget {values['max_words']}"
        print(
            f"- {name}: required {values['required_documents']} docs, "
            f"{values['required_words']} words; upper bound {values['documents']} docs, "
            f"{values['words']} words ({values['optional_increment_words']} optional words), "
            f"{values['bytes']} bytes"
            f" -> {values['with_level0_documents']} docs, {values['with_level0_words']} words"
            f" -> {values['with_instruction_envelope_documents']} docs, "
            f"{values['with_instruction_envelope_words']} words"
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
            report["instruction_envelope"]["incomplete"],
            report["authority_route_inventory"]["incomplete"],
            report["level0"]["budget_exceeded"],
            report["dynamic_task_documents"]["budget_exceeded"],
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
