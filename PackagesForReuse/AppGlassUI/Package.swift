// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppGlassUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppGlassUI", targets: ["AppGlassUI"]),
    ],
    targets: [
        .target(name: "AppGlassUI"),
        .testTarget(
            name: "AppGlassUITests",
            dependencies: ["AppGlassUI"]
        ),
    ]
)
