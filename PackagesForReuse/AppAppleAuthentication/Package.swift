// swift-tools-version: 5.9
import PackageDescription

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
            name: "AppAppleAuthentication"
        ),
        .testTarget(
            name: "AppAppleAuthenticationTests",
            dependencies: [
                "AppAppleAuthentication",
            ]
        ),
    ]
)
