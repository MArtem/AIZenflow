// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppConfiguration",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppConfiguration", targets: ["AppConfiguration"]),
    ],
    targets: [
        .target(
            name: "AppConfiguration"
        ),
        .testTarget(
            name: "AppConfigurationTests",
            dependencies: [
                "AppConfiguration",
            ]
        ),
    ]
)
