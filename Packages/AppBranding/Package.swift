// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

let package = Package(
    name: "AppBranding",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppBranding", targets: ["AppBranding"]),
    ],
    targets: [
        .target(
            name: "AppBranding",
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppBrandingTests",
            dependencies: [
                "AppBranding",
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
