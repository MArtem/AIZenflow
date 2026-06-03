// swift-tools-version: 5.9
import PackageDescription

private let strictConcurrencySettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"])
]

let package = Package(
    name: "AppErrors",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppErrorsCore", targets: ["AppErrorsCore"]),
        .library(name: "AppNetworkingErrorAdapter", targets: ["AppNetworkingErrorAdapter"]),
        .library(name: "AppErrors", targets: ["AppErrors"]),
    ],
    dependencies: [
        .package(path: "../AppNetworking"),
    ],
    targets: [
        .target(
            name: "AppErrorsCore",
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "AppNetworkingErrorAdapter",
            dependencies: [
                "AppErrorsCore",
                .product(name: "AppNetworking", package: "AppNetworking"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "AppErrors",
            dependencies: [
                "AppErrorsCore",
                "AppNetworkingErrorAdapter",
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AppErrorsTests",
            dependencies: [
                "AppErrors",
                .product(name: "AppNetworking", package: "AppNetworking"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)
