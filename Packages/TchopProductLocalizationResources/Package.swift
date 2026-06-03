// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

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
    dependencies: [
        .package(path: "../AppLocalization"),
    ],
    targets: [
        .target(
            name: "TchopProductLocalizationResources",
            dependencies: [
                .product(name: "AppLocalization", package: "AppLocalization"),
            ],
            resources: [.process("Resources")],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopProductLocalizationResourcesTests",
            dependencies: ["TchopProductLocalizationResources"],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
