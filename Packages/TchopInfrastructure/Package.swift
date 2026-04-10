// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TchopInfrastructure",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TchopNetworking",
            targets: ["TchopNetworking"]
        ),
        .library(
            name: "TchopDatabase",
            targets: ["TchopDatabase"]
        )
    ],
    targets: [
        .target(
            name: "TchopNetworking"
        ),
        .target(
            name: "TchopDatabase"
        ),
        .testTarget(
            name: "TchopNetworkingTests",
            dependencies: ["TchopNetworking"]
        ),
        .testTarget(
            name: "TchopDatabaseTests",
            dependencies: ["TchopDatabase"]
        )
    ]
)
