// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppBackgroundTasks",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AppBackgroundTasks",
            targets: ["AppBackgroundTasks"]
        )
    ],
    targets: [
        .target(
            name: "AppBackgroundTasks"
        ),
        .testTarget(
            name: "AppBackgroundTasksTests",
            dependencies: ["AppBackgroundTasks"]
        )
    ]
)
