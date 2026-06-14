// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppDownloads",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AppDownloads",
            targets: ["AppDownloads"]
        )
    ],
    targets: [
        .target(
            name: "AppDownloads"
        ),
        .testTarget(
            name: "AppDownloadsTests",
            dependencies: ["AppDownloads"]
        )
    ]
)
