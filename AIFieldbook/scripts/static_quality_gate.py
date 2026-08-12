#!/usr/bin/env python3
"""Deterministic, dependency-free static gate for the AI Fieldbook app."""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
APP = Path("AIFieldbook")
PROJECT = APP / "AIFieldbook.xcodeproj/project.pbxproj"
FORBIDDEN_COMPONENTS = frozenset({".build", ".cache", ".swiftpm", "build", "deriveddata", "dist", "node_modules", "tmp"})
FORBIDDEN_SUFFIXES = (".app", ".dSYM", ".dSYM.zip", ".ipa", ".xcarchive", ".xcresult")
FORBIDDEN_CREDENTIAL_NAMES = frozenset({".env", "googleservice-info.plist"})
FORBIDDEN_CREDENTIAL_SUFFIXES = (".cer", ".key", ".mobileprovision", ".p12", ".p8", ".pem", ".provisionprofile")


def fail(rule: str, path: Path, message: str) -> None:
    print(f"FAIL {rule} {path.as_posix()} — {message}")


def scanned_files() -> list[Path]:
    result = subprocess.run(
        ["git", "-C", str(ROOT), "ls-files", "-z", "--cached", "--others", "--exclude-standard", "--", APP.as_posix()],
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError("git ls-files failed")
    return [Path(value.decode("utf-8")) for value in result.stdout.split(b"\0") if value]


def has_forbidden_path(path: Path) -> bool:
    components = [component.casefold() for component in path.parts]
    return any(
        component in FORBIDDEN_COMPONENTS
        or component.endswith(tuple(suffix.casefold() for suffix in FORBIDDEN_SUFFIXES))
        for component in components
    )


def has_credential_artifact(path: Path) -> bool:
    name = path.name.casefold()
    return name in FORBIDDEN_CREDENTIAL_NAMES or name.endswith(FORBIDDEN_CREDENTIAL_SUFFIXES)


def check_project_contract(files: list[Path]) -> int:
    failures = 0
    if PROJECT not in files:
        fail("QC.XCODE.PROJECT_MISSING", PROJECT, "required Xcode project is not tracked")
        return 1
    project = ROOT / PROJECT
    if project.is_symlink():
        fail("QC.XCODE.PROJECT_SYMLINK", PROJECT, "Xcode project must not be a symlink")
        return 1
    lint = subprocess.run(["plutil", "-lint", str(project)], capture_output=True, text=True, check=False)
    if lint.returncode != 0:
        fail("QC.XCODE.PROJECT_SYNTAX", PROJECT, lint.stderr.strip() or lint.stdout.strip() or "plutil rejected project.pbxproj")
        failures += 1
    return failures


def check_swift_syntax(files: list[Path]) -> int:
    sources = [ROOT / path for path in files if path.suffix == ".swift"]
    if not sources:
        fail("QC.SWIFT.SOURCES_MISSING", APP, "no tracked Swift sources found")
        return 1
    cache = ROOT / ".zenflow-build/static-quality-module-cache"
    cache.mkdir(parents=True, exist_ok=True)
    environment = dict(os.environ, CLANG_MODULE_CACHE_PATH=str(cache))
    result = subprocess.run(
        ["xcrun", "swiftc", "-parse", *map(str, sources)],
        env=environment,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        fail("QC.SWIFT.SYNTAX", APP, result.stderr.strip() or result.stdout.strip() or "swiftc rejected a source file")
        return 1
    return 0


def check_m16_ocr_boundary(files: list[Path]) -> int:
    required = {
        APP / "AIFieldbook/Core/AI/AIFoundation.swift": "maximumTextUTF8Bytes",
        APP / "AIFieldbook/Core/AI/VisionTextRecognitionService.swift": "AIResultOutputLimits.maximumTextUTF8Bytes",
        APP / "AIFieldbook/Core/Persistence/FieldbookRepository.swift": "AIResultOutputLimits.accepts(result.text)",
    }
    failures = 0
    for path, required_fragment in required.items():
        if path not in files or required_fragment not in (ROOT / path).read_text(encoding="utf-8"):
            fail("QC.M16.OCR_OUTPUT_BOUND", path, "OCR output must have producer and persistence bounds")
            failures += 1
    return failures


def main() -> int:
    try:
        files = scanned_files()
    except (OSError, RuntimeError) as error:
        fail("QC.REPOSITORY.UNREADABLE", APP, str(error))
        return 1

    failures = 0
    for path in files:
        absolute = ROOT / path
        if absolute.is_symlink():
            fail("QC.REPOSITORY.SYMLINK", path, "tracked symlinks are not accepted")
            failures += 1
        if has_forbidden_path(path):
            fail("QC.REPOSITORY.GENERATED_ARTIFACT", path, "generated build artifact is tracked")
            failures += 1
        if has_credential_artifact(path):
            fail("QC.SECRET.CREDENTIAL_ARTIFACT", path, "credential artifact must not be tracked")
            failures += 1

    failures += check_project_contract(files)
    failures += check_swift_syntax(files)
    failures += check_m16_ocr_boundary(files)
    if failures == 0:
        print(f"AI Fieldbook static quality gate: {len(files)} visible project files checked, 0 blocking findings")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
