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
            name: "TchopDatabase",
            targets: ["TchopDatabase"]
        ),
        .library(
            name: "TchopLocalization",
            targets: ["TchopLocalization"]
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
            name: "TchopDatabase"
        ),
        .target(
            name: "TchopLocalization",
            resources: [
                .process("Resources")
            ]
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
            name: "TchopCacheTests",
            dependencies: ["TchopCache"]
        )
    ]
)
