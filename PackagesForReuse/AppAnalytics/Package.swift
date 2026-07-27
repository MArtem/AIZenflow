// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppAnalytics",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppAnalyticsCore", targets: ["AppAnalyticsCore"]),
        .library(name: "AppAnalytics", targets: ["AppAnalytics"]),
    ],
    targets: [
        .target(
            name: "AppAnalyticsCore"
        ),
        .target(
            name: "AppAnalytics",
            dependencies: [
                "AppAnalyticsCore",
            ]
        ),
        .testTarget(
            name: "AppAnalyticsTests",
            dependencies: [
                "AppAnalytics",
            ]
        ),
    ]
)
