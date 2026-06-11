// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppErrors",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppErrorsCore", targets: ["AppErrorsCore"]),
        .library(name: "AppErrors", targets: ["AppErrors"]),
    ],
    targets: [
        .target(
            name: "AppErrorsCore"
        ),
        .target(
            name: "AppErrors",
            dependencies: [
                "AppErrorsCore",
            ]
        ),
        .testTarget(
            name: "AppErrorsTests",
            dependencies: [
                "AppErrors",
            ]
        ),
    ]
)
