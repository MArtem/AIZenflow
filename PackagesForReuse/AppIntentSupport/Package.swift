// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppIntentSupport",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "AppIntentSupport",
            targets: ["AppIntentSupport"]
        )
    ],
    targets: [
        .target(
            name: "AppIntentSupport"
        )
    ]
)
