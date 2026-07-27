// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppTaskQueue",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AppTaskQueue",
            targets: ["AppTaskQueue"]
        )
    ],
    targets: [
        .target(
            name: "AppTaskQueue"
        ),
        .testTarget(
            name: "AppTaskQueueTests",
            dependencies: ["AppTaskQueue"]
        )
    ]
)
