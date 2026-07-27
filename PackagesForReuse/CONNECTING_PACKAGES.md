# Connecting Packages From PackagesForReuse

`./PackagesForReuse` is the full source-only package vault. A package is copied out only when a project has a concrete use for it.

## Mode 1: TchopApp source-only adoption

Use this mode in the current `TchopApp` worktree to avoid SwiftPM `.build` and cloned package growth.

1. Copy the reviewed package into `./PackagesInUse`:

```zsh
rsync -a --delete \
  --exclude '.build' \
  --exclude '.swiftpm' \
  --exclude 'build' \
  --exclude 'DerivedData' \
  --exclude 'xcuserdata' \
  ./PackagesForReuse/<PackageName>/ ./PackagesInUse/<PackageName>/
```

2. If the package has cross-package integration helpers, copy only the helper needed by the app:

```zsh
rsync -a --delete \
  --exclude '.build' \
  --exclude '.swiftpm' \
  ./PackagesForReuse/IntegrationHelpers/<HelperName>/ ./PackagesInUse/IntegrationHelpers/<HelperName>/
```

3. Add only required `Sources/**/*.swift` files and resources to the relevant Xcode runtime targets.

4. In source-only mode, remove package-module imports from app/extension/test source because the package declarations compile into the target module.

5. Replace app-local duplicated mechanics with package APIs only when the package surface fits without decorative wrappers.

6. Verify:

```zsh
plutil -lint ./TchopApp.xcodeproj/project.pbxproj
git diff --check
./scripts/verify.sh low
```

## Mode 2: Local SwiftPM dependency for another project

Use this when disk/build-cache cost is acceptable and the host project wants real SwiftPM module boundaries.

1. Copy the package into the host project:

```zsh
rsync -a --delete \
  --exclude '.build' \
  --exclude '.swiftpm' \
  --exclude 'build' \
  ./PackagesForReuse/<PackageName>/ ./Packages/<PackageName>/
```

2. In Xcode, add a local package dependency pointing to:

```text
Packages/<PackageName>
```

3. Link only the needed library products to the app/extension target.

4. Run the package-local verification script:

```zsh
cd ./Packages/<PackageName>
./Scripts/verify_package.sh
```

## Mode 3: SwiftPM manifest dependency

For a Swift package host project:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HostAppPackage",
    platforms: [.iOS(.v17)],
    dependencies: [
        .package(path: "Packages/<PackageName>")
    ],
    targets: [
        .target(
            name: "HostApp",
            dependencies: [
                .product(name: "<ProductName>", package: "<PackageName>")
            ]
        )
    ]
)
```

## Mode 4: Git dependency later

When a package moves to a dedicated Git/domain SDK repository, replace the local path with a URL and version tag:

```swift
.package(url: "https://github.com/<org>/<PackageOrSDKRepo>.git", from: "1.0.0")
```

## Adoption rule

Do not connect or copy a package just because it exists. Adopt it when at least one is true:

- app code already implements the same generic mechanism;
- current product work needs the mechanism now;
- a package is required by another adopted package or integration helper;
- it removes duplicated app infrastructure without product-policy leakage.

If none of those are true, leave the package in `./PackagesForReuse` only.

## Sandbox rule

All verification/build/cache output for this worktree must stay under `/Users/Artem/.zenflow/worktrees/`. Do not route outputs to `/Users/Artem/Library`, `/tmp`, or other external paths.
