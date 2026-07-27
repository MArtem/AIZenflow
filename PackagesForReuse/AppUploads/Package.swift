// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppUploads",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AppUploads",
            targets: ["AppUploads"]
        )
    ],
    targets: [
        .target(
            name: "AppUploads"
        ),
        .testTarget(
            name: "AppUploadsTests",
            dependencies: ["AppUploads"]
        )
    ]
)
