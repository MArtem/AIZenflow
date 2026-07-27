// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppRateLimiter",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "AppRateLimiter",
            targets: ["AppRateLimiter"]
        )
    ],
    targets: [
        .target(
            name: "AppRateLimiter"
        ),
        .testTarget(
            name: "AppRateLimiterTests",
            dependencies: ["AppRateLimiter"]
        )
    ]
)
