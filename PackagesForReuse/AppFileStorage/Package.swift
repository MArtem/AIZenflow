// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppFileStorage",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(name: "AppFileStorage", targets: ["AppFileStorage"])
    ],
    targets: [
        .target(name: "AppFileStorage"),
        .testTarget(name: "AppFileStorageTests", dependencies: ["AppFileStorage"])
    ]
)
