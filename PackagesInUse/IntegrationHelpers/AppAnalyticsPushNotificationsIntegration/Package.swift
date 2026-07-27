// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppAnalyticsPushNotificationsIntegration",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppAnalyticsPushNotificationsIntegration", targets: ["AppAnalyticsPushNotificationsIntegration"])
    ],
    dependencies: [
        .package(path: "../../AppAnalytics"),
        .package(path: "../../AppPushNotifications")
    ],
    targets: [
        .target(
            name: "AppAnalyticsPushNotificationsIntegration",
            dependencies: [
                .product(name: "AppAnalytics", package: "AppAnalytics"),
                .product(name: "AppPushNotifications", package: "AppPushNotifications")
            ]
        ),
        .testTarget(
            name: "AppAnalyticsPushNotificationsIntegrationTests",
            dependencies: ["AppAnalyticsPushNotificationsIntegration"]
        )
    ]
)
