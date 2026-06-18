#!/usr/bin/env python3
"""Validate the git-backed documentation vault shape."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parent
REQUIRED = [
    ROOT / "README.md",
    ROOT / "SYNC_POLICY.md",
    ROOT / "MANIFEST.md",
    ROOT / "inventory.json",
    ROOT / "reusable" / "MANIFEST.md",
    ROOT / "apps" / "TchopApp" / "MANIFEST.md",
    ROOT / "apps" / "MVVMExample" / "MANIFEST.md",
    ROOT / "tasks" / "MANIFEST.md",
]
FORBIDDEN_PARTS = {".git", ".build", ".swiftpm", "build", "DerivedData", "xcuserdata", "node_modules", "__pycache__"}

def fail(message: str) -> None:
    print(f"documentation-vault check failed: {message}", file=sys.stderr)
    raise SystemExit(1)

def main() -> None:
    for path in REQUIRED:
        if not path.exists():
            fail(f"missing required file: {path.relative_to(REPO)}")

    inventory = json.loads((ROOT / "inventory.json").read_text())
    if not inventory.get("copied_counts"):
        fail("inventory has no copied_counts")

    files = [p for p in ROOT.rglob("*") if p.is_file()]
    if len(files) < 100:
        fail(f"unexpectedly small vault file count: {len(files)}")

    for path in files:
        rel = path.relative_to(ROOT)
        if any(part in FORBIDDEN_PARTS for part in rel.parts):
            fail(f"forbidden generated artifact path in vault: {rel}")

    reusable_text_paths = [p for p in (ROOT / "reusable").rglob("*") if p.is_file() and p.suffix.lower() in {".md", ".sh", ".py", ".json", ".yml", ".yaml"}]
    for path in reusable_text_paths:
        rel = path.relative_to(ROOT).as_posix()
        if "MVVMEXAMPLE_REMEDIATION_SPEC" in rel:
            fail(f"MVVMExample remediation spec is in reusable area: {rel}")
        text = path.read_text(errors="ignore")
        if "MVVMEXAMPLE_REMEDIATION_SPEC.md" in text:
            fail(f"reusable area still references MVVMExample remediation spec: {rel}")

    for app in ["TchopApp", "MVVMExample"]:
        app_root = ROOT / "apps" / app
        if not app_root.exists():
            fail(f"missing app vault: {app}")
        if not any(app_root.rglob("*.md")):
            fail(f"app vault has no markdown docs: {app}")

    print(f"documentation-vault OK: {len(files)} files")

if __name__ == "__main__":
    main()
