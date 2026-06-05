// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppBranding",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppBranding", targets: ["AppBranding"]),
    ],
    targets: [
        .target(
            name: "AppBranding"
        ),
        .testTarget(
            name: "AppBrandingTests",
            dependencies: [
                "AppBranding",
            ]
        ),
    ]
)
