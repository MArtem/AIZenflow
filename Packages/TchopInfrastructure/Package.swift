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
            name: "TchopCache",
            targets: ["TchopCache"]
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
            name: "TchopDatabase",
            dependencies: [
                "TchopDatabaseCore",
                "TchopSwiftDataDatabase",
                "TchopCoreDataDatabase",
                "TchopDatabaseComposition"
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
            name: "TchopCache"
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
            name: "TchopCacheTests",
            dependencies: ["TchopCache"]
        )
    ]
)
