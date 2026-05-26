// swift-tools-version: 5.9
// Defines reusable infrastructure modules for networking, database, and navigation.
import PackageDescription

/// Shared strict-concurrency configuration applied across package targets.
private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

/// Root package manifest describing infrastructure products and targets.
let package = Package(
    name: "TchopInfrastructure",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TchopNetworking",
            targets: ["TchopNetworking"]
        ),
        .library(
            name: "TchopDatabaseCore",
            targets: ["TchopDatabaseCore"]
        ),
        .library(
            name: "TchopSwiftDataDatabase",
            targets: ["TchopSwiftDataDatabase"]
        ),
        .library(
            name: "TchopCoreDataDatabase",
            targets: ["TchopCoreDataDatabase"]
        ),
        .library(
            name: "TchopDatabaseComposition",
            targets: ["TchopDatabaseComposition"]
        ),
        .library(
            name: "TchopNavigation",
            targets: ["TchopNavigation"]
        ),
        .library(
            name: "TchopDatabase",
            targets: ["TchopDatabase"]
        ),
        .library(
            name: "SyncCore",
            targets: ["SyncCore"]
        ),
        .library(
            name: "TchopLocalization",
            targets: ["TchopLocalization"]
        ),
        .library(
            name: "TchopBranding",
            targets: ["TchopBranding"]
        ),
        .library(
            name: "TchopUIConfiguration",
            targets: ["TchopUIConfiguration"]
        ),
        .library(
            name: "TchopCache",
            targets: ["TchopCache"]
        ),
        .library(
            name: "TchopWidgets",
            targets: ["TchopWidgets"]
        ),
        .library(
            name: "TchopPushNotifications",
            targets: ["TchopPushNotifications"]
        ),
        .library(
            name: "TchopAnalytics",
            targets: ["TchopAnalytics"]
        ),
        .library(
            name: "TchopAppleAuthentication",
            targets: ["TchopAppleAuthentication"]
        ),
        .library(
            name: "TchopErrors",
            targets: ["TchopErrors"]
        ),
        .library(
            name: "TchopOnDeviceAI",
            targets: ["TchopOnDeviceAI"]
        ),
        .library(
            name: "TchopShareSupport",
            targets: ["TchopShareSupport"]
        )
    ],
    targets: [
        .target(
            name: "TchopNetworking",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopDatabaseCore",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopSwiftDataDatabase",
            dependencies: ["TchopDatabaseCore"],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopCoreDataDatabase",
            dependencies: ["TchopDatabaseCore"],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopDatabaseComposition",
            dependencies: [
                "TchopDatabaseCore",
                "TchopSwiftDataDatabase",
                "TchopCoreDataDatabase"
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopNavigation",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopDatabase",
            dependencies: [
                "TchopDatabaseCore",
                "TchopSwiftDataDatabase",
                "TchopCoreDataDatabase",
                "TchopDatabaseComposition",
                "TchopNavigation",
                "SyncCore"
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "SyncCore",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopLocalization",
            resources: [
                .process("Resources")
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopBranding",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopUIConfiguration",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopCache",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopWidgets",
            dependencies: ["TchopLocalization"],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopPushNotifications",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopAppleAuthentication",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopErrors",
            dependencies: ["TchopNetworking"],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopOnDeviceAI",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopShareSupport",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "TchopAnalytics",
            dependencies: [
                "TchopNavigation",
                "TchopNetworking",
                "TchopPushNotifications"
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "SyncCoreTests",
            dependencies: ["SyncCore"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopNetworkingTests",
            dependencies: ["TchopNetworking"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopDatabaseTests",
            dependencies: ["TchopDatabase"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopLocalizationTests",
            dependencies: ["TchopLocalization"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopBrandingTests",
            dependencies: ["TchopBranding"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopUIConfigurationTests",
            dependencies: ["TchopUIConfiguration"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopCacheTests",
            dependencies: ["TchopCache"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopWidgetsTests",
            dependencies: ["TchopWidgets"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopPushNotificationsTests",
            dependencies: ["TchopPushNotifications"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopAnalyticsTests",
            dependencies: ["TchopAnalytics"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopErrorsTests",
            dependencies: ["TchopErrors"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopOnDeviceAITests",
            dependencies: ["TchopOnDeviceAI"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopShareSupportTests",
            dependencies: ["TchopShareSupport"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopAppleAuthenticationTests",
            dependencies: ["TchopAppleAuthentication"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "TchopNavigationTests",
            dependencies: ["TchopNavigation"],
            swiftSettings: strictConcurrencySettings
        )
    ]
)
