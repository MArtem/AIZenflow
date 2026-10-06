// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppValidationCore",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AppValidationCore",
            targets: ["AppValidationCore"]
        )
    ],
    targets: [
        .target(
            name: "AppValidationCore"
        ),
        .testTarget(
            name: "AppValidationCoreTests",
            dependencies: ["AppValidationCore"]
        )
    ]
)
