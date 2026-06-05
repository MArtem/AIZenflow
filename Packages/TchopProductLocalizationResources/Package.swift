// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TchopProductLocalizationResources",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "TchopProductLocalizationResources", targets: ["TchopProductLocalizationResources"]),
    ],
    targets: [
        .target(
            name: "TchopProductLocalizationResources",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "TchopProductLocalizationResourcesTests",
            dependencies: ["TchopProductLocalizationResources"]
        ),
    ]
)
