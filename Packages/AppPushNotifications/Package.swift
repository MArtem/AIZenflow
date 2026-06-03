// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

let package = Package(
    name: "AppPushNotifications",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppPushNotifications", targets: ["AppPushNotifications"]),
    ],
    targets: [
        .target(
            name: "AppPushNotifications",
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppPushNotificationsTests",
            dependencies: [
                "AppPushNotifications",
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
