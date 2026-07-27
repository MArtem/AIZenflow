// swift-tools-version: 5.9
import PackageDescription

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
            name: "AppShareExtensionSupport"
        ),
        .testTarget(
            name: "AppShareExtensionSupportTests",
            dependencies: [
                "AppShareExtensionSupport",
            ]
        ),
    ]
)
