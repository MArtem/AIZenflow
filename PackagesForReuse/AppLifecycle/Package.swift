// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppLifecycle",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AppLifecycle",
            targets: ["AppLifecycle"]
        )
    ],
    targets: [
        .target(
            name: "AppLifecycle"
        ),
        .testTarget(
            name: "AppLifecycleTests",
            dependencies: ["AppLifecycle"]
        )
    ]
)
