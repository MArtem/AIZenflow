// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

let package = Package(
    name: "AppWidgetSupport",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppWidgetSupport", targets: ["AppWidgetSupport"]),
    ],
    targets: [
        .target(
            name: "AppWidgetSupport",
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppWidgetSupportTests",
            dependencies: [
                "AppWidgetSupport",
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
