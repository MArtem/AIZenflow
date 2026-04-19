// swift-tools-version: 5.9
// Defines reusable infrastructure modules for networking, database, and navigation.
import PackageDescription

/// Root package manifest describing infrastructure products and targets.
let package = Package(
    name: "TchopInfrastructure",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
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
        )
    ],
    targets: [
        .target(
            name: "TchopNetworking"
        ),
        .target(
            name: "TchopDatabaseCore"
        ),
        .target(
            name: "TchopSwiftDataDatabase",
            dependencies: ["TchopDatabaseCore"]
        ),
        .target(
            name: "TchopCoreDataDatabase",
            dependencies: ["TchopDatabaseCore"]
        ),
        .target(
            name: "TchopDatabaseComposition",
            dependencies: [
                "TchopDatabaseCore",
                "TchopSwiftDataDatabase",
                "TchopCoreDataDatabase"
            ]
        ),
        .target(
            name: "TchopNavigation"
        ),
        .target(
            name: "TchopDatabase",
            dependencies: [
                "TchopDatabaseCore",
                "TchopSwiftDataDatabase",
                "TchopCoreDataDatabase",
                "TchopDatabaseComposition",
                "TchopNavigation"
            ]
        ),
        .target(
            name: "TchopLocalization",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "TchopBranding"
        ),
        .target(
            name: "TchopUIConfiguration"
        ),
        .target(
            name: "TchopCache"
        ),
        .target(
            name: "TchopWidgets"
        ),
        .target(
            name: "TchopPushNotifications"
        ),
        .testTarget(
            name: "TchopNetworkingTests",
            dependencies: ["TchopNetworking"]
        ),
        .testTarget(
            name: "TchopDatabaseTests",
            dependencies: ["TchopDatabase"]
        ),
        .testTarget(
            name: "TchopLocalizationTests",
            dependencies: ["TchopLocalization"]
        ),
        .testTarget(
            name: "TchopBrandingTests",
            dependencies: ["TchopBranding"]
        ),
        .testTarget(
            name: "TchopUIConfigurationTests",
            dependencies: ["TchopUIConfiguration"]
        ),
        .testTarget(
            name: "TchopCacheTests",
            dependencies: ["TchopCache"]
        ),
        .testTarget(
            name: "TchopWidgetsTests",
            dependencies: ["TchopWidgets"]
        ),
        .testTarget(
            name: "TchopPushNotificationsTests",
            dependencies: ["TchopPushNotifications"]
        )
    ]
)
