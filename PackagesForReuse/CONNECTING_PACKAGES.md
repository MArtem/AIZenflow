# Connecting Packages From PackagesForReuse

## Local Xcode Project Dependency

Use this when actively developing the package together with the app:

1. Copy or sync the package into the project:

```zsh
rsync -a --delete   --exclude '.build'   --exclude '.swiftpm'   --exclude 'build'   ./PackagesForReuse/<PackageName>/ ./Packages/<PackageName>/
```

2. In Xcode, add a local package dependency pointing to:

```text
Packages/<PackageName>
```

3. Link the needed library product to the app/extension target.

## SwiftPM Manifest Dependency

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

## Git Dependency Later

When a package moves to a dedicated Git/domain SDK repository, replace the local path with a URL and version tag:

```swift
.package(url: "https://github.com/<org>/<PackageOrSDKRepo>.git", from: "1.0.0")
```

## Adoption Rule

Do not connect a package just because it exists. Connect it when at least one of these is true:

- app code already implements the same generic mechanism;
- current product work needs the mechanism now;
- a package is required by another connected package or integration helper;
- it removes duplicated app infrastructure without product-policy leakage.

If none of those are true, leave the package in `./PackagesForReuse` only.
