// swift-tools-version: 5.9
import PackageDescription

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
            name: "AppPushNotifications"
        ),
        .testTarget(
            name: "AppPushNotificationsTests",
            dependencies: [
                "AppPushNotifications",
            ]
        ),
    ]
)
