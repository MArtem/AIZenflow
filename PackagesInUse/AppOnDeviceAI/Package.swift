// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppOnDeviceAI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppOnDeviceAI", targets: ["AppOnDeviceAI"]),
    ],
    targets: [
        .target(
            name: "AppOnDeviceAI"
        ),
        .testTarget(
            name: "AppOnDeviceAITests",
            dependencies: [
                "AppOnDeviceAI",
            ]
        ),
    ]
)
