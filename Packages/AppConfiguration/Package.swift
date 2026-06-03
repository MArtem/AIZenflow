// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

let package = Package(
    name: "AppConfiguration",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppConfiguration", targets: ["AppConfiguration"]),
    ],
    targets: [
        .target(
            name: "AppConfiguration",
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppConfigurationTests",
            dependencies: [
                "AppConfiguration",
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
