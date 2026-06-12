// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppDeviceInfo",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AppDeviceInfo",
            targets: ["AppDeviceInfo"]
        )
    ],
    targets: [
        .target(
            name: "AppDeviceInfo"
        ),
        .testTarget(
            name: "AppDeviceInfoTests",
            dependencies: ["AppDeviceInfo"]
        )
    ]
)
