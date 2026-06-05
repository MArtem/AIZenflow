// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppLocalization",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppLocalization", targets: ["AppLocalization"]),
    ],
    targets: [
        .target(
            name: "AppLocalization",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "AppLocalizationTests",
            dependencies: [
                "AppLocalization",
            ]
        ),
    ]
)
