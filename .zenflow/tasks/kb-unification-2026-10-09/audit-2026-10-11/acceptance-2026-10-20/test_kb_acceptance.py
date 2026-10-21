#!/usr/bin/env python3
"""Authorized task-local KB CLI acceptance. No app/runtime/global-state tests."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
WORKTREE = HERE.parents[4]
SCRIPTS = WORKTREE / "scripts"
MARKER = "AIZENFLOW_GLOBAL_RULES_PORTABLE_SNAPSHOT_V1"
ENV = {**os.environ, "PYTHONDONTWRITEBYTECODE": "1"}
RESULTS: list[dict] = []


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def json_file(path: Path, value: dict) -> None:
    write(path, json.dumps(value, indent=2) + "\n")


def project(root: Path) -> None:
    write(root / "AGENTS.md", "Fixture project instruction.\n")
    write(root / "docs/TASK_TYPE_DOCUMENTATION_ROUTER.md", "Fixture router.\n")
    write(root / "docs/base.md", "Fixture baseline.\n")
    write(root / "docs/required.md", "local\n")
    write(root / "docs/optional.md", "Fixture optional.\n")
    json_file(root / "docs/TASK_DOCUMENT_ROUTES.json", {
        "schema_version": 1,
        "level0": {"documents": ["./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md", "./docs/base.md"],
                   "dynamic_task_documents": ["./.zenflow/tasks/{task_id}/handoff.md", "./.zenflow/tasks/{task_id}/plan.md"]},
        "routes": {"selected": {"documents": ["./docs/required.md"], "optional_documents": ["./docs/optional.md"]}},
    })
    json_file(root / "docs/DOCUMENT_ROUTING_REGISTRY.json", {
        "level0": ["./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md", "./docs/base.md"],
        "level1": ["./docs/required.md"], "level2": ["./docs/optional.md"], "level3": [],
        "path_patterns": {}, "level0_max_words": 10000, "dynamic_task_max_words": 10000,
    })


def registry(root: Path) -> dict:
    return json.loads((root / "docs/TASK_DOCUMENT_ROUTES.json").read_text())


def run(argv: list[str]) -> tuple[int, dict | None, str, str]:
    proc = subprocess.run(argv, cwd=WORKTREE, env=ENV, capture_output=True, text=True, timeout=15)
    parsed = None
    try:
        parsed = json.loads(proc.stdout)
    except json.JSONDecodeError:
        pass
    return proc.returncode, parsed, proc.stdout, proc.stderr


def resolver(root: Path):
    return run([sys.executable, str(SCRIPTS / "resolve_docs_route.py"), "selected", "--root", str(root), "--task-id", "fixture-task", "--json"])


def reporter(root: Path, reusable: Path):
    # Inject only the filesystem dependency. Production functions/return values
    # remain unchanged; this does NOT simulate actual host canonical unavailability.
    wrapper = """import sys
from pathlib import Path
sys.dont_write_bytecode = True
sys.path.insert(0, sys.argv[1])
import report_documentation_context_cost as target
target.CANONICAL_REUSABLE = Path(sys.argv[2])
sys.argv = ['report', '--root', sys.argv[3], '--task-id', 'fixture-task', '--json', '--check']
raise SystemExit(target.main())
"""
    return run([sys.executable, "-c", wrapper, str(SCRIPTS), str(reusable), str(root)])


def record(name: str, result, expected: str, predicate) -> None:
    code, data, stdout, stderr = result
    try:
        passed = bool(predicate(code, data, stdout, stderr))
    except (KeyError, TypeError, ValueError):
        passed = False
    RESULTS.append({"case": name, "expected": expected, "exit_code": code, "status": "PASS" if passed else "FAIL",
                    "observed": data if not passed and data is not None else stdout[:1200], "stderr": stderr[:1200]})


def boundary(vault: Path):
    return run([sys.executable, str(SCRIPTS / "check_documentation_boundaries.py"), str(vault)])


def main() -> int:
    fixture_root = HERE / "fixtures"
    fixture_root.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="owned-kb-acceptance-", dir=fixture_root) as temporary:
        area = Path(temporary)

        def fresh(name):
            case = area / name
            root, reusable = case / "work", case / "reusable"
            project(root); project(reusable / "baseline")
            write(reusable / "GLOBAL_RULES_BOOTSTRAP.md", "Fixture canonical bootstrap.\n")
            write(reusable / "baseline/docs/required.md", "canonical authoritative selected route has seven words\n")
            return root, reusable

        root, canon = fresh("positive")
        record("resolver_positive", resolver(root), "exit0; no required missing", lambda c,d,o,e: c == 0 and not d["missing"])
        record("reporter_positive", reporter(root,canon), "exit0; canonical complete", lambda c,d,o,e: c == 0 and not d["instruction_envelope"]["incomplete"])

        root, canon = fresh("missing_static")
        (root / "docs/base.md").unlink()
        record("missing_static_level0", resolver(root), "nonzero; base is mandatory missing", lambda c,d,o,e: c != 0 and "./docs/base.md" in d["missing"])

        for name, path in [("required_optional_collision", "./docs/required.md"), ("level0_optional_collision", "./docs/base.md")]:
            root, canon = fresh(name); reg = registry(root); reg["routes"]["selected"]["optional_documents"].append(path)
            json_file(root / "docs/TASK_DOCUMENT_ROUTES.json", reg); (root / path[2:]).unlink()
            record(name, resolver(root), "nonzero; required wins over optional", lambda c,d,o,e,p=path: c != 0 and p in d["missing"] and p not in d["optional_missing"])

        root, canon = fresh("missing_optional")
        (root / "docs/optional.md").unlink()
        record("absent_optional", resolver(root), "exit0; optional missing only", lambda c,d,o,e: c == 0 and "./docs/optional.md" in d["optional_missing"])

        root, canon = fresh("conditional_task")
        record("absent_conditional_task_state", reporter(root,canon), "exit0; missing conditional handoff/plan do not block", lambda c,d,o,e: c == 0 and not d["instruction_envelope"]["incomplete"])
        write(root / ".zenflow/tasks/fixture-task/plan.md", "Fixture task plan.\n")
        record("one_present_conditional_task_document", reporter(root,canon), "exit0; plan counted, absent handoff does not block", lambda c,d,o,e: c == 0 and d["dynamic_task_documents"]["existing_documents"] == 1 if "existing_documents" in d["dynamic_task_documents"] else c == 0 and len(d["dynamic_task_documents"]["files"]) == 1)

        root, canon = fresh("malformed")
        write(root / "docs/TASK_DOCUMENT_ROUTES.json", "{")
        record("malformed_registry_json", resolver(root), "nonzero; invalid JSON", lambda c,d,o,e: c != 0)
        root, canon = fresh("unsupported_schema")
        reg = registry(root); reg["schema_version"] = 99; json_file(root / "docs/TASK_DOCUMENT_ROUTES.json", reg)
        record("unsupported_registry_schema", resolver(root), "nonzero; schema rejected", lambda c,d,o,e: c != 0)

        for name, snapshot in [("valid_fallback", MARKER), ("invalid_fallback", "invalid snapshot"), ("missing_fallback", None)]:
            root, canon = fresh(name); (canon / "GLOBAL_RULES_BOOTSTRAP.md").unlink()
            if snapshot is not None: write(root / "GLOBAL_RULES_PORTABLE_SNAPSHOT.md", snapshot)
            good = name == "valid_fallback"
            record(name, reporter(root,canon), "exit0 only for valid portable marker; canonical unavailable explicit", lambda c,d,o,e,g=good: (c == 0) == g and d["instruction_envelope"]["authority"] == "canonical-baseline-unavailable")

        root, canon = fresh("missing_canonical_level0")
        (canon / "baseline/docs/base.md").unlink()
        record("canonical_level0_not_masked_by_local_copy", reporter(root,canon), "nonzero even though local baseline exists", lambda c,d,o,e: c != 0 and d["instruction_envelope"]["incomplete"])
        root, canon = fresh("bad_canonical_registry")
        reg = registry(canon / "baseline"); reg["schema_version"] = 99; json_file(canon / "baseline/docs/TASK_DOCUMENT_ROUTES.json",reg)
        record("invalid_canonical_registry", reporter(root,canon), "nonzero for invalid startup authority", lambda c,d,o,e: c != 0)

        root, canon = fresh("canonical_route_missing")
        (canon / "baseline/docs/required.md").unlink()
        record("authoritative_route_missing_not_masked", reporter(root,canon), "nonzero for missing canonical selected-route file", lambda c,d,o,e: c != 0)
        root, canon = fresh("canonical_route_cost")
        record("route_cost_uses_authoritative_body", reporter(root,canon), "required words match7-word canonical body, not1-word local copy", lambda c,d,o,e: c == 0 and d["authority_route_inventory"]["routes"]["selected"]["required_words"] == 7 and d["routes"]["selected"]["required_words"] == 1)
        record("same_physical_startup_path_counted_once", reporter(canon / "baseline",canon), "startup physical paths unique", lambda c,d,o,e: c == 0 and len(d["instruction_envelope"]["files"]) == len({x["physical_path"] for x in d["instruction_envelope"]["files"]}))

        root, canon = fresh("escape")
        write(root.parent / "outside.md", "Owned fixture outside selected root.\n")
        reg=registry(root);reg["routes"]["selected"]["documents"]=["./../outside.md"];json_file(root / "docs/TASK_DOCUMENT_ROUTES.json",reg)
        levels=json.loads((root / "docs/DOCUMENT_ROUTING_REGISTRY.json").read_text());levels["level1"]=["./../outside.md"];json_file(root / "docs/DOCUMENT_ROUTING_REGISTRY.json",levels)
        record("route_parent_escape_rejected", resolver(root), "nonzero for source path escaping selected root", lambda c,d,o,e: c != 0)

        for kind in ["base", "overlay"]:
            root, canon = fresh("symlink_document_" + kind)
            target = root.parent / "owned-target.md"
            write(target, "Owned fixture target outside document root.\n")
            (root / "docs/escaped.md").symlink_to(target)
            if kind == "base":
                reg = registry(root)
                reg["routes"]["selected"]["documents"] = ["./docs/escaped.md"]
                json_file(root / "docs/TASK_DOCUMENT_ROUTES.json", reg)
            else:
                json_file(root / "docs/TASK_DOCUMENT_ROUTES.overlay.json", {
                    "schema_version": 1,
                    "route_overrides": {"selected": {"optional_documents": ["./docs/escaped.md"]}},
                })
            record("reject_document_symlink_" + kind, resolver(root),
                   "nonzero; resolved document containment enforced",
                   lambda c,d,o,e: c != 0 and "escapes its root" in o + e)
            record("reporter_reject_document_symlink_" + kind, reporter(root, canon),
                   "nonzero; rejection before candidate content read",
                   lambda c,d,o,e: c != 0 and "escapes its root" in o + e)

        for rel in ["docs/TASK_DOCUMENT_ROUTES.json", "docs/DOCUMENT_ROUTING_REGISTRY.json", "AGENTS.md", "docs/TASK_TYPE_DOCUMENTATION_ROUTER.md"]:
            root, canon = fresh("input_link_" + rel.replace("/", "_"))
            original = root / rel
            target = root.parent / "owned-external-input"
            write(target, original.read_text())
            original.unlink(); original.symlink_to(target)
            record("reporter_reject_input_link_" + rel, reporter(root, canon),
                   "nonzero; reject escaped input before parsing/counting",
                   lambda c,d,o,e: c != 0 and "escapes its root" in o + e)

        def vault(name):
            root = area / name
            for rel in ["reusable", "apps", "tasks"]:(root / rel).mkdir(parents=True)
            write(root / "apps/FutureApp/MANIFEST.md", "Fixture app manifest.\n")
            return root
        root=vault("app_positive")
        record("dynamic_new_app_positive", boundary(root), "exit0 for non-hardcoded app with manifest", lambda c,d,o,e:c==0)
        root=vault("app_missing_manifest");(root / "apps/FutureApp/MANIFEST.md").unlink()
        record("dynamic_new_app_missing_manifest", boundary(root), "nonzero naming FutureApp", lambda c,d,o,e:c!=0 and "FutureApp" in o)
        root=vault("app_copied_baseline");write(root / "apps/FutureApp/AGENTS.md", "Copied baseline.\n")
        record("dynamic_new_app_copied_baseline", boundary(root), "nonzero for active generic baseline copy", lambda c,d,o,e:c!=0 and "AGENTS.md" in o)
        root=vault("archive_positive");write(root / "apps/FutureApp/archive/AGENTS.md", "Historical baseline.\n")
        record("historical_baseline_not_active", boundary(root), "exit0 for archive-only baseline", lambda c,d,o,e:c==0)
        for kind in ["root", "app", "manifest", "nested"]:
            root=vault("link_"+kind);target=area/("owned-link-target-"+kind);target.mkdir();write(target / "doc.md", "Owned link target.\n")
            if kind=="root":
                (root / "apps/FutureApp/MANIFEST.md").unlink();(root / "apps/FutureApp").rmdir();(root / "apps").rmdir();(root / "apps").symlink_to(target,target_is_directory=True)
            elif kind=="app":
                (root / "apps/FutureApp/MANIFEST.md").unlink();(root / "apps/FutureApp").rmdir();(root / "apps/FutureApp").symlink_to(target,target_is_directory=True)
            elif kind=="manifest":
                (root / "apps/FutureApp/MANIFEST.md").unlink();(root / "apps/FutureApp/MANIFEST.md").symlink_to(target / "doc.md")
            else:(root / "apps/FutureApp/nested").symlink_to(target,target_is_directory=True)
            record("reject_linked_app_"+kind,boundary(root),"nonzero; symlink is explicit failure",lambda c,d,o,e:c!=0 and "linked" in o)

    hashes={name:hashlib.sha256((SCRIPTS/name).read_bytes()).hexdigest() for name in ["resolve_docs_route.py","report_documentation_context_cost.py","check_documentation_boundaries.py"]}
    report={"status":"PASS" if all(x["status"]=="PASS" for x in RESULTS) else "FAIL", "scope":"Task-local KB CLI acceptance only", "source_hashes":hashes,"fixture_dependency":"Reporter CANONICAL_REUSABLE injected as path only; production logic/return values unchanged; no actual host fallback transition", "cases":RESULTS}
    output=HERE/"behavioral-results.json";output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n")
    failures=[x["case"] for x in RESULTS if x["status"]!="PASS"]
    print(json.dumps({"cases":len(RESULTS),"passed":len(RESULTS)-len(failures),"failed":failures},ensure_ascii=False))
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
