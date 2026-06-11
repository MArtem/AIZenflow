// swift-tools-version: 5.9
import PackageDescription

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
            name: "AppDatabaseCore"
        ),
        .target(
            name: "AppSwiftDataDatabase",
            dependencies: [
                "AppDatabaseCore",
            ]
        ),
        .target(
            name: "AppCoreDataDatabase",
            dependencies: [
                "AppDatabaseCore",
            ]
        ),
        .target(
            name: "AppDatabaseComposition",
            dependencies: [
                "AppDatabaseCore",
                "AppSwiftDataDatabase",
                "AppCoreDataDatabase",
            ]
        ),
        .target(
            name: "AppDatabase",
            dependencies: [
                "AppDatabaseCore",
                "AppSwiftDataDatabase",
                "AppCoreDataDatabase",
                "AppDatabaseComposition",
            ]
        ),
        .testTarget(
            name: "AppDatabaseTests",
            dependencies: [
                "AppDatabase",
            ]
        ),
    ]
)
