// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppRemoteAssets",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AppRemoteAssets",
            targets: ["AppRemoteAssets"]
        )
    ],
    targets: [
        .target(
            name: "AppRemoteAssets"
        ),
        .testTarget(
            name: "AppRemoteAssetsTests",
            dependencies: ["AppRemoteAssets"]
        )
    ]
)
