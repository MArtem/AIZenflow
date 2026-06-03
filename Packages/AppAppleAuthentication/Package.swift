// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

let package = Package(
    name: "AppAppleAuthentication",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppAppleAuthentication", targets: ["AppAppleAuthentication"]),
    ],
    targets: [
        .target(
            name: "AppAppleAuthentication",
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppAppleAuthenticationTests",
            dependencies: [
                "AppAppleAuthentication",
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
