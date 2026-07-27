// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppWidgetSupport",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppWidgetSupport", targets: ["AppWidgetSupport"]),
    ],
    targets: [
        .target(
            name: "AppWidgetSupport"
        ),
        .testTarget(
            name: "AppWidgetSupportTests",
            dependencies: [
                "AppWidgetSupport",
            ]
        ),
    ]
)
