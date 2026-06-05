// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppSync",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppSyncCore", targets: ["AppSyncCore"]),
        .library(name: "AppSyncObservation", targets: ["AppSyncObservation"]),
    ],
    targets: [
        .target(
            name: "AppSyncCore"
        ),
        .target(
            name: "AppSyncObservation",
            dependencies: [
                "AppSyncCore",
            ]
        ),
        .testTarget(
            name: "AppSyncTests",
            dependencies: [
                "AppSyncCore",
                "AppSyncObservation",
            ]
        ),
    ]
)
