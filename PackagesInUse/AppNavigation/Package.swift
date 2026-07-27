// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppNavigation",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppNavigation", targets: ["AppNavigation"]),
    ],
    targets: [
        .target(
            name: "AppNavigation"
        ),
        .testTarget(
            name: "AppNavigationTests",
            dependencies: [
                "AppNavigation",
            ]
        ),
    ]
)
