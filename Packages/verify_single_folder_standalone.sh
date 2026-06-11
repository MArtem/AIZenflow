#!/bin/sh
set -eu

packages_dir="$(cd "$(dirname "$0")" && pwd)"

cleanup_generated_package_state() {
  find "$packages_dir" -name .swiftpm -type d -prune -exec rm -rf {} +
}

cleanup_generated_package_state

python3 - "$packages_dir" <<'PY'
import os
import re
import sys
from pathlib import Path

packages_dir = Path(sys.argv[1])
root_packages = [
    "AppAnalytics",
    "AppAppleAuthentication",
    "AppBranding",
    "AppCache",
    "AppConfiguration",
    "AppDatabase",
    "AppErrors",
    "AppFeatureFlags",
    "AppGlassUI",
    "AppLogging",
    "AppObservability",
    "AppConnectivity",
    "AppLocalization",
    "AppNavigation",
    "AppNetworking",
    "AppOnDeviceAI",
    "AppPushNotifications",
    "AppSecureStorage",
    "AppShareExtensionSupport",
    "AppSync",
    "AppWidgetSupport",
    "TchopProductLocalizationResources",
]
helper_packages = [
    "AppAnalyticsNavigationIntegration",
    "AppAnalyticsNetworkingIntegration",
    "AppAnalyticsPushNotificationsIntegration",
    "AppErrorsNetworkingIntegration",
    "TchopProductLocalizationResourcesAppLocalizationIntegration",
]

failures: list[str] = []
module_owners: dict[str, set[str]] = {}

# Repository/archive hygiene.
for forbidden in ["__MACOSX", ".DS_Store"]:
    for path in packages_dir.rglob(forbidden):
        failures.append(f"Archive hygiene violation: {path.relative_to(packages_dir)}")

# Generated state must not be inside copyable package folders.
for generated in [".build", ".swiftpm", "xcuserdata"]:
    for path in packages_dir.rglob(generated):
        # The repository-level .build lives outside Packages in our scripts. Anything under Packages is wrong.
        failures.append(f"Generated local build state must not be inside Packages/: {path.relative_to(packages_dir)}")

for package in root_packages:
    package_path = packages_dir / package
    if not package_path.is_dir():
        failures.append(f"Missing root package folder: {package}")
        continue

    for required in ["Package.swift", "README.md", "PackageContract.md"]:
        if not (package_path / required).exists():
            failures.append(f"{package} is missing {required}")
    for required_dir in ["Sources", "Tests"]:
        if not (package_path / required_dir).is_dir():
            failures.append(f"{package} is missing {required_dir}/")
    if not (package_path / "Scripts" / "verify_package.sh").exists():
        failures.append(f"{package} is missing Scripts/verify_package.sh")

    has_docc = False
    sources = package_path / "Sources"
    if sources.is_dir():
        has_docc = any(p.is_dir() and p.name.endswith(".docc") for p in sources.rglob("*.docc"))
        for target_dir in sources.iterdir():
            if target_dir.is_dir():
                module_owners.setdefault(target_dir.name, set()).add(package)
    if not has_docc:
        failures.append(f"{package} is missing source DocC documentation (*.docc)")

for package in root_packages:
    package_path = packages_dir / package
    if not package_path.is_dir():
        continue

    manifest = package_path / "Package.swift"
    if manifest.exists():
        text = manifest.read_text(errors="ignore")
        if re.search(r"\.package\s*\(", text):
            failures.append(f"{package} has external or sibling package dependencies; root packages must be dependency-free")
        if "unsafeFlags" in text:
            failures.append(f"{package} contains unsafeFlags in Package.swift")

    for root_name in ["Sources", "Tests"]:
        root = package_path / root_name
        if not root.is_dir():
            continue
        for swift_file in root.rglob("*.swift"):
            text = swift_file.read_text(errors="ignore")
            for match in re.finditer(r"^\s*import\s+([A-Za-z_][A-Za-z0-9_]*)", text, flags=re.MULTILINE):
                module = match.group(1)
                owners = module_owners.get(module, set())
                for owner in owners:
                    if owner != package:
                        rel = swift_file.relative_to(packages_dir)
                        failures.append(f"{package} imports sibling module '{module}' owned by {owner}: {rel}")

# Integration helpers must exist in both copy-file and package forms.
helpers_dir = packages_dir / "IntegrationHelpers"
copy_files_dir = helpers_dir / "CopyFiles"
if not helpers_dir.is_dir():
    failures.append("Missing IntegrationHelpers/ directory")
else:
    if not (helpers_dir / "README.md").exists():
        failures.append("IntegrationHelpers is missing README.md")
    if not (helpers_dir / "INTEGRATION_HELPERS_CATALOG.md").exists():
        failures.append("IntegrationHelpers is missing INTEGRATION_HELPERS_CATALOG.md")
    if not copy_files_dir.is_dir():
        failures.append("IntegrationHelpers is missing CopyFiles/ copy-in helper directory")

    for loose_swift_file in helpers_dir.glob("*.swift"):
        failures.append(f"IntegrationHelpers contains loose Swift file at top level instead of CopyFiles/ or a package: {loose_swift_file.name}")

    for helper in helper_packages:
        helper_path = helpers_dir / helper
        if not helper_path.is_dir():
            failures.append(f"Missing integration helper package: {helper}")
            continue
        for required in ["Package.swift", "README.md", "PackageContract.md"]:
            if not (helper_path / required).exists():
                failures.append(f"Integration helper {helper} is missing {required}")
        if not (helper_path / "Sources" / helper).is_dir():
            failures.append(f"Integration helper {helper} is missing Sources/{helper}/")
        if not (helper_path / "Tests" / f"{helper}Tests").is_dir():
            failures.append(f"Integration helper {helper} is missing Tests/{helper}Tests/")
        if not (helper_path / "Scripts" / "verify_package.sh").exists():
            failures.append(f"Integration helper {helper} is missing Scripts/verify_package.sh")
        has_docc = False
        source_root = helper_path / "Sources"
        if source_root.is_dir():
            has_docc = any(p.is_dir() and p.name.endswith(".docc") for p in source_root.rglob("*.docc"))
        if not has_docc:
            failures.append(f"Integration helper {helper} is missing source DocC documentation (*.docc)")
        copy_file = copy_files_dir / f"{helper}.swift"
        if not copy_file.exists():
            failures.append(f"Integration helper {helper} is missing copy-file form: CopyFiles/{helper}.swift")

# Privacy/telemetry semantic gate for helper packages and copy files.
if helpers_dir.is_dir():
    for swift_file in helpers_dir.rglob("*.swift"):
        text = swift_file.read_text(errors="ignore")
        rel = swift_file.relative_to(packages_dir)
        # Tests may use fixture strings, but source/copy files must be sanitized.
        is_source = "/Sources/" in str(swift_file) or "/CopyFiles/" in str(swift_file)
        forbidden_patterns = [
            (r"String\(describing:\s*error\)", "raw String(describing: error) telemetry"),
            (r'\"title\"\s*:\s*\.string\(', "raw notification title analytics attribute"),
            (r'\"body\"\s*:\s*\.string\(', "raw notification body analytics attribute"),
            (r'\"body_text\"\s*:', "raw body_text analytics attribute"),
            (r'\"headers\"\s*:', "raw headers analytics attribute"),
            (r'\"user_id\"\s*:\s*\.string\(', "raw user id analytics attribute"),
        ]
        if is_source:
            forbidden_patterns.extend([
                (r'\.bodyText\b', "raw HTTP body reference in integration helper"),
                (r'\.headers\b', "raw HTTP headers reference in integration helper"),
                (r'\.absoluteString\b', "raw URL absoluteString reference in integration helper"),
            ])
        for pattern, message in forbidden_patterns:
            if re.search(pattern, text):
                failures.append(f"{message}: {rel}")

if failures:
    print("❌ Single-folder standalone contract violations found:", file=sys.stderr)
    for failure in failures:
        print(f"- {failure}", file=sys.stderr)
    sys.exit(1)

print("✅ Root packages are 100% single-folder standalone by structure and dependency contract.")
print("✅ Every root package has Package.swift, README.md, PackageContract.md, Sources/, Tests/, DocC, and a local verify script.")
print("✅ Integration helpers are outside root packages, available as copy files and testable helper packages, and privacy-gated.")
PY
