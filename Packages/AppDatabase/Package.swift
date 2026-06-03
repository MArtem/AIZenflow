// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

let package = Package(
    name: "AppDatabase",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppDatabaseCore", targets: ["AppDatabaseCore"]),
        .library(name: "AppSwiftDataDatabase", targets: ["AppSwiftDataDatabase"]),
        .library(name: "AppCoreDataDatabase", targets: ["AppCoreDataDatabase"]),
        .library(name: "AppDatabaseComposition", targets: ["AppDatabaseComposition"]),
        .library(name: "AppDatabase", targets: ["AppDatabase"]),
    ],
    targets: [
        .target(
            name: "AppDatabaseCore",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "AppSwiftDataDatabase",
            dependencies: [
                "AppDatabaseCore",
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "AppCoreDataDatabase",
            dependencies: [
                "AppDatabaseCore",
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "AppDatabaseComposition",
            dependencies: [
                "AppDatabaseCore",
                "AppSwiftDataDatabase",
                "AppCoreDataDatabase",
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "AppDatabase",
            dependencies: [
                "AppDatabaseCore",
                "AppSwiftDataDatabase",
                "AppCoreDataDatabase",
                "AppDatabaseComposition",
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppDatabaseTests",
            dependencies: [
                "AppDatabase",
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
