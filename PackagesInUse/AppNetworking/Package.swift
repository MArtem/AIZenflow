// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppNetworking",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppNetworking", targets: ["AppNetworking"]),
    ],
    targets: [
        .target(
            name: "AppNetworking"
        ),
        .testTarget(
            name: "AppNetworkingTests",
            dependencies: [
                "AppNetworking",
            ]
        ),
    ]
)
