// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

let package = Package(
    name: "AppOnDeviceAI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppOnDeviceAI", targets: ["AppOnDeviceAI"]),
    ],
    targets: [
        .target(
            name: "AppOnDeviceAI",
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppOnDeviceAITests",
            dependencies: [
                "AppOnDeviceAI",
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
