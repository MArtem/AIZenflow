// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

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
            name: "AppSyncCore",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "AppSyncObservation",
            dependencies: [
                "AppSyncCore",
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppSyncTests",
            dependencies: [
                "AppSyncCore",
                "AppSyncObservation",
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
