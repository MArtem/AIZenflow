// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppErrorsNetworkingIntegration",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppErrorsNetworkingIntegration", targets: ["AppErrorsNetworkingIntegration"])
    ],
    dependencies: [
        .package(path: "../../AppErrors"),
        .package(path: "../../AppNetworking")
    ],
    targets: [
        .target(
            name: "AppErrorsNetworkingIntegration",
            dependencies: [
                .product(name: "AppErrors", package: "AppErrors"),
                .product(name: "AppNetworking", package: "AppNetworking")
            ]
        ),
        .testTarget(
            name: "AppErrorsNetworkingIntegrationTests",
            dependencies: ["AppErrorsNetworkingIntegration"]
        )
    ]
)
