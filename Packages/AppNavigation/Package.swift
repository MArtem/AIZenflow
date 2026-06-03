// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

let package = Package(
    name: "AppNavigation",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppNavigation", targets: ["AppNavigation"]),
    ],
    targets: [
        .target(
            name: "AppNavigation",
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppNavigationTests",
            dependencies: [
                "AppNavigation",
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
