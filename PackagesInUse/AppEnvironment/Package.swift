// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppEnvironment",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "AppEnvironment", targets: ["AppEnvironment"])
    ],
    targets: [
        .target(name: "AppEnvironment"),
        .testTarget(name: "AppEnvironmentTests", dependencies: ["AppEnvironment"])
    ]
)
