// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppCache",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppCache", targets: ["AppCache"]),
    ],
    targets: [
        .target(
            name: "AppCache"
        ),
        .testTarget(
            name: "AppCacheTests",
            dependencies: [
                "AppCache",
            ]
        ),
    ]
)
