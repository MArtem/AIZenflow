// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AppConnectivity",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "AppConnectivity", targets: ["AppConnectivity"])
    ],
    targets: [
        .target(
            name: "AppConnectivity",
            path: "Sources/AppConnectivity"
        ),
        .testTarget(
            name: "AppConnectivityTests",
            dependencies: ["AppConnectivity"],
            path: "Tests/AppConnectivityTests"
        )
    ]
)
