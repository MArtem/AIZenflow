// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AppLogging",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "AppLogging", targets: ["AppLogging"])
    ],
    targets: [
        .target(
            name: "AppLogging",
            path: "Sources/AppLogging"
        ),
        .testTarget(
            name: "AppLoggingTests",
            dependencies: ["AppLogging"],
            path: "Tests/AppLoggingTests"
        )
    ]
)
