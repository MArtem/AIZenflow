// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AppObservability",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "AppObservability", targets: ["AppObservability"])
    ],
    targets: [
        .target(
            name: "AppObservability",
            path: "Sources/AppObservability"
        ),
        .testTarget(
            name: "AppObservabilityTests",
            dependencies: ["AppObservability"],
            path: "Tests/AppObservabilityTests"
        )
    ]
)
