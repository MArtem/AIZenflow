// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TchopProductLocalizationResourcesAppLocalizationIntegration",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "TchopProductLocalizationResourcesAppLocalizationIntegration", targets: ["TchopProductLocalizationResourcesAppLocalizationIntegration"])
    ],
    dependencies: [
        .package(path: "../../AppLocalization"),
        .package(path: "../../TchopProductLocalizationResources")
    ],
    targets: [
        .target(
            name: "TchopProductLocalizationResourcesAppLocalizationIntegration",
            dependencies: [
                .product(name: "AppLocalization", package: "AppLocalization"),
                .product(name: "TchopProductLocalizationResources", package: "TchopProductLocalizationResources")
            ]
        ),
        .testTarget(
            name: "TchopProductLocalizationResourcesAppLocalizationIntegrationTests",
            dependencies: ["TchopProductLocalizationResourcesAppLocalizationIntegration"]
        )
    ]
)
