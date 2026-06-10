// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppFeatureFlags",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "AppFeatureFlags", targets: ["AppFeatureFlags"])
    ],
    targets: [
        .target(name: "AppFeatureFlags"),
        .testTarget(name: "AppFeatureFlagsTests", dependencies: ["AppFeatureFlags"])
    ]
)
