#!/usr/bin/env python3
"""Generate or validate the deterministic package-library snapshot manifest."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import NoReturn


SCHEMA_VERSION = 1
EXCLUDED_NAMES = {".build", ".swiftpm", "Package.resolved", ".DS_Store"}
PACKAGE_NAME_RE = re.compile(r"\bname\s*:\s*\"([^\"]+)\"")
PRODUCT_RE = re.compile(r"\.library\s*\(\s*name\s*:\s*\"([^\"]+)\"", re.DOTALL)


def fail(message: str) -> NoReturn:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def sha256_tree(root: Path) -> str:
    digest = hashlib.sha256()
    files = []
    for path in root.rglob("*"):
        if not path.is_file() or any(part in EXCLUDED_NAMES for part in path.parts):
            continue
        if path.name == "PACKAGE_SNAPSHOT_MANIFEST.json":
            continue
        files.append(path)
    for path in sorted(files, key=lambda item: item.relative_to(root).as_posix()):
        relative = path.relative_to(root).as_posix().encode("utf-8")
        digest.update(len(relative).to_bytes(8, "big"))
        digest.update(relative)
        contents = path.read_bytes()
        digest.update(len(contents).to_bytes(8, "big"))
        digest.update(contents)
    return digest.hexdigest()


def git_revision(root: Path) -> str:
    try:
        result = subprocess.run(
            ["git", "-C", str(root), "rev-parse", "HEAD"],
            check=True,
            capture_output=True,
            text=True,
        )
    except (OSError, subprocess.CalledProcessError) as exc:
        fail(f"cannot resolve Documentation Vault revision: {exc}")
    revision = result.stdout.strip()
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        fail("Documentation Vault revision is not a full commit SHA")
    return revision


def parse_package(package_root: Path, repository_root: Path, kind: str, maturity: str) -> dict:
    manifest_path = package_root / "Package.swift"
    if not manifest_path.is_file():
        fail(f"missing Package.swift: {package_root}")
    text = manifest_path.read_text()
    package_names = PACKAGE_NAME_RE.findall(text)
    products = sorted(set(PRODUCT_RE.findall(text)))
    if not package_names:
        fail(f"cannot parse package name: {manifest_path}")
    package_name = package_names[0]
    folder_name = package_root.name
    if package_name != folder_name:
        fail(f"package/folder name mismatch: {manifest_path}")
    required = {
        "README.md": (package_root / "README.md").is_file(),
        "PackageContract.md": (package_root / "PackageContract.md").is_file(),
        "REUSE.md": (package_root / "REUSE.md").is_file(),
        "Scripts/verify_package.sh": (package_root / "Scripts/verify_package.sh").is_file(),
    }
    missing = sorted(name for name, present in required.items() if not present)
    if missing:
        fail(f"package {package_name} is missing required surfaces: {', '.join(missing)}")
    relative = package_root.relative_to(repository_root).as_posix()
    entry = {
        "path": relative,
        "kind": kind,
        "package_name": package_name,
        "products": products,
        "maturity": maturity,
        "package_manifest_sha256": sha256_bytes(manifest_path.read_bytes()),
        "content_sha256": sha256_tree(package_root),
        "required_surfaces": required,
    }
    return entry


def package_roots(root: Path, integration: bool) -> list[Path]:
    base = root / "IntegrationHelpers" if integration else root
    return sorted(
        (path.parent for path in base.glob("*/Package.swift")),
        key=lambda path: path.name,
    )


def build_manifest(args: argparse.Namespace) -> dict:
    repository_root = Path(__file__).resolve().parents[1]
    reusable_root = Path(args.reusable_root).resolve()
    active_root = Path(args.active_root).resolve()
    documentation_root = Path(args.documentation_vault_root).resolve()
    for required_root in (reusable_root, active_root, documentation_root):
        if not required_root.is_dir():
            fail(f"required root does not exist: {required_root}")

    docs_revision = git_revision(documentation_root)
    reusable_entries = []
    active_entries = []
    for integration in (False, True):
        kind = "integration-helper" if integration else "root-package"
        for package_root in package_roots(reusable_root, integration):
            maturity = "product-owned" if package_root.name.startswith("Tchop") else "vault-cataloged"
            entry = parse_package(package_root, repository_root, kind, maturity)
            active_package = active_root / package_root.relative_to(reusable_root)
            if active_package.is_dir():
                entry["active_snapshot"] = {
                    "path": active_package.relative_to(repository_root).as_posix(),
                    "content_sha256": sha256_tree(active_package),
                    "maturity": "source-only-active",
                }
                active_entries.append(entry["active_snapshot"] | {"kind": kind, "package_name": entry["package_name"]})
            reusable_entries.append(entry)

    expected = {
        "reusable_root": 40,
        "reusable_helpers": 5,
        "active_root": 21,
        "active_helpers": 3,
    }
    actual = {
        "reusable_root": sum(item["kind"] == "root-package" for item in reusable_entries),
        "reusable_helpers": sum(item["kind"] == "integration-helper" for item in reusable_entries),
        "active_root": sum(item["kind"] == "root-package" for item in active_entries),
        "active_helpers": sum(item["kind"] == "integration-helper" for item in active_entries),
    }
    if actual != expected:
        fail(f"package counts changed: expected {expected}, got {actual}")
    return {
        "schema_version": SCHEMA_VERSION,
        "generated_by": "scripts/generate_package_snapshot_manifest.py",
        "documentation_vault_revision": docs_revision,
        "counts": actual,
        "reusable_packages": reusable_entries,
        "active_packages": active_entries,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true", help="write the generated manifest")
    mode.add_argument("--check", action="store_true", help="compare the generated manifest with the file")
    repository_root = Path(__file__).resolve().parents[1]
    default_docs = Path(os.environ.get("ZENFLOW_DOCUMENTATION_VAULT_ROOT", repository_root.parent / "documentation-vault"))
    parser.add_argument("--output", default=repository_root / "PackagesForReuse/PACKAGE_SNAPSHOT_MANIFEST.json")
    parser.add_argument("--reusable-root", default=repository_root / "PackagesForReuse")
    parser.add_argument("--active-root", default=repository_root / "PackagesInUse")
    parser.add_argument("--documentation-vault-root", default=default_docs)
    args = parser.parse_args()
    output_path = Path(args.output).resolve()
    generated = build_manifest(args)
    encoded = (json.dumps(generated, indent=2, ensure_ascii=False, sort_keys=False) + "\n").encode("utf-8")
    if args.check:
        if not output_path.is_file():
            fail(f"manifest is missing: {output_path}")
        if output_path.read_bytes() != encoded:
            fail(f"manifest is stale: {output_path}; run with --write")
        print(f"package snapshot manifest check passed: {output_path}")
        return 0
    output_path.write_bytes(encoded)
    print(f"package snapshot manifest written: {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
