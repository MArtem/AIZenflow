// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

let package = Package(
    name: "AppAnalytics",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppAnalyticsCore", targets: ["AppAnalyticsCore"]),
        .library(name: "AppNavigationAnalytics", targets: ["AppNavigationAnalytics"]),
        .library(name: "AppNetworkingAnalytics", targets: ["AppNetworkingAnalytics"]),
        .library(name: "AppPushNotificationAnalytics", targets: ["AppPushNotificationAnalytics"]),
        .library(name: "AppAnalytics", targets: ["AppAnalytics"]),
    ],
    dependencies: [
        .package(path: "../AppNavigation"),
        .package(path: "../AppNetworking"),
        .package(path: "../AppPushNotifications"),
    ],
    targets: [
        .target(
            name: "AppAnalyticsCore",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "AppNavigationAnalytics",
            dependencies: [
                "AppAnalyticsCore",
                .product(name: "AppNavigation", package: "AppNavigation"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "AppNetworkingAnalytics",
            dependencies: [
                "AppAnalyticsCore",
                .product(name: "AppNetworking", package: "AppNetworking"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "AppPushNotificationAnalytics",
            dependencies: [
                "AppAnalyticsCore",
                .product(name: "AppPushNotifications", package: "AppPushNotifications"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "AppAnalytics",
            dependencies: [
                "AppAnalyticsCore",
                "AppNavigationAnalytics",
                "AppNetworkingAnalytics",
                "AppPushNotificationAnalytics",
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppAnalyticsTests",
            dependencies: [
                "AppAnalytics",
                .product(name: "AppNavigation", package: "AppNavigation"),
                .product(name: "AppNetworking", package: "AppNetworking"),
                .product(name: "AppPushNotifications", package: "AppPushNotifications"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
