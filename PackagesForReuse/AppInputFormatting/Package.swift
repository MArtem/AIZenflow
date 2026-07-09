// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppInputFormatting",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AppInputFormatting",
            targets: ["AppInputFormatting"]
        )
    ],
    targets: [
        .target(name: "AppInputFormatting"),
        .testTarget(
            name: "AppInputFormattingTests",
            dependencies: ["AppInputFormatting"]
        )
    ]
)
