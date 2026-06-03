// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

let package = Package(
    name: "AppCache",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppCache", targets: ["AppCache"]),
    ],
    targets: [
        .target(
            name: "AppCache",
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppCacheTests",
            dependencies: [
                "AppCache",
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
