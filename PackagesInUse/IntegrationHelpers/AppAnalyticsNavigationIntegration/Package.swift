// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppAnalyticsNavigationIntegration",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppAnalyticsNavigationIntegration", targets: ["AppAnalyticsNavigationIntegration"])
    ],
    dependencies: [
        .package(path: "../../AppAnalytics"),
        .package(path: "../../AppNavigation")
    ],
    targets: [
        .target(
            name: "AppAnalyticsNavigationIntegration",
            dependencies: [
                .product(name: "AppAnalytics", package: "AppAnalytics"),
                .product(name: "AppNavigation", package: "AppNavigation")
            ]
        ),
        .testTarget(
            name: "AppAnalyticsNavigationIntegrationTests",
            dependencies: ["AppAnalyticsNavigationIntegration"]
        )
    ]
)
