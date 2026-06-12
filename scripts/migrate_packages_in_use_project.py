#!/usr/bin/env python3
"""Migrate TchopApp.xcodeproj from local SwiftPM package products to PackagesInUse source files.

The script edits project.pbxproj text directly because the installed xcodeproj gem does not
support this project object version. It intentionally targets only real PBX build phase objects
by ID and isa, avoiding accidental matches in PBXNativeTarget blocks.
"""
from __future__ import annotations

import hashlib
import re
from pathlib import Path

PROJECT_PATH = Path("TchopApp.xcodeproj/project.pbxproj")
ROOT = Path("PackagesInUse")

SOURCE_PHASES = {
    "app": [
        "A000000D0000000000000001",
        "B00000070000000000000001",
    ],
    "widget": [
        "D000001A0000000000000001",
        "D000002D0000000000000001",
    ],
    "share": [
        "L00000330000000000000001",
        "L00000360000000000000001",
    ],
}

RESOURCE_PHASES = [
    "A000000F0000000000000001",
    "B00000060000000000000001",
    "D000001B0000000000000001",
    "D000002E0000000000000001",
    "L00000350000000000000001",
    "L00000380000000000000001",
]

APP_PACKAGES = {
    "AppAnalytics",
    "AppAppleAuthentication",
    "AppBranding",
    "AppConfiguration",
    "AppDatabase",
    "AppEnvironment",
    "AppErrors",
    "AppGlassUI",
    "AppLifecycle",
    "AppLocalization",
    "AppNavigation",
    "AppNetworking",
    "AppOnDeviceAI",
    "AppPermissions",
    "AppPushNotifications",
    "AppShareExtensionSupport",
    "AppWidgetSupport",
    "TchopProductLocalizationResources",
}
APP_HELPERS = {
    "AppAnalyticsNetworkingIntegration",
    "AppAnalyticsPushNotificationsIntegration",
    "AppAnalyticsNavigationIntegration",
}
WIDGET_PACKAGES = {
    "AppWidgetSupport",
    "TchopProductLocalizationResources",
}
SHARE_PACKAGES = {
    "AppBranding",
    "AppLocalization",
    "AppOnDeviceAI",
    "AppShareExtensionSupport",
    "TchopProductLocalizationResources",
}

PRODUCT_NAMES = {
    "AppNetworking",
    "AppDatabase",
    "AppEnvironment",
    "AppLifecycle",
    "AppLocalization",
    "TchopProductLocalizationResources",
    "AppBranding",
    "AppGlassUI",
    "AppWidgetSupport",
    "AppShareExtensionSupport",
    "AppConfiguration",
    "AppPushNotifications",
    "AppNavigation",
    "AppAnalytics",
    "AppAnalyticsNetworkingIntegration",
    "AppAnalyticsPushNotificationsIntegration",
    "AppAnalyticsNavigationIntegration",
    "AppAppleAuthentication",
    "AppErrors",
    "AppOnDeviceAI",
    "AppPermissions",
}


def pbx_id(prefix: str, value: str) -> str:
    digest = hashlib.sha1(value.encode("utf-8")).hexdigest().upper()
    return (prefix + digest)[:24]


def section_bounds(text: str, section: str) -> tuple[int, int]:
    begin = text.index(f"/* Begin {section} section */")
    end = text.index(f"/* End {section} section */", begin)
    return begin, end


def insert_before_section_end(text: str, section: str, entries: list[str]) -> str:
    if not entries:
        return text
    begin, end = section_bounds(text, section)
    insertion = "".join(entries)
    return text[:end] + insertion + text[end:]


def strip_spm_framework_entries(text: str) -> str:
    # Remove PBXBuildFile rows that link SwiftPM products into Frameworks.
    pattern = re.compile(
        r"\n\t\t[A-Z0-9]+ /\* (" + "|".join(re.escape(n) for n in sorted(PRODUCT_NAMES, key=len, reverse=True)) +
        r") in Frameworks \*/ = \{isa = PBXBuildFile; productRef = [A-Z0-9]+ /\* \1 \*/; \};"
    )
    text = pattern.sub("", text)

    # Remove entries inside PBXFrameworksBuildPhase file arrays for those products.
    text = re.sub(
        r"\n\t\t\t\t[A-Z0-9]+ /\* (" + "|".join(re.escape(n) for n in sorted(PRODUCT_NAMES, key=len, reverse=True)) +
        r") in Frameworks \*/,",
        "",
        text,
    )
    return text


def strip_spm_dependency_blocks(text: str) -> str:
    # Remove product dependency object blocks.
    text = re.sub(
        r"\n\t\t[A-Z0-9]+ /\* (" + "|".join(re.escape(n) for n in sorted(PRODUCT_NAMES, key=len, reverse=True)) +
        r") \*/ = \{\n\t\t\tisa = XCSwiftPackageProductDependency;\n\t\t\tpackage = [^;]+;\n\t\t\tproductName = \1;\n\t\t\};",
        "",
        text,
    )

    # Remove local package reference object blocks and their project references.
    text = re.sub(
        r'\n\t\t[A-Z0-9]+ /\* XCLocalSwiftPackageReference "Packages(?:/IntegrationHelpers)?/[^"]+" \*/ = \{\n\t\t\tisa = XCLocalSwiftPackageReference;\n\t\t\trelativePath = Packages(?:/IntegrationHelpers)?/[^;]+;\n\t\t\};',
        "",
        text,
    )
    text = re.sub(
        r'\n\t\t\t\t[A-Z0-9]+ /\* XCLocalSwiftPackageReference "Packages(?:/IntegrationHelpers)?/[^"]+" \*/,',
        "",
        text,
    )

    # Remove packageProductDependencies entries from native targets.
    text = re.sub(
        r"\n\t\t\t\t[A-Z0-9]+ /\* (" + "|".join(re.escape(n) for n in sorted(PRODUCT_NAMES, key=len, reverse=True)) + r") \*/,",
        "",
        text,
    )
    return text


def actual_phase_pattern(phase_id: str, isa: str) -> re.Pattern[str]:
    return re.compile(
        rf"(\n\t\t{re.escape(phase_id)} /\* [^*]+ \*/ = \{{\n\t\t\tisa = {isa};\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = \(\n)(?P<files>.*?)(\t\t\t\);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t\}};)",
        re.S,
    )


def add_to_phase(text: str, phase_id: str, isa: str, build_ids: list[tuple[str, str]]) -> str:
    pat = actual_phase_pattern(phase_id, isa)
    match = pat.search(text)
    if not match:
        raise RuntimeError(f"Phase {phase_id} with isa {isa} not found")
    existing = match.group("files")
    new_lines = []
    for build_id, comment in build_ids:
        token = f"{build_id} /* {comment} */"
        if token not in existing:
            new_lines.append(f"\t\t\t\t{token},\n")
    if not new_lines:
        return text
    replacement = match.group(1) + existing + "".join(new_lines) + match.group(3)
    return text[:match.start()] + replacement + text[match.end():]


def package_name_for_source(path: Path) -> str:
    parts = path.parts
    if parts[0] != "PackagesInUse":
        raise ValueError(path)
    if parts[1] == "IntegrationHelpers":
        return parts[2]
    return parts[1]


def source_files_for(kind: str) -> list[Path]:
    all_sources = sorted(ROOT.glob("**/Sources/**/*.swift"))
    selected: list[Path] = []
    for path in all_sources:
        package = package_name_for_source(path)
        if kind == "app" and (package in APP_PACKAGES or package in APP_HELPERS):
            selected.append(path)
        elif kind == "widget" and package in WIDGET_PACKAGES:
            selected.append(path)
        elif kind == "share" and package in SHARE_PACKAGES:
            selected.append(path)
    return selected


def file_ref_entry(file_id: str, path: Path, file_type: str, name: str | None = None) -> str:
    name_part = f"name = {name}; " if name else ""
    return (
        f"\t\t{file_id} /* {path.name} */ = "
        f"{{isa = PBXFileReference; lastKnownFileType = {file_type}; {name_part}path = {path.as_posix()}; sourceTree = \"<group>\"; }};\n"
    )


def build_file_entry(build_id: str, file_id: str, comment: str) -> str:
    return f"\t\t{build_id} /* {comment} */ = {{isa = PBXBuildFile; fileRef = {file_id} /* {comment.split(' in ')[0]} */; }};\n"


def main() -> None:
    text = PROJECT_PATH.read_text()
    text = strip_spm_framework_entries(text)
    text = strip_spm_dependency_blocks(text)

    source_sets = {kind: source_files_for(kind) for kind in SOURCE_PHASES}
    all_source_files = sorted(set().union(*source_sets.values()))
    resource_dirs = sorted((ROOT / "TchopProductLocalizationResources" / "Sources" / "TchopProductLocalizationResources" / "Resources").glob("*.lproj"))

    file_ref_entries: list[str] = []
    build_entries: list[str] = []
    source_build_by_path: dict[Path, tuple[str, str]] = {}

    for path in all_source_files:
        rel = path.as_posix()
        file_id = pbx_id("F1", rel)
        build_id = pbx_id("B1", rel)
        comment = f"{path.name} in Sources"
        source_build_by_path[path] = (build_id, comment)
        if file_id not in text:
            file_ref_entries.append(file_ref_entry(file_id, path, "sourcecode.swift"))
        if build_id not in text:
            build_entries.append(build_file_entry(build_id, file_id, comment))

    resource_builds: list[tuple[str, str]] = []
    for path in resource_dirs:
        rel = path.as_posix()
        file_id = pbx_id("F2", rel)
        build_id = pbx_id("B2", rel)
        comment = f"{path.name} in Resources"
        resource_builds.append((build_id, comment))
        if file_id not in text:
            file_ref_entries.append(file_ref_entry(file_id, path, "folder", name=path.name))
        if build_id not in text:
            build_entries.append(build_file_entry(build_id, file_id, comment))

    text = insert_before_section_end(text, "PBXFileReference", file_ref_entries)
    text = insert_before_section_end(text, "PBXBuildFile", build_entries)

    for kind, phases in SOURCE_PHASES.items():
        build_ids = [source_build_by_path[path] for path in source_sets[kind]]
        for phase in phases:
            text = add_to_phase(text, phase, "PBXSourcesBuildPhase", build_ids)

    for phase in RESOURCE_PHASES:
        text = add_to_phase(text, phase, "PBXResourcesBuildPhase", resource_builds)

    # Local product resources now include German as well.
    text = text.replace(
        "\t\t\tknownRegions = (\n\t\t\t\ten,\n\t\t\t\tru,\n\t\t\t\tBase,\n\t\t\t);",
        "\t\t\tknownRegions = (\n\t\t\t\ten,\n\t\t\t\tru,\n\t\t\t\tde,\n\t\t\t\tBase,\n\t\t\t);",
    )

    PROJECT_PATH.write_text(text)
    print(f"Added {len(all_source_files)} source files and {len(resource_dirs)} localized resource folders from PackagesInUse.")


if __name__ == "__main__":
    main()
