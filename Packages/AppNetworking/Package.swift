// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

let package = Package(
    name: "AppNetworking",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppNetworking", targets: ["AppNetworking"]),
    ],
    targets: [
        .target(
            name: "AppNetworking",
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppNetworkingTests",
            dependencies: [
                "AppNetworking",
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
