// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppAnalyticsNetworkingIntegration",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppAnalyticsNetworkingIntegration", targets: ["AppAnalyticsNetworkingIntegration"])
    ],
    dependencies: [
        .package(path: "../../AppAnalytics"),
        .package(path: "../../AppNetworking")
    ],
    targets: [
        .target(
            name: "AppAnalyticsNetworkingIntegration",
            dependencies: [
                .product(name: "AppAnalytics", package: "AppAnalytics"),
                .product(name: "AppNetworking", package: "AppNetworking")
            ]
        ),
        .testTarget(
            name: "AppAnalyticsNetworkingIntegrationTests",
            dependencies: ["AppAnalyticsNetworkingIntegration"]
        )
    ]
)
