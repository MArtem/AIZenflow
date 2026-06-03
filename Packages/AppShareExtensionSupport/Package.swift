// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

let package = Package(
    name: "AppShareExtensionSupport",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppShareExtensionSupport", targets: ["AppShareExtensionSupport"]),
    ],
    targets: [
        .target(
            name: "AppShareExtensionSupport",
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppShareExtensionSupportTests",
            dependencies: [
                "AppShareExtensionSupport",
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
